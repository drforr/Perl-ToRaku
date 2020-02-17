package Perl::ToRaku::Transformers::Shebang;

use strict;
use warnings;

sub long_description {
  <<'_EOS_';
Replace the old shebang to invoke Perl with the new Raku shebang style.

XXX Someone please advise a proper shebang for Windows?

#!perl                ==> #!raku
#!/usr/bin/perl       ==> #!/usr/bin/env raku
#!/usr/sisin/env perl ==> #!/usr/bin/env raku
_EOS_
}
sub short_description {
  <<'_EOS_';
Rewrite Perl #! line into Raku style
_EOS_
}
sub depends_upon { }
sub is_core { 1 }
sub transforms { 'PPI::Token::Comment' }
sub transform {
  my $self          = shift;
  my $comment_token = shift;

  return unless $comment_token->line;
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
    return;
  }

  $comment_token->set_content( $new_content );
}

1;
