package Perl::ToRaku::Transformers::CoreRakuModules;

use strict;
use warnings;

# 'use IO::Handle'                  => '' # Rare though, would be the last line.
# 'use IO::Handle;'                 => ''
# 'use IO::Handle "vars";'          => ''
# 'use IO::Handle qw( vars refs );' => ''
#
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  my %map = map { $_ => 1 } (
    'DateTime',
    'FatRat',
    'IO::File',
    'IO::Handle',
    'IO::Path',
    'IO::Socket',
    'Proc::Async'
  );

  my $includes = $ppi->find( 'PPI::Statement::Include' );
  if ( $includes ) {
    for my $include ( @{ $includes } ) {
      next unless $include->type eq 'use';
      next unless exists $map{ $include->module };

      $include->delete;
    }
  }
}

1;
