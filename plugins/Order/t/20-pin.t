use lib qw( lib extlib plugins/Order/lib );

use strict;
use warnings;

use MT;
use MT::Template::Context;
use MT::Builder;
use MT::App;

use Test::More tests => 4;

use Order::Plugin;

my $cms = MT::App->new;
my $t;


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


$t = <<EOF;
<mt:Order>
    <mt:OrderItem>
        <mt:setvarblock name="order_by">bar</mt:setvarblock>
        bar
    </mt:OrderItem>
    <mt:OrderItem pin="0">
        <mt:setvarblock name="order_by">1234</mt:setvarblock>
        1234
    </mt:OrderItem>
    <mt:OrderItem>
        <mt:setvarblock name="order_by">foo</mt:setvarblock>
        foo
    </mt:OrderItem>
</mt:Order>
EOF
like(build($t), qr{ \A \s* 1234 \s+ foo \s+ bar \s* \z }xms, "Pinning an item to 0 puts it in front");

$t = <<EOF;
<mt:Order>
    <mt:OrderItem>
        <mt:setvarblock name="order_by">bar</mt:setvarblock>
        bar
    </mt:OrderItem>
    <mt:OrderItem pin="1">
        <mt:setvarblock name="order_by">1234</mt:setvarblock>
        1234
    </mt:OrderItem>
    <mt:OrderItem>
        <mt:setvarblock name="order_by">foo</mt:setvarblock>
        foo
    </mt:OrderItem>
</mt:Order>
EOF
like(build($t), qr{ \A \s* foo \s+ 1234 \s+ bar \s* \z }xms, "Pinning an item to 1 puts it second");

$t = <<EOF;
<mt:Order>
    <mt:OrderItem pin="-1">
        <mt:setvarblock name="order_by">bar</mt:setvarblock>
        bar
    </mt:OrderItem>
    <mt:OrderItem>
        <mt:setvarblock name="order_by">1234</mt:setvarblock>
        1234
    </mt:OrderItem>
    <mt:OrderItem>
        <mt:setvarblock name="order_by">foo</mt:setvarblock>
        foo
    </mt:OrderItem>
</mt:Order>
EOF
like(build($t), qr{ \A \s* foo \s+ 1234 \s+ bar \s* \z }xms, "Pinning an item to -1 puts it last");

$t = <<EOF;
<mt:Order>
    <mt:OrderItem pin="0">
        <mt:setvarblock name="order_by">bar</mt:setvarblock>
        bar
    </mt:OrderItem>
    <mt:OrderItem pin="0">
        <mt:setvarblock name="order_by">1234</mt:setvarblock>
        1234
    </mt:OrderItem>
    <mt:OrderItem pin="0">
        <mt:setvarblock name="order_by">foo</mt:setvarblock>
        foo
    </mt:OrderItem>
</mt:Order>
EOF
like(build($t), qr{ \A \s* foo \s+ bar \s+ 1234 \s* \z }xms, "Pinning all the items sorts them normally");


1;
