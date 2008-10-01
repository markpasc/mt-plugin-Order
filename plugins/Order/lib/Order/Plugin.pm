
package Order::Plugin;

sub _natural_sort {
    sort {
        $a->[0] =~ m{ \A [+-]? \d+ }xms && $b->[0] =~ m{ \A [+-]? \d+ }xms
            ?    $a->[0] <=>    $b->[0]
            : lc $a->[0] cmp lc $b->[0]
    } @_;
}

sub _regular_sort {
    sort { lc $a->[0] cmp lc $b->[0] } @_;
}

sub _reverse_sort {
    sort { lc $b->[0] cmp lc $a->[0] } @_;
}

sub sort_function_for_args {
    my ($args) = @_;

    my $descend = !$args->{sort_order}             ? 1
                :  $args->{sort_order} eq 'ascend' ? 0
                :                                    1
                ;

    my $sort;
    if ($args->{natural}) {
        $sort = $descend ? sub { reverse _natural_sort(@_) }
              :            \&_natural_sort
              ;
    }
    elsif ($args->{shuffle}) {
        require List::Util;
        $sort = \&List::Util::shuffle;
    }
    else {
        $sort = $descend ? \&_reverse_sort : \&_regular_sort;
    }

    return $sort;
}

sub _sort_group_ids {
    return $a < 0 && 0 < $b ?  1
         : $b < 0 && 0 < $a ? -1
         : $a < 0           ? $b <=> $a
         :                    $a <=> $b
         ;
}

sub tag_order {
    my ($ctx, $args, $cond) = @_;

    my %groups = ( items => [] );
    local $ctx->{__stash}{order_items}  = \%groups;
    local $ctx->{__stash}{order_by_var} = $args->{by} || 'order_by';
    local $ctx->{__stash}{order_header} = q{};
    local $ctx->{__stash}{order_footer} = q{};

    # Build, but ignore the full build value.
    defined($ctx->slurp($args, $cond))
        or return;

    # Ready the regular group of items.
    my $items = delete $groups{items};
    my $sort = sort_function_for_args($args);
    my @objs = $sort->(@$items);

    # Inject the pinned groups from first place (0) to last (-1).
    for my $i (sort _sort_group_ids keys %groups) {
        my $items = $groups{$i};
        if ($i >= 0) {
            splice @objs, $i, 0, $sort->(@$items);
        }
        elsif ($i < -1) {
            splice @objs, $i + 1, 0, $sort->(@$items);
        }
        else {
            push @objs, $sort->(@$items);
        }
    }

    # Collapse the transform.
    @objs = map { $_->[1] } @objs;

    if (my $limit = ($args->{lastn} || $args->{limit})) {
        if (scalar @objs > $limit) {
            @objs = @objs[0..$limit-1];
        }
    }

    return q{} if !@objs;
    return join q{}, $ctx->stash('order_header'), @objs,
        $ctx->stash('order_footer');
}

sub tag_order_header {
    my ($ctx, $args, $cond) = @_;
    my $output = $ctx->slurp($args, $cond)
        or return;
    $ctx->stash('order_header', $output);
    return q{};
}

sub tag_order_footer {
    my ($ctx, $args, $cond) = @_;
    my $output = $ctx->slurp($args, $cond)
        or return;
    $ctx->stash('order_footer', $output);
    return q{};
}

sub tag_order_item {
    my ($ctx, $args, $cond) = @_;

    my $group_id = defined $args->{pin} ? int $args->{pin} : 'items';

    my $order_var = $ctx->stash('order_by_var');
    local $ctx->{__stash}{vars}{$order_var};
    my $output = $ctx->slurp($args, $cond)
        or return;

    my $order_value = $ctx->var($order_var) || q{};
    $order_value =~ s{ \A \s+ | \s+ \z }{}xmsg;

    my $groups = $ctx->stash('order_items');
    my $group = ($groups->{$group_id} ||= []);
    push @$group, [ $order_value, $output ];
}

1;

