#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

my %transformers;
opendir my $lib_dir, 'lib/Perl/ToRaku/Transformers' or die $!;
%transformers = map { $_ => 1 }
                map { s{ \.pm $ }{}x; $_ }
                grep { $_ !~ m{ ^ \. }x }
                readdir $lib_dir;
closedir $lib_dir;

my %tests;
opendir my $test_dir, 't' or die $!;
%tests = map { $_ => 1 }
         map { s{ \.t $ }{}x; $_ }
         grep { m{ ^ [A-Z][a-zA-Z0-9_]*\.t }x }
         readdir $test_dir;
closedir $test_dir;

is keys %transformers, keys %tests;

for my $transformer ( sort keys %transformers ) {
  ok exists $tests{ $transformer }, "$transformer.pm has a test";
}

BEGIN {
  use Module::Pluggable
    sub_name    => 'core_transformers',
    search_path => 'Perl::ToRaku::Transformers',
    require     => 1;
}

for my $plugin ( core_transformers ) {
  my $plugin_name = $plugin;
  $plugin_name    =~ s{ ^ Perl::ToRaku::Transformers:: }{}x;

  ok $plugin->can( 'transformer' ), "$plugin_name has transformer()";
  ok $plugin->can( 'is_core' ),     "$plugin_name can tell you if it's core";
}

done_testing( (keys %transformers) * 3 + 1 );
