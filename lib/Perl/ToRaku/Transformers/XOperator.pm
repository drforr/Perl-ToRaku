package Perl::ToRaku::Transformers::XOperator;

use strict;
use warnings;

# '1 x 2' # No change
#
# '(1) x 2'
# =>
# '(1) xx 2'
#
sub short_description {
  <<'_EOS_';
Change Perl-style 'x' to 'xx' if you're doing the '(1) x 80' Perl "trick".
_EOS_
}
sub is_core { 1 }
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  my $operator_tokens = $ppi->find( 'PPI::Token::Operator' );
  if ( $operator_tokens  ) {
    for my $operator_token ( @{ $operator_tokens } ) {
      next unless $operator_token->content eq 'x';
      next unless $operator_token->
                  sprevious_sibling->isa( 'PPI::Structure::List' );

      my $new_content = 'xx';
      $operator_token->set_content( $new_content );
    }
  }
}

1;
