#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Perl::ToRaku;

plan tests => 5;

my $package = 'Perl::ToRaku::Transformers::HashKeys';
my $toRaku  = Perl::ToRaku->new;

use_ok $package;

is $toRaku->test_transform( $package, q{$a{"foo"}} ),
   q{$a{"foo"}};

is $toRaku->test_transform( $package, q{$a{'foo'}} ),
   q{$a{'foo'}};

is $toRaku->test_transform( $package, q{$a{foo}} ),
   q{$a{'foo'}};

# XXX This needs work
#
#is $toRaku->test_transform( $package,
#   q{$oBook.{FormatStr}{ $rhKey{Format}{FmtIdx} }} ),
#   q{$oBook.{'FormatStr'}{ $rhKey{'Format'}{'FmtIdx'} }};

is $toRaku->test_transform( $package, '1/=1' ),
   '1/=1';

done_testing;
