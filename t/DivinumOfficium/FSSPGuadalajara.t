use strict;
use warnings;
use utf8;

BEGIN {
  my $script = 'web/cgi-bin/horas/stlawrence-check.pl';
  die "Run prove from the repository root\n" unless -f $script;
  $0 = $script;
}

use FindBin qw($Bin);
use lib "$Bin/..";

package main;
our $Bin;
our $datafolder = "$Bin/../../www/horas";
our $version = 'Rubrics 1960 - San Pedro en Cadenas';
our $lang1 = 'Latin';
our $lang2 = 'English';
our $hora = 'Laudes';
our $missa = 0;
our $votive = 'Hodie';
our $testmode = '';
our $missanumber = 0;
our ($winner, $rank, $commemoratio);
our @dayname;
our $dayofweek;

require "$Bin/../DivinumOfficium/SetupString.pl";
require "$Bin/../DivinumOfficium/dialogcommon.pl";
require "$Bin/horascommon.pl";

sub initiarule { return ''; }

use DivinumOfficium::Date qw(getweek day_of_week geteaster);
use DivinumOfficium::Directorium qw(get_from_directorium);
use DivinumOfficium::ParticularCalendar qw(layers mass_file ordo_note);
use Test::More;

my $parish = 'Rubrics 1960 - San Pedro en Cadenas';
my $fssp_gdl = 'Rubrics 1960 - FSSP Guadalajara';
my $fssp_mx = 'Rubrics 1960 - Mexico FSSP';
my $gdl = 'Rubrics 1960 - Guadalajara';
my $fssp_usa = 'Rubrics 1960 - FSSP';
my $usa = 'Rubrics 1960 - USA 1962';

is_deeply(
  [layers($parish)],
  [qw(mexico mexico-fssp fssp-guadalajara sanpedro)],
  'the quasi-parish stack has no USA token',
);
is_deeply(
  [layers($fssp_gdl)],
  [qw(mexico mexico-fssp fssp-guadalajara)],
  'FSSP Guadalajara stops at the diocese',
);
is_deeply([layers($gdl)], [qw(mexico guadalajara)], 'bare Guadalajara is unchanged');
ok(!grep { $_ eq 'usa' } layers($parish), 'San Pedro does not list usa');

is(get_from_directorium('kalendar', $parish, '08-01'), 'overlay/sanpedro/08-01', '1 August is the titular');
is(get_from_directorium('kalendar', $fssp_gdl, '08-01'), '08-01', 'FSSP Guadalajara keeps the upstream Chains file');
is(get_from_directorium('kalendar', $gdl, '08-01') || '', '08-01r', 'bare Guadalajara keeps the 1960 Machabees line');
is(get_from_directorium('kalendar', $parish, '02-22'), 'overlay/fssp/02-22', 'Chair comes from the FSSP file');
is(get_from_directorium('kalendar', $parish, '03-07'), 'overlay/fssp/03-07', 'Aquinas comes from the FSSP file');
is(get_from_directorium('kalendar', $parish, '12-12'), 'overlay/mexico/12-12', 'Guadalupe stays the Mexico office');
is(get_from_directorium('kalendar', $parish, '10-12'), 'overlay/guadalajara/10-12', '12 October stays diocesan Zapopan');
isnt(get_from_directorium('kalendar', $parish, '10-25') || '', '10-25n~10-25', 'USA Isidore is not inherited');
isnt(get_from_directorium('kalendar', $parish, '11-13') || '', '11-13n~11-13', 'Cabrini is not inherited');
isnt(get_from_directorium('kalendar', $parish, '09-09') || '', '09-09n~09-09', 'Claver is not inherited');

sub office_day {
  my (%arg) = @_;
  $version = $arg{version};
  our ($day, $month, $year);
  ($day, $month, $year) = ($arg{d}, $arg{m}, $arg{y});
  @dayname = (getweek($day, $month, $year, 0, 0), '', '');
  $dayofweek = day_of_week($day, $month, $year);
  occurrence($day, $month, $year, $version, '', 0);
  my $rank_s = defined $rank ? "$rank" : '';
  $rank_s =~ s/\s+/ /g;
  $rank_s =~ s/\A //;
  $rank_s =~ s/ \z//;
  my $title = $dayname[1] || '';
  $title =~ s/\s+/ /g;
  return { rank => $rank_s, winner => $winner || '', title => $title };
}

my $got = office_day(version => $parish, y => 2027, m => 8, d => 1);
like($got->{winner}, qr{overlay/sanpedro/08-01\.txt\z}, '2027-08-01 uses the quasi-parish file');
is($got->{rank}, '6', 'the titular is I class');
like($got->{title}, qr{Petri ad Vincula}, 'the title is Peter in Chains');

$got = office_day(version => $fssp_gdl, y => 2025, m => 8, d => 1);
like($got->{winner}, qr{Sancti/08-01\.txt\z}, 'FSSP Guadalajara uses the upstream Chains file');
is($got->{rank}, '4', 'that file remains Duplex majus');

$got = office_day(version => $parish, y => 2025, m => 2, d => 22);
like($got->{winner}, qr{overlay/fssp/02-22\.txt\z}, '2025-02-22 is the Chair');
is($got->{rank}, '6', 'the Chair is I class');

$got = office_day(version => $gdl, y => 2026, m => 2, d => 22);
isnt($got->{rank}, '6', 'bare Guadalajara does not raise the Chair');

$got = office_day(version => $parish, y => 2026, m => 3, d => 7);
like($got->{winner}, qr{overlay/fssp/03-07\.txt\z}, '2026-03-07 is Aquinas');
is($got->{rank}, '5', 'Aquinas is II class');

$got = office_day(version => $parish, y => 2027, m => 10, d => 12);
like($got->{winner}, qr{overlay/guadalajara/10-12\.txt\z}, '2027-10-12 remains Zapopan');
unlike($got->{title}, qr{Pilar|Column}, 'Zapopan is not renamed Pillar');

foreach my $spec ([1, 4, 2026], [1, 5, 2026], [10, 25, 2026], [11, 13, 2026]) {
  my $day = office_day(version => $parish, y => $spec->[2], m => $spec->[0], d => $spec->[1]);
  unlike($day->{winner}, qr{n\.txt\z}, "$spec->[2]-$spec->[0]-$spec->[1] is not a USA n file");
  unlike($day->{title}, qr{Seton|Neumann|Cabrini|Isidor}, 'USA saint names are absent');
}

is(mass_file($parish, 18, 1, 1), '', '18 January votive is not an Office Mass on this stack');
is(ordo_note($parish, 18, 1, 1), '', '18 January votive is not written into the Office');
is(mass_file($parish, 5, 11, 1), '', '5 November requiem is not an Office Mass on this stack');
is(ordo_note($fssp_usa, 18, 1, 1), 'Missa votiva Cathedræ S. Petri (IV. classis)', 'the USA FSSP votive remains');

$got = office_day(version => $usa, y => 2026, m => 11, d => 13);
like($got->{winner}, qr{11-13n\.txt\z}, 'USA Cabrini is unchanged');

my $transferred;
for my $year (2015 .. 2040) {
  my @easter = geteaster($year);
  my $easter = $easter[1] * 100 + $easter[0];
  next unless $easter == 405 || $easter == 322 || $easter == 329 || $easter == 409;
  my $day = office_day(version => $parish, y => $year, m => 2, d => 23);
  if ($day->{winner} =~ m{overlay/fssp/02-22\.txt\z} && $day->{rank} eq '6') {
    $transferred = $year;
    last;
  }
}
ok($transferred, 'an impeded Chair is transferred onto 23 February') or diag "no sample year";

done_testing;
