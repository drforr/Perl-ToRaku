package Perl::ToRaku::Transformers::RedundantModules;

use strict;
use warnings;

sub long_description {
  <<'_EOS_';
Remove 'use' statements for Perl packages that are Raku builtins.

Note that it removes any qw()s that may be hanging around, but it won't remove
the newline. It looks odd but it keeps the code closer to 1:1 so that it's
easier to read when you're comparing side-by-side versions with scrollbind on.

use DateTime    ==> ''
use FatRat      ==> ''
use IO::File    ==> ''
use IO::Handle  ==> ''
use IO::Path    ==> ''
use IO::Socket  ==> ''
use Proc::Async ==> ''
_EOS_
}
sub short_description {
  <<'_EOS_';
Remove redundant module invocations like 'IO::Handle'.
_EOS_
}
sub run_before { }
sub run_after { }
sub is_core { 1 }
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  my %map = map { $_ => 1 } (
    'DateTime',
    'FatRat',
    'IO::File',
    'IO::Handle',
    'IO::Path',
    'IO::Socket',
    'Proc::Async'
  );

  my $include_stmts = $ppi->find( 'PPI::Statement::Include' );
  if ( $include_stmts ) {
    for my $include_stmt ( @{ $include_stmts } ) {
      next unless $include_stmt->type eq 'use';
      next unless exists $map{ $include_stmt->module };

      $include_stmt->delete;
    }
  }
}

1;
