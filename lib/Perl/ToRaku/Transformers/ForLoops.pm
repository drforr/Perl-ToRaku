package Perl::ToRaku::Transformers::ForLoops;

use strict;
use warnings;

sub long_description {
  <<'_EOS_';
Rename Perl C-style for() to 'loop', everything else to Raku 'loop'

foreach my $x ( @y ) { }              ==> for my $x ( @y ) { }
for ( my $i = 0; $i < 10 ; $i++ ) { } ==> loop ( my $i = 0; $i < 10 ; $i++ ) { }
_EOS_
}
sub short_description {
  <<'_EOS_';
Change Perl 'for' and 'foreach' names to Raku 'for' and 'loop' style.
_EOS_
}
sub depends_upon { }
sub is_core { 1 }
sub transforms { 'PPI::Statement::Compound' }
sub transform {
  my $self               = shift;
  my $compound_statement = shift;

  my %map = (
    foreach => 1,
    for     => 1,
  );

  return unless $map{ $compound_statement->type };

  if ( $compound_statement->find( 'PPI::Structure::For' ) ) {
    $compound_statement->first_element->set_content( 'loop' );
  }
  else {
    $compound_statement->first_element->set_content( 'for' );
  }
}

1;
