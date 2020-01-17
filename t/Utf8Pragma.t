#!/usr/bin/perl

use Test::More;
use lib 't/lib/';
use Perl::ToRaku::Utils qw( transform );

plan tests => 3;

my $package = 'Perl::ToRaku::Transformers::Utf8Pragma';

use_ok $package;

is transform( $package, 'use utf8 qw(foo);' ), '';

is transform( $package, 'use warnings;' ), 'use warnings;';

done_testing;
