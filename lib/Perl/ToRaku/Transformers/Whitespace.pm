package Perl::ToRaku::Transformers::Whitespace;

use strict;
use warnings;

# 'print($x);'
# =>
# 'print ($x);'
#
# 'my($x);'
# =>
# 'my ($x);'
#
# 'if($i==0) {}'
# =>
# 'if ($i==0) {}'
#
sub is_core { 1 }
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  my %map = map { $_ => 1 } (
    'print',

    'if',
    'elsif',
    'unless',
    'given',
    'when',
    'while',
    'until',
    'for',
    'foreach',

#    'qw',

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

  my $quoted_word_tokens = $ppi->find( 'PPI::Token::QuoteLike::Words' );
  if ( $quoted_word_tokens ) {
    for my $quoted_word_token ( @{ $quoted_word_tokens } ) {
      next unless $quoted_word_token->content =~ m{ ^ qw \( }x; # \)

      my $new_content = $quoted_word_token->content;
      $new_content =~ s{ ^ qw }{qw }x;
      $quoted_word_token->set_content( $new_content );
    }
  }
}

1;
