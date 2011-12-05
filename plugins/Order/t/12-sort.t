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
like(build($t), qr{ \A \s* foo \s+ bar \s+ 1234 \s* \z }xms, "Default order is descending asciibetical");

$t = <<EOF;
<mt:Order sort_order="ascend">
    <mt:OrderItem>
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
like(build($t), qr{ \A \s* 1234 \s+ bar \s+ foo \s* \z }xms, "Ascending order reverses the default");

$t = <<EOF;
<mt:Order>
    <mt:OrderItem>
        <mt:setvarblock name="order_by">17</mt:setvarblock>
        17
    </mt:OrderItem>
    <mt:OrderItem>
        <mt:setvarblock name="order_by">1</mt:setvarblock>
        1
    </mt:OrderItem>
    <mt:OrderItem>
        <mt:setvarblock name="order_by">quux</mt:setvarblock>
        quux
    </mt:OrderItem>
    <mt:OrderItem>
        <mt:setvarblock name="order_by">1234</mt:setvarblock>
        1234
    </mt:OrderItem>
</mt:Order>
EOF
like(build($t), qr{ \A \s* quux \s+ 17 \s+ 1234 \s+ 1 \s* \z }xms, "Default order for numbers is descending asciibetical");

$t = <<EOF;
<mt:Order natural="1">
    <mt:OrderItem>
        <mt:setvarblock name="order_by">17</mt:setvarblock>
        17
    </mt:OrderItem>
    <mt:OrderItem>
        <mt:setvarblock name="order_by">1</mt:setvarblock>
        1
    </mt:OrderItem>
    <mt:OrderItem>
        <mt:setvarblock name="order_by">quux</mt:setvarblock>
        quux
    </mt:OrderItem>
    <mt:OrderItem>
        <mt:setvarblock name="order_by">1234</mt:setvarblock>
        1234
    </mt:OrderItem>
</mt:Order>
EOF
like(build($t), qr{ \A \s* quux \s+ 1234 \s+ 17 \s+ 1 \s* \z }xms, "Natural order for numbers is descending numerical");

$t = <<EOF;
<mt:Order sort_order="ascend" natural="1">
    <mt:OrderItem>
        <mt:setvarblock name="order_by">17</mt:setvarblock>
        17
    </mt:OrderItem>
    <mt:OrderItem>
        <mt:setvarblock name="order_by">1</mt:setvarblock>
        1
    </mt:OrderItem>
    <mt:OrderItem>
        <mt:setvarblock name="order_by">quux</mt:setvarblock>
        quux
    </mt:OrderItem>
    <mt:OrderItem>
        <mt:setvarblock name="order_by">1234</mt:setvarblock>
        1234
    </mt:OrderItem>
</mt:Order>
EOF
like(build($t), qr{ \A \s* 1 \s+ 17 \s+ 1234 \s+ quux \s* \z }xms, "Ascending natural order reverses regular numerical");


1;
