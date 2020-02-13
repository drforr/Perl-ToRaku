package Perl::ToRaku::Collectors::IsPackage;

use strict;
use warnings;
use Carp qw(carp);

# 'package My::Name;' # Is the file a package?
#
sub is_core { 1 }
sub collector {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  my $package_statements = $ppi->find( 'PPI::Statement::Package' );
  if ( $package_statements ) {
    for my $package_statement ( @{ $package_statements } ) {
      $obj->{is_package} = {
        name => $package_statement->namespace
      };

      if ( $package_statement->version ) {
        $obj->{is_package}{version} = $package_statement->version;
      }
      else {
        my $variable_stmts = $ppi->find( 'PPI::Statement::Variable' );
        if ( $variable_stmts ) {
          for my $variable_stmt ( @{ $variable_stmts } ) {
            next unless $variable_stmt->type eq 'our';
            next unless grep { $_ eq '$VERSION' } $variable_stmt->variables;
          
            unless ( scalar( $variable_stmt->variables ) == 1 ) {
              carp "'our' statement has more than just '\$VERSION'";
            }
            $obj->{version} = $variable_stmt->find_first( 'PPI::Token::Quote' );
     
            last;
          }
        }
      }
      last;
    }
  }
}

1;
