package Perl::ToRaku::Transformers::PackageDeclaration;

# 'package My::Name;' => 'unit class My::Name'
# 'package My::Name v1.2.3;' => 'unit class My::Name:ver<1.2.3>;'
#
sub transformer {
  my $self = shift;
  my $ppi  = shift;

  my $token;
  return unless $token = $ppi->find_first( 'PPI::Statement::Package' );
  my $version = $token->version;

  if ( $version ) {
    my $_token = $token->last_element;
    $version =~ s{ ^ v (.+) }{:ver<$1>}x;

    my $new_token = PPI::Token::Word->new( $version );
    $_token->previous_sibling->previous_sibling->delete;
    $_token->previous_sibling->delete;
    $_token->insert_before( $new_token );
  }

  $token = $token->first_element;
  my $new_token = PPI::Token::Word->new( 'class' );
  $token->insert_before( $new_token );
  $token->delete;

  my $_new_token = PPI::Token::Whitespace->new( ' ' );
  $new_token->insert_before( $_new_token );

  my $__new_token = PPI::Token::Word->new( 'unit' );
  $_new_token->insert_before( $__new_token );
}

1;
