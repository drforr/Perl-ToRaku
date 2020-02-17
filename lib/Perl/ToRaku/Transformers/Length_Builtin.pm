package Perl::ToRaku::Transformers::Length_Builtin;

use strict;
use warnings;

# Finally got ordered tranforms working.
# However it seems to be revealing another problem, and that is that
# once the tree has been munged, certain things don't quite seem
# to work the way I want them to.
#
# Ultimately I think the solution is to pull the list out of PPI and
# put the content into a structure I can more easily walk over.
# I don't *really* need PPI to be present while I'm doing the editing,
# but finding things sure is easier...
#
# It'd be nice though to have a custom find() method...

# Some thing need to be fixed before the operators as a whole can
# be straightened out. It's easier to run these as a separate block
# before transforming the operators as a whole.
#

# For instance, if we made the 'new Foo(2)' => 'Foo(2).new' change
# separately to '$x.$y' => '$x~$y', then 'new Foo(2)' => 'Foo~new(2)'
# intead of what we expect.
#
# I may generalize this behavior if I can find a name for it.
#
# For now, let's just say that those transforms that add an operator,
# since they won't *necessarily* run before the operator changeover,
# need to be run as *part* of the operator changeover.
#

sub long_description {
  <<'_EOS_';
Change Perl length() builtin to Raku .chars style.

Note that we don't change the parentheses around the body because
who knows what's inside that expression?

length( $a ) => ( $a ).chars
_EOS_
}
sub short_description {
  <<'_EOS_';
Change Perl length() builtin to Raku method.
_EOS_
}
sub depends_upon { 'BinaryOperators' }
sub is_core { 1 }
sub transforms { 'PPI::Structure::List' }
sub transform {
  my $self           = shift;
  my $list_structure = shift;

  return unless $list_structure->sprevious_sibling;
  return unless $list_structure->sprevious_sibling->content eq 'length';

  my $new_chars = PPI::Token::Word->new( 'chars' );
  $list_structure->insert_after( $new_chars );

  my $new_dot = PPI::Token::Operator->new( '.' );
  $list_structure->insert_after( $new_dot );

  $list_structure->previous_sibling->delete;
  if ( $list_structure->previous_sibling and
       $list_structure->previous_sibling->isa( 'PPI::Token::Word' ) and
       $list_structure->previous_sibling->content eq 'length' ) {
    $list_structure->previous_sibling->remove;
  }
}

1;
