package Perl::ToRaku::Transformers::BitwiseOperators;

# '1 & 3'
# =>
# '1 +& 3'
#
sub transformer {
  my $self = shift;
  my $ppi  = shift;

  my %operator = (
    '&'  => '+&',
    '|'  => '+|',
    '^'  => '+^',
    '<<' => '+<',
    '>>' => '+>'
  );

  for my $token ( @{ $ppi->find( 'PPI::Token::Operator' ) } ) {
    next unless exists $operator{ $token->content };

    my $new_token = PPI::Token::Operator->new( $operator{ $token->content } );
    $token->insert_before( $new_token );
    $token->delete;
  }
}

1;
