package Perl::ToRaku::Transformers::Constant;

use strict;
use warnings;

# 'use constant FOO => 1;'
# =>
# 'constant FOO = 1;'
#
sub transformer {
  my $self = shift;
  my $ppi  = shift;

  my $includes = $ppi->find( 'PPI::Statement::Include' );
  if ( $includes ) {
    for my $include ( @{ $ppi->find( 'PPI::Statement::Include' ) } ) {
      next unless $include->type eq 'use';
      next unless $include->module eq 'constant';

      my $fat_arrow = $include->find_first( 'PPI::Token::Operator' );
      next unless $fat_arrow;

      $include->first_token->delete; # Delete 'use'
      $include->first_token->delete; # Delete ' '

      my $equal = PPI::Token::Operator->new( '=' );
      $fat_arrow->insert_before( $equal );
      $fat_arrow->delete;
    }
  }
}

1;
