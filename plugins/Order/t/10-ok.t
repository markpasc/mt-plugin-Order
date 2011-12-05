use lib qw( t/lib lib extlib plugins/Order/lib );

use strict;
use warnings;

use MT::Test qw( :app :db );
use Test::More tests => 1;


use_ok('Order::Plugin');

1;
