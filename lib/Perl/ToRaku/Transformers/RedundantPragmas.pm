package Perl::ToRaku::Transformers::RedundantPragmas;

use strict;
use warnings;

# 'use 5.008'                  => '' # Rare though, would be the last line.
# 'use 5.008;'                 => ''
# 'use 5.008 "vars";'          => ''
# 'use 5.008 qw( vars refs );' => ''
#
# 'use utf8'                  => '' # Rare though, would be the last line.
# 'use utf8;'                 => ''
# 'use utf8 "vars";'          => ''
# 'use utf8 qw( vars refs );' => ''
#
# 'use strict'                  => '' # Rare though, would be the last line.
# 'use strict;'                 => ''
# 'use strict "vars";'          => ''
# 'use strict qw( vars refs );' => ''
# 'no strict'                  => '' # Rare though, would be the last line.
# 'no strict;'                 => ''
# 'no strict "vars";'          => ''
# 'no strict qw( vars refs );' => ''
#
# 'use warnings'                  => '' # Rare though, would be the last line.
# 'use warnings;'                 => ''
# 'use warnings "vars";'          => ''
# 'use warnings qw( vars refs );' => ''
# 'no warnings'                   => '' # Rare though, would be the last line.
# 'no warnings;'                  => ''
# 'no warnings "vars";'           => ''
# 'no warnings qw( vars refs );'  => ''
#
sub long_description {
  <<'_EOS_';
Just like RedundantModules, this removes pragmas that Raku either doesn't need
or has turned on all the time, like 'strict' and 'warnings'.

(it also removes all the qw() &c) And just like RedundantModules, it keeps the
newline intact. This design decision may change later on.

use 5.008    ==> ''
use utf8     ==> ''
use strict   ==> ''
no strict    ==> ''
use warnings ==> ''
no warnings  ==> ''
_EOS_
}
sub short_description {
  <<'_EOS_';
Remove redundant pragmas like 'strict', 'warning' and 'utf8'.
_EOS_
}
sub run_before { }
sub run_after { }
sub is_core { 1 }
sub transformer {
  my $self = shift;
  my $obj  = shift;
  my $ppi  = $obj->_ppi;

  my %map = map { $_ => 1 } (
    'strict',
    'utf8',
    'warnings'
  );

  my $include_stmts = $ppi->find( 'PPI::Statement::Include' );
  if ( $include_stmts ) {
    for my $include_stmt ( @{ $include_stmts } ) {
      next unless $include_stmt->type eq 'use' or
                  $include_stmt->type eq 'no';
      next unless exists $map{ $include_stmt->module } or
                  $include_stmt->version =~ m{ [1-9][0-9]* \. [0-9]+ }x;

      $include_stmt->delete;
    }
  }
}

1;
