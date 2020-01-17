package Perl::ToRaku;

use strict;
use warnings;

use Carp qw(croak);

use File::Slurp;
use PPI;

BEGIN {
  my @core_modules = (
    'Perl::ToRaku::Transformers::Constant',
    'Perl::ToRaku::Transformers::Shebang',
    'Perl::ToRaku::Transformers::PackageDeclaration',
    'Perl::ToRaku::Transformers::StrictPragma',
    'Perl::ToRaku::Transformers::WarningsPragma',
    'Perl::ToRaku::Transformers::Utf8Pragma',
    'Perl::ToRaku::Transformers::CoreRakuModules',
    'Perl::ToRaku::Transformers::BitwiseOperators',
    'Perl::ToRaku::Transformers::Whitespace',
    'Perl::ToRaku::Transformers::VersionPragma',
    'Perl::ToRaku::Transformers::Undef',
    'Perl::ToRaku::Transformers::Undef_Workarounds'
  );
  use Module::Pluggable
    sub_name    => 'core_plugins',
    search_path => ['Perl::ToRaku::Transformers'],
    require     => 1,
    only        => \@core_modules;
  use Module::Pluggable
    sub_name    => 'user_plugins',
    search_path => ['Perl::ToRaku::TransformersX'],
    require     => 1;
}

# Argument to pass in:
#   --remove-redundant-parentheses-around-conditions
#   --remove-redundant-parentheses-around-expressions (superset of above)
#
#   --PAUSE-author='JGOFF' # To help populate 'unit class MyClass:auth<JGOFF>'
#
sub new {
  my ( $class, $filename ) = @_;
  my $content = read_file( $filename ); # Don't put in the hashref.
  my $ppi     = PPI::Document->new( $filename );

  # Collect $VERSION from 'our $VERSION = v1.2.3;' or
  #                       'our $VERSION = "0.1.2";
  # Collect $VERSION from 'package MyPackage v0.1.2' # PPI fails to do this

  return bless {
    content => $content,
    ppi     => $ppi
  }, $class;
}

# 'use overload' may cause an issue
#
sub transform {
  my ( $self ) = @_;
  my $ppi      = $self->{ppi};

  my $packages = $ppi->find( 'PPI::Statement::Package' );
  if ( $packages and @{ $packages } > 1 ) {
    die "Currently only one package per file is supported.\n";
  }

  for my $plugin ( $self->core_plugins ) {
    $plugin->transformer( $ppi );
  }
  #use YAML;die Dump($self->user_plugins);
}

# Note that subroutines may "fool" you into thinking they're methods.
# Look at ParseExcel.pm's _subStrWk "method".
# It has '$self' as the first argument.
# Actually it probably *is* because of how it's called, but not how a modern Perl
# author would think of it.
#
# Specifically _subStrWk( $oBook, substr( $sWk, 8 ) );
#sub _subStrWk {
#    my ( $self, $biff_data, $is_continue ) = @_;
#}

# 'sort { $a <=> $b } @list'
# =>
# 'sort { $^a <=> $^b }, @list'

# 'sub Name { my ( $x ) = @_; my $y = shift; ... }'
# =>
# 'sub Name( $x, $y ) { ... }'

# Does the package have a parent(s)?
#
# 'use base qw(...)'
# or
# 'use parent qw(...)'
# or
# 'our @ISA = qw(...)'

# 'if ( exists $error_strings{$parse_error} )'
# =>
# 'if ( %error_strings{$parse_error}:defined )'

# Does pack() exist?
#
# 'pack( "vVv", $value );'
# =>
# 'use experimental :pack;'
# '$value.pack( "vVv" );'


#    my $width = unpack 'v', $data;
#                    my ( undef, $cch ) = unpack 'vc', $self->{_buffer};
#                    substr( $self->{_buffer}, 2, 1 ) = pack( 'C', $cch | 0x01 );

# 'pack "vV", $value'
# =>
# '$value.pack( "vV" );'

# int( $x )
# =>
# Int( $x )

# '$x = $self->{Foo};'
# =>
# 'has $.Foo;'
# ...
# '$x = $.Foo;'

# '%x = $self->{Foo};'
# =>
# 'has %.Foo;'
# ...
# '%x = %.Foo;'

# '@x = $self->{Foo};'
# =>
# 'has @.Foo;'
# ...
# '@x = @.Foo;'

# '$self->{Foo}[0]'
# =>
# 'has @.Foo;'
# ...
# '@.Foo[0]'

# 'sub new { ... }'
# =>
# 'multi method new(...) { ... }'

# For packages, collect the name of the "functions" it declares.
# In a given method, look to see if it calls one of those function names.
# If so, the variable that calls it must be $self.

# ... Then the operators, I guess....

# Drop parens around if... operators.

# for... blocks &c
#
# for ( my $i = 0; $i < $x ; $i++ ) { ... }
# =>
# for ( 0 .. $x - 1 ) -> $i { ... }
# or
# for ^$x -> $i { ... }

# for ( my $i = $l ; $i < $h ; $i++ ) { ... }
# =>
# for ( $l .. $h - 1 ) -> $i { ... }

# length( $x )
# =>
# $x.chars # XXX or $x.bytes ?

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

1;
