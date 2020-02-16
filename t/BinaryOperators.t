#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Perl::ToRaku;

plan tests => 32;

my $package = 'Perl::ToRaku::Transformers::BinaryOperators';
my $toRaku  = Perl::ToRaku->new;

use_ok $package;

is $toRaku->test_transform( $package, 'Foo -> new ( 2 )' ),
   'Foo . new ( 2 )';

is $toRaku->test_transform( $package, 'Foo->new( 2 )' ),
   'Foo.new( 2 )';

is $toRaku->test_transform( $package, 'Foo -> newt ( 2 )' ),
   'Foo . newt ( 2 )';

is $toRaku->test_transform( $package, 'Foo->newt( 2 )' ),
   'Foo.newt( 2 )';

is $toRaku->test_transform( $package, '$x -> $y' ),
   '$x . $y';

is $toRaku->test_transform( $package, '$x->$y' ),
   '$x.$y';

is $toRaku->test_transform( $package, '$x . $y' ),
   '$x ~ $y';

is $toRaku->test_transform( $package, '$x.$y' ),
   '$x~$y';

is $toRaku->test_transform( $package, '$x =~ $y' ),
   '$x ~~ $y';

is $toRaku->test_transform( $package, '$x=~$y' ),
   '$x~~$y';

is $toRaku->test_transform( $package, '$x !~ $y' ),
   '$x !~~ $y';

is $toRaku->test_transform( $package, '$x!~$y' ),
   '$x!~~$y';

is $toRaku->test_transform( $package, '$x .= $y' ),
   '$x ~= $y';

is $toRaku->test_transform( $package, '$x.=$y' ),
   '$x~=$y';

is $toRaku->test_transform( $package, '$x cmp $y' ),
   '$x leg $y';

is $toRaku->test_transform( $package, '1 + 1' ),
   '1 + 1';

is $toRaku->test_transform( $package, '1+1' ),
   '1+1';

is $toRaku->test_transform( $package, '1 += 1' ),
   '1 += 1';

is $toRaku->test_transform( $package, '1+=1' ),
   '1+=1';

is $toRaku->test_transform( $package, '1 - 1' ),
   '1 - 1';

is $toRaku->test_transform( $package, '1-1' ),
   '1-1';

is $toRaku->test_transform( $package, '1 -= 1' ),
   '1 -= 1';

is $toRaku->test_transform( $package, '1-=1' ),
   '1-=1';

is $toRaku->test_transform( $package, '1 * 1' ),
   '1 * 1';

is $toRaku->test_transform( $package, '1*1' ),
   '1*1';

is $toRaku->test_transform( $package, '1 *= 1' ),
   '1 *= 1';

is $toRaku->test_transform( $package, '1*=1' ),
   '1*=1';

is $toRaku->test_transform( $package, '1 / 1' ),
   '1 / 1';

is $toRaku->test_transform( $package, '1/1' ),
   '1/1';

is $toRaku->test_transform( $package, '1 /= 1' ),
   '1 /= 1';

is $toRaku->test_transform( $package, '1/=1' ),
   '1/=1';

done_testing;
