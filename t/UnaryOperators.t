#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Perl::ToRaku;

plan tests => 4;

my $package = 'Perl::ToRaku::Transformers::UnaryOperators';
my $toRaku  = Perl::ToRaku->new;

use_ok $package;

is $toRaku->test_transform( $package, '~1' ),
   '+^1';

is $toRaku->test_transform( $package, '!1' ), # Is changed at user discretion
   '!1';

is $toRaku->test_transform( $package, '-1' ), # Leading '-' unchanged
   '-1';

done_testing;
