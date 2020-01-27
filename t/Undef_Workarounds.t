#!/usr/bin/perl

use strict;
use warnings;

use Perl::ToRaku;
use Test::More;

plan tests => 4;

my $package = 'Perl::ToRaku::Transformers::Undef_Workarounds';
my $toRaku  = Perl::ToRaku->new;

use_ok $package;

is $toRaku->test_transform( $package, 'undef && 1' ), 'undef && 1';

is $toRaku->test_transform( $package, '( $sWk & 32 ) ? undef : 3;' ),
   '( $sWk & 32 ) ? Nil : 3;';

is $toRaku->test_transform( $package, '# undef' ), '# undef';

done_testing;
