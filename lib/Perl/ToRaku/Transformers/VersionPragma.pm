package Perl::ToRaku::Transformers::VersionPragma;

use PPI;

# 'use 5.008'                  => '' # Rare though, would be the last line.
# 'use 5.008;'                 => ''
# 'use 5.008 "vars";'          => ''
# 'use 5.008 qw( vars refs );' => ''
#
sub transformer {
  my $self = shift;
  my $ppi  = shift;

  for my $token ( @{ $ppi->find( 'PPI::Statement::Include' ) } ) {
    next unless $token->type eq 'use';
    next if $token->module;
    next unless $token->version =~ m{ [1-9][0-9]* \. [0-9]+ }x;

    $token->delete;
  }
}

1;
