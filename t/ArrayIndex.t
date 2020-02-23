#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Perl::ToRaku;

plan tests => 2;

my $package = 'Perl::ToRaku::Transformers::ArrayIndex';
my $toRaku  = Perl::ToRaku->new;

use_ok $package;

is $toRaku->test_transform( $package, '$#a' ),
   '@a.elems';

done_testing;
