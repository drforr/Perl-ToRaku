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
  my $ppi  = shift;

  my $includes = $ppi->find( 'PPI::Statement::Include' );
  if ( $includes ) {
    for my $include ( @{ $includes } ) {
      next unless $include->type eq 'use';
      next unless $include->module eq 'utf8';

      $include->delete;
    }
  }
}

1;
