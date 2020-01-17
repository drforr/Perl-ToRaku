#!/usr/bin/perl

use Test::More;
use lib 't/lib/';
use Perl::ToRaku::Utils qw( transform );

plan tests => 4;

my $package = 'Perl::ToRaku::Transformers::Undef';

use_ok $package;

is transform( $package, 'undef && 1' ), 'Nil && 1';

# Handled by a Workaround file
#
is transform( $package, '( $sWk & 32 ) ? undef : 3;' ),
   '( $sWk & 32 ) ? undef : 3;';

is transform( $package, '# undef' ), '# undef';

done_testing;
