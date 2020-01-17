package Perl::ToRaku::Transformers::Shebang;

use strict;
use warnings;

# '#!perl'              => '#!raku'
# '#!/usr/bin/perl'     => '#!/usr/bin/env raku'
# '#!/usr/bin/env perl' => '#!/usr/bin/env raku'
#
sub transformer {
  my $self = shift;
  my $ppi  = shift;

  my $comments = $ppi->find( 'PPI::Token::Comment' );
  if ( $comments ) {
    for my $comment ( @{ $comments } ) {
      next unless $comment->line;
      my $new_text = $comment->content;

      if ( $new_text =~ m{ ^ \# \! perl }x ) {
        $new_text = "#!raku\n";
      }
      elsif ( $new_text =~ m{ ^ \# \s* \! .+ env \s+ perl }x ) {
        $new_text = $comment->content;
        $new_text =~ s{ perl }{raku}x;
      }
      elsif ( $new_text =~ m{ ^ \# \s* \! .+ perl }x ) {
        $new_text =~ s{ perl }{env raku}x;
      }
      else {
        next;
      }

      my $new_comment = PPI::Token::Comment->new( $new_text );
      $comment->insert_before( $new_comment );
      $comment->delete;
    }
  }
}

1;
