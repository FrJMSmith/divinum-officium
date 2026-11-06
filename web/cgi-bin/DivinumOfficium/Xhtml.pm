package DivinumOfficium::Xhtml;

use strict;
use warnings;
use utf8;
use Exporter qw(import);

our $VERSION = 1.00;
our @EXPORT_OK = qw(xhtml_escape);

# Markup already stored in the office heading and the Ordo comment line.
# concurrence() inserts <br/>; a few rank titles use <i>.
my $MARKUP = qr{<br\s*/?>|</?i>}i;

#*** xhtml_escape($text)
# Escape text for an HTML or XHTML element. A bare "&" is not an entity;
# XML readers then fail with "xmlParseEntityRef: no name".
# < and > are escaped except for the markup these fields already contain.
sub xhtml_escape {
  my ($text) = @_;
  return '' unless defined $text;

  my @parts = split /($MARKUP)/, $text, -1;

  for my $part (@parts) {
    next if $part =~ /\A$MARKUP\z/;
    $part =~ s/&(?!(?:\#(?:[0-9]+|x[0-9A-Fa-f]+)|[A-Za-z][A-Za-z0-9]+);)/&amp;/g;
    $part =~ s/</&lt;/g;
    $part =~ s/>/&gt;/g;
  }
  return join '', @parts;
}

1;
