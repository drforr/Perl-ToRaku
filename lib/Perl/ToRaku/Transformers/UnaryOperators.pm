package Perl::ToRaku::Transformers::UnaryOperators;

use strict;
use warnings;

sub long_description {
  <<'_EOS_';
Convert unary modifiers from Perl to Raku style

Right now the rather rare '~$a' to do bitwise negation is the only thing that
gets changed, '-$a' and '!$a' *could* have alternatives, but those depend upon
knowing the type of the variable, which is impossible to tell statically.

~$a ==> +^$a
_EOS_
}
sub short_description {
  <<'_EOS_';
Change Perl unary operators like '~$a' to Raku-style '+^$a'.
_EOS_
}
sub depends_upon { }
sub is_core { 1 }
sub transforms { 'PPI::Token::Operator' }
sub transform {
  my $self           = shift;
  my $operator_token = shift;

  my %map = (
    '~' => '+^'
#    '!' => '?^',
  );

  # Just in case, make sure the operator is an unary one.
  # I.E. it doesn't have a previous sibling.
  #
  return if $operator_token->sprevious_sibling;
  return unless $map{ $operator_token->content };

  my $new_content = $map{ $operator_token->content };
  $operator_token->set_content( $new_content );
}

1;
