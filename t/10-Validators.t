#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

my %validators;
opendir my $lib_dir, 'lib/Perl/ToRaku/Validators' or die $!;
%validators = map { $_ => 1 }
              map { s{ \.pm $ }{}x; $_ }
              grep { $_ !~ m{ ^ \. }x }
              readdir $lib_dir;
closedir $lib_dir;

my %tests;
opendir my $test_dir, 't' or die $!;
%tests = map { $_ => 1 }
         map { s{ ^ V- }{}x; $_ }
         map { s{ \.t $ }{}x; $_ }
         grep { m{ ^ V- [A-Z][a-zA-Z0-9_]*\.t }x }
         readdir $test_dir;
closedir $test_dir;

is keys %validators, keys %tests;

for my $validator ( sort keys %validators ) {
  ok exists $tests{ $validator }, "$validator.pm has a test";
}

done_testing;
