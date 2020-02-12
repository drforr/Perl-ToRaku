#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Perl::ToRaku;

plan tests => 3;

my $package = 'Perl::ToRaku::Transformers::Exists';
my $toRaku  = Perl::ToRaku->new;

use_ok $package;

subtest 'exists in middle of statement', sub {
  is $toRaku->test_transform( $package, '1 if exists $q -> { a }' ),
     '1 if $q -> { a }:exists';

  is $toRaku->test_transform( $package, '1 if exists $q -> {a}' ),
     '1 if $q -> {a}:exists';

  is $toRaku->test_transform( $package, '1 if exists $q { a }' ),
     '1 if $q { a }:exists';

  is $toRaku->test_transform( $package, '1 if exists $q{a}' ),
     '1 if $q{a}:exists';

  is $toRaku->test_transform( $package, '1 if exists %q -> { a }' ),
     '1 if %q -> { a }:exists';

  is $toRaku->test_transform( $package, '1 if exists $q->{a}' ),
     '1 if $q->{a}:exists';

  is $toRaku->test_transform( $package, '1 if exists %q { a }' ),
     '1 if %q { a }:exists';

  is $toRaku->test_transform( $package, '1 if exists $q{a}' ),
     '1 if $q{a}:exists';
};

subtest 'exists at start of statement', sub {
  is $toRaku->test_transform( $package, 'exists $q -> { a }' ),
     '$q -> { a }:exists';

  is $toRaku->test_transform( $package, 'exists $q->{a}' ),
     '$q->{a}:exists';

  is $toRaku->test_transform( $package, 'exists $q { a }' ),
     '$q { a }:exists';

  is $toRaku->test_transform( $package, 'exists $q{a}' ),
     '$q{a}:exists';

  is $toRaku->test_transform( $package, 'exists %q { a }' ),
     '%q { a }:exists';

  is $toRaku->test_transform( $package, 'exists $q{a}' ),
     '$q{a}:exists';

  is $toRaku->test_transform( $package, '1 /= 1' ),
     '1 /= 1';
};

done_testing;
