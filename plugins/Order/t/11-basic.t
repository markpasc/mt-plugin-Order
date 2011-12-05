use lib qw( lib extlib plugins/Order/lib );

use strict;
use warnings;

use MT;
use MT::Template::Context;
use MT::Builder;
use MT::App;

use Test::More tests => 5;

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

$t = <<EOF;
<mt:Order>
    asf dasf
    <mt:OrderItem>
        <mt:setvarblock name="order_by">1</mt:setvarblock>
        hello
    </mt:OrderItem>
    foo bar baz
</mt:Order>
EOF
like(build($t), qr{ \A \s* hello \s* \z }xms, "Order ignores content not in items");

$t = <<EOF;
<mt:Order>
    <mt:OrderItem>
        <mt:setvarblock name="order_by">bar</mt:setvarblock>
        hello
    </mt:OrderItem>
    <mt:OrderItem>
        <mt:setvarblock name="order_by">foo</mt:setvarblock>
        goodbye
    </mt:OrderItem>
</mt:Order>
EOF
like(build($t), qr{ \A \s* goodbye \s+ hello \s* \z }xms, "Order puts two items in order");

$t = <<EOF;
<mt:Order>
    <mt:For from="5" to="9">
        <mt:OrderItem>
            <mt:setvarblock name="order_by"><mt:var name="__index__"></mt:setvarblock>
            <mt:var name="__index__">
        </mt:OrderItem>
    </mt:For>
</mt:Order>
EOF
like(build($t), qr{ \A \s* 9 \s+ 8 \s+ 7 \s+ 6 \s+ 5 \s* \z }xms, "Order puts looped items in order");


1;
