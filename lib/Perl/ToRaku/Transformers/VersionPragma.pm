package Perl::ToRaku::Transformers::VersionPragma;

use strict;
use warnings;

# 'use 5.008'                  => '' # Rare though, would be the last line.
# 'use 5.008;'                 => ''
# 'use 5.008 "vars";'          => ''
# 'use 5.008 qw( vars refs );' => ''
#
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  my $include_stmts = $ppi->find( 'PPI::Statement::Include' );
  if ( $include_stmts ) {
    for my $include_stmt ( @{ $include_stmts } ) {
      next unless $include_stmt->type eq 'use';
      next if $include_stmt->module;
      next unless $include_stmt->version =~ m{ [1-9][0-9]* \. [0-9]+ }x;

      $include_stmt->delete;
    }
  }
}

1;
