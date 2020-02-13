package Perl::ToRaku::Transformers::Shebang;

use strict;
use warnings;

# '#!perl'              => '#!raku'
# '#!/usr/bin/perl'     => '#!/usr/bin/env raku'
# '#!/usr/bin/env perl' => '#!/usr/bin/env raku'
#
sub is_core { 1 }
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  my $comment_tokens = $ppi->find( 'PPI::Token::Comment' );
  if ( $comment_tokens ) {
    for my $comment_token ( @{ $comment_tokens } ) {
      next unless $comment_token->line;
      my $new_content = $comment_token->content;

      if ( $new_content =~ m{ ^ \# \! perl }x ) {
        $new_content = "#!raku\n";
      }
      elsif ( $new_content =~ m{ ^ \# \s* \! .+ env \s+ perl }x ) {
        $new_content = $comment_token->content;
        $new_content =~ s{ perl }{raku}x;
      }
      elsif ( $new_content =~ m{ ^ \# \s* \! .+ perl }x ) {
        $new_content =~ s{ perl }{env raku}x;
      }
      else {
        next;
      }

      $comment_token->set_content( $new_content );
    }
  }
}

1;
