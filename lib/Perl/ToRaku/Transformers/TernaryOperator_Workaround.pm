package Perl::ToRaku::Transformers::TernaryOperator_Workaround;

use strict;
use warnings;

# XXX This may be solved by now...
# XXX There's a known case we have to solve somehow... just look for an undef
# XXX ( 0x00 == 0x00 ) ?? undef !! 1;
#                         ^
#                         |

# 'verExcel95 ? verBIFF5 : verBIFF8'
# =>
# 'verExcel95 ?? verBIFF5 !! verBIFF8' - PPI workaround
#
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  my $label_tokens = $ppi->find( 'PPI::Token::Label' );
  if ( $label_tokens ) {
    for my $label_token ( @{ $label_tokens } ) {
      next unless $label_token->content =~ m{ \s+ : $ }x;

      my $new_content = $label_token->content;
      $new_content =~ s{ : }{!!}x;
      $label_token->set_content( $new_content );
    }
  }
}

1;
