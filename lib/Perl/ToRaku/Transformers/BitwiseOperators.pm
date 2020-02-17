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
sub depends_upon { }
sub is_core { 1 }
sub transforms { 'PPI::Token::Operator' }
sub transform {
  my $self           = shift;
  my $operator_token = shift;

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
  return unless $operator_token->sprevious_sibling;
  return unless exists $map{ $operator_token->content };

  my $new_content = $map{ $operator_token->content };
  $operator_token->set_content( $new_content );
}

1;
