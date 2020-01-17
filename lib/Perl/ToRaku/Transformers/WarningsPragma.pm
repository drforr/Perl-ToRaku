package Perl::ToRaku::Transformers::WarningsPragma;

use strict;
use warnings;

# 'use warnings'                  => '' # Rare though, would be the last line.
# 'use warnings;'                 => ''
# 'use warnings "vars";'          => ''
# 'use warnings qw( vars refs );' => ''
# 'no warnings'                  => '' # Rare though, would be the last line.
# 'no warnings;'                 => ''
# 'no warnings "vars";'          => ''
# 'no warnings qw( vars refs );' => ''
#
sub transformer {
  my $self = shift;
  my $ppi  = shift;

  my $includes = $ppi->find( 'PPI::Statement::Include' );
  if ( $includes ) {
    for my $include ( @{ $includes } ) {
      next unless $include->type eq 'use' or
                  $include->type eq 'no';
      next unless $include->module eq 'warnings';

      $include->delete;
    }
  }
}

1;
