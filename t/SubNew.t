#!/usr/bin/perl

use strict;
use warnings;

use Perl::ToRaku;
use Test::More;

plan tests => 7;

my $package = 'Perl::ToRaku::Transformers::SubNew';

use_ok $package;

do {
  my $toRaku = Perl::ToRaku->new;
  is $toRaku->test_transform( $package, 'package Foo; sub new { }' ),
     'package Foo; multi method new { }';
  ok $toRaku->{is_package};
};

do {
  my $toRaku = Perl::ToRaku->new;
  is $toRaku->test_transform( $package, 'package Foo; sub newt { }' ),
     'package Foo; sub newt { }';
  ok $toRaku->{is_package};
};

do {
  my $toRaku = Perl::ToRaku->new;
  is $toRaku->test_transform( $package, 'sub new { }' ),
     'sub new { }';
  ok !defined( $toRaku->{is_package} );
};

done_testing;
