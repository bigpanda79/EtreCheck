# A class understands a single EtreCheck section.
package EtreCheckSection;

use strict;
use Exporter;
use vars qw($VERSION);

our $VERSION = 1.00;

sub new
  {
  my $class = shift;

  my $self = 
    {
    };

  bless $self, $class;

  return $self;
  }

1;
