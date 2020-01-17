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
  my $ppi  = shift;

  my $includes = $ppi->find( 'PPI::Statement::Include' );
  if ( $includes ) {
    for my $include ( @{ $includes } ) {
      next unless $include->type eq 'use' or
                  $include->type eq 'no';
      next unless $include->module eq 'strict';

      $include->delete;
    }
  }
}

1;
