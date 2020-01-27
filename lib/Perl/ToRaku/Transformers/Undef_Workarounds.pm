package Perl::ToRaku::Transformers::Undef_Workarounds;

use strict;
use warnings;

# 'undef;'                     => 'Nil;'
# '( $sWk & 32 ) ? undef : 3;' => '( $sWk & 32 ) ? Nil : 3;' # XXX The workaround
#
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  my $label_tokens = $ppi->find( 'PPI::Token::Label' );
  if ( $label_tokens ) {
    for my $label_token ( @{ $label_tokens } ) {
      next unless $label_token->content =~ / undef /x;
      next unless $label_token->sprevious_sibling->isa( 'PPI::Token::Operator' ) and
                  $label_token->sprevious_sibling->content eq '?';

      my $text = $label_token->content;
      $text =~ s{ undef }{Nil}x;
      my $new_word = PPI::Token::Word->new( $text );
      $label_token->insert_before( $new_word );
      $label_token->delete;
    }
  }
}

1;
