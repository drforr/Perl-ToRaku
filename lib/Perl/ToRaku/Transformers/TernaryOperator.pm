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

      my $new_content = $map{ $operator_token->content };
      $operator_token->set_content( $new_content );
    }
  }
}

1;
