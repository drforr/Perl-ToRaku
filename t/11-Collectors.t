#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

my %collectors;
opendir my $lib_dir, 'lib/Perl/ToRaku/Collectors' or die $!;
%collectors = map { $_ => 1 }
              map { s{ \.pm $ }{}x; $_ }
              grep { $_ !~ m{ ^ \. }x }
              readdir $lib_dir;
closedir $lib_dir;

my %tests;
opendir my $test_dir, 't' or die $!;
%tests = map { $_ => 1 }
         map { s{ ^ C- }{}x; $_ }
         map { s{ \.t $ }{}x; $_ }
         grep { m{ ^ C- [A-Z][a-zA-Z0-9_]*\.t }x }
         readdir $test_dir;
closedir $test_dir;

is keys %collectors, keys %tests;

for my $collector ( sort keys %collectors ) {
  ok exists $tests{ $collector }, "$collector.pm has a test";
}

BEGIN {
  use Module::Pluggable
    sub_name    => 'core_collectors',
    search_path => 'Perl::ToRaku::Collectors',
    require     => 1;
}

for my $plugin ( core_collectors ) {
  my $plugin_name = $plugin;
  $plugin_name    =~ s{ ^ Perl::ToRaku::Collectors:: }{}x;

  ok $plugin->can( 'collector' ), "$plugin_name has collector()";
  ok $plugin->can( 'is_core' ),   "$plugin_name can tell you if it's core";
}

done_testing( (keys %collectors) * 3 + 1 );
