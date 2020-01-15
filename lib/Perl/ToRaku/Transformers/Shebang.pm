package Perl::ToRaku::Transformers::Shebang;

use PPI;

# '#!perl'              => '#!raku'
# '#!/usr/bin/perl'     => '#!/usr/bin/env raku'
# '#!/usr/bin/env perl' => '#!/usr/bin/env raku'
#
sub transformer {
  my $self = shift;
  my $ppi  = shift;

  for my $token ( @{ $ppi->find( 'PPI::Token::Comment' ) } ) {
    next unless $token->line;
    my $new_text = $token->content;

    if ( $new_text eq "#!perl\n" ) {
      $new_text = "#!raku\n";
    }
    elsif ( $new_text =~ m{ ^ \# \s* \! .+ env \s+ perl }x ) {
      $new_text = $token->content;
      $new_text =~ s{ perl }{raku}x;
    }
    elsif ( $new_text =~ m{ ^ \# \s* \! .+ perl }x ) {
      $new_text =~ s{ perl }{env raku}x;
    }
    else {
	    next;
    }

    my $new_token = PPI::Token::Comment->new( $new_text );
    $token->insert_before( $new_token );
    $token->delete;
  }
}

1;
