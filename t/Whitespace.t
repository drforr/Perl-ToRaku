#!/usr/bin/perl

use strict;
use warnings;

use Perl::ToRaku;
use Test::More;

plan tests => 24;

my $package = 'Perl::ToRaku::Transformers::Whitespace';
my $toRaku  = Perl::ToRaku->new;

use_ok $package;

is $toRaku->test_transform( $package, 'q( $x , $y );' ),
   'q ( $x , $y );';

is $toRaku->test_transform( $package, 'qw( $x , $y );' ),
   'qw ( $x , $y );';

is $toRaku->test_transform( $package, 'qq( $x , $y );' ),
   'qq ( $x , $y );';

is $toRaku->test_transform( $package, 'print( $x , $y );' ),
   'print ( $x , $y );';

is $toRaku->test_transform( $package, 'print($x,$y);' ),
   'print ($x,$y);';

is $toRaku->test_transform( $package, 'print ( $x , $y );' ),
   'print ( $x , $y );';

is $toRaku->test_transform( $package, 'print ($x,$y);' ), 'print ($x,$y);';

is $toRaku->test_transform( $package, 'qw( $x , $y );' ), 'qw ( $x , $y );';

is $toRaku->test_transform( $package, 'qw($x,$y);' ), 'qw ($x,$y);';

is $toRaku->test_transform( $package, 'my( $x , $y );' ), 'my ( $x , $y );';

is $toRaku->test_transform( $package, 'my($x,$y);' ), 'my ($x,$y);';

is $toRaku->test_transform( $package, 'my ( $x , $y );' ), 'my ( $x , $y );';

is $toRaku->test_transform( $package, 'my ($x,$y);' ), 'my ($x,$y);';

is $toRaku->test_transform( $package, 'qw( $x , $y );' ), 'qw ( $x , $y );';

is $toRaku->test_transform( $package, 'qw($x,$y);' ), 'qw ($x,$y);';

is $toRaku->test_transform( $package, 'qw ( $x , $y );' ), 'qw ( $x , $y );';

is $toRaku->test_transform( $package, 'qw ($x,$y);' ), 'qw ($x,$y);';

is $toRaku->test_transform( $package, 'foo( $x , $y );' ), 'foo( $x , $y );';

is $toRaku->test_transform( $package, 'foo($x,$y);' ), 'foo($x,$y);';

is $toRaku->test_transform( $package, 'if( $x == $y ) { }' ),
   'if ( $x == $y ) { }';

is $toRaku->test_transform( $package, 'if($x==$y){}' ),
   'if ($x==$y){}';

is $toRaku->test_transform( $package, '1 if( $x == $y );' ),
   '1 if ( $x == $y );';

is $toRaku->test_transform( $package, '1 if($x==$y);' ),
   '1 if ($x==$y);';

done_testing;
