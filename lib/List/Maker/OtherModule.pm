package List::Maker::OtherModule;

use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.0.1');

sub _regular_glob {
    my @data = <1..10>;
    return @data != 10;
}

package main;

sub _regular_glob {
    my @data = <1..10>;
    return @data != 10;
}

1; # Magic true value required at end of module
