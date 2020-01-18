#!/usr/bin/perl

use strict;
use warnings;

use Perl::ToRaku;
use Test::More;

plan tests => 5;

my $package = 'Perl::ToRaku::Transformers::VersionPragma';
my $toRaku  = Perl::ToRaku->new;

use_ok $package;

is $toRaku->test_transform( $package, 'use 5.008 qw(a b c);' ), '';

is $toRaku->test_transform( $package, 'use 5.008 "vars";' ), '';

is $toRaku->test_transform( $package, 'use 5.008;' ), '';

is $toRaku->test_transform( $package, 'use warnings;' ), 'use warnings;';

done_testing;
