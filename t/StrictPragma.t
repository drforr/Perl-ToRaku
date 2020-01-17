#!/usr/bin/perl

use Test::More;
use lib 't/lib/';
use Perl::ToRaku::Utils qw( transform );

plan tests => 3;

my $package = 'Perl::ToRaku::Transformers::StrictPragma';

use_ok $package;

is transform( $package, "use strict 'warnings';" ), '';

is transform( $package, '1 or 2' ), '1 or 2';

done_testing;
