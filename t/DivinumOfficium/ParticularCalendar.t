use strict;
use warnings;
use utf8;

use lib 'web/cgi-bin';
use DivinumOfficium::Date qw(geteaster);
use DivinumOfficium::ParticularCalendar
  qw(layers ordo_note mass_file episcopal_collect_file impedes_anniversary_collect);
use Test::More;

is_deeply([layers('Rubrics 1960 - 1960')], [], 'universal 1960 has no particular layer');
is_deeply([layers('Rubrics 1960 - USA 1962')], ['usa'], 'USA 1962 is only the first layer');
is_deeply([layers('Rubrics 1960 - FSSP')], ['usa', 'fssp'], 'FSSP stacks on USA');
is_deeply(
  [layers('Rubrics 1960 - Harrisburg')],
  ['usa', 'fssp', 'harrisburg'],
  'Harrisburg stacks on FSSP',
);
is_deeply(
  [layers('Rubrics 1960 - St. Lawrence')],
  ['usa', 'fssp', 'harrisburg', 'stlawrence'],
  'the parish calendar is the full stack',
);
is_deeply([layers('Rubrics 1960 - 2020 USA')], [], 'the 2020 USA version is not this stack');

is(
  ordo_note('Rubrics 1960 - St. Lawrence', 22, 1, 2.2),
  'Missa votiva pro pace (IV. classis)',
  '22 January votive is named below II class',
);
is(ordo_note('Rubrics 1960 - St. Lawrence', 22, 1, 5), '', 'the peace votive yields on a II class day');
is(ordo_note('Rubrics 1960 - USA 1962', 18, 1, 1), '', 'the Chair votive is not on the USA layer');
is(
  mass_file('Rubrics 1960 - FSSP', 5, 11, 1),
  'Sancti/overlay/fssp/11-05.txt',
  '5 November requiem is an FSSP Mass',
);
is(mass_file('Rubrics 1960 - USA 1962', 5, 11, 1), '', '5 November is not a USA Mass');

ok(!impedes_anniversary_collect(25, 4, 2027), 'a Sunday that is not Easter does not impede the collect');
is(
  episcopal_collect_file('Rubrics 1960 - St. Lawrence', 25, 4, 2026),
  'Sancti/overlay/harrisburg/pro-episcopo.txt',
  '25 April 2026 keeps the collect pro Episcopo',
);
is(episcopal_collect_file('Rubrics 1960 - FSSP', 25, 4, 2026), '', 'FSSP alone has no diocesan collect');
is(episcopal_collect_file('Rubrics 1960 - St. Lawrence', 26, 4, 2026), '', 'the next day is not the anniversary');

my $easter_year;
for my $year (2020 .. 2100) {
  my @easter = geteaster($year);
  if ($easter[0] == 25 && $easter[1] == 4) {
    $easter_year = $year;
    last;
  }
}
ok($easter_year, 'some year in range has Easter on 25 April');
if ($easter_year) {
  ok(impedes_anniversary_collect(25, 4, $easter_year), 'Easter Sunday impedes the collect');
  is(
    episcopal_collect_file('Rubrics 1960 - Harrisburg', 25, 4, $easter_year),
    '',
    'the collect is not said on Easter',
  );
  is(
    episcopal_collect_file('Rubrics 1960 - Harrisburg', 26, 4, $easter_year),
    'Sancti/overlay/harrisburg/pro-episcopo.txt',
    'an Easter anniversary moves to the next day',
  );
}

done_testing;
