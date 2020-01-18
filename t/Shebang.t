#!/usr/bin/perl

use strict;
use warnings;

use Perl::ToRaku;
use Test::More;

plan tests => 7;

my $package = 'Perl::ToRaku::Transformers::Shebang';
my $toRaku  = Perl::ToRaku->new;

use_ok $package;

is $toRaku->test_transform( $package, "#!/usr/bin/env perl -w\n" ),
   "#!/usr/bin/env raku -w\n";

is $toRaku->test_transform( $package, "#!/usr/bin/perl -w\n" ),
   "#!/usr/bin/env raku -w\n";

is $toRaku->test_transform( $package, "#!perl -w\n" ),
   "#!raku\n";

is $toRaku->test_transform( $package, "#!/usr/bin/env perl\n" ),
   "#!/usr/bin/env raku\n";

is $toRaku->test_transform( $package, "#!/usr/bin/perl\n" ),
   "#!/usr/bin/env raku\n";

is $toRaku->test_transform( $package, "#!perl\n" ),
   "#!raku\n";

done_testing;
