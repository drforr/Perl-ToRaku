#!/usr/bin/perl

use strict;
use warnings;

use Perl::ToRaku;
use Test::More;

plan tests => 4;

my $package = 'Perl::ToRaku::Transformers::Attributes';

use_ok $package;

subtest 'Multi-line package', sub {
  my $toRaku = Perl::ToRaku->new;
  is $toRaku->test_transform( $package, <<'_EOS_' ),
package Foo;

sub new { }
_EOS_
  <<'_EOS_',
package Foo;

multi method new { }
_EOS_
  'multiple-line package';
  ok $toRaku->{is_package};
};

subtest 'single line inside package', sub {
  subtest 'single-line package', sub {
    my $toRaku = Perl::ToRaku->new;
    is $toRaku->test_transform( $package, 'package Foo; sub new { }' ),
       'package Foo; multi method new { }';
    ok $toRaku->{is_package}, q{package found with 'new' method};
  };

  subtest 'single-line package, no "new"', sub {
    my $toRaku = Perl::ToRaku->new;
    is $toRaku->test_transform( $package, 'package Foo; sub newt { }' ),
       'package Foo; method newt { }';
    ok $toRaku->{is_package}, q{package found even without 'new' method};
  };
};

subtest 'single line outside of package', sub {
  subtest 'new() function', sub {
    my $toRaku = Perl::ToRaku->new;
    is $toRaku->test_transform( $package, 'sub new { }' ),
       'sub new { }';
    ok !defined( $toRaku->{is_package} ), q{only change if in package};
  };

  subtest 'new() function, no spaces', sub {
    my $toRaku = Perl::ToRaku->new;
    is $toRaku->test_transform( $package, 'sub new{}' ),
       'sub new{}';
    ok !defined( $toRaku->{is_package} ), q{only change if in package};
  };
};

done_testing;
