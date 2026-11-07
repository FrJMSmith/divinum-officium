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
our $version = 'Rubrics 1960 - Guadalajara';
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
use DivinumOfficium::Directorium qw(get_from_directorium);
use Test::More;

sub office_day {
  my (%arg) = @_;
  $version = $arg{version};
  $hora = 'Laudes';
  our ($day, $month, $year);
  ($day, $month, $year) = ($arg{d}, $arg{m}, $arg{y});
  @dayname = (getweek($day, $month, $year, 0, 0), '', '');
  $dayofweek = day_of_week($day, $month, $year);
  occurrence($day, $month, $year, $version, '', 0);
  my $rank_s = defined $rank ? "$rank" : '';
  $rank_s =~ s/\s+/ /g;
  $rank_s =~ s/\A //;
  $rank_s =~ s/ \z//;
  return {
    rank => $rank_s,
    winner => $winner || '',
    note => do { my $n = $dayname[2] || ''; $n =~ s/\s+/ /g; $n },
    title => do { my $t = $dayname[1] || ''; $t =~ s/\s+/ /g; $t },
    comm => $commemoratio || '',
  };
}

my $gdl = 'Rubrics 1960 - Guadalajara';
my $mx = 'Rubrics 1960 - Mexico';
my $uni = 'Rubrics 1960 - 1960';
my $usa = 'Rubrics 1960 - USA 1962';
my $sl = 'Rubrics 1960 - St. Lawrence';

is(
  get_from_directorium('kalendar', $gdl, '12-12'),
  'overlay/mexico/12-12',
  'Dec 12 comes from the Mexico kalendar',
);
is(
  get_from_directorium('kalendar', $gdl, '02-05'),
  'overlay/guadalajara/02-05~02-05',
  'Feb 5 commemorates the universal office',
);
unlike(
  get_from_directorium('kalendar', $gdl, '11-23') || '',
  qr{overlay/guadalajara},
  'Clement is not given a Guadalajara kalendar line',
);
isnt(
  get_from_directorium('kalendar', $gdl, '09-09') || '',
  '09-09n',
  'Guadalajara does not inherit the USA Claver line',
);

# Marker-line words are part of the antiphon. Checked against the printed lines.
my %antiphon = (
  'web/www/horas/Latin/Sancti/overlay/mexico/12-12.txt' => {
    'Ant 1' => 'Elégi et sanctificávi locum istum',
    'Ant 2' => 'Quasi arcus refúlgens',
    'Ant 3' => 'Leva in circúitu óculos tuos',
  },
  'web/www/horas/Latin/Sancti/overlay/guadalajara/03-23.txt' => {
    'Ant 2' => 'Quasi thus rédolens',
    'Ant 3' => 'Quasi olíva púllulans',
  },
  'web/www/horas/Latin/Sancti/overlay/guadalajara/05-15.txt' => {
    'Ant 2' => 'Exiit qui séminat',
    'Ant 3' => 'Ecce homo agrícola',
  },
  'web/www/horas/Latin/Sancti/overlay/guadalajara/05-16.txt' => {
    'Ant 2' => 'Quicúmque * glorificáverit me',
  },
  'web/www/horas/Latin/Sancti/overlay/guadalajara/08-30.txt' => {
    'Ant 1' => 'Benedícta tu * a Deo tuo, Rosa',
    'Ant 2' => 'O Rosa odorífera',
    'Ant 3' => 'Rosa, soror nostra',
  },
  'web/www/horas/Latin/Sancti/overlay/guadalajara/10-21.txt' => {
    'Ant 2' => 'Prudéntes vírgines, aptáte vestras lámpades',
  },
  'web/www/horas/Latin/Sancti/overlay/guadalajara/12-18.txt' => {
    'Ant 2' => 'Super sólium David',
  },
);

foreach my $path (sort keys %antiphon) {
  my $office = officestring('Latin', $path =~ s{^web/www/horas/Latin/}{}r);
  foreach my $section (sort keys %{$antiphon{$path}}) {
    my $text = $office->{$section} || '';
    like($text, qr/\A\Q$antiphon{$path}{$section}\E/, "$path $section keeps the marker line");
    unlike($text, qr/_|Adducéntur|Próximæ/, "$path $section has no versicle or rule line");
  }
}

my $guadalupe = officestring('Latin', 'Sancti/overlay/mexico/12-12.txt');
like($guadalupe->{Oratio}, qr/suplícibus tuis/, 'Guadalupe oration keeps the printed spelling');
like($guadalupe->{Oratio}, qr/in terris, ejus conspéctu/, 'Guadalupe oration is the whole collect');
like($guadalupe->{'Hymnus Matutinum'}, qr/Praclara custos/, 'the hymn spelling is not normalized');
like($guadalupe->{'Hymnus Matutinum'}, qr/formosíssma/, 'formosíssma is kept');
like($guadalupe->{'Hymnus Matutinum'}, qr/rubéta/, 'rubéta is kept');
like($guadalupe->{Lectio1}, qr/meis mitte radíces/, 'the tt ligature in mitte is restored');
unlike($guadalupe->{Lectio1}, qr/mi e rad/, 'the dropped ligature is not left as two words');
like($guadalupe->{Lectio1}, qr/Lectio j/, 'the printed lesson mark is kept');
ok($guadalupe->{Lectio1} && $guadalupe->{Lectio9}, 'nine lessons are present');
unlike($guadalupe->{Oratio}, qr/Et fit|PROPRIA/, 'the collect is not the following rubric');

my $rose = officestring('Latin', 'Sancti/overlay/guadalajara/08-30.txt');
like($rose->{Oratio}, qr/un in odórem/, 'the I Vespers printing un is kept');
like($rose->{Oratio}, qr/\$Qui tecum/, 'Rose uses the Qui tecum conclusion');

my $got = office_day(version => $gdl, y => 2026, m => 12, d => 12);
like($got->{winner}, qr{overlay/mexico/12-12\.txt\z}, '2026-12-12 Guadalajara uses the national Office');
is($got->{rank}, '6', '2026-12-12 is I class');

$got = office_day(version => $mx, y => 2026, m => 12, d => 12);
like($got->{winner}, qr{overlay/mexico/12-12\.txt\z}, 'Mexico alone also keeps Dec 12');

$got = office_day(version => $uni, y => 2026, m => 12, d => 12);
unlike($got->{winner}, qr{overlay/mexico}, 'universal 1960 does not gain Guadalupe');

$got = office_day(version => $gdl, y => 2026, m => 2, d => 5);
like($got->{winner}, qr{overlay/guadalajara/02-05\.txt\z}, '2026-02-05 is Philip');
like($got->{comm}, qr{02-05\.txt\z}, 'Agatha is commemorated');
unlike($got->{comm}, qr{overlay/guadalajara}, 'the commemoration is the universal file');

$got = office_day(version => $gdl, y => 2026, m => 11, d => 23);
like($got->{winner}, qr{Sancti/11-23\.txt\z}, 'Clement stays the universal office');
is($got->{rank}, '3', 'Clement stays III class');

$got = office_day(version => $gdl, y => 2026, m => 4, d => 27);
like($got->{winner}, qr{Sancti/04-27\.txt\z}, 'Apr 27 remains Canisius');
unlike($got->{title}, qr/Turib/, 'Turibius is not moved onto Apr 27');

$got = office_day(version => $gdl, y => 2026, m => 3, d => 23);
like($got->{winner}, qr{overlay/guadalajara/03-23\.txt\z}, '2026-03-23 is Turibius');
is($got->{rank}, '5', 'Turibius is II class in Lent');

$got = office_day(version => $gdl, y => 2026, m => 11, d => 11);
like($got->{winner}, qr{overlay/guadalajara/11-11\.txt\z}, 'Martin uses the diocesan file');
is($got->{rank}, '5', 'Martin is II class');

$got = office_day(version => $usa, y => 2026, m => 12, d => 12);
like($got->{winner}, qr{12-12n\.txt\z}, 'USA Guadalupe is unchanged');
$got = office_day(version => $sl, y => 2026, m => 8, d => 10);
like($got->{winner}, qr{overlay/stlawrence/08-10\.txt\z}, 'St. Lawrence Lawrence day is unchanged');
is($got->{rank}, '6', 'St. Lawrence rank is unchanged');

# Every source date resolves on a year when the day is not a Sunday.
my @dates = (
  [12, 12, 2026, qr{overlay/mexico/12-12}, '6'],
  [12, 18, 2026, qr{Tempora/}, ''],
  [1, 24, 2026, qr{overlay/guadalajara/01-24}, '3'],
  [2, 5, 2026, qr{overlay/guadalajara/02-05}, '3'],
  [2, 25, 2025, qr{overlay/guadalajara/02-25}, '3'],
  [3, 2, 2030, qr{overlay/guadalajara/03-02}, '3'],
  [3, 23, 2026, qr{overlay/guadalajara/03-23}, '5'],
  [5, 15, 2026, qr{overlay/guadalajara/05-15}, '3'],
  [5, 16, 2026, qr{overlay/guadalajara/05-16}, '5'],
  [7, 4, 2026, qr{overlay/guadalajara/07-04}, '5'],
  [8, 17, 2026, qr{overlay/guadalajara/08-17}, '3'],
  [8, 30, 2025, qr{overlay/guadalajara/08-30}, '6'],
  [10, 12, 2026, qr{overlay/guadalajara/10-12}, '6'],
  [10, 21, 2025, qr{overlay/guadalajara/10-21}, '3'],
  [10, 22, 2026, qr{overlay/guadalajara/10-22}, '6'],
  [11, 11, 2026, qr{overlay/guadalajara/11-11}, '5'],
);
$got = office_day(version => $gdl, y => 2026, m => 12, d => 18);
like($got->{winner}, qr{Tempora/Adv3-5\.txt\z}, '2026-12-18 keeps the Advent feria');
like($got->{comm}, qr{overlay/guadalajara/12-18\.txt\z}, 'Expectation is commemorated at the feria');

$got = office_day(version => $gdl, y => 2026, m => 2, d => 25);
like($got->{winner}, qr{Tempora/Quad1-3\.txt\z}, '2026-02-25 Ember Wednesday outranks Sebastian');
like($got->{comm}, qr{overlay/guadalajara/02-25\.txt\z}, 'Sebastian is commemorated on the Ember day');

$got = office_day(version => $gdl, y => 2026, m => 3, d => 2);
like($got->{winner}, qr{Tempora/Quad2-1\.txt\z}, '2026-03-02 Lenten feria outranks Gutierrez');
like($got->{comm}, qr{overlay/guadalajara/03-02\.txt\z}, 'Gutierrez is commemorated in Lent');

$got = office_day(version => $gdl, y => 2027, m => 5, d => 16);
like($got->{winner}, qr{Tempora/Pasc7-0\.txt\z}, '2027-05-16 Pentecost outranks Nepomucene');
is($got->{comm}, '', 'Pentecost does not commemorate the II class feast');

# Rubrics 1960 nn. 95-96: only a 1st class feast transfers, and it moves to the
# next day that is not 1st or 2nd class. Advent Sunday is item 6; a national
# patron is item 12, so the Sunday wins and Guadalupe moves to 13 December.
# 13 December 2027 is St Lucy, 3rd class, and the Advent feria is also 3rd class.
$got = office_day(version => $gdl, y => 2027, m => 12, d => 12);
like($got->{winner}, qr{Tempora/Adv3-0\.txt\z}, '2027-12-12 Advent Sunday is kept');
is($got->{comm}, '', 'the impeded I class feast is not reduced to a commemoration');
like($got->{note}, qr/Transfer/, '2027-12-12 records the transfer');

$got = office_day(version => $gdl, y => 2027, m => 12, d => 13);
like($got->{winner}, qr{overlay/mexico/12-12\.txt\z}, '2027-12-13 keeps the transferred Guadalupe');
is($got->{rank}, '6', 'the transferred feast stays I class');
like($got->{comm}, qr{Tempora/Adv3-1\.txt\z}, 'the Advent feria is the privileged commemoration');
unlike($got->{winner}, qr{12-13}, 'Lucy does not take the transferred day');

$got = office_day(version => $mx, y => 2027, m => 12, d => 13);
like($got->{winner}, qr{overlay/mexico/12-12\.txt\z}, 'Mexico transfers Guadalupe on the same day');

foreach my $year (2021, 2038) {
  $got = office_day(version => $gdl, y => $year, m => 12, d => 13);
  like($got->{winner}, qr{overlay/mexico/12-12\.txt\z}, "$year-12-13 also receives the transferred feast");
}

$got = office_day(version => $gdl, y => 2016, m => 3, d => 23);
like($got->{winner}, qr{Tempora/Quad6-3\.txt\z}, '2016-03-23 Holy Wednesday outranks Turibius');
is($got->{comm}, '', 'Holy Wednesday does not commemorate the II class feast');

$got = office_day(version => $gdl, y => 2026, m => 8, d => 30);
like($got->{winner}, qr{overlay/guadalajara/08-30\.txt\z}, '2026-08-30 Rose outranks the Sunday');
like($got->{comm}, qr{Pent14-0\.txt\z}, 'the Sunday is commemorated at Rose');

foreach my $row (@dates) {
  my ($m, $d, $y, $winner_re, $rank_s) = @$row;
  my $day = office_day(version => $gdl, y => $y, m => $m, d => $d);
  like($day->{winner}, $winner_re, "$y-$m-$d winner");
  is($day->{rank}, $rank_s, "$y-$m-$d rank") if $rank_s ne '';
}

done_testing;
