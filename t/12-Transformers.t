#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

plan tests => 2;

# Collect the names of the existing transformers for tests later.
#
my %transformers;
opendir my $lib_dir, 'lib/Perl/ToRaku/Transformers' or die $!;
%transformers = map { $_ => undef }
                map { s{ \.pm $ }{}x; $_ }
                grep { $_ !~ m{ ^ \. }x }
                grep { $_ =~ m{ \.pm $ }x }
                readdir $lib_dir;
closedir $lib_dir;

subtest 'All transformers have test files', sub {
  plan tests => 1 + scalar( keys %transformers );

  my %tests;
  opendir my $test_dir, 't' or die $!;
  %tests = map { $_ => undef }
           map { s{ \.t $ }{}x; $_ }
           grep { m{ ^ [A-Z][a-zA-Z0-9_]*\.t }x }
           readdir $test_dir;
  closedir $test_dir;

  is keys %transformers, keys %tests;

  for my $transformer ( sort keys %transformers ) {
    ok exists $tests{ $transformer }, "$transformer.pm has a test";
  }
};

BEGIN {
  use Module::Pluggable
    sub_name    => 'transformers',
    search_path => 'Perl::ToRaku::Transformers',
    require     => 1;
}

subtest 'All transformers have common methods', sub {
  plan tests => scalar( keys %transformers ) * 6;

  my @transformers = transformers;
  for my $plugin ( @transformers ) {
    my $plugin_name = $plugin;
    $plugin_name    =~ s{ ^ Perl::ToRaku::Transformers:: }{}x;

#    ok $plugin->can( 'transformer' ), "$plugin_name has transformer()";
    ok $plugin->can( 'is_core' ),     "$plugin_name can tell you if it's core";
    ok $plugin->can( 'short_description' ),
       "$plugin_name has a short description";
    ok length( $plugin->short_description() ) <= 80,
       "short description for $plugin_name is at most 80 glyphs";
    ok $plugin->can( 'long_description' ),
       "$plugin_name has a long description";
    ok $plugin->can( 'depends_upon' ), "$plugin_name has depends_upon()";

    ok( $plugin->can( 'transformer' ) or
       ( $plugin->can( 'transform' ) and
         $plugin->can( 'transforms' ) ),
       "$plugin_name either runs over the whole file or transforms one type" );
  }
};

done_testing;
