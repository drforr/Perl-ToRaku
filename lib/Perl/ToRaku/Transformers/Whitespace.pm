package Perl::ToRaku::Transformers::Whitespace;

use strict;
use warnings;

sub long_description {
  <<'_EOS_';
Add some whitespace where Raku needs it for builtins.

print($x)    ==> print ($x) 
my($x)       ==> my ($x)
if($i==0) {} ==> if ($i==0) {}
q(foo bar)   ==> q (foo bar)
qq(foo bar)   ==> qq (foo bar)
qw(foo bar)   ==> qw (foo bar)
_EOS_
}
sub short_description {
  <<'_EOS_';
Add whitespace after 'print', 'if' etc. so Raku doesn't confuse with methods.
_EOS_
}
sub depends_upon { }
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

    'q',
    'qq',
    'qw',

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
      next unless $quoted_word_token->content =~ m{ ^ q[wq]? \( }x; # \)

      my $new_content = $quoted_word_token->content;
      $new_content =~ s{ ^ qw }{qw }x;
      $quoted_word_token->set_content( $new_content );
    }
  }

  my $quoted_tokens = $ppi->find( 'PPI::Token::Quote' );
  if ( $quoted_tokens ) {
    for my $quoted_token ( @{ $quoted_tokens } ) {
      next unless $quoted_token->content =~ m{ ^ q[wq]? \( }x; # \)

      my $new_content = $quoted_token->content;
      $new_content =~ s{ \( }{ \(}x;
      $quoted_token->set_content( $new_content );
    }
  }
}

1;
