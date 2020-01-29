#!/usr/bin/perl

use strict;
use warnings;

use Perl::ToRaku;
use Test::More;

plan tests => 3;

my $package = 'Perl::ToRaku::Transformers::ForLoops';
my $toRaku  = Perl::ToRaku->new;

use_ok $package;

is $toRaku->test_transform( $package, 'for ( my $i = 0 ; $i < 10 ; $i++ ) { }' ),
   'loop ( my $i = 0 ; $i < 10 ; $i++ ) { }';

is $toRaku->test_transform( $package, 'for ( @foo ) { }' ),
   'for ( @foo ) { }';

done_testing;
