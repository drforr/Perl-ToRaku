package Perl::ToRaku::Transformers::XOperator;

use strict;
use warnings;

sub long_description {
  <<'_EOS_';
The special case where 'x' can create a list gets its own op in Raku.

This transformer doesn't remove the parens, just adds the needed 'x'.

1 x 2   ==> 1 x 2
(1) x 2 ==> (1) xx 2
_EOS_
}
sub short_description {
  <<'_EOS_';
Change Perl-style 'x' to 'xx' if you're doing the '(1) x 80' Perl "trick".
_EOS_
}
sub depends_upon { }
sub is_core { 1 }
sub transforms { 'PPI::Token::Operator' }
sub transform {
  my $self           = shift;
  my $operator_token = shift;

  return unless $operator_token->content eq 'x';
  return unless
    $operator_token->sprevious_sibling->isa( 'PPI::Structure::List' );

  my $new_content = 'xx';
  $operator_token->set_content( $new_content );
}

1;
