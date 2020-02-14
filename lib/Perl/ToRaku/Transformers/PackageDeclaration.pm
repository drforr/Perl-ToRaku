package Perl::ToRaku::Transformers::PackageDeclaration;

use strict;
use warnings;

use Carp qw(carp);

# 'package My::Name;'                 => 'unit class My::Name'
# 'package My::Name v1.2.3;'          => 'unit class My::Name:ver<1.2.3>;'
# 'package My::Name; use base "foo";' => 'unit class My::Name is foo;'
#
sub long_description {
  <<'_EOS_';
Convert package declaration into Raku 'unit class'.

It also captures the version (if any) specified as C<our $VERSION> and any
superclasses with 'use base' or 'use parent'. It doesn't really need to do
this, but it uses information from the IsPackage collector in order to do its
job.

Since this particular translator can run at any time and remove the
evidence that there was a package here at all, it's best that other translators
rely on the IsPackage output if they need to know whether they're in a 
package or not. This translator also removes things such as the package version
and any parents it might have, so that's another reason to rely on IsPackage.
_EOS_
}
sub short_description {
  <<'_EOS_';
Change Perl package declaration (with version and parents) to Raku style.
_EOS_
}
sub run_before { }
sub run_after { }
sub is_core { 1 }
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  return unless defined( $obj->{is_package} );

  my $package_stmt    = $ppi->find_first( 'PPI::Statement::Package' );
  my @parent_packages = _get_parent_packages( $ppi );

  # This isn't hard once you visualize the process, but I'll do it in steps.
  #
  # First, add 'unit' before 'package'.
  # Then, add ' ' before 'package'.
  #
  # Add 'class' before 'package'.
  # Delete 'package', so it now reads 'unit' ' ' 'class' ...
  #
  my $package = $package_stmt->first_element;

  my $unit = PPI::Token::Word->new( 'unit' );
  $package->insert_before( $unit );
  my $ws = PPI::Token::Whitespace->new( ' ' );
  $package->insert_before( $ws );
  my $class = PPI::Token::Word->new( 'class' );
  $package->insert_before( $class );
  $package->delete;

  # If we have a version, save it and delete the token because we need to
  # reformat it a bit anyway.
  #
  my $version = $package_stmt->find_first( 'PPI::Token::Number::Version' );

  # 'package My::Package v1.2.3;'
  #
  if ( $version and $version->content ) {
    my $version_text = $version->content;
    my $semicolon = $package_stmt->last_element;
    $semicolon->previous_sibling->delete; # 'v1.2.3'
    $semicolon->previous_sibling->delete; # ' '

    $version_text =~ s{ ^ v (.+) }{:ver<$1>}x;
    my $new_version = PPI::Token::Word->new( $version_text );
    $semicolon->insert_before( $new_version );
  }

  # 'package My::Package;'
  # 'our $VERSION = '1.2.3';'
  #
  else {
    my $variable_stmts = $ppi->find( 'PPI::Statement::Variable' );
    if ( $variable_stmts ) {
      for my $variable_stmt ( @{ $variable_stmts } ) {
        next unless $variable_stmt->type eq 'our';
        next unless grep { $_ eq '$VERSION' } $variable_stmt->variables;
      
        unless ( scalar( $variable_stmt->variables ) == 1 ) {
          carp "'our' statement has more than just '\$VERSION'";
        }
        $version = $variable_stmt->find_first( 'PPI::Token::Quote' );
        my $version_text = $version->string;
        $variable_stmt->delete;

        my $semicolon = $package_stmt->last_element;
    
        $version_text = ":ver<$version_text>";
        my $new_version = PPI::Token::Word->new( $version_text );
        $semicolon->insert_before( $new_version );
        last;
      }
    }
  }

  if ( @parent_packages ) {
    my $package_stmt = $ppi->find_first( 'PPI::Statement::Package' );
    my $semicolon = $package_stmt->last_element;

    my $new_ws = PPI::Token::Whitespace->new( ' ' );
    my $new_is = PPI::Token::Word->new( 'is' );
    my $new_ws_2 = PPI::Token::Whitespace->new( ' ' );
    my $new_name = PPI::Token::Word->new( $parent_packages[0] ); # XXX

    $semicolon->insert_before( $new_ws );
    $semicolon->insert_before( $new_is );
    $semicolon->insert_before( $new_ws_2 );
    $semicolon->insert_before( $new_name );
  }
}

# Handle the variety of arguments that can follow 'use base' and 'use parent'.
# 
sub __get_parent_packages {
  my $token = shift;
  my @package;

  if ( my $quoted_tokens = $token->find( 'PPI::Token::Quote' ) ) {
    for my $quoted_token ( @{ $quoted_tokens } ) {
      push @package, $quoted_token->string;
    }
  }
  elsif ( my $quotelike_words = $token->find_first( 'PPI::Token::QuoteLike::Words' ) ) {
      push @package, $quotelike_words->literal;
  }
  return @package;
}

sub _get_parent_packages {
  my $ppi = shift;
  my @package;

  my $include_stmts = $ppi->find( 'PPI::Statement::Include' );
  if ( $include_stmts ) {
    for my $include_stmt ( @{ $include_stmts } ) {
      next unless $include_stmt->type eq 'use';
      next unless $include_stmt->module eq 'base' or
                  $include_stmt->module eq 'parent';
      push @package, __get_parent_packages( $include_stmt );
    }
  }

  remove_parent_package( $ppi );

  return @package;
}

sub remove_parent_package {
  my $ppi = shift;
  my @package;

  my $include_stmts = $ppi->find( 'PPI::Statement::Include' );
  if ( $include_stmts ) {
    for my $include_stmt ( @{ $include_stmts } ) {
      next unless $include_stmt->type eq 'use';
      next unless $include_stmt->module eq 'base' or
                  $include_stmt->module eq 'parent';

      $include_stmt->delete;
    }

    $include_stmts = $ppi->find( 'PPI::Statement::Variable' );
    for my $include_stmt ( @{ $include_stmts } ) {
      next unless $include_stmt->type eq 'our';
      next unless grep { $_ eq '@ISA' } $include_stmt->variables;
      if ( $include_stmt->variables > 1 ) {
        warn 'Parent package @ISA is more complex than I can deal with ATM';
        return;
      }

      $include_stmt->delete;
    }
  }
}

1;
