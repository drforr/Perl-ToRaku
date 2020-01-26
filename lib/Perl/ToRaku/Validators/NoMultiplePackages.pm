package Perl::ToRaku::Validators::NoMultiplePackages;

use strict;
use warnings;

# 'package Foo' # Return 1 if we have no multiple packages
#
sub validator {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  my $include_stmts = $ppi->find( 'PPI::Statement::Package' );

  return "Currently only one package per file is supported." if
    $include_stmts and @{ $include_stmts } > 1;
}

1;
