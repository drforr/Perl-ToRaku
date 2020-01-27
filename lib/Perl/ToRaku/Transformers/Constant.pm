package Perl::ToRaku::Transformers::Constant;

use strict;
use warnings;

# 'use constant FOO => 1;'
# =>
# 'constant FOO = 1;'
#
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  my $include_stmts = $ppi->find( 'PPI::Statement::Include' );
  if ( $include_stmts ) {
    for my $include_stmt ( @{ $include_stmts } ) {
      next unless $include_stmt->type eq 'use';
      next unless $include_stmt->module eq 'constant';

      my $fat_arrow = $include_stmt->find_first( 'PPI::Token::Operator' );
      next unless $fat_arrow;

      $include_stmt->first_token->delete; # Delete 'use'
      $include_stmt->first_token->delete; # Delete ' '

      my $equal = PPI::Token::Operator->new( '=' );
      $fat_arrow->insert_before( $equal );
      $fat_arrow->delete;
    }
  }
}

1;
