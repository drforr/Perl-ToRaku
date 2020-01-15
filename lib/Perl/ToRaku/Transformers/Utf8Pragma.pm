package Perl::ToRaku::Transformers::Utf8Pragma;

use PPI;

# 'use utf8'                  => '' # Rare though, would be the last line.
# 'use utf8;'                 => ''
# 'use utf8 "vars";'          => ''
# 'use utf8 qw( vars refs );' => ''
#
sub transformer {
  my $self = shift;
  my $ppi  = shift;
  for my $token ( @{ $ppi->find( 'PPI::Statement::Include' ) } ) {
    next unless $token->type eq 'use';
    next unless $token->module eq 'utf8';

    $token->delete;
  }
}

1;
