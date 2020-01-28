package Perl::ToRaku::Transformers::Casts;

use strict;
use warnings;

# 'int (...)' => 'Int(...)'
# 'int(...)' => 'Int(...)'
#
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  my %map = (
    'int' => 'Int',
  );

  my $token_words = $ppi->find( 'PPI::Token::Word' );
  if ( $token_words ) {
    for my $token_word ( @{ $token_words } ) {
      next unless exists $map{ $token_word->content };

      $token_word->set_content( $map{ $token_word->content } );
      if ( $token_word->next_sibling->isa( 'PPI::Token::Whitespace' ) ) {
        $token_word->next_sibling->delete;
      }
    }
  }
}

1;
