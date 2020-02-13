package Perl::ToRaku::Transformers::Sigils;

use strict;
use warnings;

# %foo    --> %foo
# $foo{a} --> %foo{a} # Note it does not pointify braces.
# @foo    --> @foo
# $foo[1] --> @foo[1]
#
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

#    if ( $elem->isa('PPI::Token::ArrayIndex') ) {
#        my $content = $elem->content;
#
#        $content =~ s{\$#}{};
#
#        $elem->insert_before(
#            PPI::Token::Symbol->new('@' . $content)
#        );
#        $elem->insert_before(
#            PPI::Token::Symbol->new('.')
#        );
#        $elem->insert_before(
#            PPI::Token::Word->new('end')
#        );
#        $elem->delete;
#    }
#    else {
#        return if $elem->raw_type eq '@';
#        return if $elem->raw_type eq '%';
#    }
#}
#
#1;
