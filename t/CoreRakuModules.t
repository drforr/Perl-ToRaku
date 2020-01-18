#!/usr/bin/perl

use strict;
use warnings;

use Perl::ToRaku;
use Test::More;

plan tests => 3;

my $package = 'Perl::ToRaku::Transformers::CoreRakuModules';
my $toRaku  = Perl::ToRaku->new;

use_ok $package;

is $toRaku->test_transform( $package, 'use IO::Handle;' ),
   '';

is $toRaku->test_transform( $package, 'use IO::IO;' ),
   'use IO::IO;';

done_testing;
