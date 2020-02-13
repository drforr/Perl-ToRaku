package Perl::ToRaku::Collectors::IsPackage;

use strict;
use warnings;

# 'package My::Name;' # Is the file a package?
#
sub is_core { 1 }
sub collector {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  my $include_stmts = $ppi->find( 'PPI::Statement::Package' );
  if ( $include_stmts ) {
    if ( @{ $include_stmts } ) {
      $obj->{is_package} = 1;
    }
  }
}

1;
