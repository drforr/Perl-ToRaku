package Perl::ToRaku::Transformers::Sigils;

use strict;
use warnings;

sub long_description {
  <<'_EOS_';
Change Perl sigils to Raku style.

Only affects the sigils themselves, changing the brace style to <> is done
in another transformer.

%foo    ==> %foo
$foo{a} ==> %foo{a}
@foo    ==> @foo
$foo[1] ==> @foo[1]
_EOS_
}
sub short_description {
  <<'_EOS_';
Change Perl sigil usage '$a[0]' to Raku-style '@a[0]'.
_EOS_
}
sub depends_upon { }
sub is_core { 1 }
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  my $array_indices = $ppi->find( 'PPI::Token::Symbol' );
  if ( $array_indices ) {
    for my $array_index ( @{ $array_indices } ) {
      if ( $array_index->snext_sibling and
           $array_index->snext_sibling->isa( 'PPI::Structure::Subscript' ) ) {
        if ( $array_index->snext_sibling->start->content eq '{' ) {
          my $new_content = $array_index->content;
          $new_content =~ s{ \$ }{\%}x;
          $array_index->set_content( $new_content );
        }
        elsif ( $array_index->snext_sibling->start->content eq '[' ) {
          my $new_content = $array_index->content;
          $new_content =~ s{ \$ }{\@}x;
          $array_index->set_content( $new_content );
        }
      }
    }
  }
}

1;
