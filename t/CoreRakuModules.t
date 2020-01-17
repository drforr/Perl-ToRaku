#!/usr/bin/perl

use Test::More;
use lib 't/lib/';
use Perl::ToRaku::Utils qw( transform );

plan tests => 3;

my $package = 'Perl::ToRaku::Transformers::CoreRakuModules';

use_ok $package;

is transform( $package, 'use IO::Handle;' ),
   '';

is transform( $package, 'use IO::IO;' ),
   'use IO::IO;';

done_testing;
