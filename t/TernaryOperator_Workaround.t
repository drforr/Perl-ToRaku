#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Perl::ToRaku;

plan tests => 3;

my $package = 'Perl::ToRaku::Transformers::TernaryOperator_Workaround';
my $toRaku  = Perl::ToRaku->new;

use_ok $package;

# Note that it only fixes the : side of the operator.
#
is $toRaku->test_transform( $package, 'verExcel95 ? verBIFF5 : verBIFF8' ),
   'verExcel95 ? verBIFF5 !! verBIFF8';

is $toRaku->test_transform( $package, '1 or 2' ),
   '1 or 2';

done_testing;
