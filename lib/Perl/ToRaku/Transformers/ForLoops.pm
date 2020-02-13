package Perl::ToRaku::Transformers::ForLoops;

use strict;
use warnings;

# 'foreach my $x ( @y ) { ... }' => 'for my $x ( @y ) { ... }'
#
# 'for ( my $i = 0; $i < 10 ; $i++ ) { ... }'
# =>
# 'loop ( my $i = 0; $i < 10 ; $i++ ) { ... }'
#
# 'for my $x ( @y ) { ... }' => no change
#
sub is_core { 1 }
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  my $compound_statements = $ppi->find( 'PPI::Statement::Compound' );
  if ( $compound_statements ) {
    for my $compound_statement ( @{ $compound_statements } ) {
      next unless $compound_statement->type eq 'foreach' or
                  $compound_statement->type eq 'for';

      if ( $compound_statement->find( 'PPI::Structure::For' ) ) {
        $compound_statement->first_element->set_content( 'loop' );
      }
      else {
        $compound_statement->first_element->set_content( 'for' );
      }
    }
  }
}

1;
