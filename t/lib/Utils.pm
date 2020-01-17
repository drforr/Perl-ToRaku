package Perl::ToRaku::Utils;

use PPI;
use Exporter;
our @ISA = qw( Exporter );
our @EXPORT_OK = qw( transform );

sub transform {
  my $text = shift;
  my $ppi = PPI::Document->new( \$text );
  $package->transformer( $ppi );
  return $ppi->serialize;
}

1;
