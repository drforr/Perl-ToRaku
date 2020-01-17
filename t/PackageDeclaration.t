#!/usr/bin/perl

use strict;
use warnings;

use lib 't/lib/';
use Perl::ToRaku::Utils qw( transform );
use Test::More;

plan tests => 5;

my $package = 'Perl::ToRaku::Transformers::PackageDeclaration';

use_ok $package;

is transform( $package, 'package My::Name v1.2.3;' ),
   'unit class My::Name:ver<1.2.3>;';

is transform( $package, "package My::Name;\nour \$VERSION='1.2.3';" ),
   'unit class My::Name:ver<1.2.3>;';

is transform( $package, 'package My::Name;' ),
   'unit class My::Name;';

is transform( $package, '1 or 2' ),
   '1 or 2';

done_testing;
