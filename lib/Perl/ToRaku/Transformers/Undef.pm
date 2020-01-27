package Perl::ToRaku::Transformers::Undef;

use strict;
use warnings;

# 'undef;'                     => 'Nil;'
# '( $sWk & 32 ) ? undef : 3;' => '( $sWk & 32 ) ? Nil : 3;'
#
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  my $word_tokens = $ppi->find( 'PPI::Token::Word' );
  if ( $word_tokens ) {
    for my $word_token ( @{ $word_tokens } ) {
      next unless $word_token->content eq 'undef';

      my $new_word = PPI::Token::Word->new( 'Nil' );
      $word_token->insert_before( $new_word );
      $word_token->delete;
    }
  }
}

1;
