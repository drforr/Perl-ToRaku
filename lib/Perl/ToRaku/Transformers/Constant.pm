package Perl::ToRaku::Transformers::Constant;

use strict;
use warnings;

sub long_description {
  <<'_EOS_';
Change Perl constant pragma into Raku 'constant' storage type.

use constant FOO => 1 ==> constant FOO = 1
_EOS_
}
sub short_description {
  <<'_EOS_';
Change Perl 'use constant' declarations to Raku 'constant' style.
_EOS_
}
sub depends_upon { }
sub is_core { 1 }
sub transforms { 'PPI::Statement::Include' }
sub transform {
  my $self         = shift;
  my $include_stmt = shift;

  return unless $include_stmt->type eq 'use';
  return unless $include_stmt->module eq 'constant';

  my $fat_arrow = $include_stmt->find_first( 'PPI::Token::Operator' );
  return unless $fat_arrow;

  $include_stmt->first_token->delete; # Delete 'use'
  $include_stmt->first_token->delete; # Delete ' '

  my $new_content = '=';
  $fat_arrow->set_content( $new_content );
}

1;
