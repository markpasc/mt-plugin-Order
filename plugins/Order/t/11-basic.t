use lib qw( lib extlib plugins/Order/lib );

use strict;
use warnings;

use MT;
use MT::Template::Context;
use MT::Builder;
use MT::App;

use Test::More tests => 2;

use Order::Plugin;

my $cms = MT::App->new;


sub build {
    my ($template, $data) = @_;
    my $ctx = MT::Template::Context->new;
    my $b = MT::Builder->new;
    my $tokens = $b->compile($ctx, $template);

    $ctx->{__stash} = $data;
    my $ret = $b->build($ctx, $tokens);
    die $b->errstr if !defined $ret;

    return $ret;
}


is(build(q{<mt:Ignore>derp</mt:Ignore>}), q{}, "templates will build");

my $t = <<EOF;
<mt:Order>
    <mt:OrderItem>
        <mt:setvarblock name="order_by">1</mt:setvarblock>
        hello
    </mt:OrderItem>
</mt:Order>
EOF
like(build($t), qr{ \A \s* hello \s* \z }xms, "Order works at all (one item)");

1;
