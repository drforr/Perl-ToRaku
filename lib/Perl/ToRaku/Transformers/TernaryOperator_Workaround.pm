package Perl::ToRaku::Transformers::TernaryOperator_Workaround;

use strict;
use warnings;

sub long_description {
  <<'_EOS_';
Handle an edge case in PPI where ': bareword' get treated as a label.

It should be treated as a colon of the ternary operator and a bareword, but
right now it doesn't. This should already be filed as a bug, but may not be.

verExcel95 ? verBIFF5 : verBIFF8 ==> verExcel95 ?? verBIFF5 !! verBIFF8
_EOS_
}
sub short_description {
  <<'_EOS_';
Fix a few PPI bugs with the ternary operator.
_EOS_
}
sub depends_upon { }
sub is_core { 1 }
sub transforms { 'PPI::Token::Label' }
sub transform {
  my $self        = shift;
  my $label_token = shift;

  return unless $label_token->content =~ m{ \s+ : $ }x;

  my $new_content = $label_token->content;
  $new_content =~ s{ : }{!!}x;
  $label_token->set_content( $new_content );
}

1;
