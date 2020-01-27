package Perl::ToRaku::Transformers::Utf8Pragma;

use strict;
use warnings;

# 'use utf8'                  => '' # Rare though, would be the last line.
# 'use utf8;'                 => ''
# 'use utf8 "vars";'          => ''
# 'use utf8 qw( vars refs );' => ''
#
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  my $include_stmts = $ppi->find( 'PPI::Statement::Include' );
  if ( $include_stmts ) {
    for my $include_stmt ( @{ $include_stmts } ) {
      next unless $include_stmt->type eq 'use';
      next unless $include_stmt->module eq 'utf8';

      $include_stmt->delete;
    }
  }
}

1;
