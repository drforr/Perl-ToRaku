package Perl::ToRaku;

use strict;
use warnings;

use Carp qw(croak);

use PPI;

sub _replace {
  my ( $token, $replacement ) = @_;

  $token->insert_before( $replacement );
  $token->delete;
}

sub mogrify {
  my ( $ppi ) = @_;

  mogrify_shebang( $ppi );

  remove_strict_pragma( $ppi );
  remove_warnings_pragma( $ppi );
  remove_utf8_pragma( $ppi );

  remove_core_raku_modules( $ppi );

  mogrify_numerical_operators( $ppi );

#  # 'sub Name { my ( $x ) = @_; my $y = shift; ... }'
#  # =>
#  # 'sub Name( $x, $y ) { ... }'
#
#  # 'package My::Name;'
#  # =>
#  # 'unit class My::Name;'
#
#  # Does the package have a parent(s)?
#  #
#  # 'use base qw(...)'
#  # or
#  # 'use parent qw(...)'
#  # or
#  # 'our @ISA = qw(...)'
#
#  # Does pack() exist?
#  #
#  # 'pack( "vVv", $value );'
#  # =>
#  # 'use experimental :pack;'
#  # '$value.pack( "vVv" );'
#
#  # 'pack "vV", $value'
#  # =>
#  # '$value.pack( "vV" );'
#
#  # 'use constant NAME => $value;'
#  # =>
#  # 'constant NAME = $value;'
#
#  # '$x = $self->{Foo};'
#  # =>
#  # 'has $.Foo;'
#  # ...
#  # '$x = $.Foo;'
#
#  # '%x = $self->{Foo};'
#  # =>
#  # 'has %.Foo;'
#  # ...
#  # '%x = %.Foo;'
#
#  # '@x = $self->{Foo};'
#  # =>
#  # 'has @.Foo;'
#  # ...
#  # '@x = @.Foo;'
#
#  # '$self->{Foo}[0]'
#  # =>
#  # 'has @.Foo;'
#  # ...
#  # '@.Foo[0]'
#
#  # 'sub new { ... }'
#  # =>
#  # 'multi method new(...) { ... }'
#
#  # For packages, collect the name of the "functions" it declares.
#  # In a given method, look to see if it calls one of those function names.
#  # If so, the variable that calls it must be $self.
#
#  # ... Then the operators, I guess....
#
#  # Drop parens around if... operators.
#
#  # for... blocks &c
#  #
#  # for ( my $i = 0; $i < $x ; $i++ ) { ... }
#  # =>
#  # for ( 0 .. $x - 1 ) -> $i { ... }
#  # or
#  # for ^$x -> $i { ... }
#
#  # for ( my $i = $l ; $i < $h ; $i++ ) { ... }
#  # =>
#  # for ( $l .. $h - 1 ) -> $i { ... }
#
#  # 'my( $x, $y );'
#  # =>
#  # 'my ( $x, $y );'
#
#  # 'if( $x ) { }'
#  # =>
#  # 'if ( $x ) { }'
#
#  # length( $x )
#  # =>
#  # $x.chars # XXX or $x.bytes ?
}

## 'package My::Name;' exists
##
#sub is_package {
#  my $ppi = shift;
#
#  return $ppi->find_first( 'PPI::Statement::Package' ) ? 1 : 0;
#}
#
## 'package My::Name;'
## ...
## 'package Other::Name;'
##
## Two or more packages exist
##
#sub has_multiple_packages {
#  my $ppi = shift;
#
#  my @names = $ppi->find( 'PPI::Statement::Package' );
#
#  return @names > 1 ? 1 : 0;
#}

# '#!perl'              => '#!raku'
# '#!/usr/bin/perl'     => '#!/usr/bin/env raku'
# '#!/usr/bin/env perl' => '#!/usr/bin/env raku'
#
sub mogrify_shebang {
  my $ppi = shift;
  for my $token ( @{ $ppi->find( 'PPI::Token::Comment' ) } ) {
    next unless $token->line;
    my $new_text = $token->content;

    if ( $new_text eq "#!perl\n" ) {
      $new_text = "#!raku\n";
    }
    elsif ( $new_text =~ m{ ^ \# \s* \! .+ env \s+ perl }x ) {
      $new_text = $token->content;
      $new_text =~ s{ perl }{raku}x;
    }
    elsif ( $new_text =~ m{ ^ \# \s* \! .+ perl }x ) {
      $new_text =~ s{ perl }{env raku}x;
    }
    else {
	    next;
    }

    my $new_token = PPI::Token::Comment->new( $new_text );
    _replace( $token, $new_token );
  }
}

# 'use strict'                  => '' # Rare though, would be the last line.
# 'use strict;'                 => ''
# 'use strict "vars";'          => ''
# 'use strict qw( vars refs );' => ''
#
sub remove_strict_pragma {
  my $ppi = shift;
  for my $token ( @{ $ppi->find( 'PPI::Statement::Include' ) } ) {
    next unless $token->type eq 'use';
    next unless $token->module eq 'strict';

    $token->delete;
  }
}

# 'use warnings'                  => '' # Rare though, would be the last line.
# 'use warnings;'                 => ''
# 'use warnings "vars";'          => ''
# 'use warnings qw( vars refs );' => ''
#
sub remove_warnings_pragma {
  my $ppi = shift;
  for my $token ( @{ $ppi->find( 'PPI::Statement::Include' ) } ) {
    next unless $token->type eq 'use';
    next unless $token->module eq 'warnings';

    $token->delete;
  }
}

# 'use utf8'                  => '' # Rare though, would be the last line.
# 'use utf8;'                 => ''
# 'use utf8 "vars";'          => ''
# 'use utf8 qw( vars refs );' => ''
#
sub remove_utf8_pragma {
  my $ppi = shift;
  for my $token ( @{ $ppi->find( 'PPI::Statement::Include' ) } ) {
    next unless $token->type eq 'use';
    next unless $token->module eq 'utf8';

    $token->delete;
  }
}

# 'use IO::Handle'                  => '' # Rare though, would be the last line.
# 'use IO::Handle;'                 => ''
# 'use IO::Handle "vars";'          => ''
# 'use IO::Handle qw( vars refs );' => ''
#
sub remove_core_raku_modules {
  my $ppi = shift;
  my %modules = map { $_ => 1 } (
    'DateTime',
    'FatRat',
    'IO::File',
    'IO::Handle',
    'IO::Path',
    'IO::Socket',
    'Proc::Async'
  );

  for my $token ( @{ $ppi->find( 'PPI::Statement::Include' ) } ) {
    next unless $token->type eq 'use';
    next unless exists $modules{ $token->module };

    $token->delete;
  }
}

# '1 & 3'
# =>
# '1 +& 3'
#
sub mogrify_numerical_operators {
  my $ppi = shift;
  my %operators = (
    '&' => '+&',
    '|' => '+|'
  );

  for my $token ( @{ $ppi->find( 'PPI::Token::Operator' ) } ) {
    next unless exists $operators{ $token->content };

    my $new_token = PPI::Token::Operator->new( $operators{ $token->content } );
    _replace( $token, $new_token );
  }
}


## Does the package have a parent(s)?
##
## 'use base qw(...)'
## or
## 'use parent qw(...)'
## or
## 'our @ISA = qw(...)'
##
#sub _has_parent_package {
#  my $ppi = shift;
#
#  my $tokens = $ppi->find( 'PPI::Statement::Include' );
#  return 1 if
#    grep { $_->type eq 'use' and
#	    ( $_->module eq 'base' or $_->module eq 'parent' ) } @{ $tokens };
#
#  $tokens = $ppi->find( 'PPI::Statement::Variable' );
#  return 1 if
#    grep { $_->type eq 'our' and
#           grep { $_ eq '@ISA' } $_->variables } @{ $tokens };
#
#  return 0;
#}
#
#sub __get_parent_packages {
#  my $token = shift;
#  my @package;
#
#  if ( my $tokens = $token->find( 'PPI::Token::Quote' ) ) {
#    for my $_token ( @{ $tokens } ) {
#      push @package, $_token->string;
#    }
#  }
#  elsif ( my $_tokens = $token->find( 'PPI::Token::QuoteLike::Words' ) ) {
#  }
#  return @package;
#}
#
#sub _get_parent_packages {
#  my $ppi = shift;
#  my @package;
#
#  my $tokens = $ppi->find( 'PPI::Statement::Include' );
#  for my $token ( @{ $tokens } ) {
#    next unless $token->type eq 'use';
#    next unless $token->module eq 'base' or
#                $token->module eq 'parent';
#    push @package, __get_parent_packages( $token );
#  }
#
#  return @package;
#}
#
#sub remove_parent_package {
#  my $ppi = shift;
#  my @package;
#
#  my $tokens = $ppi->find( 'PPI::Statement::Include' );
#  for my $token ( @{ $tokens } ) {
#    next unless $token->type eq 'use';
#    next unless $token->module eq 'base' or
#                $token->module eq 'parent';
#
#    $token->delete;
#  }
#
#  $tokens = $ppi->find( 'PPI::Statement::Variable' );
#  for my $token ( @{ $tokens } ) {
#    next unless $token->type eq 'our';
#    next unless grep { $_ eq '@ISA' } $token->variables;
#    if ( $token->variables > 1 ) {
#      warn 'Parent package @ISA is more complex than I can deal with ATM';
#      return;
#    }
#
#    $token->delete;
#  }
#}
#
#sub mogrify_package_declaration {
#  my $ppi = shift;
#  return unless _has_parent_package( $ppi );
#
#  my @parent = _get_parent_packages( $ppi );
#
#  my $token = $ppi->find_first( 'PPI::Statement::Package' );
#use YAML; die Dump($token);
#}

1;
