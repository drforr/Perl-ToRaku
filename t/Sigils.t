#!/usr/bin/perl

use strict;
use warnings;

use Perl::ToRaku;
use Test::More;

plan tests => 8;

my $package = 'Perl::ToRaku::Transformers::Sigils';
my $toRaku  = Perl::ToRaku->new;

use_ok $package;

subtest 'initialization', sub {
  is $toRaku->test_transform( $package, q{$a = '';} ),
     q{$a = '';};

  is $toRaku->test_transform( $package, q{@a = ();} ),
     q{@a = ();};

  is $toRaku->test_transform( $package, q{%a = ();} ),
     q{%a = ();};
};

subtest 'scalar assignment', sub {
  is $toRaku->test_transform( $package, q{$a = '';} ),
     q{$a = '';};

  is $toRaku->test_transform( $package, q{$a = [];} ),
     q{$a = [];};

  is $toRaku->test_transform( $package, q{$a = [ 0 ];} ),
     q{$a = [ 0 ];};

  is $toRaku->test_transform( $package, q{$a = [ 'a' ];} ),
     q{$a = [ 'a' ];};
};

subtest 'array assignment', sub {
  is $toRaku->test_transform( $package, q{$a [ 0 ] = 'a';} ),
     q{@a [ 0 ] = 'a';};

  is $toRaku->test_transform( $package, q{$a [ 0 ] = 'a' if 1;} ),
     q{@a [ 0 ] = 'a' if 1;};

  is $toRaku->test_transform( $package, q{$a [ 0 ] = 'a' and 1;} ),
     q{@a [ 0 ] = 'a' and 1;};

  is $toRaku->test_transform( $package, q{1 if $a [ 0 ] = 'a';} ),
     q{1 if @a [ 0 ] = 'a';};

  is $toRaku->test_transform( $package, q{1 and $a [ 0 ] = 'a';} ),
     q{1 and @a [ 0 ] = 'a';};
};

subtest 'hash assignment', sub {
  is $toRaku->test_transform( $package, q{$a { a } = 'a';} ),
     q{%a { a } = 'a';};

  is $toRaku->test_transform( $package, q{$a { 'a' } = 'a';} ),
     q{%a { 'a' } = 'a';};

  is $toRaku->test_transform( $package, q{$a { a } = 'a' if 1;} ),
     q{%a { a } = 'a' if 1;};

  is $toRaku->test_transform( $package, q{$a { 'a' } = 'a' if 1;} ),
     q{%a { 'a' } = 'a' if 1;};

  is $toRaku->test_transform( $package, q{$a { a } = 'a' and 1;} ),
     q{%a { a } = 'a' and 1;};

  is $toRaku->test_transform( $package, q{$a { 'a' } = 'a' and 1;} ),
     q{%a { 'a' } = 'a' and 1;};

  is $toRaku->test_transform( $package, q{1 if $a { a } = 'a';} ),
     q{1 if %a { a } = 'a';};

  is $toRaku->test_transform( $package, q{1 if $a { 'a' } = 'a';} ),
     q{1 if %a { 'a' } = 'a';};

  is $toRaku->test_transform( $package, q{1 and $a { a } = 'a';} ),
     q{1 and %a { a } = 'a';};

  is $toRaku->test_transform( $package, q{1 and $a { 'a' } = 'a';} ),
     q{1 and %a { 'a' } = 'a';};
};

# No changes here.
#
subtest 'reference assignment', sub {
  is $toRaku->test_transform( $package, q{$a -> [ 0 ] = '';} ),
     q{$a -> [ 0 ] = '';};

  is $toRaku->test_transform( $package, q{$a -> { a } = '';} ),
     q{$a -> { a } = '';};
};

subtest 'slice assignment', sub {
  is $toRaku->test_transform( $package, q{$a [ 0, 1 ] = ( 'a', 'b' );} ),
    q{@a [ 0, 1 ] = ( 'a', 'b' );};

  is $toRaku->test_transform( $package, q{$a { 'a', 'b' } = ( 'a', 'b' );} ),
    q{%a { 'a', 'b' } = ( 'a', 'b' );};

  is $toRaku->test_transform( $package, q{$a { qw(a b) } = ( 'a', 'b' );} ),
    q{%a { qw(a b) } = ( 'a', 'b' );};
};



# ## name: last index
# $#x = 1;
# if( $icom > $#Commands ){ }
# $Defined{$#Commands} = " #$expr";
# ##-->
# @x.end = 1;
# if( $icom > @Commands.end ){ }
# %Defined{@Commands.end} = " #$expr";







is $toRaku->test_transform( $package, '1 or 2' ), '1 or 2';

done_testing;
