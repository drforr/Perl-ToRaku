package Perl::ToRaku::Transformers::BinaryOperators;

use strict;
use warnings;

sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  # This may *look* like a transitive loop, but it's not because it's all
  # happening at once.
  #
  my %map = (
    '.'   => '~',
    '.='  => '~=',
    '->'  => '.',
    'cmp' => 'leg',
  );

  # Just in case, make sure the operator is a binary one.
  # I.E. it doesn't have a previous sibling.
  #
  my $operator_tokens = $ppi->find( 'PPI::Token::Operator' );
  if ( $operator_tokens  ) {
    for my $operator_token ( @{ $operator_tokens } ) {
#      next unless $operator_token->sprevious_sibling;
      next unless exists $map{ $operator_token->content };

      my $new_content = $map{ $operator_token->content };
      $operator_token->set_content( $new_content );
    }
  }
}

1;
