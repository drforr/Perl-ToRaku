package Perl::ToRaku::Transformers::TernaryOperator;

use strict;
use warnings;

# '1 ? 2 : 3'
# =>
# '1 ?? 2 !! 3'
#
sub is_core { 1 }
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  my %map = (
    '?'  => '??',
    ':'  => '!!'
  );

  my $operator_tokens = $ppi->find( 'PPI::Token::Operator' );
  if ( $operator_tokens  ) {
    for my $operator_token ( @{ $operator_tokens } ) {
      next unless exists $map{ $operator_token->content };

      my $new_content = $map{ $operator_token->content };
      $operator_token->set_content( $new_content );
    }
  }
}

1;
