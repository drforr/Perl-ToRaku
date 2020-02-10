package Perl::ToRaku::Transformers::RedundantModules;

use strict;
use warnings;

# 'use IO::Handle'                  => '' # Rare though, would be the last line.
# 'use IO::Handle;'                 => ''
# 'use IO::Handle "vars";'          => ''
# 'use IO::Handle qw( vars refs );' => ''
#
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
