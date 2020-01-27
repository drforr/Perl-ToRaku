package Perl::ToRaku::Transformers::Shebang;

use strict;
use warnings;

# '#!perl'              => '#!raku'
# '#!/usr/bin/perl'     => '#!/usr/bin/env raku'
# '#!/usr/bin/env perl' => '#!/usr/bin/env raku'
#
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  my $comment_tokens = $ppi->find( 'PPI::Token::Comment' );
  if ( $comment_tokens ) {
    for my $comment_token ( @{ $comment_tokens } ) {
      next unless $comment_token->line;
      my $new_text = $comment_token->content;

      if ( $new_text =~ m{ ^ \# \! perl }x ) {
        $new_text = "#!raku\n";
      }
      elsif ( $new_text =~ m{ ^ \# \s* \! .+ env \s+ perl }x ) {
        $new_text = $comment_token->content;
        $new_text =~ s{ perl }{raku}x;
      }
      elsif ( $new_text =~ m{ ^ \# \s* \! .+ perl }x ) {
        $new_text =~ s{ perl }{env raku}x;
      }
      else {
        next;
      }

      my $new_comment = PPI::Token::Comment->new( $new_text );
      $comment_token->insert_before( $new_comment );
      $comment_token->delete;
    }
  }
}

1;
