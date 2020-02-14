package Perl::ToRaku::Transformers::BitwiseOperators;

use strict;
use warnings;

sub long_description {
  <<'_EOS_';
Change Perl bitwise operators into Raku bitwise operators.

1 & 3 ==> 1 +& 3
1 | 3 ==> 1 +| 3
1 ^ 3 ==> 1 +^ 3

(and the ^= versions as well)
_EOS_
}
sub short_description {
  <<'_EOS_';
Change Perl bitwise operators like '&' into Raku '+&' style.
_EOS_
}
sub run_before { }
sub run_after { }
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
