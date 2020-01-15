package Perl::ToRaku::Transformers::StrictPragma;

use PPI;

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

  for my $token ( @{ $ppi->find( 'PPI::Statement::Include' ) } ) {
    next unless $token->type eq 'use' or
                $token->type eq 'no';
    next unless $token->module eq 'strict';

    $token->delete;
  }
}

1;
