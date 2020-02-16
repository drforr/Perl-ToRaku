#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Perl::ToRaku;

plan tests => 3;

my $package = 'Perl::ToRaku::Transformers::ArrayIndex';
my $toRaku  = Perl::ToRaku->new;

use_ok $package;

is $toRaku->test_transform( $package, '$#a' ),
   '@a.elems';

is $toRaku->test_transform( $package, '1/1' ),
   '1/1';

done_testing;
