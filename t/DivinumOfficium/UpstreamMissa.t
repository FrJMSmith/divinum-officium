use strict;
use warnings;
use utf8;

use lib 'web/cgi-bin';
use DivinumOfficium::Xhtml qw(xhtml_escape);
use Test::More;

sub slurp {
  my ($path) = @_;
  open my $fh, '<:encoding(UTF-8)', $path or die "$path: $!";
  local $/;
  return scalar <$fh>;
}

my $john = slurp('web/www/missa/Espanol/Sancti/03-27.txt');
like(
  $john,
  qr/El Señor ha salvado tu mano, porque peleas las batallas del Señor\. Aleluya\./,
  'Spanish John Damascene Graduale has its verse',
);
like(
  $john,
  qr/Bendito sea el Señor, Dios mío, que adiestra mis manos para el combate/,
  'Spanish John Damascene Graduale has the second verse',
);

my $raphael = slurp('web/www/missa/Espanol/Sancti/10-24.txt');
like(
  $raphael,
  qr/El santo ángel del Señor Rafael fue enviado por Dios a Tobías/,
  'Spanish Raphael Graduale names Raphael',
);

my $four = slurp('web/www/missa/Latin/Sancti/11-08r.txt');
like(
  $four,
  qr/\[Rule\]\n(?:.*\n)*?vide C3;\nEvangelium non appropriatum\n/,
  'Four Crowned Martyrs do not take a proper last Gospel',
);

my $theodore = slurp('web/www/missa/Nederlands/Sancti/11-09cc.txt');
like($theodore, qr/^\[Officium\]\nS\. Theodori Martyris\n/m, 'Dutch Theodore title is Theodori Martyris');

is(
  xhtml_escape('S. Petri & S. Pauli'),
  'S. Petri &amp; S. Pauli',
  'a Mass or Office ampersand is escaped for XHTML',
);
is(xhtml_escape('already &amp; &#160;'), 'already &amp; &#160;', 'an existing entity is not doubled');

done_testing;
