#!/usr/bin/perl

use Test::More;
use lib 't/lib/';
use Perl::ToRaku::Utils qw( transform );

plan tests => 3;

# Package name to test goes here
#
my $package = 'Perl::ToRaku::Transformers::StyleGuide';

use_ok $package;

# At least one passing test for each line type that the original 
# transformer can handle.
#
is transform( $package, "use strict 'warnings';" ),
   "use strict 'warnings';";

# And at least one thing that it can't handle. Looking close to 
# a passing test, like 'use strict' when the test only looks for
# 'use warnings' is a bonus, but not necessary.
#
is transform( $package, '1 or 2' ),
   '1 or 2';

# For Undef_Workaround.t -like stuff:
#
# Suppose that when combined, Undef.t and Undef_Workaround.t together
# replace all instances of 'undef' with 'Nil' that aren't in a comment.
# (this is true as of this typing)
#
# Undef.t:
#
# is transform( $package, 'undef => 1,' ), 'Nil => 1,';
#
# is transform( $package, '(1) ? undef : 1' ), '(1) ? undef : 1';
#
# Undef_Workaround.t
#
# is transform( $package, 'undef => 1,' ), 'undef => 1,';
#
# is transform( $package, '(1) ? undef : 1' ), '(1) ? Nil : 1';
#
# Should PPI ever fix this particular test case, at least one of the
# test files will break, and we'll be able to change a line in the
# original and remove the workaround.

done_testing;
