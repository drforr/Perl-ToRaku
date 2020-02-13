package Perl::ToRaku::Transformers::SortVariables;

use strict;
use warnings;

# 'sort{ $a cmp $b }' => 'sort{ $^a cmp $^b }'
#
sub is_core { 1 }
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  my $word_tokens = $ppi->find( 'PPI::Token::Word' );
  if ( $word_tokens ) {
    for my $word_token ( @{ $word_tokens } ) {
      next unless $word_token->content eq 'sort';
      next unless $word_token->snext_sibling->isa( 'PPI::Structure::Block' );

      my $block = $word_token->snext_sibling;
      my $symbol_tokens = $block->find( 'PPI::Token::Symbol' );
      if ( $symbol_tokens ) {
        for my $symbol_token ( @{ $symbol_tokens } ) {
          next unless $symbol_token->content eq '$a' or
                      $symbol_token->content eq '$b';
          my $new_content = $symbol_token->content;
          $new_content =~ s{ ^ \$ }{\$^}x;

          $symbol_token->set_content( $new_content );
        }
      }
    }
  }
}

1;
