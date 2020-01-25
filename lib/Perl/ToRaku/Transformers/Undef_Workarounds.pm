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

  my $labels = $ppi->find( 'PPI::Token::Label' );
  if ( $labels ) {
    for my $label ( @{ $labels } ) {
      next unless $label->content =~ / undef /x;
      next unless $label->sprevious_sibling->isa( 'PPI::Token::Operator' ) and
                  $label->sprevious_sibling->content eq '?';

      my $text = $label->content;
      $text =~ s{ undef }{Nil}x;
      my $new_word = PPI::Token::Word->new( $text );
      $label->insert_before( $new_word );
      $label->delete;
    }
  }
}

1;
