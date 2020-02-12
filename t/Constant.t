#!/usr/bin/perl

use strict;
use warnings;

use Perl::ToRaku;
use Test::More;

plan tests => 5;

my $package = 'Perl::ToRaku::Transformers::Constant';
my $toRaku  = Perl::ToRaku->new;

use_ok $package;

is $toRaku->test_transform( $package, 'use constant FOO => 1;' ),
   'constant FOO = 1;';

is $toRaku->test_transform( $package, 'use constant FOO=>1;' ),
   'constant FOO=1;';

is $toRaku->test_transform( $package, 'use constant FOO;' ),
   'use constant FOO;';

is $toRaku->test_transform( $package, 'use strict "warnings";' ),
   'use strict "warnings";';

done_testing;
