package Perl::ToRaku::Transformers::SubNew;

use strict;
use warnings;

sub long_description {
  <<'_EOS_';
Override the built-in Raku 'new' method with what the Perl user wants.

Which means both changing from 'sub new' to 'method new', and because there's
already an existing 'method new' the Raku equivalent has to be
'multi method new'.

sub new { ... } => multi method { ... }
_EOS_
}
sub short_description {
  <<'_EOS_';
Change Perl 'new' subroutine to Raku-style 'multi method'.
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

  my $sub_stmts = $ppi->find( 'PPI::Statement::Sub' );
  if ( $sub_stmts ) {
    for my $sub_stmt ( @{ $sub_stmts } ) {
      next unless $sub_stmt->name eq 'new';

      $sub_stmt->first_element->set_content( 'multi method' );
    }
  }
}

1;
