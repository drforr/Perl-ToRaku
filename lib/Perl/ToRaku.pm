package Perl::ToRaku;

use strict;
use warnings;

use Carp qw(croak);

use File::Slurp;
use PPI;

BEGIN {
  my @core_validators = map { __PACKAGE__ . '::Validators::' . $_ } (
    'NoOverloadPragma',
    'NoMultiplePackages',
  );

  use Module::Pluggable
    sub_name    => 'core_validators',
    search_path => 'Perl::ToRaku::Validators',
    only        => \@core_validators,
    require     => 1;

  use Module::Pluggable
    sub_name    => 'optional_validators',
    search_path => 'Perl::ToRaku::Validators',
    except      => \@core_validators,
    require     => 1;

  use Module::Pluggable
    sub_name    => 'user_validators',
    search_path => 'Perl::ToRaku::ValidatorsX',
    require     => 1;

  my @core_collectors = map { __PACKAGE__ . '::Collectors::' . $_ } (
    'IsPackage',
    'IsMoose',
  );

  use Module::Pluggable
    sub_name    => 'core_collectors',
    search_path => 'Perl::ToRaku::Collectors',
    only        => \@core_collectors,
    require     => 1;

  use Module::Pluggable
    sub_name    => 'optional_collectors',
    search_path => 'Perl::ToRaku::Collectors',
    except      => \@core_collectors,
    require     => 1;

  use Module::Pluggable
    sub_name    => 'user_collectors',
    search_path => 'Perl::ToRaku::CollectorsX',
    require     => 1;

  my @core_transformers = map { __PACKAGE__ . '::Transformers::' . $_ } (
    'BitwiseOperators',
    'Casts',
    'Constant',
    'CoreRakuModules',
    'HigherOrderCommas',
    'PackageDeclaration',
    'Shebang',
    'SortVariables',
    'SpecialLiterals',
    'StrictPragma',
    'TernaryOperator',
    'TernaryOperator_Workaround',
    'Undef',
    'Undef_Workarounds',
    'Utf8Pragma',
    'VersionPragma',
    'WarningsPragma',
    'Whitespace',
  );

  use Module::Pluggable
    sub_name    => 'core_transformers',
    search_path => 'Perl::ToRaku::Transformers',
    only        => \@core_transformers,
    require     => 1;

  use Module::Pluggable
    sub_name    => 'optional_transformers',
    search_path => 'Perl::ToRaku::Transformers',
    except      => \@core_transformers,
    require     => 1;

  use Module::Pluggable
    sub_name    => 'user_transformers',
    search_path => 'Perl::ToRaku::TransformersX',
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
  my $self = {
    ppi => PPI::Document->new( $filename )
  };

  if ( ref( $filename ) ) {
    $self->{content} = $filename;
  }
  elsif ( $filename ) {
    $self->{filename} = $filename;
    $self->{content} = read_file( $filename );
  }

  return bless $self, $class;
}

sub _ppi {
  my ( $self ) = @_;
  my $ppi = $self->{ppi};

  return $ppi;
}

sub _validate {
  my ( $self ) = @_;
  my $ppi      = $self->{ppi};

  my @message;

  for my $plugin ( $self->core_validators ) {
    my $message = $plugin->validator( $self );
    push @message, $message if $message;
  }

  for my $plugin ( $self->optional_validators ) {
    my $message = $plugin->validator( $self );
    push @message, $message if $message;
  }

  for my $plugin ( $self->user_validators ) {
    my $message = $plugin->validator( $self );
    push @message, $message if $message;
  }

  croak( map { "$_\n" } @message ) if @message;
}

sub _collect {
  my ( $self ) = @_;
  my $ppi      = $self->{ppi};

  for my $plugin ( $self->core_collectors ) {
    $plugin->collector( $self );
  }

  for my $plugin ( $self->optional_collectors ) {
    $plugin->collector( $self );
  }

  for my $plugin ( $self->user_collectors ) {
    $plugin =~ m{ :: (.+) $ }x;
    $self->{$1} = $plugin->collector( $self );
  }
}

sub transform {
  my ( $self ) = @_;
  my $ppi      = $self->{ppi};

  my $validation = $self->_validate;
  if ( $validation ) {
    croak $validation;
  }

  $self->_collect;

  for my $plugin ( $self->core_transformers ) {
    $plugin->transformer( $self );
  }

  for my $plugin ( $self->optional_transformers ) {
    $plugin->transformer( $self );
  }

  for my $plugin ( $self->user_transformers ) {
    $plugin->transformer( $self );
  }
}

sub test_validate {
  my ( $self, $package, $text ) = @_;
  $self->{ppi} = PPI::Document->new( \$text );

  return $package->validator( $self );
}

sub test_collect {
  my ( $self, $package, $text ) = @_;
  $self->{ppi} = PPI::Document->new( \$text );

  $package->collector( $self );
}

sub test_transform {
  my ( $self, $package, $text ) = @_;
  $self->{ppi} = PPI::Document->new( \$text );

  $package->transformer( $self );
  $self->{ppi}->serialize;
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

# 'sub Name { my ( $x ) = @_; my $y = shift; ... }'
# =>
# 'sub Name( $x, $y ) { ... }'

# 'if ( exists $error_strings{$parse_error} )'
# =>
# 'if ( %error_strings{$parse_error}:defined )'

# Does pack() exist?
#
# 'pack( "vVv", $value );'
# =>
# 'use experimental :pack;'
# '$value.pack( "vVv" );'

# my $width = unpack 'v', $data;
#                 my ( undef, $cch ) = unpack 'vc', $self->{_buffer};
#                 substr( $self->{_buffer}, 2, 1 ) = pack( 'C', $cch | 0x01 );

# 'pack "vV", $value'
# =>
# '$value.pack( "vV" );'

# '$x = $self->{Foo};' => 'has $.Foo;' ... '$x = $.Foo;'

# '%x = $self->{Foo};' => 'has %.Foo;' ... '%x = %.Foo;'

# '@x = $self->{Foo};' => 'has @.Foo;' ... '@x = @.Foo;'

# '$self->{Foo}[0]' => 'has @.Foo;' ... '@.Foo[0]'

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

1;

=head1 NAME

Perl::ToRaku - Perl to Raku language converter

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    ...

=head1 DESCRIPTION

=head1 LAYOUT

This is meant to be all-plugins. For example, right now we don't handle more than one package in a file because of I/O concerns. I started out with a quick test at the start of C<transform()>, but quickly realized it's easy enough to turn that into a plugin which returns an error string if there's any problem.

So begins the mission to make sure everything is a plugin. I started out with the L<Perl::ToRaku::Transformers> namespace with what are the built-in transformers. If you want to add your own custom transformers, you can add them to the L<Perl::ToRaku::TransformersX> namespace.

=head2 Custom ValidatorsX packages

Suppose you're writing translators, and want to skip translating C<.xt> tests because they're usually very specific to an author's setup and may require a bunch of tools you don't have.

Writing a L<::ValidatorsX> package is exactly the right way to go, then. A Validator has access to the C<$self->{filename}> and C<$self->{ppi}> object, so you can check the C<$self->{filename}> and if it's in the C<xt/> directory you just need to return C<"Local rules don't allow xt/ files to be translated."> from your validator and you're done.

=head2 Writing your own Transformers

Let's explore some of the challenges by assuming you want to write a Transformer that only runs on packages, and needs to know the parent name of the existing Perl package. (And pretend that this isn't already saved.)

Ordinarily you'd simply search for a L<PPI::Statement::Include> that looks like 'use base qw(...)', but this poses a problem. The core Translators delete the existing Perl code, so while you could search for the Include statement, you wouldn't find it.

Which means, of course, it's impossible. NOT. More to the point, it's an excluse to:

=head2 Write your own Collector

Which is just a file in the L<::CollectorX::> namespace. I should point out that you're supposed to return the data structure you want to save. That way we can store it safely under your own package name, with no collisions.

=head1 AUTHOR

Jeff Goff, C<< <jgoff at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-perl-toraku at rt.cpan.org>, or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Perl-ToRaku>.  I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Perl::ToRaku

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Perl-ToRaku>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Perl-ToRaku>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Perl-ToRaku>

=item * Search CPAN

L<http://search.cpan.org/dist/Perl-ToRaku>

=back

=head1 ACKNOWLEDGEMENTS

Certainly a tip o' my top hat to Jeff Thalmer, author of Perl::Critic.

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Jeff Goff.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1; # End of Perl::ToRaku
