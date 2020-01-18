#!/usr/bin/perl

use strict;
use warnings;

use Perl::ToRaku;
use Test::More;

plan tests => 3;

my $package = 'Perl::ToRaku::Transformers::Utf8Pragma';
my $toRaku  = Perl::ToRaku->new;

use_ok $package;

is $toRaku->test_transform( $package, 'use utf8 qw(foo);' ), '';

is $toRaku->test_transform( $package, 'use warnings;' ), 'use warnings;';

done_testing;
