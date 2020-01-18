#!/usr/bin/perl

use strict;
use warnings;

use Perl::ToRaku;
use Test::More;

plan tests => 5;

my $package = 'Perl::ToRaku::Transformers::WarningsPragma';
my $toRaku  = Perl::ToRaku->new;

use_ok $package;

is $toRaku->test_transform( $package, 'use warnings qw(a b c);' ), '';

is $toRaku->test_transform( $package, 'use warnings "vars";' ), '';

is $toRaku->test_transform( $package, 'use warnings;' ), '';

is $toRaku->test_transform( $package, 'use strict;' ), 'use strict;';

done_testing;
