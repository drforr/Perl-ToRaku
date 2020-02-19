package Perl::ToRaku::Transformers::HashKeys;

use strict;
use warnings;

# q{$a{"foo"}} => q{$a{"foo"}};
#
# q{$a{'foo'}} => q{$a{'foo'}};
#
# q{$a{foo}} => q{$a{'foo'}}; # unless 'foo' is a constant...
#
sub long_description {
  <<'_EOS_';
Convert Perl bareword-style hash key to Raku quoted variety

$a{"foo"} ==> $a{"foo"}
$a{'foo'} ==> $a{'foo'}
$a{foo}   ==> $a{'foo'} # XXX should check for $a{+foo} which is a constant
_EOS_
}
sub short_description {
  <<'_EOS_';
Change Perl bareword '$a{foo}' hash key to Raku quoted style C<$a{'foo'}>.
_EOS_
}
sub depends_upon { }
sub is_core { 1 }
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  # This may *look* like a transitive loop, but it's not because it's all
  # happening at once.
  #
  my %map = (
    '.'   => '~',
    '.='  => '~=',
    '->'  => '.',
    'cmp' => 'leg',
    '=~'  => '~~',
    '!~'  => '!~~'
  );

  # Just in case, make sure the operator is a binary one.
  # I.E. it doesn't have a previous sibling.
  #
  my $subscript_structures = $ppi->find( 'PPI::Structure::Subscript' );
  if ( $subscript_structures  ) {
    for my $subscript_structure ( @{ $subscript_structures } ) {
      next unless $subscript_structure->start;
      next unless $subscript_structure->start->content eq '{';
      next unless $subscript_structure->content;
      next if $subscript_structure->content =~ m{ ^ \{ \s* ( ['"\$\@] | q [ ^ a-z ] ) }x;

# XXX A bit of asymmetry here... why doesn't first_element work?
# XXX Or is it just not arranged like I'd think?
      my $word = $subscript_structure->schild(0)->schild(0);
      my $new_word = q{'} . $word->content . q{'};
      $word->set_content( $new_word );
    }
  }

#  my $subscript_blocks = $ppi->find( 'PPI::Structure::Block' );
#  if ( $subscript_blocks  ) {
#    for my $subscript_block ( @{ $subscript_blocks } ) {
#      next unless $subscript_block->schild(0)->isa( 'PPI::Statement' );
#      next unless $subscript_block->schild(0)->schild(0)->isa( 'PPI::Structure::Subscript' );
#
#      my $word = $subscript_block->schild(0)->schild(0);
#      my $new_word = q{'} . $word->content . q{'};
#      $word->set_content( $new_word );
#    }
#  }
}

1;
