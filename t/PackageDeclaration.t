#!/usr/bin/perl

use strict;
use warnings;

use Perl::ToRaku;
use Test::More;

plan tests => 17;

my $package = 'Perl::ToRaku::Transformers::PackageDeclaration';

use_ok $package;

do {
  my $toRaku  = Perl::ToRaku->new;
  is $toRaku->test_transform( $package, 'package My::Name v1.2.3;' ),
   'unit class My::Name:ver<1.2.3>;';

  is $toRaku->test_transform( $package, <<'_EOS_' ), <<'_EOS_';
package My::Name;
use base 'My::Parent';
our $VERSION='2.3.4';
_EOS_
unit class My::Name:ver<2.3.4> is My::Parent;


_EOS_
  ok $toRaku->{is_package};
  is $toRaku->{is_package}{name}, 'My::Name';
#  is $toRaku->{is_package}{version}, '2.3.4';
};

do {
  my $toRaku  = Perl::ToRaku->new;
  is $toRaku->test_transform( $package, <<'_EOS_' ), <<'_EOS_';
package My::Name;
use base qw(My::Parent);
our $VERSION='2.3.4';
_EOS_
unit class My::Name:ver<2.3.4> is My::Parent;


_EOS_
  ok $toRaku->{is_package};
  is $toRaku->{is_package}{name}, 'My::Name';
#  is $toRaku->{is_package}{version}, '2.3.4';
};

do {
  my $toRaku = Perl::ToRaku->new;
  is $toRaku->test_transform( $package, <<'_EOS_' ), <<'_EOS_';
package My::Name;
our $VERSION='2.3.4';
_EOS_
unit class My::Name:ver<2.3.4>;

_EOS_
  ok $toRaku->{is_package};
  is $toRaku->{is_package}{name}, 'My::Name';
#  is $toRaku->{is_package}{version}, '2.3.4';
};

do {
  my $toRaku  = Perl::ToRaku->new;
  is $toRaku->test_transform( $package, 'package My::Name;' ),
     'unit class My::Name;';
  ok $toRaku->{is_package};
  is $toRaku->{is_package}{name}, 'My::Name';
  ok !defined( $toRaku->{is_package}{version} );
};

do {
  my $toRaku  = Perl::ToRaku->new;
  is $toRaku->test_transform( $package, '1 or 2' ),
     '1 or 2';
  ok !defined( $toRaku->{is_package} );
};

done_testing;
