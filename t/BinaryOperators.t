#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Perl::ToRaku;

plan tests => 45;

my $package = 'Perl::ToRaku::Transformers::BinaryOperators';
my $toRaku  = Perl::ToRaku->new;

use_ok $package;

#    %q{'streamLen'} = length( $stream_data );    # stream length

is $toRaku->test_transform( $package, 'for ( $i = 0 ; $i < length( $password ) ; $i++ ) { }' ),
   'for ( $i = 0 ; $i < ( $password ).chars ; $i++ ) { }';

is $toRaku->test_transform( $package, 'for($i=0;$i<length($password);$i++){}' ),
   'for($i=0;$i<($password).chars;$i++){}';

is $toRaku->test_transform( $package, 'length ( $a . $b ) > 1' ),
   '( $a ~ $b ).chars > 1';

is $toRaku->test_transform( $package, 'length($a.$b)>1' ),
   '($a~$b).chars>1';

is $toRaku->test_transform( $package, 'length ( $a . $b )' ),
   '( $a ~ $b ).chars';

is $toRaku->test_transform( $package, 'length($a.$b)' ),
   '($a~$b).chars';

is $toRaku->test_transform( $package, 'length ( $a )' ),
   '( $a ).chars';

is $toRaku->test_transform( $package, 'length($a)' ),
   '($a).chars';

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
