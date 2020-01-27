package Perl::ToRaku::Transformers::HigherOrderCommas;

use strict;
use warnings;

# 'grep &bar,....' shouldn't be caught, but we test for it...

# 'map{ ... } @foo' => 'map{ ... }, @foo'
# 'grep{ ... } @foo' => 'grep{ ... }, @foo'
# 'sort{ ... } @foo' => 'sort{ ... }, @foo'
#
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  my $word_tokens = $ppi->find( 'PPI::Token::Word' );
  if ( $word_tokens ) {
    for my $word_token ( @{ $word_tokens } ) {
      next unless $word_token->content eq 'sort' or
                  $word_token->content eq 'map' or
                  $word_token->content eq 'grep';
      next unless $word_token->snext_sibling->isa( 'PPI::Structure::Block' );
      next if $word_token->snext_sibling->snext_sibling
                         ->isa( 'PPI::Token::Operator' ) and
              $word_token->snext_sibling->snext_sibling->content eq ',';

      my $block = $word_token->snext_sibling;
      my $new_comma = PPI::Token::Operator->new( ',' ); 
      $block->insert_after( $new_comma );
    }
  }
}

1;
