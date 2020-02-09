package Perl::ToRaku::Transformers::UnaryOperators;

use strict;
use warnings;

# '~$a'
# =>
# '+^$a'
#
# '-$a'
# =>
# '-$a'
#
# '!$a' # XXX ONLY IF THE TRANSFORM IS REQUIRED BY THE USER...
# =>    # In most cases  ?^$a doesn't appear to be needed.
# '?^$a'
#
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  my %map = (
    '~' => '+^'
#    '!' => '?^',
  );

  # Just in case, make sure the operator is an unary one.
  # I.E. it doesn't have a previous sibling.
  #
  my $operator_tokens = $ppi->find( 'PPI::Token::Operator' );
  if ( $operator_tokens  ) {
    for my $operator_token ( @{ $operator_tokens } ) {
      next if $operator_token->sprevious_sibling;
      next unless exists $map{ $operator_token->content };

      my $new_content = $map{ $operator_token->content };
      $operator_token->set_content( $new_content );
    }
  }
}

1;
