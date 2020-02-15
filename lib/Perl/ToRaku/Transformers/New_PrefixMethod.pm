package Perl::ToRaku::Transformers::New_PrefixMethod;

use strict;
use warnings;

# Some thing need to be fixed before the operators as a whole can
# be straightened out. It's easier to run these as a separate block
# before transforming the operators as a whole.
#

sub long_description {
  <<'_EOS_';
Change Perl 'new' before package name to Raku style.

new Foo(2) ==> Foo.new(2)
_EOS_
}
sub short_description {
  <<'_EOS_';
Change Perl prefix 'new' to Raku OO position.
_EOS_
}
sub run_before { }
sub run_after { 'BinaryOperators' }
sub is_core { 1 }
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  my $statements = $ppi->find( 'PPI::Statement' );
  if ( $statements ) {
    for my $statement ( @{ $statements } ) {
      next unless $statement->first_element->content eq 'new';

      my $new_new = PPI::Token::Word->new( 'new' );
      $statement->first_element->snext_sibling->insert_after( $new_new );

      my $new_dot = PPI::Token::Operator->new( '.' );
      $statement->first_element->snext_sibling->insert_after( $new_dot );

      my $first_element = $statement->first_element;

      if ( $first_element->next_sibling->isa( 'PPI::Token::Whitespace' ) ) {
        $first_element->next_sibling->delete();
      }
      $first_element->delete();
    }
  }
}

1;
