package Perl::ToRaku::Transformers::Undef;

use strict;
use warnings;

# 'undef;'                     => 'Nil;'
# '( $sWk & 32 ) ? undef : 3;' => '( $sWk & 32 ) ? Nil : 3;'
#
sub transformer {
  my $self = shift;
  my $ppi  = shift;

  my $words = $ppi->find( 'PPI::Token::Word' );
  if ( $words ) {
    for my $word ( @{ $words } ) {
      next unless $word->content eq 'undef';

      my $new_word = PPI::Token::Word->new( 'Nil' );
      $word->insert_before( $new_word );
      $word->delete;
    }
  }
}

1;
