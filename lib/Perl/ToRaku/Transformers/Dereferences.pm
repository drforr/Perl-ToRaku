package Perl::ToRaku::Transformers::Dereferences;

use strict;
use warnings;

sub long_description {
  <<'_EOS_';
Convert Perl dereference "operator" into Raku dereference style.

${ $x } ==> $( $x )
@{ $x } ==> @( $x )
%{ $x } ==> %( $x )
_EOS_
}
sub short_description {
  <<'_EOS_';
Change Perl '${$x}' dereferences into Raku '$($x)' style.
_EOS_
}
sub depends_upon { }
sub is_core { 1 }
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  # Another asymmetry in PPI -
  #   in %{...} the % is a Cast, in @{...} the @ is an Operator.
  #
  my $cast_tokens = $ppi->find( 'PPI::Token::Cast' );
  if ( $cast_tokens ) {
    for my $cast_token ( @{ $cast_tokens } ) {
      next unless $cast_token->snext_sibling->isa( 'PPI::Structure::Block' );
      $cast_token->snext_sibling->start->set_content( '(' );
      $cast_token->snext_sibling->finish->set_content( ')' );
    }
  }

  my $operator_tokens = $ppi->find( 'PPI::Token::Operator' );
  if ( $operator_tokens ) {
    for my $operator_token ( @{ $operator_tokens } ) {
      next unless $operator_token->snext_sibling and
                  $operator_token->snext_sibling->isa( 'PPI::Structure::Block' );
      $operator_token->snext_sibling->start->set_content( '(' );
      $operator_token->snext_sibling->finish->set_content( ')' );
    }
  }
}

1;
