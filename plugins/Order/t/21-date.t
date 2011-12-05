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
<mt:Order sort_order="ascend">
    <mt:OrderItem>
        <mt:setvarblock name="order_by">20111205010000</mt:setvarblock>
        1:00
    </mt:OrderItem>
    <mt:OrderItem>
        <mt:setvarblock name="order_by">20111205020000</mt:setvarblock>
        2:00
    </mt:OrderItem>
    <mt:OrderItem>
        <mt:setvarblock name="order_by">20111205030000</mt:setvarblock>
        3:00
    </mt:OrderItem>
</mt:Order>
EOF
like(build($t), qr{ \A \s* 1:00 \s+ 2:00 \s+ 3:00 \s* \z }xms, "Ordering by timestamp data works fine");

$t = <<EOF;
<mt:Order sort_order="ascend">
    <mt:OrderItem>
        <mt:setvarblock name="order_by">20111205010000</mt:setvarblock>
        1:00
    </mt:OrderItem>
    <mt:OrderItem>
        <mt:setvarblock name="order_by">20111205020000</mt:setvarblock>
        2:00
    </mt:OrderItem>
    <mt:OrderItem>
        <mt:setvarblock name="order_by">20111205030000</mt:setvarblock>
        3:00
    </mt:OrderItem>
    <mt:OrderDateHeader>
        <mt:OrderDate format="%e-%b-%Y">
    </mt:OrderDateHeader>
    <mt:OrderDateFooter>
        footer
    </mt:OrderDateFooter>
</mt:Order>
EOF
like(build($t), qr{ \A \s* 5-Dec-2011 \s+ 1:00 \s+ 2:00 \s+ 3:00 \s+ footer \s* \z }xms,
    "For items all on the same date, date header and footer bracket everything");

$t = <<EOF;
<mt:Order sort_order="ascend">
    <mt:OrderItem>
        <mt:setvarblock name="order_by">20111205010000</mt:setvarblock>
        1:00
    </mt:OrderItem>
    <mt:OrderItem>
        <mt:setvarblock name="order_by">20111206020000</mt:setvarblock>
        2:00
    </mt:OrderItem>
    <mt:OrderItem>
        <mt:setvarblock name="order_by">20120101030000</mt:setvarblock>
        3:00
    </mt:OrderItem>
    <mt:OrderDateHeader>
        <mt:OrderDate format="%e-%b-%Y">
    </mt:OrderDateHeader>
    <mt:OrderDateFooter>
        footer
    </mt:OrderDateFooter>
</mt:Order>
EOF
like(build($t), qr{ \A \s* 5-Dec-2011 \s+ 1:00 \s+ footer \s+ 6-Dec-2011 \s+ 2:00 \s+ footer \s+ 1-Jan-2012 \s+ 3:00 \s+ footer \s* \z }xms,
    "For items on different dates, date header and footer bracket each item");

$t = <<EOF;
<mt:Order sort_order="ascend">
    <mt:OrderItem>
        <mt:setvarblock name="order_by">20111205010000</mt:setvarblock>
        1:00
    </mt:OrderItem>
    <mt:OrderItem>
        <mt:setvarblock name="order_by">20111205020000</mt:setvarblock>
        2:00
    </mt:OrderItem>
    <mt:OrderItem>
        <mt:setvarblock name="order_by">20120101030000</mt:setvarblock>
        3:00
    </mt:OrderItem>
    <mt:OrderDateHeader>
        <mt:OrderDate format="%e-%b-%Y">
    </mt:OrderDateHeader>
    <mt:OrderDateFooter>
        footer
    </mt:OrderDateFooter>
</mt:Order>
EOF
like(build($t), qr{ \A \s* 5-Dec-2011 \s+ 1:00 \s+ 2:00 \s+ footer \s+ 1-Jan-2012 \s+ 3:00 \s+ footer \s* \z }xms,
    "Multi-item date brackets work too");


1;
