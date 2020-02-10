#!/usr/bin/perl

use strict;
use warnings;

use Perl::ToRaku;
use Test::More;

plan tests => 10;

my $package = 'Perl::ToRaku::Transformers::RedundantPragmas';
my $toRaku  = Perl::ToRaku->new;

use_ok $package;

is $toRaku->test_transform( $package, 'use 5.008 qw(a b c);' ), '';

is $toRaku->test_transform( $package, 'use 5.008 "vars";' ), '';

is $toRaku->test_transform( $package, 'use 5.008;' ), '';

is $toRaku->test_transform( $package, 'use utf8 qw(foo);' ), '';

is $toRaku->test_transform( $package, "use strict 'warnings';" ), '';

is $toRaku->test_transform( $package, 'use warnings qw(a b c);' ), '';

is $toRaku->test_transform( $package, 'use warnings "vars";' ), '';

is $toRaku->test_transform( $package, 'use warnings;' ), '';

is $toRaku->test_transform( $package, 'use Something;' ), 'use Something;';

done_testing;
