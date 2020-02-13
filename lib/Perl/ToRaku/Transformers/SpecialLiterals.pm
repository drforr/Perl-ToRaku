package Perl::ToRaku::Transformers::SpecialLiterals;

use strict;
use warnings;

# '__END__' => '=finish'
# '__FILE__' => '$?FILE'
# '__LINE__' => '$?LINE'
# '__PACKAGE__' => '$?PACKAGE'
#
sub short_description {
  <<'_EOS_';
Change Perl-style '__END__' literals to Raku style.
_EOS_
}
sub is_core { 1 }
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  my %map = (
    '__END__'     => '=finish',
    '__FILE__'    => '$?FILE',
    '__LINE__'    => '$?LINE',
    '__PACKAGE__' => '$?PACKAGE',
  );

  my $token_separators = $ppi->find( 'PPI::Token::Separator' );
  if ( $token_separators ) {
    for my $token_separator ( @{ $token_separators } ) {
      next unless exists $map{ $token_separator->content };

      $token_separator->set_content( $map{ $token_separator->content } );
    }
  }

  my $token_ends = $ppi->find( 'PPI::Token::End' );
  if ( $token_ends ) {
    for my $token_end ( @{ $token_ends } ) {
      next unless exists $map{ $token_end->content };

      $token_end->set_content( $map{ $token_end->content } );
    }
  }

  my $token_words = $ppi->find( 'PPI::Token::Word' );
  if ( $token_words ) {
    for my $token_word ( @{ $token_words } ) {
      next unless exists $map{ $token_word->content };

      $token_word->set_content( $map{ $token_word->content } );
    }
  }
}

1;
