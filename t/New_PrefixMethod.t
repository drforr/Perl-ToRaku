#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Perl::ToRaku;

plan tests => 3;

my $package = 'Perl::ToRaku::Transformers::New_PrefixMethod';
my $toRaku  = Perl::ToRaku->new;

use_ok $package;

# XXX Maybe try to read surrounding code to figure out, later on?
#
is $toRaku->test_transform( $package, 'new Foo ( 2 )' ),
   'Foo.new ( 2 )';

is $toRaku->test_transform( $package, 'new Foo( 2 )' ),
   'Foo.new( 2 )';

done_testing;
