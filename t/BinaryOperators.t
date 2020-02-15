#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Perl::ToRaku;

plan tests => 45-8;

my $package = 'Perl::ToRaku::Transformers::BinaryOperators';
my $toRaku  = Perl::ToRaku->new;

use_ok $package;

# Heavy sigh. $# {...} and $#{...} are respectively
# Token::Magic and Token::Cast objects.
#

# So they need to be tested independently.
#
is $toRaku->test_transform( $package, '$# { $a }' ),
   '@ { $a }.elems';

is $toRaku->test_transform( $package, '$#{$a}' ),
   '@{$a}.elems';

is $toRaku->test_transform( $package, '$#a' ),
   '@a.elems';

# XXX Maybe try to read surrounding code to figure out, later on?
#
is $toRaku->test_transform( $package, 'new Foo ( 2 )' ),
   'Foo.new ( 2 )';

is $toRaku->test_transform( $package, 'new Foo( 2 )' ),
   'Foo.new( 2 )';

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
