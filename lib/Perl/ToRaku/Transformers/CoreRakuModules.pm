package Perl::ToRaku::Transformers::CoreRakuModules;

# 'use IO::Handle'                  => '' # Rare though, would be the last line.
# 'use IO::Handle;'                 => ''
# 'use IO::Handle "vars";'          => ''
# 'use IO::Handle qw( vars refs );' => ''
#
sub transformer {
  my $self = shift;
  my $ppi  = shift;

  my %module = map { $_ => 1 } (
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
    next unless exists $module{ $token->module };

    $token->delete;
  }
}

1;
