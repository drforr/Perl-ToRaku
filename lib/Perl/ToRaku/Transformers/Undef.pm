package Perl::ToRaku::Transformers::Undef;

# 'undef;'                     => 'Nil;'
# '( $sWk & 32 ) ? undef : 3;' => '( $sWk & 32 ) ? Nil : 3;' # XXX Workaround this
#
sub transformer {
  my $self = shift;
  my $ppi  = shift;

  for my $token ( @{ $ppi->find( 'PPI::Token::Word' ) } ) {
    next unless $token->content eq 'undef';

    my $new_token = PPI::Token::Word->new( 'Nil' );
    $token->insert_before( $new_token );
    $token->delete;
  }
}

1;
