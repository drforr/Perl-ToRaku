package Perl::ToRaku::Transformers::ArrayIndex;

use strict;
use warnings;

sub long_description {
  <<'_EOS_';
Change Perl '$#' array index to Raku '.elems' method.

$#x ==> @x.elems
_EOS_
}
sub short_description {
  <<'_EOS_';
Change Perl array index '$#' to its Raku equivalent
_EOS_
}
sub depends_upon { 'BinaryOperators' }
sub is_core { 1 }
sub transforms { 'PPI::Token::ArrayIndex' }
sub transform {
  my $self        = shift;
  my $array_index = shift;

  my $new_content = $array_index->content;
  $new_content =~ s{ ^ \$\# }{@}x;
  $array_index->set_content( $new_content );

  my $new_elems = PPI::Token::Word->new( 'elems' );
  $array_index->insert_after( $new_elems );

  my $new_dot = PPI::Token::Operator->new( '.' );
  $array_index->insert_after( $new_dot );
}

1;
