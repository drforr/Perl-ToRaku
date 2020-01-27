package Perl::ToRaku::Transformers::TernaryOperator;

use strict;
use warnings;

# '1 ? 2 : 3'
# =>
# '1 ?? 2 !! 3'
#
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

      my $new_operator =
        PPI::Token::Operator->new( $map{ $operator_token->content } );
      $operator_token->insert_before( $new_operator );
      $operator_token->delete;
    }
  }
}

1;
