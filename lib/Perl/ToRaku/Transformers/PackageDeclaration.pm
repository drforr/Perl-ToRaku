package Perl::ToRaku::Transformers::PackageDeclaration;

use PPI;

# 'package My::Name;'
# =>
# 'unit class My::Name;'
#
# XXX 'package My::Name v1.23;' fails because $token->version isn't there.
#
sub transformer {
  my $self = shift;
  my $ppi  = shift;
  if ( my $token = $ppi->find_first( 'PPI::Statement::Package' ) ) {
    my $version = $token->version;

    $token = $token->first_element;
    my $new_token = PPI::Token::Word->new( 'class' );
    $token->insert_before( $new_token );
    $token->delete;

    my $_new_token = PPI::Token::Whitespace->new( ' ' );
    $new_token->insert_before( $_new_token );

    my $__new_token = PPI::Token::Word->new( 'unit' );
    $_new_token->insert_before( $__new_token );
  }
}

1;
