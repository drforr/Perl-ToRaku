package Perl::ToRaku::Transformers::HigherOrderCommas;

use strict;
use warnings;

sub long_description {
  <<'_EOS_';
Add a comma between the block and iteration variable of map{}, grep{}, sort{}.

map{ }  @foo ==> map{ },  @foo
grep{ } @foo ==> grep{ }, @foo
sort{ } @foo ==> sort{ }, @foo
_EOS_
}
sub short_description {
  <<'_EOS_';
Insert comma between 'map{}' and the variable.
_EOS_
}
sub depends_upon { }
sub is_core { 1 }
sub transforms { 'PPI::Token::Word' }
sub transform {
  my $self       = shift;
  my $word_token = shift;

  my %map = (
    'sort' => undef,
    'map'  => undef,
    'grep' => undef,
  );

  return unless exists $map{ $word_token->content };
  return unless $word_token->snext_sibling->isa( 'PPI::Structure::Block' );
  return if $word_token->snext_sibling->snext_sibling
                       ->isa( 'PPI::Token::Operator' ) and
            $word_token->snext_sibling->snext_sibling->content eq ',';

  my $block = $word_token->snext_sibling;
  my $new_comma = PPI::Token::Operator->new( ',' ); 
  $block->insert_after( $new_comma );
}

1;
