
package Collate::Plugin;

sub tag_collate {
    my ($ctx, $args, $cond) = @_;

    my @items;
    local $ctx->{__stash}{collate_items} = \@items;
    local $ctx->{__stash}{collate_by_var} = $args->{by} || 'collate_by';

    my ($builder, $tokens) = map { $ctx->stash($_) } qw( builder tokens );
    $builder->build($ctx, $tokens, $args)
        or return $ctx->error($builder->errstr);

    return join q{},
        map { $_->[1] }
        sort {
            $a->[0] =~ m{ \A [+-]? \d+ }xms && $b->[0] =~ m{ \A [+-]? \d+ }xms
                ?    $a->[0] <=>    $b->[0]
                : lc $a->[0] cmp lc $b->[0]
        } @items;
}

sub tag_collate_item {
    my ($ctx, $args, $cond) = @_;

    my $collate_var = $ctx->stash('collate_by_var');
    local $ctx->{__stash}{vars}{$collate_var};

    my ($builder, $tokens) = map { $ctx->stash($_) } qw( builder tokens );
    my $output = $builder->build($ctx, $tokens, $args)
        or return $ctx->error($builder->errstr);

    my $collate_value = $ctx->var($collate_var);
    $collate_value = q{} if !defined $collate_value;

    push @{ $ctx->{__stash}{collate_items} }, [ $collate_value, $output ];
}

1;

