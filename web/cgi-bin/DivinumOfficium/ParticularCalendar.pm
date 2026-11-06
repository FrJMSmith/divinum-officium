package DivinumOfficium::ParticularCalendar;

use strict;
use warnings;
use utf8;

use Exporter qw(import);

our $VERSION = 1.00;
our @EXPORT_OK = qw(layers ordo_note mass_file episcopal_collect_file impedes_anniversary_collect);

use DivinumOfficium::Date qw(geteaster day_of_week date_to_ydays ydays_to_date leapyear);

# Layers, later ones winning, for the St. Lawrence particular calendar.
# The kalendar files themselves stack through data.txt; this list is only
# for the few assignments that are a Mass and not an office.
sub layers {
  my ($version) = @_;
  return () unless defined $version;
  return () unless $version =~ /^Rubrics 1960 - (?:USA 1962|FSSP|Harrisburg|St\. Lawrence)\z/;

  my @layers = ('usa');
  push @layers, 'fssp' if $version =~ /FSSP|Harrisburg|St\. Lawrence/;
  push @layers, 'harrisburg' if $version =~ /Harrisburg|St\. Lawrence/;
  push @layers, 'stlawrence' if $version =~ /St\. Lawrence/;
  return @layers;
}

sub _has {
  my ($version, $layer) = @_;
  return grep { $_ eq $layer } layers($version);
}

# Text added to the Ordo line. These IV class Masses do not take the office.
# They yield on a I or II class day (rank 5 and above).
sub ordo_note {
  my ($version, $day, $month, $rank) = @_;
  $rank = 0 unless defined $rank && $rank ne '';
  return '' if $rank >= 5;

  if (_has($version, 'usa') && $month == 1 && $day == 22) {
    return 'Missa votiva pro pace (IV. classis)';
  }
  if (_has($version, 'fssp') && $month == 1 && $day == 18) {
    return 'Missa votiva Cathedræ S. Petri (IV. classis)';
  }
  if (_has($version, 'fssp') && $month == 11 && $day == 5) {
    return 'Missa cotidiana Defunctorum pro defunctis Sodalitatis (IV. classis)';
  }
  return '';
}

# Mass file that replaces the occurring Mass. Empty unless this version
# and this date assign one, and the day is below II class.
sub mass_file {
  my ($version, $day, $month, $rank) = @_;
  $rank = 0 unless defined $rank && $rank ne '';
  return '' if $rank >= 5;

  if (_has($version, 'usa') && $month == 1 && $day == 22) {
    return 'Sancti/overlay/usa/01-22.txt';
  }
  if (_has($version, 'fssp') && $month == 1 && $day == 18) {
    return 'Sancti/overlay/fssp/01-18.txt';
  }
  if (_has($version, 'fssp') && $month == 11 && $day == 5) {
    return 'Sancti/overlay/fssp/11-05.txt';
  }
  return '';
}

# Missal rubric 449: the collect is omitted on table-of-precedence days
# 1, 2, 3 and 8, and said on the next day that is not one of those.
# 1 Christmas, Easter, Pentecost. 2 the sacred Triduum.
# 3 Epiphany, Ascension, Trinity, Corpus Christi, Sacred Heart, Christ the King.
# 8 All Souls, which yields to a Sunday.
sub impedes_anniversary_collect {
  my ($day, $month, $year) = @_;
  return 0 unless $day && $month && $year;
  return 1 if $month == 12 && $day == 25;
  return 1 if $month == 1 && $day == 6;
  return 1 if $month == 11 && $day == 2 && (day_of_week($day, $month, $year) // -1) != 0;

  my @easter = geteaster($year);
  my $delta = date_to_ydays($day, $month, $year) - date_to_ydays($easter[0], $easter[1], $year);
  return 1 if $delta >= -3 && $delta <= 0;
  return 1 if $delta == 39;
  return 1 if $delta == 49;
  return 1 if $delta == 56;
  return 1 if $delta == 60;
  return 1 if $delta == 68;
  return 1 if _christ_the_king($day, $month, $year);
  return 0;
}

sub _christ_the_king {
  my ($day, $month, $year) = @_;
  return 0 unless $month == 10;

  for my $dd (reverse 25 .. 31) {
    if ((day_of_week($dd, 10, $year) // -1) == 0) {
      return $day == $dd;
    }
  }
  return 0;
}

sub _next_ymd {
  my ($day, $month, $year) = @_;
  my $yday = date_to_ydays($day, $month, $year) + 1;
  my $limit = 365 + (leapyear($year) ? 1 : 0);

  if ($yday > $limit) {
    return (1, 1, $year + 1);
  }
  return ydays_to_date($yday, $year);
}

sub _observed_on {
  my ($day, $month, $year, $ad, $am) = @_;
  my ($d, $m, $y) = ($ad, $am, $year);

  for (1 .. 16) {
    if (!impedes_anniversary_collect($d, $m, $y)) {
      return $d == $day && $m == $month && $y == $year;
    }
    ($d, $m, $y) = _next_ymd($d, $m, $y);
  }
  return 0;
}

# One file covers both anniversaries: the Missal uses the same three prayers
# for the election (or appointment) and for the consecration.
sub episcopal_collect_file {
  my ($version, $day, $month, $year) = @_;
  return '' unless _has($version, 'harrisburg');
  return '' unless $day && $month && $year;

  if ( _observed_on($day, $month, $year, 25, 4)
    || _observed_on($day, $month, $year, 31, 7))
  {
    return 'Sancti/overlay/harrisburg/pro-episcopo.txt';
  }
  return '';
}

1;
