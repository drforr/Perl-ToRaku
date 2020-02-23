#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Perl::ToRaku;

plan tests => 3;

my $package = 'Perl::ToRaku::Transformers::BitwiseOperators';
my $toRaku  = Perl::ToRaku->new;

use_ok $package;

is $toRaku->test_transform( $package, '1 & 2' ),
   '1 +& 2';

is $toRaku->test_transform( $package, '1&2' ),
   '1+&2';

done_testing;
