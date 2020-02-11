package Perl::ToRaku::Transformers::BinaryOperators;

use strict;
use warnings;

# Some thing need to be fixed before the operators as a whole can
# be straightened out. It's easier to run these as a separate block
# before transforming the operators as a whole.
#

# For instance, if we made the 'new Foo(2)' => 'Foo(2).new' change
# separately to '$x.$y' => '$x~$y', then 'new Foo(2)' => 'Foo~new(2)'
# intead of what we expect.
#
# I may generalize this behavior if I can find a name for it.
#
# For now, let's just say that those transforms that add an operator,
# since they won't *necessarily* run before the operator changeover,
# need to be run as *part* of the operator changeover.
#

# '$#x' => '@x.elems'
# 'new Foo(2)' => 'Foo.new(2)'

# 'Foo->new(2)' => 'Foo.new(2)'
# '$x->$y' => '$x.$y' # And so on.
#
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  _fixup_array_index_as_deref_no_ws( $ppi );
  _fixup_array_index_as_deref( $ppi );
  _fixup_array_index( $ppi );
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

# Ah, '$#{...}' and '$# {...}' use Token::Cast and Token::Magic...
#
sub _fixup_array_index_as_deref {
  my $ppi = shift;

  my $cast_tokens = $ppi->find( 'PPI::Token::Magic' );
  if ( $cast_tokens ) {
    for my $cast_token ( @{ $cast_tokens } ) {
      next unless $cast_token->content eq '$#';

      my $new_content = '@';
      $cast_token->set_content( $new_content );

      my $new_elems = PPI::Token::Word->new( 'elems' );
      $cast_token->snext_sibling->insert_after( $new_elems );

      my $new_arrow = PPI::Token::Operator->new( '->' );
      $cast_token->snext_sibling->insert_after( $new_arrow );
    }
  }
}

sub _fixup_array_index_as_deref_no_ws {
  my $ppi = shift;

  my $cast_tokens = $ppi->find( 'PPI::Token::Cast' );
  if ( $cast_tokens ) {
    for my $cast_token ( @{ $cast_tokens } ) {
      next unless $cast_token->content eq '$#';

      my $new_content = '@';
      $cast_token->set_content( $new_content );

      my $new_elems = PPI::Token::Word->new( 'elems' );
      $cast_token->snext_sibling->insert_after( $new_elems );

      my $new_arrow = PPI::Token::Operator->new( '->' );
      $cast_token->snext_sibling->insert_after( $new_arrow );
    }
  }
}


sub _fixup_array_index {
  my $ppi = shift;

  my $array_indices = $ppi->find( 'PPI::Token::ArrayIndex' );
  if ( $array_indices ) {
    for my $array_index ( @{ $array_indices } ) {
      my $new_content = $array_index->content;
      $new_content =~ s{ ^ \$\# }{@}x;
      $array_index->set_content( $new_content );

      my $new_elems = PPI::Token::Word->new( 'elems' );
      $array_index->insert_after( $new_elems );

      my $new_arrow = PPI::Token::Operator->new( '->' );
      $array_index->insert_after( $new_arrow );
    }
  }
}

1;
