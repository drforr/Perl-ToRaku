package Perl::ToRaku::Transformers::BitwiseOperators;

use strict;
use warnings;

# '1 & 3'
# =>
# '1 +& 3'
#
sub is_core { 1 }
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  my %map = (
    '&'  => '+&', '&=' => '+&=',
    '|'  => '+|', '|=' => '+|=',
    '^'  => '+^', '^=' => '+^=',

    '<<' => '+<', '<<=' => '+<=',
    '>>' => '+>', '>>=' => '+>='
  );

  # Just in case, make sure the operator is a binary one.
  # I.E. it has a previous sibling.
  #
  my $operator_tokens = $ppi->find( 'PPI::Token::Operator' );
  if ( $operator_tokens  ) {
    for my $operator_token ( @{ $operator_tokens } ) {
      next unless $operator_token->sprevious_sibling;
      next unless exists $map{ $operator_token->content };

      my $new_content = $map{ $operator_token->content };
      $operator_token->set_content( $new_content );
    }
  }
}

1;
