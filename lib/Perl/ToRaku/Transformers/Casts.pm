package Perl::ToRaku::Transformers::Casts;

use strict;
use warnings;

sub long_description {
  <<'_EOS_';
Converts 'int()' "cast" to Raku 'Int()' "type cast".

int ( 1 / 3 ) ==> Int( 1 / 3 )
int( 1 / 3 ) ==> Int( 1 / 3 )
_EOS_
}
sub short_description {
  <<'_EOS_';
Change Perl 'int()' to Raku 'Int()' "cast" style.
_EOS_
}
sub run_before { }
sub run_after { }
sub is_core { 1 }
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
