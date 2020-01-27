package Perl::ToRaku::Transformers::StrictPragma;

use strict;
use warnings;

# 'use strict'                  => '' # Rare though, would be the last line.
# 'use strict;'                 => ''
# 'use strict "vars";'          => ''
# 'use strict qw( vars refs );' => ''
# 'no strict'                  => '' # Rare though, would be the last line.
# 'no strict;'                 => ''
# 'no strict "vars";'          => ''
# 'no strict qw( vars refs );' => ''
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
      next unless $include_stmt->module eq 'strict';

      $include_stmt->delete;
    }
  }
}

1;
