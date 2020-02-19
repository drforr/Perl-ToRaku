package Perl::ToRaku::Transformers::RedundantPragmas;

use strict;
use warnings;

sub long_description {
  <<'_EOS_';
Just like RedundantModules, this removes pragmas that Raku either doesn't need
or has turned on all the time, like 'strict' and 'warnings'.

(it also removes all the qw() &c) And just like RedundantModules, it keeps the
newline intact. This design decision may change later on.

use 5.008    ==> ''
use utf8     ==> ''
use strict   ==> ''
no strict    ==> ''
use warnings ==> ''
no warnings  ==> ''
_EOS_
}
sub short_description {
  <<'_EOS_';
Remove redundant pragmas like 'strict', 'warning' and 'utf8'.
_EOS_
}
sub depends_upon { }
sub is_core { 1 }
sub transforms { 'PPI::Statement::Include' }
sub transform {
  my $self         = shift;
  my $include_stmt = shift;

  my %map = (
    'strict'   => undef,
    'utf8'     => undef,
    'warnings' => undef
  );

  return unless exists $map{ $include_stmt->module } or
                $include_stmt->version =~ m{ [1-9][0-9]* \. [0-9]+ }x;

  $include_stmt->delete;
}

1;
