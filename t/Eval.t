#!/usr/bin/perl

use strict;
use warnings;

use Perl::ToRaku;
use Test::More;

plan tests => 5;

my $package = 'Perl::ToRaku::Transformers::Eval';
my $toRaku  = Perl::ToRaku->new;

use_ok $package;

is $toRaku->test_transform( $package, 'eval { 32 }' ),
   'EVAL { 32 }';

is $toRaku->test_transform( $package, 'eval{ 32 }' ),
   'EVAL{ 32 }';

is $toRaku->test_transform( $package, 'eval " 32 "' ),
   'EVAL " 32 "';

is $toRaku->test_transform( $package, '1 or 2' ),
   '1 or 2';

done_testing;
