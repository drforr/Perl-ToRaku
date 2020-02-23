#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Perl::ToRaku;

plan tests => 13;

my $package = 'Perl::ToRaku::Transformers::Length_Builtin';
my $toRaku  = Perl::ToRaku->new;

use_ok $package;

#    %q{'streamLen'} = length( $stream_data );    # stream length

is $toRaku->test_transform( $package,
   'for ( $i = 0 ; $i < length( $password ) ; $i++ ) { }' ),
   'for ( $i = 0 ; $i < ( $password ).chars ; $i++ ) { }';

is $toRaku->test_transform( $package,
   'for($i=0;$i<length($password);$i++){}' ),
   'for($i=0;$i<($password).chars;$i++){}';

is $toRaku->test_transform( $package, 'length ( $a . $b ) > 1' ),
   '( $a . $b ).chars > 1';

is $toRaku->test_transform( $package, 'length ( $a ~ $b ) > 1' ),
   '( $a ~ $b ).chars > 1';

is $toRaku->test_transform( $package, 'length($a.$b)>1' ),
   '($a.$b).chars>1';

is $toRaku->test_transform( $package, 'length($a~$b)>1' ),
   '($a~$b).chars>1';

is $toRaku->test_transform( $package, 'length ( $a . $b )' ),
   '( $a . $b ).chars';

is $toRaku->test_transform( $package, 'length ( $a ~ $b )' ),
   '( $a ~ $b ).chars';

is $toRaku->test_transform( $package, 'length($a.$b)' ),
   '($a.$b).chars';

is $toRaku->test_transform( $package, 'length ( $a )' ),
   '( $a ).chars';

is $toRaku->test_transform( $package, 'length($a)' ),
   '($a).chars';

is $toRaku->test_transform( $package, '1/=1' ),
   '1/=1';

done_testing;
