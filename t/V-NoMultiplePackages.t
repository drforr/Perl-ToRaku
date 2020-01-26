#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Perl::ToRaku;

plan tests => 4;

my $package = 'Perl::ToRaku::Validators::NoMultiplePackages';

use_ok $package;

do {
  my $toRaku = Perl::ToRaku->new;
  ok !$toRaku->test_validate( $package, 'use Moo' );
};

do {
  my $toRaku = Perl::ToRaku->new;
  ok !$toRaku->test_validate( $package, 'package Foo; use Moo' );
};

do {
  my $toRaku = Perl::ToRaku->new;
  like $toRaku->test_validate( $package, 'package Foo; package Moo;' ),
       qr/Currently only /;
};

done_testing;
