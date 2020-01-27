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

done_testing;
