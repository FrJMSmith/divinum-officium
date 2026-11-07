package DivinumOfficium::ParticularCalendar;

use strict;
use warnings;
use utf8;

use Exporter qw(import);

our $VERSION = 1.00;
our @EXPORT_OK = qw(
  layers ordo_note mass_file episcopal_collect_file impedes_anniversary_collect
  propria_versions propria_entries validate_propria
);

use DivinumOfficium::Date qw(geteaster day_of_week date_to_ydays ydays_to_date leapyear);

my $CACHE;

# Records live in web/www/Tabulae/Propria and are read by this module.
# Office assignment still comes from Kalendaria/*.txt through Directorium.
# A later layer replaces only that date's kalendar line. occurrence() in
# horascommon.pl resolves the day against the temporal cycle.

sub _propria_root {
  return $ENV{PROPRIA_PATH} if defined $ENV{PROPRIA_PATH} && $ENV{PROPRIA_PATH} ne '';

  my $pm = $INC{'DivinumOfficium/ParticularCalendar.pm'}
    or die "ParticularCalendar.pm is not in %INC\n";
  $pm =~ s{/DivinumOfficium/ParticularCalendar\.pm$}{/../www/Tabulae/Propria};
  return $pm;
}

sub _read_records {
  my ($path) = @_;
  open my $fh, '<:encoding(UTF-8)', $path or die "Can't open $path: $!";

  my @recs;
  my %rec;
  my $key = '';

  my $flush = sub {
    return unless %rec;
    $rec{_path} = $path;
    push @recs, {%rec};
    %rec = ();
    $key = '';
  };

  while (my $line = <$fh>) {
    $line =~ s/\r?\n\z//;

    if ($line eq '---') {
      $flush->();
      next;
    }
    next if $line =~ /^\s*$/;
    next if $line =~ /^\s*#/;

    if ($line =~ /^([A-Za-z0-9_]+):\s*(.*)\z/) {
      $key = $1;
      $rec{$key} = $2;
    } elsif ($key && $line =~ /^[ \t]+(\S(?:.*\S)?)\z/) {
      $rec{$key} .= ($rec{$key} eq '' ? '' : ' ') . $1;
    } else {
      die "Unrecognized line in $path: $line\n";
    }
  }
  $flush->();
  return @recs;
}

sub _load {
  return $CACHE if $CACHE;

  my $root = _propria_root();
  die "No propria directory at $root\n" unless -d $root;

  my $versions_path = "$root/versions.txt";
  die "No $versions_path\n" unless -f $versions_path;
  my @versions = _read_records($versions_path);

  my @entries;

  for my $scope (qw(country institute diocese seminary apostolate)) {
    my $dir = "$root/$scope";
    next unless -d $dir;
    opendir my $dh, $dir or die "Can't open $dir: $!";
    my @places = sort grep { !/^\./ && -d "$dir/$_" } readdir $dh;
    closedir $dh;

    for my $place (@places) {
      opendir my $ph, "$dir/$place" or die "Can't open $dir/$place: $!";
      my @files = sort grep { /\.txt\z/ && !/^_/ && !/^README/i } readdir $ph;
      closedir $ph;

      for my $file (@files) {
        my ($rec) = _read_records("$dir/$place/$file");
        next unless $rec && defined $rec->{date} && $rec->{date} ne '';
        $rec->{_scope_dir} = $scope;
        push @entries, $rec;
      }
    }
  }

  $CACHE = {
    root => $root,
    versions => \@versions,
    entries => \@entries,
  };
  return $CACHE;
}

sub propria_versions {
  return @{_load()->{versions}};
}

sub propria_entries {
  return @{_load()->{entries}};
}

sub _version_row {
  my ($name) = @_;
  return unless defined $name;

  for my $row (propria_versions()) {
    next unless ($row->{status} || '') eq 'in-use';
    return $row if ($row->{version} || '') eq $name;
  }
  return;
}

sub layers {
  my ($version) = @_;
  my $row = _version_row($version);
  return () unless $row && ($row->{layers} || '') ne '';
  return split /,/, $row->{layers};
}

sub _has {
  my ($version, $layer) = @_;
  return grep { $_ eq $layer } layers($version);
}

sub _on_date {
  my ($version, $month, $day, $mass) = @_;

  for my $entry (propria_entries()) {
    next unless ($entry->{status} || '') eq 'in-use';
    next unless ($entry->{mass} || '') eq $mass;
    next unless _has($version, $entry->{layer} || '');
    my ($mm, $dd) = split /-/, ($entry->{date} || '');
    next unless defined $mm && defined $dd && $mm == $month && $dd == $day;
    return $entry;
  }
  return;
}

# Text added to the Ordo line. These IV class Masses do not take the office.
# They yield on a I or II class day (rank 5 and above).
sub ordo_note {
  my ($version, $day, $month, $rank) = @_;
  $rank = 0 unless defined $rank && $rank ne '';
  return '' if $rank >= 5;

  my $entry = _on_date($version, $month, $day, 'yes');
  return $entry ? ($entry->{note} || '') : '';
}

# Mass file that replaces the occurring Mass. Empty unless this version
# and this date assign one, and the day is below II class.
sub mass_file {
  my ($version, $day, $month, $rank) = @_;
  $rank = 0 unless defined $rank && $rank ne '';
  return '' if $rank >= 5;

  my $entry = _on_date($version, $month, $day, 'yes');
  return $entry ? ($entry->{file} || '') : '';
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

# One file covers both anniversaries. The dates and the file name come from
# in-use records whose mass field is collect. Rubric 449 still decides
# whether the anniversary is kept or moved.
sub episcopal_collect_file {
  my ($version, $day, $month, $year) = @_;
  return '' unless _has($version, 'harrisburg');
  return '' unless $day && $month && $year;

  for my $entry (propria_entries()) {
    next unless ($entry->{status} || '') eq 'in-use';
    next unless ($entry->{mass} || '') eq 'collect';
    next unless _has($version, $entry->{layer} || '');
    my ($mm, $dd) = split /-/, ($entry->{date} || '');
    next unless defined $mm && defined $dd;

    if (_observed_on($day, $month, $year, $dd + 0, $mm + 0)) {
      return $entry->{file} || '';
    }
  }
  return '';
}

sub _push_err {
  my ($errors, $msg) = @_;
  push @$errors, $msg;
  return;
}

sub _data_row {
  my ($path, $version) = @_;
  open my $fh, '<:encoding(UTF-8)', $path or return;

  while (my $line = <$fh>) {
    next if $line =~ /^\s*#/ || $line =~ /^\s*$/;
    my ($ver, $kal, $tra, $str, $base, $tbase) = split /,/, $line;
    next unless defined $ver && $ver eq $version;
    return {
      kalendar => $kal // '',
      transfer => $tra // '',
      stransfer => ($str // '') =~ s/\s+\z//r,
      base => $base // '',
      tbase => ($tbase // '') =~ s/\s+\z//r,
    };
  }
  return;
}

sub _kalendar_lines {
  my ($path) = @_;
  open my $fh, '<:encoding(UTF-8)', $path or die "Can't open $path: $!";
  my @lines;

  while (my $line = <$fh>) {
    $line =~ s/\r?\n\z//;

    # Comments in USA1962.txt contain an equals sign. Directorium keeps
    # that line as a non-date cache key. Only real MM-DD lines are records.
    next unless $line =~ /^\d{2}-\d{2}=/;
    push @lines, $line;
  }
  return @lines;
}

# Compare the in-use records with data.txt, the kalendar files, the version
# menus, and the proposal directory. Proposals are not part of layers().
sub validate_propria {

  my $data = _load();
  my $root = $data->{root};
  my $tabulae = "$root/..";
  my @errors;

  my %by_version;
  my %layer_of;

  for my $row (@{$data->{versions}}) {
    for my $key (qw(id version layer scope layers kalendar transfer stransfer base status)) {
      _push_err(\@errors, "version $row->{id} missing $key") if !defined $row->{$key} || $row->{$key} eq '';
    }
    next if @errors && !$row->{version};

    if (($row->{status} || '') ne 'in-use') {
      _push_err(\@errors, "version $row->{version} is not in-use; proposals do not belong in versions.txt");
    }

    if ($by_version{$row->{version} || ''}) {
      _push_err(\@errors, "duplicate version name $row->{version}");
    }
    $by_version{$row->{version}} = $row if $row->{version};
    $layer_of{$row->{layer}} = $row if $row->{layer};

    my $kal_path = "$tabulae/Kalendaria/$row->{kalendar}.txt";
    _push_err(\@errors, "missing kalendar $kal_path") if $row->{kalendar} && !-f $kal_path;
  }

  for my $row (values %by_version) {
    my @layers = split /,/, $row->{layers} || '';
    my $parent = $by_version{$row->{base} || ''};
    my @expect;

    if ($parent) {
      @expect = (split(/,/, $parent->{layers}), $row->{layer});
    } elsif (($row->{base} || '') eq 'Rubrics 1960 - 1960') {
      @expect = ($row->{layer});
    } else {
      _push_err(\@errors,
        "version $row->{version} base $row->{base} is not the universal 1960 calendar or another propria version",
      );
    }

    if (@expect && join(',', @layers) ne join(',', @expect)) {
      _push_err(\@errors, "version $row->{version} layers do not follow its base");
    }

    my $data_row = _data_row("$tabulae/data.txt", $row->{version});

    if (!$data_row) {
      _push_err(\@errors, "data.txt has no row for $row->{version}");
    } else {
      _push_err(\@errors, "data.txt kalendar for $row->{version} is not $row->{kalendar}")
        if $data_row->{kalendar} ne $row->{kalendar};
      _push_err(\@errors, "data.txt transfer for $row->{version} is not $row->{transfer}")
        if $data_row->{transfer} ne $row->{transfer};
      _push_err(\@errors, "data.txt stransfer for $row->{version} is not $row->{stransfer}")
        if $data_row->{stransfer} ne $row->{stransfer};
      _push_err(\@errors, "data.txt base for $row->{version} is not $row->{base}")
        if $data_row->{base} ne $row->{base};
      _push_err(\@errors, "data.txt tbase for $row->{version} is not $row->{base}")
        if $data_row->{tbase} ne $row->{base};
    }
  }

  my %seen_id;
  my %office_line;

  for my $entry (@{$data->{entries}}) {
    my $id = $entry->{id} || $entry->{_path};
    _push_err(\@errors, "$id missing id") if !$entry->{id};

    for my $key (qw(layer scope date title rank office mass provenance status evidence independent_source source)) {
      _push_err(\@errors, "$id missing $key") if !defined $entry->{$key} || $entry->{$key} eq '';
    }
    _push_err(\@errors, "$id duplicated") if $entry->{id} && $seen_id{$entry->{id}}++;
    _push_err(\@errors, "$id status must be in-use in the runtime directories")
      if ($entry->{status} || '') ne 'in-use';
    _push_err(\@errors, "$id scope does not match its directory $entry->{_scope_dir}")
      if ($entry->{scope} || '') ne ($entry->{_scope_dir} || '');
    _push_err(\@errors, "$id date is not MM-DD")
      if ($entry->{date} || '') !~ /^(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])\z/;
    _push_err(\@errors, "$id provenance is not a known kind")
      if ($entry->{provenance} || '') !~ /^(owner-supplied|upstream-text|mixed)\z/;
    _push_err(\@errors, "$id independent_source must say pending when no external decree is cited")
      if ($entry->{independent_source} || '') !~ /pending/;
    _push_err(\@errors, "$id source cites a decree this repository does not contain")
      if ($entry->{source} || '') =~ /\b(AAS|decree|rescript|prot\.)\b/i;

    my $layer_row = $layer_of{$entry->{layer} || ''};
    _push_err(\@errors, "$id layer is not one of the in-use versions") unless $layer_row;

    if (($entry->{office} || '') eq 'yes') {
      _push_err(\@errors, "$id office entry needs a kalendar field") if ($entry->{kalendar} || '') eq '';

      if ($layer_row && $entry->{date} && $entry->{kalendar}) {
        $office_line{$layer_row->{kalendar}}{$entry->{date}} = $entry->{kalendar};
        my ($main) = split /~/, $entry->{kalendar};
        my $text = "$tabulae/../horas/Latin/Sancti/$main.txt";
        _push_err(\@errors, "$id office file $text is missing") unless -f $text;
      }
    } elsif (($entry->{mass} || '') eq 'yes' || ($entry->{mass} || '') eq 'collect') {
      _push_err(\@errors, "$id needs a file") if ($entry->{file} || '') eq '';
      _push_err(\@errors, "$id mass-only entry needs a note")
        if ($entry->{mass} || '') eq 'yes' && ($entry->{note} || '') eq '';

      if ($entry->{file}) {
        _push_err(\@errors, "$id mass file is missing")
          unless -f "$tabulae/../missa/Latin/$entry->{file}";
      }
    } else {
      _push_err(\@errors, "$id office/mass combination is not one this loader understands");
    }
  }

  for my $kal (sort keys %office_line) {
    my $path = "$tabulae/Kalendaria/$kal.txt";
    my @lines = -f $path ? _kalendar_lines($path) : ();
    my %want = %{$office_line{$kal}};
    my %got;

    for my $line (@lines) {
      my ($date, $value) = split /=/, $line, 2;
      $got{$date} = $value;
    }

    for my $date (sort keys %want) {
      if (!defined $got{$date}) {
        _push_err(\@errors, "$kal.txt has no line for $date");
      } elsif ($got{$date} ne $want{$date}) {
        _push_err(\@errors, "$kal.txt $date does not match the propria record");
      }
    }

    for my $date (sort keys %got) {
      if (!defined $want{$date}) {
        _push_err(\@errors, "$kal.txt $date is not in the propria records");
      }
    }
  }

  for my $menu (qw(horas missa)) {
    my $dialog = "$tabulae/../$menu/$menu.dialog";
    my $text = '';

    if (open my $fh, '<:encoding(UTF-8)', $dialog) {
      local $/;
      $text = <$fh>;
    } else {
      _push_err(\@errors, "cannot read $dialog");
    }

    for my $row (values %by_version) {
      _push_err(\@errors, "$menu.dialog does not list $row->{version}") if index($text, $row->{version}) < 0;
    }
    _push_err(\@errors, "$menu.dialog no longer lists Rubrics 1960 - 2020 USA")
      if $menu eq 'horas' && index($text, 'Rubrics 1960 - 2020 USA') < 0;
  }

  my $proposal_dir = "$root/proposals";
  my $saw_example = 0;
  my @proposal_ids;

  if (!-d $proposal_dir) {
    _push_err(\@errors, 'proposals directory is missing');
  } else {
    opendir my $dh, $proposal_dir or die "Can't open $proposal_dir: $!";
    my @files = sort grep { /\.txt\z/ && !/^README/i } readdir $dh;
    closedir $dh;

    for my $file (@files) {
      my ($rec) = _read_records("$proposal_dir/$file");
      next unless $rec && exists $rec->{status};
      push @proposal_ids, $rec->{id} || $file;
      _push_err(\@errors, "$file is not status proposed") if ($rec->{status} || '') ne 'proposed';
      _push_err(\@errors, "$file uses an in-use layer") if $layer_of{$rec->{layer} || ''};

      if (($rec->{id} || '') eq 'EXAMPLE-NOT-A-CALENDAR') {
        $saw_example = 1;
        _push_err(\@errors, 'example proposal title does not say it is an example')
          if ($rec->{title} || '') !~ /EXAMPLE ONLY/;
        _push_err(\@errors, 'example proposal date should stay 00-00') if ($rec->{date} || '') ne '00-00';
      }
    }
  }
  _push_err(\@errors, 'example proposal EXAMPLE-NOT-A-CALENDAR is missing') unless $saw_example;

  my $runtime_blob = '';

  if (open my $fh, '<:encoding(UTF-8)', "$tabulae/data.txt") {
    local $/;
    $runtime_blob .= <$fh>;
  }

  for my $menu (qw(horas missa)) {
    if (open my $fh, '<:encoding(UTF-8)', "$tabulae/../$menu/$menu.dialog") {
      local $/;
      $runtime_blob .= <$fh>;
    }
  }

  if (opendir my $dh, "$tabulae/Kalendaria") {
    for my $name (grep {/\.txt\z/} readdir $dh) {
      if (open my $fh, '<:encoding(UTF-8)', "$tabulae/Kalendaria/$name") {
        local $/;
        $runtime_blob .= <$fh>;
      }
    }
    closedir $dh;
  }

  for my $id (@proposal_ids) {
    _push_err(\@errors, "proposal id $id appears in the runtime calendar")
      if $id ne '' && index($runtime_blob, $id) >= 0;
  }

  return @errors;
}

1;
