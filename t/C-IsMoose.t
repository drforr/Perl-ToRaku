#!/usr/bin/perl

use strict;
use warnings;

use Perl::ToRaku;
use Test::More;

plan tests => 4;

my $package = 'Perl::ToRaku::Collectors::IsMoose';
my $toRaku  = Perl::ToRaku->new;

use_ok $package;

do {
  my $toRaku = Perl::ToRaku->new;
  $toRaku->test_collect( $package, 'use Moo;' );
  is $toRaku->{is_moose}, 1;
};

do {
  my $toRaku = Perl::ToRaku->new;
  $toRaku->test_collect( $package, 'use Moose;' );
  is $toRaku->{is_moose}, 1;
};

do {
  my $toRaku = Perl::ToRaku->new;
  $toRaku->test_collect( $package, 'use Morraine;' );
  ok !exists $toRaku->{is_moose};
};

done_testing;
