#!/usr/bin/perl

use Test::More;
use lib 't/lib/';
use Perl::ToRaku::Utils qw( transform );

plan tests => 4;

my $package = 'Perl::ToRaku::Transformers::Constant';

use_ok $package;

is transform( $package, 'use constant FOO => 1;' ),
   'constant FOO = 1;';

is transform( $package, 'use constant FOO;' ),
   'use constant FOO;';

is transform( $package, 'use strict "warnings";' ),
   'use strict "warnings";';

done_testing;
