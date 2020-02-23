package Perl::ToRaku::Transformers::Attributes;

use strict;
use warnings;

sub long_description {
  <<'_EOS_';
Converts a Perl-style package to a Raku-style class.

Which means a lot of changes, unsurprisingly. 
Which means both changing from 'sub new' to 'method new', and because there's
already an existing 'method new' the Raku equivalent has to be
'multi method new'.

Depends upon BinaryOperators and PackageDeclaration so I don't have to rewrite
much.

sub new { ... } => multi method { ... }
...
_EOS_
}
sub short_description {
  <<'_EOS_';
Change Perl 'new' subroutine to Raku-style 'multi method'.
_EOS_
}
sub depends_upon { 'BinaryOperators', 'PackageDeclaration' }
sub is_core { 1 }
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  return unless defined( $obj->{is_package} );

  my $word_tokens = $ppi->find( 'PPI::Token::Word' );
  return unless $word_tokens; # Like that's going to happen...

  # XXX For now, just look for bless { ... }, $class.
  # XXX There is bless $self, $class; # then trace down $self...
  # XXX
  for my $word_token ( @{ $word_tokens } ) {
    next unless $word_token->content eq 'bless';
    next unless
       $word_token->snext_sibling->isa( 'PPI::Structure::Constructor' );

    my $block = $word_token->snext_sibling;
    my $expressions = $block->find( 'PPI::Statement::Expression' );
    next unless $expressions;
  }

  my $sub_stmts = $ppi->find( 'PPI::Statement::Sub' );
  return unless $sub_stmts;

  for my $sub_stmt ( @{ $sub_stmts } ) {
    $sub_stmt->first_element->set_content( 'method' );
    if ( $sub_stmt->name eq 'new' ) {
      my $new_whitespace = PPI::Token::Whitespace->new( ' ' );
      $sub_stmt->first_element->insert_before( $new_whitespace );
      my $new_multi = PPI::Token::Word->new( 'multi' );
      $sub_stmt->first_element->insert_before( $new_multi );
    }
  }
}

#
# "I think so, Brain, but what *would* Jane Fonda do with all that custard?"
#
# Where do attribute come from? Anything that manipulates the $self'ish
# hash reference in a method. (Yes, you in the back, I know about non-hash
# blessing, if *you* want to reimplement that, go right ahead.)
#
# How do we know that 'sub Blah' is a method?
#
# 1) $first_variable->{'hash key'}
# 2) $first_variable->function_call
# 3) known_method_name( $first_variable, ... )
#
# They're probably not a *sure* sign, but again, if someone else wants to
# do better detection, they're welcome to try.
#
# On the other hand, we can tell they're not if:
#
# 1) $first_variable += 100; # Or some other operator than hashref
# 2) this_subroutine_name( $something_other_than_first_variable, ... )

1;
