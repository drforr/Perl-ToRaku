package Perl::ToRaku::Transformers::HigherOrderCommas;

use strict;
use warnings;

sub long_description {
  <<'_EOS_';
Add a comma between the block and iteration variable of map{}, grep{}, sort{}.

map{ }  @foo ==> map{ },  @foo
grep{ } @foo ==> grep{ }, @foo
sort{ } @foo ==> sort{ }, @foo
_EOS_
}
sub short_description {
  <<'_EOS_';
Insert comma between 'map{}' and the variable.
_EOS_
}
sub run_before { }
sub run_after { }
sub is_core { 1 }
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
