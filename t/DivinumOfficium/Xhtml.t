use strict;
use warnings;
use utf8;

use lib 'web/cgi-bin';
use DivinumOfficium::Xhtml qw(xhtml_escape);
use Test2::V0;

# 18 January 2027, Rubrics 1960 particular calendar: the comment joins
# the commemoration and the votive Mass with a bare ampersand.
is(
  xhtml_escape(
    'Commemoratio  ad Laudes tantum: S. Priscæ Virginis et Martyris & Missa votiva Cathedræ S. Petri (IV. classis)'),
  'Commemoratio  ad Laudes tantum: S. Priscæ Virginis et Martyris &amp; Missa votiva Cathedræ S. Petri (IV. classis)',
  '18 January comment ampersand is escaped',
);

# 22 January 2027, same calendar.
is(
  xhtml_escape('Tempora: Feria VI infra Hebdomadam II post Epiphaniam & Missa votiva pro pace (IV. classis)'),
  'Tempora: Feria VI infra Hebdomadam II post Epiphaniam &amp; Missa votiva pro pace (IV. classis)',
  '22 January comment ampersand is escaped',
);

is(
  xhtml_escape('S. Thomæ <i>Cantuariensis,</i> Episcopi & Martyris'),
  'S. Thomæ <i>Cantuariensis,</i> Episcopi &amp; Martyris',
  'rank italics stay and the ampersand is escaped',
);

is(
  xhtml_escape('Commemoratio: Dominica<br/>Vespera de sequenti & nihil <de> præcedenti'),
  'Commemoratio: Dominica<br/>Vespera de sequenti &amp; nihil &lt;de&gt; præcedenti',
  'a concurrence line break stays and stray brackets are escaped',
);

is(xhtml_escape('already &amp; &#160; &#xA0;'), 'already &amp; &#160; &#xA0;', 'existing entities are not doubled');
is(xhtml_escape('ad Laudes & Matutinum'), 'ad Laudes &amp; Matutinum', 'Lauds and Matins ampersand is escaped');
is(xhtml_escape(undef), '', 'undef is empty');
is(xhtml_escape(''), '', 'empty stays empty');

done_testing;
