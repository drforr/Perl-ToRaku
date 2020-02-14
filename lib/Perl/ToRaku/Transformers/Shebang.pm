package Perl::ToRaku::Transformers::Shebang;

use strict;
use warnings;

# '#!perl'              => '#!raku'
# '#!/usr/bin/perl'     => '#!/usr/bin/env raku'
# '#!/usr/bin/env perl' => '#!/usr/bin/env raku'
#
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
sub run_before { }
sub run_after { }
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
