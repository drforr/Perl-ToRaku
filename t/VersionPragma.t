#!/usr/bin/perl

use Test::More;
use lib 't/lib/';
use Perl::ToRaku::Utils qw( transform );

plan tests => 5;

my $package = 'Perl::ToRaku::Transformers::VersionPragma';

use_ok $package;

is transform( $package, 'use 5.008 qw(a b c);' ), '';

is transform( $package, 'use 5.008 "vars";' ), '';

is transform( $package, 'use 5.008;' ), '';

is transform( $package, 'use warnings;' ), 'use warnings;';

done_testing;
