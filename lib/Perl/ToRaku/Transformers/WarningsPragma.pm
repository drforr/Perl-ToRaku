package Perl::ToRaku::Transformers::WarningsPragma;

use strict;
use warnings;

# 'use warnings'                  => '' # Rare though, would be the last line.
# 'use warnings;'                 => ''
# 'use warnings "vars";'          => ''
# 'use warnings qw( vars refs );' => ''
# 'no warnings'                   => '' # Rare though, would be the last line.
# 'no warnings;'                  => ''
# 'no warnings "vars";'           => ''
# 'no warnings qw( vars refs );'  => ''
#
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  my $include_stmts = $ppi->find( 'PPI::Statement::Include' );
  if ( $include_stmts ) {
    for my $include_stmt ( @{ $include_stmts } ) {
      next unless $include_stmt->type eq 'use' or
                  $include_stmt->type eq 'no';
      next unless $include_stmt->module eq 'warnings';

      $include_stmt->delete;
    }
  }
}

1;
