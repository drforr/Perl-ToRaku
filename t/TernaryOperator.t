#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Perl::ToRaku;

plan tests => 3;

my $package = 'Perl::ToRaku::Transformers::TernaryOperator';
my $toRaku  = Perl::ToRaku->new;

use_ok $package;

is $toRaku->test_transform( $package, '1 ? 2 : 3' ),
   '1 ?? 2 !! 3';

is $toRaku->test_transform( $package, '1?2:3' ),
   '1??2!!3';

done_testing;
