package Perl::ToRaku::Transformers::Undef_Workarounds;

use strict;
use warnings;

sub long_description {
  <<'_EOS_';
Workaround for a PPI bug - ': undef' is treated as a label even with '?'...

( $sWk & 32 ) ? undef : 3 ==> ( $sWk & 32 ) ? Nil : 3
_EOS_
}
sub short_description {
  <<'_EOS_';
Fix some PPI problems with the 'undef' keywords.
_EOS_
}
sub depends_upon { }
sub is_core { 1 }
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  my $label_tokens = $ppi->find( 'PPI::Token::Label' );
  if ( $label_tokens ) {
    for my $label_token ( @{ $label_tokens } ) {
      next unless $label_token->content =~ / undef /x;

      my $new_content = $label_token->content;
      $new_content =~ s{ undef }{Nil}x;
      $label_token->set_content( $new_content );
    }
  }
}

1;
