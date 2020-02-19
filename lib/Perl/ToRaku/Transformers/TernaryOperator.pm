package Perl::ToRaku::Transformers::TernaryOperator;

use strict;
use warnings;

sub long_description {
  <<'_EOS_';
Change Perl-style ternary expressions to Raku style.

1 ? 2 : 3 ==> 1 ?? 2 !! 3
_EOS_
}
sub short_description {
  <<'_EOS_';
Change the Perl ternary operator to Raku style.
_EOS_
}
sub depends_upon { }
sub is_core { 1 }
sub transforms { 'PPI::Token::Operator' }
sub transform {
  my $self           = shift;
  my $operator_token = shift;

  my %map = (
    '?'  => '??',
    ':'  => '!!'
  );

  return unless $map{ $operator_token->content };

  my $new_content = $map{ $operator_token->content };
  $operator_token->set_content( $new_content );
}

1;
