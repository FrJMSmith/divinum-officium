#!/usr/bin/perl
# Report the St. Lawrence particular calendar for one date, or every
# I class feast across the Easter-date tables.
# Usage:
#   perl stlawrence-check.pl 2026-02-22
#   perl stlawrence-check.pl --scan
#   perl stlawrence-check.pl --transfers
use utf8;
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

# Scripture-transfer lookup lives in specmatins.pl. The winner name does not need it.
sub initiarule { return ''; }

use DivinumOfficium::Date qw(geteaster leapyear day_of_week getweek);
use DivinumOfficium::Directorium qw(get_from_directorium);

sub report_day {
  my ($y, $m, $d) = @_;
  $version = 'Rubrics 1960 - St. Lawrence';
  $hora = 'Laudes';
  $missa = 0;
  our ($day, $month, $year);
  ($day, $month, $year) = ($d, $m, $y);
  @dayname = (getweek($day, $month, $year, 0, 0), '', '');
  $dayofweek = day_of_week($day, $month, $year);
  occurrence($day, $month, $year, $version, '', 0);
  my $name = $dayname[1] || '';
  $name =~ s/\s+/ /g;
  my $note = $dayname[2] || '';
  $note =~ s/\s+/ /g;
  sprintf(
    "%04d-%02d-%02d dow=%d rank=%s winner=%s | %s | %s",
    $year, $month, $day, $dayofweek, (defined $rank ? $rank : ''),
    ($winner || ''), $name, $note
  );
}

my @watch = (
  [2, 22, 'overlay/fssp/02-22', 'FSSP', 6],
  [3, 7, 'overlay/fssp/03-07', '', 0],
  [3, 17, 'overlay/harrisburg/03-17', 'Harrisburg', 6],
  [4, 20, 'overlay/stlawrence/04-20', 'StLawrence', 6],
  [5, 14, 'overlay/harrisburg/05-14', 'Harrisburg', 6],
  [8, 10, 'overlay/stlawrence/08-10', 'StLawrence', 6],
  [10, 11, 'overlay/stlawrence/10-11', 'StLawrence', 6],
);

sub easter_code {
  my ($year) = @_;
  my @e = geteaster($year);
  return $e[1] * 100 + $e[0], leapyear($year);
}

if (@ARGV && $ARGV[0] eq '--transfers') {
  my %seen;
  my @out;

  # Wide enough to meet every Gregorian Easter date in the transfer tables,
  # including 22 March, which does not occur between 1900 and 2199.
  for my $year (1583 .. 2599) {
    for my $feast (@watch) {
      my ($month, $day, $file, $tag) = @$feast;
      next unless $tag;
      report_day($year, $month, $day);
      next if $winner && $winner =~ /\Q$file\E/;

      my ($dm, $dd, $dy) = ($month, $day, $year);
      my $dest;
      for (1 .. 50) {
        ($dd, $dm, $dy) = next_civil($dd, $dm, $dy);
        report_day($dy, $dm, $dd);
        my $busy = get_from_directorium('transfer', 'Rubrics 1960 - 1960', sprintf('%02d-%02d', $dm, $dd), $dy);
        my $home = 0;
        for my $other (@watch) {
          $home = 1 if $other->[0] == $dm && $other->[1] == $dd && $other->[4] >= 6;
        }
        if (($rank // 0) < 4.9 && !$busy && !$home) {
          $dest = sprintf('%02d-%02d', $dm, $dd);
          last;
        }
      }
      next unless $dest;
      # Rubric 111a: a I class day keeps only a privileged commemoration.
      # The season supplies those. The displaced III/IV class saint is omitted.
      my $value = $file;
      # The loader classifies a line by its destination (the key), and in a
      # leap year reads 1 January-23 February from the next Easter file.
      my ($dcode, $dleap) = easter_code($dy);
      my $early = $dm < 2 || ($dm == 2 && $dd <= 23);
      if ($dleap && $early) {
        $dcode++;
        $dcode = 401 if $dcode == 332;
      }
      my $entry = "$dest=$value;;$tag";
      my $key = "$dcode|$entry";
      next if $seen{$key}++;
      push @out, [$dcode, $entry, $year];
    }
  }
  for my $row (sort { $a->[0] <=> $b->[0] || $a->[1] cmp $b->[1] } @out) {
    print "$row->[0]\t$row->[1]\t# e.g. $row->[2]\n";
  }
  exit;
}

sub next_civil {
  my ($day, $month, $year) = @_;
  use DivinumOfficium::Date qw(date_to_ydays ydays_to_date leapyear);
  my $y = date_to_ydays($day, $month, $year) + 1;
  my $limit = 365 + (leapyear($year) ? 1 : 0);
  if ($y > $limit) { return (1, 1, $year + 1); }
  return ydays_to_date($y, $year);
}

if (@ARGV && $ARGV[0] eq '--scan') {
  for my $year (2025, 2026, 2027) {
    print report_day($year, $_->[0], $_->[1]), "\n" for (
      [1, 18], [1, 22], [2, 22], [2, 23], [3, 7], [3, 17],
      [4, 20], [4, 25], [4, 28], [5, 14], [5, 15], [5, 18],
      [7, 31], [8, 1], [8, 10], [9, 9], [9, 26], [10, 11],
      [10, 25], [11, 5], [11, 13], [12, 12]
    );
    print "\n";
  }
  exit;
}

my ($y, $m, $d) = split('-', $ARGV[0] || '2026-02-22');
print report_day($y, $m, $d), "\n";
