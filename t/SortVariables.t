#!/usr/bin/perl

use strict;
use warnings;

use Perl::ToRaku;
use Test::More;

plan tests => 5;

my $package = 'Perl::ToRaku::Transformers::SortVariables';
my $toRaku  = Perl::ToRaku->new;

use_ok $package;

is $toRaku->test_transform( $package, 'sort { $a <=> $b }' ),
   'sort { $^a <=> $^b }';

is $toRaku->test_transform( $package, 'sort{$a<=>$b}' ),
   'sort{$^a<=>$^b}';

is $toRaku->test_transform( $package, 'map { $a <=> $b }' ),
   'map { $a <=> $b }';

is $toRaku->test_transform( $package, 'map{$a<=>$b}' ),
   'map{$a<=>$b}';

done_testing;
