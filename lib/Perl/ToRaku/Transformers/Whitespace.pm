package Perl::ToRaku::Transformers::Whitespace;

# 'my($x);' => 'my ($x);'
# 'if($i==0) {}' => 'if ($i==0) {}'
#
sub transformer {
  my $self = shift;
  my $ppi  = shift;

  my %word = map { $_ => 1 } (
    'if',
    'elsif',
    'unless',
    'for',
    'while',

    'my',
    'our',
    'local' # Perl only
  );

  for my $token ( @{ $ppi->find( 'PPI::Token::Word' ) } ) {
    next unless exists $word{ $token->content };
    next if $token->next_sibling->isa( 'PPI::Token::Whitespace' );

    my $new_token = PPI::Token::Whitespace->new( ' ' );
    $token->insert_after( $new_token );
  }
}

1;
