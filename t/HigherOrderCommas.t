#!/usr/bin/perl

use strict;
use warnings;

use Perl::ToRaku;
use Test::More;

plan tests => 9;

my $package = 'Perl::ToRaku::Transformers::HigherOrderCommas';
my $toRaku  = Perl::ToRaku->new;

use_ok $package;

is $toRaku->test_transform( $package, 'sort { $a <=> $b } @foo' ),
   'sort { $a <=> $b }, @foo';

is $toRaku->test_transform( $package, 'sort {$a<=>$b} @foo' ),
   'sort {$a<=>$b}, @foo';

is $toRaku->test_transform( $package, 'map { $a <=> $b } @foo' ),
   'map { $a <=> $b }, @foo';

is $toRaku->test_transform( $package, 'map {$a<=>$b} @foo' ),
   'map {$a<=>$b}, @foo';

is $toRaku->test_transform( $package, 'grep { $a <=> $b } @foo' ),
   'grep { $a <=> $b }, @foo';

is $toRaku->test_transform( $package, 'grep {$a<=>$b} @foo' ),
   'grep {$a<=>$b}, @foo';

is $toRaku->test_transform( $package, 'sub { $a <=> $b } @foo' ),
   'sub { $a <=> $b } @foo';

is $toRaku->test_transform( $package, 'sub {$a<=>$b} @foo' ),
   'sub {$a<=>$b} @foo';

done_testing;
