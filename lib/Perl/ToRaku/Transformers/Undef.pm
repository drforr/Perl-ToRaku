package Perl::ToRaku::Transformers::Undef;

use strict;
use warnings;

sub long_description {
  <<'_EOS_';
Raku uses Nil in place of Perl's 'undef', so change those.

undef;                     ==> Nil;
( $sWk & 32 ) ? undef : 3; ==> ( $sWk & 32 ) ? Nil : 3;
_EOS_
}
sub short_description {
  <<'_EOS_';
Change Perl-style 'undef' to Raku-style 'Nil'.
_EOS_
}
sub depends_upon { }
sub is_core { 1 }
sub transforms { 'PPI::Token::Word' }
sub transform {
  my $self       = shift;
  my $word_token = shift;

  return unless $word_token->content eq 'undef';

  my $new_content = 'Nil';
  $word_token->set_content( $new_content );
}

1;
