#!/usr/bin/perl

use strict;
use warnings;

use Perl::ToRaku;
use Test::More;

plan tests => 6;

my $package  = 'Perl::ToRaku::Transformers::SubNew';
my $_package = 'Perl::ToRaku::Collectors::IsPackage';
my $toRaku   = Perl::ToRaku->new;

use_ok $package;
use_ok $_package;

do {
  my $toRaku = Perl::ToRaku->new;
  $toRaku->test_collect( $_package, 'package My::Package; sub new { }' );
  is $toRaku->{is_package}, 1;
  is $toRaku->test_transform( $package, 'package Foo; sub new { }' ),
     'package Foo; multi method new { }';
};

do {
  my $toRaku = Perl::ToRaku->new;
  $toRaku->test_collect( $_package, 'package My::Package; sub newt { }' );
  is $toRaku->{is_package}, 1;
  is $toRaku->test_transform( $package, 'package Foo; sub newt { }' ),
     'package Foo; sub newt { }';
};

done_testing;
