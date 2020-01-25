package Perl::ToRaku::Transformers::PackageDeclaration;

use strict;
use warnings;

use Carp qw(carp);

# 'package My::Name;' => 'unit class My::Name'
# 'package My::Name v1.2.3;' => 'unit class My::Name:ver<1.2.3>;'
#
sub transformer {
  my $self         = shift;
  my $obj          = shift;
  my $ppi          = $obj->_ppi;
  my $package_stmt = $ppi->find_first( 'PPI::Statement::Package' );

  return unless defined $package_stmt and $package_stmt;

  # This isn't hard once you visualize the process, but I'll do it in steps.
  #
  # First, add 'unit' before 'package'.
  # Then, add ' ' before 'package'.
  #
  # Add 'class' before 'package'.
  # Delete 'package', so it now reads 'unit' ' ' 'class' ...
  #
  my $package = $package_stmt->first_element;

  my $unit = PPI::Token::Word->new( 'unit' );
  $package->insert_before( $unit );
  my $ws = PPI::Token::Whitespace->new( ' ' );
  $package->insert_before( $ws );
  my $class = PPI::Token::Word->new( 'class' );
  $package->insert_before( $class );
  $package->delete;

  # If we have a version, save it and delete the token because we need to
  # reformat it a bit anyway.
  #
  my $version = $package_stmt->find_first( 'PPI::Token::Number::Version' );

  # 'package My::Package v1.2.3;'
  #
  if ( $version and $version->content ) {
    my $version_text = $version->content;
    my $semicolon = $package_stmt->last_element;
    $semicolon->previous_sibling->delete; # 'v1.2.3'
    $semicolon->previous_sibling->delete; # ' '

    $version_text =~ s{ ^ v (.+) }{:ver<$1>}x;
    my $new_version = PPI::Token::Word->new( $version_text );
    $semicolon->insert_before( $new_version );
  }

  # 'package My::Package;'
  # 'our $VERSION = '1.2.3';'
  #
  else {
    my $variable_stmts = $ppi->find( 'PPI::Statement::Variable' );
    if ( $variable_stmts ) {
      for my $variable ( @{ $variable_stmts } ) {
        next unless $variable->type eq 'our';
        next unless grep { $_ eq '$VERSION' } $variable->variables;
      
        unless ( scalar( $variable->variables ) == 1 ) {
          carp "'our' statement has more than just '\$VERSION'";
        }
        $version = $variable->find_first( 'PPI::Token::Quote' );
        my $version_text = $version->string;
        $variable->delete;

        my $semicolon = $package_stmt->last_element;
    
        $version_text = ":ver<$version_text>";
        my $new_version = PPI::Token::Word->new( $version_text );
        $semicolon->insert_before( $new_version );
        last;
      }
    }
  }
}

1;
