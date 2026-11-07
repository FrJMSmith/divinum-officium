use strict;
use warnings;
use utf8;

use lib 'web/cgi-bin';
use DivinumOfficium::ParticularCalendar
  qw(layers propria_entries propria_versions validate_propria);
use Test::More;

my @errors = validate_propria();
ok(!@errors, 'propria records match the loader') or diag join("\n", @errors);

is(scalar(propria_versions()), 6, 'six selectable versions');
is(scalar(propria_entries()), 34, 'in-use records include Mexico and Guadalajara');

my @not_in_use = grep { ($_->{status} || '') ne 'in-use' } propria_entries();
ok(!@not_in_use, 'loaded entries are in use');
my @examples = grep { ($_->{id} || '') eq 'EXAMPLE-NOT-A-CALENDAR' } propria_entries();
ok(!@examples, 'the example is not loaded');

is_deeply([layers('Rubrics 1960 - 1960')], [], 'universal 1960 is not a propria version');
is_deeply([layers('Rubrics 1960 - 2020 USA')], [], 'the 2020 USA calendar stays off this stack');
is_deeply(
  [layers('Rubrics 1960 - St. Lawrence')],
  [qw(usa fssp harrisburg stlawrence)],
  'St. Lawrence still selects the four layers',
);

my %layers = map { $_->{layer} => $_->{scope} } propria_versions();
is($layers{usa}, 'country', 'USA is the country layer');
is($layers{fssp}, 'institute', 'FSSP is the institute layer');
is($layers{harrisburg}, 'diocese', 'Harrisburg is the diocese layer');
is($layers{stlawrence}, 'apostolate', 'St. Lawrence is the apostolate layer');
ok(!exists $layers{example}, 'no seminary or example layer is selectable');

my @scopes = map { $_->{scope} } propria_entries();
my @seminary = grep { $_ eq 'seminary' } @scopes;
ok(!@seminary, 'no seminary entry was invented');

done_testing;
