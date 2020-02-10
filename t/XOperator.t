#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Perl::ToRaku;

plan tests => 4;

my $package = 'Perl::ToRaku::Transformers::XOperator';
my $toRaku  = Perl::ToRaku->new;

use_ok $package;

is $toRaku->test_transform( $package, '1 x 2' ),
   '1 x 2';

is $toRaku->test_transform( $package, '(1) x 3' ),
   '(1) xx 3';

is $toRaku->test_transform( $package, '1 or 2' ),
   '1 or 2';

done_testing;
