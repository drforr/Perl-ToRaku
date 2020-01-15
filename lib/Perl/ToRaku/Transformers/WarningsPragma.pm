package Perl::ToRaku::Transformers::WarningsPragma;

use PPI;

# 'use warnings'                  => '' # Rare though, would be the last line.
# 'use warnings;'                 => ''
# 'use warnings "vars";'          => ''
# 'use warnings qw( vars refs );' => ''
# 'no warnings'                  => '' # Rare though, would be the last line.
# 'no warnings;'                 => ''
# 'no warnings "vars";'          => ''
# 'no warnings qw( vars refs );' => ''
#
sub transformer {
  my $self = shift;
  my $ppi  = shift;
  for my $token ( @{ $ppi->find( 'PPI::Statement::Include' ) } ) {
    next unless $token->type eq 'use' or
                $token->type eq 'no';
    next unless $token->module eq 'warnings';

    $token->delete;
  }
}

1;
