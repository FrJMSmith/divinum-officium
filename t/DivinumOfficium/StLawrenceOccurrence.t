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
our $version = 'Rubrics 1960 - St. Lawrence';
our $lang1 = 'Latin';
our $lang2 = 'English';
our $hora = 'Laudes';
our $missa = 0;
our $votive = 'Hodie';
our $testmode = '';
our $missanumber = 0;
our ($winner, $rank, $commemoratio, $commune, $communetype);
our @dayname;
our $dayofweek;

require "$Bin/../DivinumOfficium/SetupString.pl";
require "$Bin/../DivinumOfficium/dialogcommon.pl";
require "$Bin/horascommon.pl";

sub initiarule { return ''; }

use DivinumOfficium::Date qw(getweek day_of_week);
use DivinumOfficium::Main qw(liturgical_color);
use DivinumOfficium::ParticularCalendar qw(episcopal_collect_file mass_file ordo_note);
use Test::More;

sub office_day {
  my (%arg) = @_;
  $version = $arg{version};
  $hora = 'Laudes';
  $missa = $arg{missa} || 0;
  our ($day, $month, $year);
  ($day, $month, $year) = ($arg{d}, $arg{m}, $arg{y});
  @dayname = (getweek($day, $month, $year, 0, $missa), '', '');
  $dayofweek = day_of_week($day, $month, $year);
  occurrence($day, $month, $year, $version, '', 0);

  my $title = $dayname[1] || '';
  $title =~ s/\s+/ /g;
  my $note = $dayname[2] || '';
  $note =~ s/\s+/ /g;

  return {
    rank => do {
      my $r = defined $rank ? "$rank" : '';
      $r =~ s/\s+/ /g;
      $r =~ s/\A //;
      $r =~ s/ \z//;
      $r;
    },
    winner => $winner || '',
    note => $note,
    title => $title,
    color => liturgical_color($title),
    comm => $commemoratio || '',
    mass => mass_file($version, $day, $month, $rank),
    collect => episcopal_collect_file($version, $day, $month, $year),
    odonote => ordo_note($version, $day, $month, $rank),
  };
}

sub check_day {
  my ($label, %arg) = @_;
  my $expect = delete $arg{expect};
  my $got = office_day(%arg);
  local $Test::Builder::Level = $Test::Builder::Level + 1;

  is($got->{rank}, $expect->{rank}, "$label rank") if exists $expect->{rank};
  like($got->{winner}, $expect->{winner}, "$label winner") if $expect->{winner};
  like($got->{note}, $expect->{note}, "$label note") if $expect->{note};
  like($got->{title}, $expect->{title}, "$label title") if $expect->{title};
  is($got->{color}, $expect->{color}, "$label headline color") if exists $expect->{color};
  like($got->{comm}, $expect->{comm}, "$label commemoration") if $expect->{comm};
  is($got->{mass}, $expect->{mass}, "$label mass file") if exists $expect->{mass};
  is($got->{collect}, $expect->{collect}, "$label collect") if exists $expect->{collect};
  like($got->{odonote}, $expect->{odonote}, "$label ordo note") if $expect->{odonote};
}

my $sl = 'Rubrics 1960 - St. Lawrence';
my $usa = 'Rubrics 1960 - USA 1962';
my $fssp = 'Rubrics 1960 - FSSP';
my $hbg = 'Rubrics 1960 - Harrisburg';
my $uni = 'Rubrics 1960 - 1960';

# Ordinary year: the parish rank is I class; USA keeps the upstream II class.
check_day(
  '2026-08-10 parish',
  version => $sl, y => 2026, m => 8, d => 10,
  expect => {
    rank => 6,
    winner => qr{overlay/stlawrence/08-10\.txt\z},
    title => qr{Laurentii Martyris},
    color => 'red',
    note => qr{\A\z},
    mass => '',
  },
);
check_day(
  '2026-08-10 USA',
  version => $usa, y => 2026, m => 8, d => 10,
  expect => {
    rank => 5,
    winner => qr{Sancti/08-10\.txt\z},
    title => qr{II classis},
    color => 'red',
  },
);

# Layer inheritance: Patrick is I class only from the diocese upward.
check_day(
  '2026-03-17 FSSP',
  version => $fssp, y => 2026, m => 3, d => 17,
  expect => {
    winner => qr{Quad4-2},
    comm => qr{Sancti/03-17\.txt\z},
    note => qr{Patricii},
  },
);
check_day(
  '2026-03-17 Harrisburg',
  version => $hbg, y => 2026, m => 3, d => 17,
  expect => {
    rank => 6,
    winner => qr{overlay/harrisburg/03-17\.txt\z},
    note => qr{Quadragesima},
  },
);

# Country layer is not on the universal calendar. Claver is.
check_day(
  '2026-09-09 universal',
  version => $uni, y => 2026, m => 9, d => 9,
  expect => {winner => qr{Pent15-3}, comm => qr{Sancti/09-09\.txt\z}},
);
check_day(
  '2026-09-09 USA',
  version => $usa, y => 2026, m => 9, d => 9,
  expect => {rank => 2, winner => qr{09-09n\.txt\z}, title => qr{Petri Claver}},
);

# 1 August: FSSP selects Peter in Chains. Universal 1960 commemorates the Machabees.
check_day(
  '2026-08-01 universal',
  version => $uni, y => 2026, m => 8, d => 1,
  expect => {comm => qr{08-01r\.txt\z}, winner => qr{\ACommune/}},
);
check_day(
  '2026-08-01 FSSP',
  version => $fssp, y => 2026, m => 8, d => 1,
  expect => {
    rank => 4,
    winner => qr{Sancti/08-01\.txt\z},
    title => qr{Petri ad Vincula},
    color => 'red',
  },
);

# I class impeded by Lent I Sunday is transferred, and the feria is commemorated.
check_day(
  '2026-02-22 Chair impeded',
  version => $sl, y => 2026, m => 2, d => 22,
  expect => {winner => qr{Quad1-0}, note => qr{Transfer: In Cathedra}},
);
check_day(
  '2026-02-23 Chair transferred',
  version => $sl, y => 2026, m => 2, d => 23,
  expect => {
    rank => 6,
    winner => qr{overlay/fssp/02-22\.txt\z},
    note => qr{Commemoratio: Feria},
  },
);

# II class on Laetare is omitted, not transferred. Rose is the engine color.
check_day(
  '2027-03-07 Laetare',
  version => $sl, y => 2027, m => 3, d => 7,
  expect => {
    rank => 6.9,
    winner => qr{Quad4-0},
    note => qr{\A\z},
    comm => qr{\A\z},
    color => 'deeppink',
    title => qr{Quadragesima},
  },
);

# II/III class on a Sunday are omitted.
check_day(
  '2027-08-01 Sunday',
  version => $sl, y => 2027, m => 8, d => 1,
  expect => {winner => qr{Pent11-0}, note => qr{\A\z}, color => 'green'},
);
check_day(
  '2027-09-26 Sunday',
  version => $sl, y => 2027, m => 9, d => 26,
  expect => {winner => qr{Pent19-0}, note => qr{\A\z}},
);
check_day(
  '2027-12-12 Guadalupe on Advent III',
  version => $sl, y => 2027, m => 12, d => 12,
  expect => {winner => qr{Adv3-0}, note => qr{\A\z}, color => 'deeppink'},
);
check_day(
  '2026-10-25 Christ the King',
  version => $sl, y => 2026, m => 10, d => 25,
  expect => {rank => 6.5, winner => qr{10-DUr}, note => qr{\A\z}, color => 'black'},
);

# Ember Friday keeps the III class martyrs as a commemoration. Violet.
check_day(
  '2025-09-26 Ember Friday',
  version => $sl, y => 2025, m => 9, d => 26,
  expect => {
    rank => 4.9,
    winner => qr{Pent15-5},
    comm => qr{09-26n\.txt\z},
    note => qr{Commemoratio ad Laudes tantum: Ss\. Isaaci},
    color => 'purple',
  },
);

# Easter Sunday and Holy Saturday impede the dedication; the transfer table lands it later.
check_day(
  '2025-04-20 Easter',
  version => $sl, y => 2025, m => 4, d => 20,
  expect => {
    rank => 7,
    winner => qr{Pasc0-0},
    note => qr{Transfer: In Dedicatione},
    color => 'black',
  },
);
check_day(
  '2025-04-28 dedication transferred',
  version => $sl, y => 2025, m => 4, d => 28,
  expect => {rank => 6, winner => qr{overlay/stlawrence/04-20\.txt\z}, color => 'black'},
);
check_day(
  '2030-04-20 Holy Saturday',
  version => $sl, y => 2030, m => 4, d => 20,
  expect => {
    rank => 7,
    winner => qr{Quad6-6r},
    note => qr{Transfer: In Dedicatione},
    color => 'purple',
  },
);
check_day(
  '2030-04-29 after the octave',
  version => $sl, y => 2030, m => 4, d => 29,
  expect => {rank => 6, winner => qr{overlay/stlawrence/04-20\.txt\z}},
);

# Ascension impedes the cathedral dedication.
check_day(
  '2026-05-14 Ascension',
  version => $sl, y => 2026, m => 5, d => 14,
  expect => {rank => 7, winner => qr{Pasc5-4}, note => qr{Transfer: In Dedicatione Ecclesi}},
);
check_day(
  '2026-05-15 cathedral transferred',
  version => $sl, y => 2026, m => 5, d => 15,
  expect => {rank => 6, winner => qr{overlay/harrisburg/05-14\.txt\z}},
);

# The parish dedication is not on the diocesan calendar.
check_day(
  '2026-04-20 Harrisburg',
  version => $hbg, y => 2026, m => 4, d => 20,
  expect => {winner => qr{Pasc2-1}},
);
check_day(
  '2026-04-20 parish',
  version => $sl, y => 2026, m => 4, d => 20,
  expect => {rank => 6, winner => qr{overlay/stlawrence/04-20\.txt\z}},
);

# Office and Mass differ for the votives and the episcopal collect.
check_day(
  '2026-01-22 peace votive',
  version => $sl, y => 2026, m => 1, d => 22,
  expect => {
    rank => 2.2,
    winner => qr{Sancti/01-22\.txt\z},
    color => 'red',
    mass => 'Sancti/overlay/usa/01-22.txt',
    odonote => qr{pro pace},
    collect => '',
  },
);
is(
  liturgical_color('Missa votiva pro pace'),
  'purple',
  'the peace votive title is violet; the Office headline stays the martyrs',
);
check_day(
  '2026-01-18 Sunday suppresses the Chair votive',
  version => $sl, y => 2026, m => 1, d => 18,
  expect => {rank => 5, mass => '', odonote => qr{\A\z}, color => 'green'},
);
check_day(
  '2027-01-18 feria keeps the Chair votive',
  version => $sl, y => 2027, m => 1, d => 18,
  expect => {mass => 'Sancti/overlay/fssp/01-18.txt', odonote => qr{Cathedr}},
);
check_day(
  '2027-01-18 USA has no Chair votive',
  version => $usa, y => 2027, m => 1, d => 18,
  expect => {mass => '', odonote => qr{\A\z}},
);
check_day(
  '2026-04-25 Office is St Mark, Mass gains the collect',
  version => $sl, y => 2026, m => 4, d => 25,
  expect => {
    rank => 5,
    winner => qr{Sancti/04-25\.txt\z},
    color => 'red',
    mass => '',
    collect => 'Sancti/overlay/harrisburg/pro-episcopo.txt',
  },
);
check_day(
  '2026-04-25 FSSP has no diocesan collect',
  version => $fssp, y => 2026, m => 4, d => 25,
  expect => {collect => ''},
);
check_day(
  '2027-04-25 Sunday keeps the collect',
  version => $sl, y => 2027, m => 4, d => 25,
  expect => {
    winner => qr{Pasc4-0},
    comm => qr{Sancti/04-25\.txt\z},
    collect => 'Sancti/overlay/harrisburg/pro-episcopo.txt',
  },
);
check_day(
  '2025-11-05 requiem is a Mass note',
  version => $sl, y => 2025, m => 11, d => 5,
  expect => {
    winner => qr{Tempora/},
    mass => 'Sancti/overlay/fssp/11-05.txt',
    odonote => qr{Defunctorum},
  },
);

# precedence() is what replaces the Mass text. occurrence() leaves the Office winner.
my $horascommon = do {
  open my $fh, '<:encoding(UTF-8)', "$Bin/horascommon.pl" or die $!;
  local $/;
  <$fh>;
};
like($horascommon, qr/mass_file\(\$version/, 'Mass precedence consults the propria mass file');

done_testing;
