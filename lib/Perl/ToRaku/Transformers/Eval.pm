package Perl::ToRaku::Transformers::Eval;

use strict;
use warnings;

sub long_description {
  <<'_EOS_';
Converts 'eval' to Raku 'EVAL()'. This may need outside help, will add later.

eval "foo" ==> EVAL "foo"
eval { foo() } ==> EVAL { foo() }
_EOS_
}
sub short_description {
  <<'_EOS_';
Converts 'eval' to Raku 'EVAL()'.
_EOS_
}
sub depends_upon { }
sub is_core { 1 }
sub transforms { 'PPI::Token::Word' }
sub transform {
  my $self       = shift;
  my $token_word = shift;

  my %map = (
    'eval' => 'EVAL',
  );

  return unless $map{ $token_word->content };

  $token_word->set_content( $map{ $token_word->content } );
}

1;
