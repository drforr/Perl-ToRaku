package Perl::ToRaku;

use strict;
use warnings;

use Carp qw(croak);

use File::Slurp;
use PPI;

use Module::Pluggable
  sub_name    => 'validators',
  search_path => 'Perl::ToRaku::Validators',
  require     => 1;

use Module::Pluggable
  sub_name    => 'user_validators',
  search_path => 'Perl::ToRaku::ValidatorsX',
  require     => 1;

use Module::Pluggable
  sub_name    => 'collectors',
  search_path => 'Perl::ToRaku::Collectors',
  require     => 1;

use Module::Pluggable
  sub_name    => 'user_collectors',
  search_path => 'Perl::ToRaku::CollectorsX',
  require     => 1;

use Module::Pluggable
  sub_name    => 'transformers',
  search_path => 'Perl::ToRaku::Transformers',
  require     => 1;

use Module::Pluggable
  sub_name    => 'user_transformers',
  search_path => 'Perl::ToRaku::TransformersX',
  require     => 1;

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

sub _topological_sort {
  my @plugins = @_;
  my @sorted_plugins;
  my %sorted_plugin_names;

  my %plugins;

  for my $plugin ( @plugins ) {
    my $plugin_name = $plugin;
    $plugin_name =~ s{ ^ Perl::ToRaku::Transformers:: }{}x;
    $plugins{$plugin_name} = {
      plugin       => $plugin,
      depends_upon => [ $plugin->depends_upon ]
    };
  }
# use YAML;die Dump(\%plugins);

  {
    my @remove_plugins;
    for my $name ( sort keys %plugins ) {
      next if @{ $plugins{$name}{depends_upon} };
      push @sorted_plugins, $plugins{$name}{plugin};
      push @remove_plugins, $name;
    }
    for my $name ( @remove_plugins ) {
      delete $plugins{$name};
    }
  }

  my $safety_catch = scalar keys %plugins;
  while ( keys %plugins ) {
    last if $safety_catch-- <= 0;
    my @remove_plugins;
    for my $name ( sort keys %plugins ) {
      my $missing = 0;
      for my $dependency ( @{ $plugins{$name}{depends_upon} } ) {
	next if grep { $dependency } @sorted_plugins;
	$missing = 1;
	last;
      }
      next if $missing;
      push @sorted_plugins, $plugins{$name}{plugin};
      push @remove_plugins, $name;
    }
    for my $name ( @remove_plugins ) {
      delete $plugins{$name};
    }
  }
  if ( $safety_catch <= 0 ) {
    die "Caught loop in plugins, this is bad.";
  }

# use YAML; die Dump(\@sorted_plugins);
# use YAML; warn Dump(\@sorted_plugins);

  if ( keys %plugins ) {
    die "Can't completely order the list of plugins given: conflicts below\n" .
        join( "\n", map { "  $_" } sort keys %plugins );
  }
  @sorted_plugins;
}

sub _validate {
  my ( $self ) = @_;
  my $ppi      = $self->{ppi};

  my @message;
  my @core_validators;
  my @optional_validators;

  for my $plugin ( $self->validators ) {
    if ( $plugin->is_core ) {
      push @core_validators, $plugin;
    }
    else {
      push @optional_validators, $plugin;
    }
  }

  for my $plugin ( @core_validators ) {
    my $message = $plugin->validator( $self );
    push @message, $message if $message;
  }

  for my $plugin ( @optional_validators ) {
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

  my @core_collectors;
  my @optional_collectors;

  for my $plugin ( $self->collectors ) {
    if ( $plugin->is_core ) {
      push @core_collectors, $plugin;
    }
    else {
      push @optional_collectors, $plugin;
    }
  }

  for my $plugin ( @core_collectors ) {
    $plugin->collector( $self );
  }

  for my $plugin ( @optional_collectors ) {
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

  my @core_transformers;
  my @optional_transformers;

  for my $plugin ( $self->transformers ) {
    if ( $plugin->is_core ) {
      push @core_transformers, $plugin;
    }
    else {
      push @optional_transformers, $plugin;
    }
  }

  my @sorted_transformers =
    _topological_sort( @core_transformers );

  for my $plugin ( @sorted_transformers ) {
	  #for my $plugin ( @sorted_transformers ) {
    $plugin->transformer( $self );
  }

  for my $plugin ( @optional_transformers ) {
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

  $self->_collect();
  $package->transformer( $self );
  $self->{ppi}->serialize;
}

# JMG Some things that came up...
#
# Maybe change 'use' statements to use Package:from<Perl5>
#
# $self->SUPER::func(...);

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
