#!/usr/bin/perl

use Test::More;
use lib 't/lib/';
use Perl::ToRaku::Utils qw( transform );

plan tests => 4;

my $package = 'Perl::ToRaku::Transformers::Undef_Workarounds';

use_ok $package;

is transform( $package, 'undef && 1' ), 'undef && 1';

# Handled by a Workaround file
#
is transform( $package, '( $sWk & 32 ) ? Nil : 3;' ),
   '( $sWk & 32 ) ? Nil : 3;';

is transform( $package, '# undef' ), '# undef';

done_testing;
