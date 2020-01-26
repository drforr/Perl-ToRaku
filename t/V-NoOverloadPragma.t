#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Perl::ToRaku;

plan tests => 3;

my $package = 'Perl::ToRaku::Validators::NoOverloadPragma';

use_ok $package;

do {
  my $toRaku = Perl::ToRaku->new;
  ok !$toRaku->test_validate( $package, 'use strict' );
};

do {
  my $toRaku = Perl::ToRaku->new;
  like $toRaku->test_validate( $package, 'package Foo; use overload;' ),
       qr/Currently we /;
};

done_testing;
