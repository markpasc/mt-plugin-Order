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
    local $ctx->{__stash}{order_row_header} = q{};
    local $ctx->{__stash}{order_row_footer} = q{};

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
        # TODO: sort and join the group, so it splices as one item, disrupting
        # the next groups less? but then they only count as one item for
        # offsets and limits.
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

    if (my $offset = $args->{offset}) {
        # Delete the first $offset items.
        splice @objs, 0, $offset;
    }

    if (my $limit = ($args->{lastn} || $args->{limit})) {
        if (scalar @objs > $limit) {
            # Keep the first $limit items.
            splice @objs, $limit;
        }
    }

    if ($ctx->stash('order_date_header') || $ctx->stash('order_date_footer')) {
        # loop over items in @objs adding headers and footers where necessary
        my $builder = $ctx->stash('builder');
        my ($yesterday, $tomorrow) = ('00000000')x2;
        my $i = 0;
        for my $o (@objs) {
            my $today    = substr $o->[0], 0, 8;
            my $tomorrow = $today;
            my $footer   = 0;
            if (defined $objs[$i+1]) {
                $tomorrow = substr($objs[$i+1]->[0], 0, 8);
                $footer = $today ne $tomorrow;
            } else {
                $footer++;
            }
            my $header = $today ne $yesterday;
            local $ctx->{current_timestamp} = $o->[0];
            my ($h_html, $f_html) = ('')x2;
            if ($header && $ctx->stash('order_date_header')) {
                my $result = $builder->build($ctx, $ctx->stash('order_date_header'), {});
                return $ctx->error( $builder->errstr ) unless defined $result;
                $h_html = $result;
            }
            if ($footer && $ctx->stash('order_date_footer')) {
                my $result = $builder->build($ctx, $ctx->stash('order_date_footer'), {});
                return $ctx->error( $builder->errstr ) unless defined $result;
                $f_html = $result;
            }
            $objs[$i][1] = $h_html.$o->[1].$f_html;
            $yesterday = $today;
            $i++;
        }
    }

    # Collapse the transform.
    @objs = map { $_->[1] } @objs;

    # Insert the row header and footers
    my $per_row = $args->{'items_per_row'} || 0;
    if ($per_row) {
        my $order_row_header = $ctx->stash('order_row_header') || '';
        my $order_row_footer = $ctx->stash('order_row_footer') || '';
        $in_position = $per_row - 1;
        my $row_count = 0;
        my $total_count = @objs;
        my $insert = $order_row_footer . $order_row_header;
        while ($in_position < $total_count - 1) {
            @objs = array_insert_after_position ( \@objs, $in_position, $insert);
            $in_position += $per_row + 1;
            $total_count += 1;
        }
        unshift(@objs,$order_row_header) if ($order_row_header);
        push(@objs,$order_row_footer) if ($order_row_footer);
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

sub tag_order_date_header {
    my ($ctx, $args, $cond) = @_;
    $ctx->stash('order_date_header', $ctx->stash('tokens'));
    return q{};
}

sub tag_order_date_footer {
    my ($ctx, $args, $cond) = @_;
    $ctx->stash('order_date_footer', $ctx->stash('tokens'));
    return q{};
}

sub tag_order_row_header {
    my ($ctx, $args, $cond) = @_;
    my $output = $ctx->slurp($args, $cond)
        or return;
    $ctx->stash('order_row_header', $output);
    return q{};
}

sub tag_order_row_footer {
    my ($ctx, $args, $cond) = @_;
    my $output = $ctx->slurp($args, $cond)
        or return;
    $ctx->stash('order_row_footer', $output);
    return q{};
}

# insert element into an arbitrary position of an array
sub array_insert_after_position {
    my ($inArray, $inPosition, $inElement) = @_;
    my @res         = ();
    my @after       = ();
    my $arrayLength = int @{$inArray};

    if ($inPosition < 0) { @after = @{$inArray}; }
    else {
        if ($inPosition >= $arrayLength)    { $inPosition = $arrayLength - 1; }
        if ($inPosition < $arrayLength - 1) { @after = @{$inArray}[($inPosition+1)..($arrayLength-1)]; }
    }

    push (@res, @{$inArray}[0..$inPosition], $inElement, @after);

    return @res;
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
    push @$group, [ $order_value, $output];
}

sub _hdlr_order_date {
    my ($ctx, $args) = @_;
    # Order dates are already UTC (or at least shouldn't be messed with after ordering).
    if ($args->{utc}) {
        my $tag = $ctx->stash('tag');
        return $ctx->error(qq{The mt:$tag doesn't support a utc attribute: items were already ordered by these dates, so can't readjust them for UTC after the fact.});
    }
    return $ctx->_hdlr_date($args);
}


1;
