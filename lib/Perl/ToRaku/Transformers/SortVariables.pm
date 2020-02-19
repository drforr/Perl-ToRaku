package Perl::ToRaku::Transformers::SortVariables;

use strict;
use warnings;

sub long_description {
  <<'_EOS_';
Change Perl's $a and $b variables to Raku special $^a and $^b.

sort{ $a cmp $b } ==> sort{ $^a cmp $^b }
_EOS_
}
sub short_description {
  <<'_EOS_';
Change Perl-style sort variables '$a', '$b' into Raku-style '$^a', '$^b'.
_EOS_
}
sub depends_upon { }
sub is_core { 1 }
sub transforms { 'PPI::Token::Word' }
sub transform {
  my $self       = shift;
  my $word_token = shift;

  return unless $word_token->content eq 'sort';
  return unless $word_token->snext_sibling->isa( 'PPI::Structure::Block' );

  my %map = (
    '$a' => '$^a',
    '$b' => '$^b',
  );

  my $block = $word_token->snext_sibling;
  my $symbol_tokens = $block->find( 'PPI::Token::Symbol' );
  return unless $symbol_tokens;

  for my $symbol_token ( @{ $symbol_tokens } ) {

    # XXX Perl only allows these for "scope" variables, Raku allows more.
    # XXX
    next unless $map{ $symbol_token->content };

    my $new_content = $map{ $symbol_token->content };
    $symbol_token->set_content( $new_content );
  }
}

1;
