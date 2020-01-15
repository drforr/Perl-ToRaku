#!/usr/bin/perl

use strict;
use warnings;

use List::Util qw(min max);
use File::Slurp;
use Test::More;
use Perl::ToRaku;

use constant CONTEXT_LINES => 3;

plan tests => 4;

sub get_context {
  my ( $context_line, $got_lines, $expected_lines ) = @_;
  my $min_line   = min( scalar @$got_lines, scalar @$expected_lines );
  my $start_line = max( $context_line - CONTEXT_LINES, 0 );
  my $end_line   = min( $context_line + CONTEXT_LINES, $min_line );
  my $result     = "Starts differing at line " . ( $context_line + 1 ) . "\n";

  for my $line ( $start_line .. $end_line ) {
    if ( $line == $context_line ) {
      $result .= '- ' . $expected_lines->[$line] . "\n";
      $result .= '+ ' . $got_lines->[$line] . "\n";
    }
    else {
      $result .= '  ' . $expected_lines->[$line] . "\n";
    }
  }
  return $result;
}

sub is_munged {
  my ( $perl_filename, $raku_filename ) = @_;

  my $toRaku = Perl::ToRaku->new( $perl_filename );
  $toRaku->transform;

  my $got_text  = $toRaku->{ppi}->serialize;
  my $raku_text = read_file( $raku_filename );

  return 1 if $got_text eq $raku_text;

  my @got_lines  = split( /\n/, $got_text  );
  my @raku_lines = split( /\n/, $raku_text );

  my $min_lines = min( scalar @got_lines, scalar @raku_lines );

  for my $line ( 0 .. $min_lines ) {
    next if $got_lines[$line] eq $raku_lines[$line];

    diag get_context( $line, \@got_lines, \@raku_lines );
    return 0;
  }
}

ok is_munged( 'corpus/ParseExcel.pm',
	      'corpus/ParseExcel.rk' ), 'ParseExcel';
ok is_munged( 'corpus/a_simple_parser.pl',
	      'corpus/a_simple_parser.rk' ), 'a_simple_parser';
ok is_munged( 'corpus/lwp-ssl-test.pl',
	      'corpus/lwp-ssl-test.rk' ), 'lwp-ssl-test';
ok is_munged( 'corpus/corogofer.pl',
	      'corpus/corogofer.rk' ), 'corogofer';

done_testing;
