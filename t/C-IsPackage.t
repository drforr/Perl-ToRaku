#!/usr/bin/perl

use strict;
use warnings;

use Perl::ToRaku;
use Test::More;

plan tests => 3;

my $package = 'Perl::ToRaku::Collectors::IsPackage';
my $toRaku  = Perl::ToRaku->new;

use_ok $package;

do {
  my $toRaku = Perl::ToRaku->new;
  $toRaku->test_collect( $package, 'package My::Name;' );
  is $toRaku->{is_package}, 1;
};

do {
  my $toRaku = Perl::ToRaku->new;
  $toRaku->test_collect( $package, 'use Morraine;' );
  ok !exists $toRaku->{is_moose};
};

done_testing;
