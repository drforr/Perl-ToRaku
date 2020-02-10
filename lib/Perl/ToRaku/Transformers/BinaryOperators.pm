package Perl::ToRaku::Transformers::BinaryOperators;

use strict;
use warnings;

# 'new Foo(2)' => 'Foo.new(2)'
# 'Foo->new(2)' => 'Foo.new(2)'
# '$x->$y' => '$x.$y' # And so on.
#
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  _fixup_new( $ppi );

  # This may *look* like a transitive loop, but it's not because it's all
  # happening at once.
  #
  my %map = (
    '.'   => '~',
    '.='  => '~=',
    '->'  => '.',
    'cmp' => 'leg',
    '=~'  => '~~',
    '!~'  => '!~~'
  );

  # Just in case, make sure the operator is a binary one.
  # I.E. it doesn't have a previous sibling.
  #
  my $operator_tokens = $ppi->find( 'PPI::Token::Operator' );
  if ( $operator_tokens  ) {
    for my $operator_token ( @{ $operator_tokens } ) {
      next unless exists $map{ $operator_token->content };

      my $new_content = $map{ $operator_token->content };
      $operator_token->set_content( $new_content );
    }
  }
}

sub _fixup_new {
  my $ppi = shift;

  my $statements = $ppi->find( 'PPI::Statement' );
  if ( $statements ) {
    for my $statement ( @{ $statements } ) {
      next unless $statement->first_element->content eq 'new';

      my $new_new = PPI::Token::Word->new( 'new' );
      $statement->first_element->snext_sibling->insert_after( $new_new );

      my $new_arrow = PPI::Token::Operator->new( '->' );
      $statement->first_element->snext_sibling->insert_after( $new_arrow );

      my $first_element = $statement->first_element;

      if ( $first_element->next_sibling->isa( 'PPI::Token::Whitespace' ) ) {
        $first_element->next_sibling->delete();
      }
      $first_element->delete();
    }
  }
}

1;
