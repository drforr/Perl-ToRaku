package Perl::ToRaku::Transformers::Whitespace;

use strict;
use warnings;

# 'my($x);' => 'my ($x);'
# 'if($i==0) {}' => 'if ($i==0) {}'
#
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

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

  my $word_tokens = $ppi->find( 'PPI::Token::Word' );
  if ( $word_tokens ) {
    for my $word_token ( @{ $word_tokens } ) {
      next unless exists $map{ $word_token->content };
      next if $word_token->next_sibling->isa( 'PPI::Token::Whitespace' );

      my $new_whitespace = PPI::Token::Whitespace->new( ' ' );
      $word_token->insert_after( $new_whitespace );
    }
  }
}

1;
