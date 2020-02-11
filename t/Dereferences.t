#!/usr/bin/perl

use strict;
use warnings;

use Perl::ToRaku;
use Test::More;

plan tests => 6;

my $package = 'Perl::ToRaku::Transformers::Dereferences';
my $toRaku  = Perl::ToRaku->new;

use_ok $package;

is $toRaku->test_transform( $package, q{% { $a }} ),
   q{% ( $a )};

is $toRaku->test_transform( $package, q{%$a} ),
   q{%$a};

is $toRaku->test_transform( $package, q{@ { $a }} ),
   q{@ ( $a )};

is $toRaku->test_transform( $package, q{@$a} ),
   q{@$a};

is $toRaku->test_transform( $package, '1 or 2' ), '1 or 2';

done_testing;
