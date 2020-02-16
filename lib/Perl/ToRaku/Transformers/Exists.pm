package Perl::ToRaku::Transformers::Exists;

use strict;
use warnings;

sub long_description {
  <<'_EOS_';
Change Perl 'exists' builtin to Raku adverb ':exists'

exists $q{a} ==> $q{a}:exists
_EOS_
}
sub short_description {
  <<'_EOS_';
Change Perl 'exists' builtin to Raku adverb ':exists'.
_EOS_
}
sub depends_upon { }
sub is_core { 1 }
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  my $statements = $ppi->find( 'PPI::Statement' );
  if ( $statements ) {
    for my $statement ( @{ $statements } ) {
      my $word_tokens = $statement->find( 'PPI::Token::Word' );
      if ( $word_tokens ) {
        for my $word_token ( @{ $word_tokens } ) {
          next unless $word_token->content eq 'exists';

          my $new_exists = PPI::Token::Word->new( ':exists' );
          if ( $word_token->snext_sibling->snext_sibling->content eq '->' or
               $word_token->snext_sibling->snext_sibling->content eq '.' ) {
            $word_token->snext_sibling->snext_sibling->snext_sibling->insert_after( $new_exists );
         
          } else {
            $word_token->snext_sibling->snext_sibling->insert_after( $new_exists );
          }

          if ( $word_token->next_sibling->isa( 'PPI::Token::Whitespace' ) ) {
            $word_token->next_sibling->delete();
          }
          $word_token->delete();

          last;
        }
      }
    }
  }
}

1;
