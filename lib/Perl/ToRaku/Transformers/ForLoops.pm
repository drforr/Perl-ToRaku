package Perl::ToRaku::Transformers::ForLoops;

use strict;
use warnings;

# 'for ( my $i = 0; $i < 10 ; $i++ ) { ... }'
# =>
# 'loop ( my $i = 0; $i < 10 ; $i++ ) { ... }' =>
# 'for my $x ( @y ) { ... }' # no change
#
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  my $word_tokens = $ppi->find( 'PPI::Token::Word' );
  if ( $word_tokens ) {
    OUTER:
    for my $word_token ( @{ $word_tokens } ) {
      next unless $word_token->content eq 'for';
      next unless $word_token->snext_sibling->isa( 'PPI::Structure::For' );

      my $has_semicolons = $self->_has_semicolons( $word_token->snext_sibling );
      next unless $has_semicolons;
    
      $word_token->set_content( 'loop' );
    }
  }
}

sub _has_semicolons {
  my $self = shift;
  my $node = shift;

  my $semicolons = $node->find( 'PPI::Token::Structure' );
  if ( $semicolons ) {
    for my $semicolon ( @{ $semicolons } ) {
      next unless $semicolon->content eq ';';
      return 1;
    }
  }

  return;
}

1;
