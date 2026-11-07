use strict;
use warnings;
use utf8;

use lib 'web/cgi-bin';
use DivinumOfficium::ParticularCalendar qw(layers propria_entries validate_propria);
use Test::More;

my @errors = validate_propria();
ok(!@errors, 'draft records do not break the in-use registry') or diag join("\n", @errors);

my @entries = propria_entries();
is(scalar(@entries), 35, 'in-use records include the quasi-parish titular');

my @drafts = grep { ($_->{id} || '') =~ /^draft-/ } @entries;
ok(!@drafts, 'draft ids are not loaded');

is_deeply(
  [layers('Rubrics 1960 - St. Lawrence')],
  [qw(usa fssp harrisburg stlawrence)],
  'St. Lawrence layers are unchanged',
);
is_deeply([layers('Rubrics 1960 - Canada')], [], 'Canada is not a menu');
is_deeply([layers('Rubrics 1960 - Mexico')], ['mexico'], 'Mexico stands on universal 1960');
is_deeply(
  [layers('Rubrics 1960 - Guadalajara')],
  [qw(mexico guadalajara)],
  'Guadalajara adds the diocese on Mexico',
);

open my $hf, '<:encoding(UTF-8)', 'web/www/horas/horas.dialog' or die $!;
open my $mf, '<:encoding(UTF-8)', 'web/www/missa/missa.dialog' or die $!;
local $/;
my $horas = <$hf>;
my $missa = <$mf>;
unlike($horas, qr/Rubrics 1960 - Canada/, 'Office menu has no Canada version');
unlike($missa, qr/Rubrics 1960 - Canada/, 'Mass menu has no Canada version');
like($horas, qr/Rubrics 1960 - Mexico/, 'Office menu lists Mexico');
like($horas, qr/Rubrics 1960 - Guadalajara/, 'Office menu lists Guadalajara');
unlike($missa, qr/Rubrics 1960 - Mexico/, 'Mass menu does not list Mexico');
unlike($missa, qr/Guadalajara/, 'Mass menu does not list Guadalajara');

open my $vh, '<:encoding(UTF-8)', 'web/www/Tabulae/Propria/versions.txt' or die $!;
my $versions = <$vh>;
like($versions, qr/^layer: mexico$/m, 'versions.txt has the Mexico layer');
like($versions, qr/^layer: guadalajara$/m, 'versions.txt has the Guadalajara layer');
unlike($versions, qr/usa,mexico|usa,guadalajara/, 'the new layers do not sit on USA');

ok(!-d 'web/www/Tabulae/Propria/proposals/country/canada', 'Canada directory is absent');

my @gdl = qw(
  12-18 01-24 02-05 02-25 03-02 03-23 05-15 05-16
  07-04 08-17 08-30 10-12 10-21 10-22 11-11 11-23
);
is(scalar(@gdl), 16, 'sixteen Guadalajara headings besides national Guadalupe');
for my $date (@gdl) {
  ok(-f "web/www/Tabulae/Propria/proposals/diocese/guadalajara/$date.txt", "Guadalajara $date");
}
ok(-f 'web/www/Tabulae/Propria/proposals/country/mexico/12-12.txt', 'national Guadalupe candidate exists');
ok(!-f 'web/www/Tabulae/Propria/proposals/diocese/guadalajara/12-12.txt', 'Guadalupe is not filed as diocesan');

open my $ch, '<:encoding(UTF-8)', 'web/www/Tabulae/Propria/proposals/diocese/guadalajara/11-23.txt' or die $!;
local $/;
my $clement = <$ch>;
like($clement, qr/source_class: unknown/, 'Clement has no printed class');
unlike($clement, qr/printed_class: [0-9]/, 'Clement is not given a guessed class');

open my $th, '<:encoding(UTF-8)', 'web/www/Tabulae/Propria/proposals/diocese/guadalajara/03-23.txt' or die $!;
my $turibius = <$th>;
like($turibius, qr/Petri Canisii/, 'Apr 27 in this repository is recorded as Canisius');
unlike($turibius, qr/universal[^.]{0,40}Apr/, 'the draft does not call Turibius universal on April 27');

my $blob = '';
for my $path (
  glob('web/www/Tabulae/Propria/proposals/country/mexico/*.txt'),
  glob('web/www/Tabulae/Propria/proposals/country/mexico/_*'),
  glob('web/www/Tabulae/Propria/proposals/diocese/guadalajara/*.txt'),
  glob('web/www/Tabulae/Propria/proposals/diocese/guadalajara/_*'),
  'docs/proper/mexico.md', 'docs/proper/guadalajara.md',
  )
{
  next unless -f $path;
  open my $fh, '<:encoding(UTF-8)', $path or die $!;
  local $/;
  $blob .= <$fh>;
}
unlike($blob, qr/Felipe/, 'Felipe is not grouped into this draft');
unlike($blob, qr/with an octave|octave is presumed|add an octave/i, 'no octave is supplied');
unlike($blob, qr/no owner-supplied Mexican source/i, 'Mexico is not declared source-empty');
like($blob, qr/approved: 2026-11-06 by Fr\. Smith/, 'Fr. Smith approval is recorded');
unlike($blob, qr/confirmation: unconfirmed/, 'the supplied source is not left unapproved');
like($blob, qr/inherits_usa: no/, 'drafts refuse USA inheritance');

done_testing;
