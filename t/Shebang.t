#!/usr/bin/perl

use Test::More;
use lib 't/lib/';
use Perl::ToRaku::Utils qw( transform );

plan tests => 7;

my $package = 'Perl::ToRaku::Transformers::Shebang';

use_ok $package;

is transform( $package, "#!/usr/bin/env perl -w\n" ),
   "#!/usr/bin/env raku -w\n";

is transform( $package, "#!/usr/bin/perl -w\n" ),
   "#!/usr/bin/env raku -w\n";

is transform( $package, "#!perl -w\n" ),
   "#!raku\n";

is transform( $package, "#!/usr/bin/env perl\n" ),
   "#!/usr/bin/env raku\n";

is transform( $package, "#!/usr/bin/perl\n" ),
   "#!/usr/bin/env raku\n";

is transform( $package, "#!perl\n" ),
   "#!raku\n";

done_testing;
