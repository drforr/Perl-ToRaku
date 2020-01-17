#!/usr/bin/perl

use Test::More;
use lib 't/lib/';
use Perl::ToRaku::Utils qw( transform );

plan tests => 3;

my $package = 'Perl::ToRaku::Transformers::BitwiseOperators';

use_ok $package;

is transform( $package, '1 & 2' ), '1 +& 2';

is transform( $package, '1 or 2' ), '1 or 2';

done_testing;
