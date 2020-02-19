package Perl::ToRaku::Transformers::BinaryOperators;

use strict;
use warnings;

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
Change Perl binary operators into Raku binary operators.

For instance, '$x->$y' changes to '$x.$y' in Raku, '$x.$y' in Perl changes
to '$x~$y' in Raku and so on. The changes are done all at once so there's
no danger of forming a "loop".

Foo->new(2) ==> Foo.new(2)
$x =~ m{}x  ==> $x ~~ m{}x
$x !~ m{}x  ==> $x !~~ m{}x
_EOS_
}
sub short_description {
  <<'_EOS_';
Change Perl binary operators like '->' and '.' into Raku '.' and '~' style.
_EOS_
}
sub depends_upon { }
sub is_core { 1 }
sub transforms { 'PPI::Token::Operator' }
sub transform {
  my $self           = shift;
  my $operator_token = shift;

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

  return unless $map{ $operator_token->content };

  my $new_content = $map{ $operator_token->content };
  $operator_token->set_content( $new_content );
}

1;
