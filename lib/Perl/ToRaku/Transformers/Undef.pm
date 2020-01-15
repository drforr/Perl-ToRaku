package Perl::ToRaku::Transformers::Undef;

use PPI;

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

  for my $token ( @{ $ppi->find( 'PPI::Token::Label' ) } ) {
    next unless $token->content =~ / undef /x;
    next unless $token->sprevious_sibling->isa( 'PPI::Token::Operator' ) and
                $token->sprevious_sibling->content eq '?';

    my $text = $token->content;
    $text =~ s{ undef }{Nil}x;
    my $new_token = PPI::Token::Word->new( $text );
    $token->insert_before( $new_token );
    $token->delete;
  }
}

1;
