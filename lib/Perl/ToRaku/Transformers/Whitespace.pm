package Perl::ToRaku::Transformers::Whitespace;

use strict;
use warnings;

# 'my($x);' => 'my ($x);'
# 'if($i==0) {}' => 'if ($i==0) {}'
#
sub transformer {
  my $self = shift;
  my $ppi  = shift;

  my %map = map { $_ => 1 } (
    'if',
    'elsif',
    'unless',
    'for',
    'while',

    'my',
    'our',
    'local' # Perl only
  );

  my $words = $ppi->find( 'PPI::Token::Word' );
  if ( $words ) {
    for my $word ( @{ $words } ) {
      next unless exists $map{ $word->content };
      next if $word->next_sibling->isa( 'PPI::Token::Whitespace' );

      my $new_whitespace = PPI::Token::Whitespace->new( ' ' );
      $word->insert_after( $new_whitespace );
    }
  }
}

1;
