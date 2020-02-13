package Perl::ToRaku::Transformers::SubNew;

use strict;
use warnings;

# 'sub new { ... }' => multi method { ... }'
#
sub short_description {
  <<'_EOS_';
Change Perl 'new' subroutine to Raku-style 'multi method'.
_EOS_
}
sub is_core { 1 }
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  return unless defined( $obj->{is_package} );

  my $sub_stmts = $ppi->find( 'PPI::Statement::Sub' );
  if ( $sub_stmts ) {
    for my $sub_stmt ( @{ $sub_stmts } ) {
      next unless $sub_stmt->name eq 'new';

      $sub_stmt->first_element->set_content( 'multi method' );
    }
  }
}

1;
