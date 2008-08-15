
package Order::Plugin;

sub tag_order {
    my ($ctx, $args, $cond) = @_;

    my @items;
    local $ctx->{__stash}{order_items} = \@items;
    local $ctx->{__stash}{order_by_var} = $args->{by} || 'order_by';

    my ($builder, $tokens) = map { $ctx->stash($_) } qw( builder tokens );
    $builder->build($ctx, $tokens, $args)
        or return $ctx->error($builder->errstr);

    my $order = !$args->{sort_order}             ? 'descend'
              :  $args->{sort_order} eq 'ascend' ? 'ascend'
              :                                    'descend'
              ;

    my @objs = $args->{natural}
        ? sort {
            $a->[0] =~ m{ \A [+-]? \d+ }xms && $b->[0] =~ m{ \A [+-]? \d+ }xms
                ?    $a->[0] <=>    $b->[0]
                : lc $a->[0] cmp lc $b->[0]
          } @items
        : sort { lc $a->[0] cmp lc $b->[0] } @items
        ;
    @objs = map { $_->[1] } @objs;
    @objs = reverse @objs if $order eq 'descend';
    
    if (my $limit = ($args->{lastn} || $args->{limit})) {
        if (scalar @objs > $limit) {
            @objs = @objs[0..$limit-1];
        }
    }
    
    return join q{}, @objs;
}

sub tag_order_item {
    my ($ctx, $args, $cond) = @_;

    my $order_var = $ctx->stash('order_by_var');
    local $ctx->{__stash}{vars}{$order_var};

    my ($builder, $tokens) = map { $ctx->stash($_) } qw( builder tokens );
    my $output = $builder->build($ctx, $tokens, $args)
        or return $ctx->error($builder->errstr);

    my $order_value = $ctx->var($order_var);
    if (defined $order_value) {
        $order_value =~ s{ \A \s+ | \s+ \z }{}xmsg;
    }
    else {
        $order_value = q{};
    }

    push @{ $ctx->{__stash}{order_items} }, [ $order_value, $output ];
}

1;

