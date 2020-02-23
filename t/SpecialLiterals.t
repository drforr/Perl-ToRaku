#!/usr/bin/perl

use strict;
use warnings;

use Perl::ToRaku;
use Test::More;

plan tests => 4;

my $package = 'Perl::ToRaku::Transformers::SpecialLiterals';
my $toRaku  = Perl::ToRaku->new;

use_ok $package;

is $toRaku->test_transform( $package, '__END__' ),
   '=finish';

is $toRaku->test_transform( $package, '__FILE__' ),
   '$?FILE';

is $toRaku->test_transform( $package, '__PACKAGE__' ),
   '$?PACKAGE';

done_testing;
