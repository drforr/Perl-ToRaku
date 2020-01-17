#!/usr/bin/perl

use Test::More;
use lib 't/lib/';
use Perl::ToRaku::Utils qw( transform );

plan tests => 4;

my $package = 'Perl::ToRaku::Transformers::Whitespace';

use_ok $package;

is transform( $package, 'my( $x, $y );' ), 'my ( $x, $y );';

is transform( $package, 'foo( $x, $y );' ), 'foo( $x, $y );';

is transform( $package, '1 or 2' ), '1 or 2';

done_testing;
