package Perl::ToRaku::Validators::NoOverloadPragma;

use strict;
use warnings;

# 'use overload' # Return 1 if it uses overload pragma
#
sub is_core { 1 }
sub validator {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  my $include_stmts = $ppi->find( 'PPI::Statement::Include' );
  if ( $include_stmts ) {
    for my $include_stmt ( @{ $include_stmts } ) {
      next unless $include_stmt->type eq 'use';
      next unless $include_stmt->module eq 'overload';
 
      return "Currently we do not allow 'overload' pragma.";
    }
  }
}

1;
