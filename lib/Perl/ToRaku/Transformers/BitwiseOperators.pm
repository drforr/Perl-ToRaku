package Perl::ToRaku::Transformers::BitwiseOperators;

use PPI;

# '1 & 3'
# =>
# '1 +& 3'
#
sub transformer {
  my $self = shift;
  my $ppi  = shift;
  my %operators = (
    '&' => '+&',
    '|' => '+|',
    '^' => '+^',
    '<<' => '+<',
    '>>' => '+>'
  );

  for my $token ( @{ $ppi->find( 'PPI::Token::Operator' ) } ) {
    next unless exists $operators{ $token->content };

    my $new_token = PPI::Token::Operator->new( $operators{ $token->content } );
    $token->insert_before( $new_token );
    $token->delete;
  }
}

1;
