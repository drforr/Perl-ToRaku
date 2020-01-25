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

  my $includes = $ppi->find( 'PPI::Statement::Include' );
  if ( $includes ) {
    for my $include ( @{ $includes } ) {
      next unless $include->type eq 'use';
      next if $include->module;
      next unless $include->version =~ m{ [1-9][0-9]* \. [0-9]+ }x;

      $include->delete;
    }
  }
}

1;
