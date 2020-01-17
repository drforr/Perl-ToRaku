package Perl::ToRaku::Transformers::BitwiseOperators;

use strict;
use warnings;

# '1 & 3'
# =>
# '1 +& 3'
#
sub transformer {
  my $self = shift;
  my $ppi  = shift;

  my %map = (
    '&'  => '+&',
    '|'  => '+|',
    '^'  => '+^',
    '<<' => '+<',
    '>>' => '+>'
  );

  for my $operator ( @{ $ppi->find( 'PPI::Token::Operator' ) } ) {
    next unless exists $map{ $operator->content };

    my $new_operator = PPI::Token::Operator->new( $map{ $operator->content } );
    $operator->insert_before( $new_operator );
    $operator->delete;
  }
}

1;
