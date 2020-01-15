package Perl::ToRaku::Transformers::Constant;

use PPI;

# 'use constant FOO => 1;'
# =>
# 'constant FOO = 1;'
#
sub transformer {
  my $self = shift;
  my $ppi  = shift;

  for my $token ( @{ $ppi->find( 'PPI::Statement::Include' ) } ) {
    next unless $token->type eq 'use';
    next unless $token->module eq 'constant';

    my $operator = $token->find_first( 'PPI::Token::Operator' );
    my $new_token = PPI::Token::Operator->new( '=' );
    $operator->insert_before( $new_token );
    $operator->delete;

    my $_token = $token->first_token;
    $_token->delete;
    $_token = $token->first_token;
    $_token->delete;
  }
}

1;
