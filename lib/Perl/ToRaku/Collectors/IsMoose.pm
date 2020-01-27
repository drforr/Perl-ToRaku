package Perl::ToRaku::Collectors::IsMoose;

use strict;
use warnings;

# 'use Moo;'         # Is this used? # Don't care about Metaprogramming
# 'use Moose;'       # Is this used?
# 'use Moose::Role;' # Is this used?
#
sub collector {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  my $include_stmts = $ppi->find( 'PPI::Statement::Include' );
  if ( $include_stmts and @{ $include_stmts } ) {
    for my $include_stmt ( @{ $include_stmts } ) {
      next unless $include_stmt->type eq 'use';
      next unless $include_stmt->module eq 'Moo' or
                  $include_stmt->module eq 'Mouse' or
                  $include_stmt->module eq 'Moose' or
                  $include_stmt->module eq 'Moose::Role';

      $obj->{is_moose} = 1;
      last;
    }
  }
}

1;
