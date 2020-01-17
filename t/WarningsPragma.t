#!/usr/bin/perl

use Test::More;
use lib 't/lib/';
use Perl::ToRaku::Utils qw( transform );

plan tests => 5;

my $package = 'Perl::ToRaku::Transformers::WarningsPragma';

use_ok $package;

is transform( $package, 'use warnings qw(a b c);' ), '';

is transform( $package, 'use warnings "vars";' ), '';

is transform( $package, 'use warnings;' ), '';

is transform( $package, 'use strict;' ), 'use strict;';

done_testing;
