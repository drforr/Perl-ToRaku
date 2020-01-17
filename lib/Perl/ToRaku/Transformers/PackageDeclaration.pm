package Perl::ToRaku::Transformers::PackageDeclaration;

use strict;
use warnings;

use Carp qw(carp);

# 'package My::Name;' => 'unit class My::Name'
# 'package My::Name v1.2.3;' => 'unit class My::Name:ver<1.2.3>;'
#
sub transformer {
  my $self = shift;
  my $ppi  = shift;
  return unless $self->{is_package};

#  my $token   = $ppi->find_first( 'PPI::Statement::Package' );
#  my $version = $token->version;
#
#  if ( !$version ) {
#    my $version_tokens = $ppi->find( 'PPI::Statement::Variable' );
#    if ( $version_tokens ) {
#      for my $_token ( @{ $version_tokens } ) {
#        next unless $_token->type eq 'our';
#        next unless grep { $_ eq '$VERSION' } $_token->variables;
#        carp "'our' statement has more than just '$VERSION', not collecting version info" unless scalar( $_token->variables ) == 1;
#        $version = $_token->find_first( 'PPI::Token::Quote' )->string;
#        $_token->delete;
#        last;
#      }
#    }
#  }
#
#  # Insert first, then remove.
#  #
#  my $_token = $token->find( 'PPI::Token::Word' )
#
##  if ( $version ) {
##    my $_token = $token->last_element;
##    $version =~ s{ ^ v (.+) }{:ver<$1>}x;
##
##    my $new_token = PPI::Token::Word->new( $version );
###    $_token->previous_sibling->previous_sibling->delete;
###    $_token->previous_sibling->delete;
##    $_token->insert_before( $new_token );
##  }
##
##  $token = $token->first_element;
##  my $new_token = PPI::Token::Word->new( 'class' );
##  $token->insert_before( $new_token );
##  $token->delete;
##
##  my $_new_token = PPI::Token::Whitespace->new( ' ' );
##  $new_token->insert_before( $_new_token );
##
##  my $__new_token = PPI::Token::Word->new( 'unit' );
##  $_new_token->insert_before( $__new_token );
}

1;
