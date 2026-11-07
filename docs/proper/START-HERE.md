# Start here

These are the particular calendars this fork can select today. The universal
1960 calendar is not copied. Each layer adds only its own days. A version
selects a stack of layers. `occurrence()` and the tagged transfer tables
decide what happens when that day meets a Sunday, Holy Week, or another
higher day.

The menu names below are the strings in `web/www/horas/horas.dialog` and
`web/www/missa/missa.dialog`. `Rubrics 1960 - 2020 USA` is a different
upstream calendar and is not this stack.

| Select this | Scope | Layers, bottom to top | Status |
|---|---|---|---|
| Rubrics 1960 - USA 1962 | Country | usa | In use. Assignment is owner-supplied. |
| Rubrics 1960 - FSSP | Religious institute | usa, fssp | In use. Assignment is owner-supplied. |
| Rubrics 1960 - Harrisburg | Diocese | usa, fssp, harrisburg | In use. Assignment is owner-supplied. |
| Rubrics 1960 - St. Lawrence | Church / apostolate | usa, fssp, harrisburg, stlawrence | In use. Worked example below. |

No seminary layer is in use. No other apostolate is selectable. Drafts stay
in [`web/www/Tabulae/Propria/proposals/`](../../web/www/Tabulae/Propria/proposals/README.txt)
and are not loaded. The file
[`EXAMPLE-NOT-A-CALENDAR.txt`](../../web/www/Tabulae/Propria/proposals/EXAMPLE-NOT-A-CALENDAR.txt)
is a template, not a place.

Records are read by `DivinumOfficium::ParticularCalendar`. Office lines
remain in `web/www/Tabulae/Kalendaria/`. `data.txt` remains the version
chain. A record whose status is not `in-use` is not a menu and not a
kalendar line.

`independent_source: pending` means this repository does not cite an
external instrument for the assignment. It does not turn the day off.

## Country — United States

Selectable version: **Rubrics 1960 - USA 1962**. Layer `usa`. Base:
`Rubrics 1960 - 1960`. Kalendar: `Kalendaria/USA1962.txt`.

| Date | Title | Rank in the file | Office / Mass | Record |
|---|---|---|---|---|
| 09-09 | S. Petri Claver | 2, Duplex optional | Both, from the upstream `*n` file | [09-09](../../web/www/Tabulae/Propria/country/usa/09-09.txt) |
| 09-26 | Ss. Isaac Jogues, Jean de Brébeuf and Companions | 3, Duplex | Both | [09-26](../../web/www/Tabulae/Propria/country/usa/09-26.txt) |
| 10-25 | S. Isidore the Farmer | 2, Duplex | Both | [10-25](../../web/www/Tabulae/Propria/country/usa/10-25.txt) |
| 11-13 | S. Frances Xavier Cabrini | 2.2, Semiduplex | Both | [11-13](../../web/www/Tabulae/Propria/country/usa/11-13.txt) |
| 12-12 | Our Lady of Guadalupe | 3, Duplex | Both | [12-12](../../web/www/Tabulae/Propria/country/usa/12-12.txt) |
| 01-22 | Votive Mass for Peace | 1.2, IV class | Mass only | [01-22](../../web/www/Tabulae/Propria/country/usa/01-22.txt) |

## Religious institute — Priestly Fraternity of St. Peter

Selectable version: **Rubrics 1960 - FSSP**. Adds layer `fssp` on top of
the United States layer.

| Date | Title | Rank in the assigning file | Office / Mass | Record |
|---|---|---|---|---|
| 02-22 | Chair of St. Peter | 6, I class | Both. Upstream rubrica 196 rank is II class | [02-22](../../web/www/Tabulae/Propria/institute/fssp/02-22.txt) |
| 03-07 | St. Thomas Aquinas | 5, II class | Both. Upstream rank is Duplex, numeric 3 | [03-07](../../web/www/Tabulae/Propria/institute/fssp/03-07.txt) |
| 08-01 | St. Peter in Chains | 4, Duplex majus | Both. Replaces the 1960 Machabees line | [08-01](../../web/www/Tabulae/Propria/institute/fssp/08-01.txt) |
| 01-18 | Votive Mass of the Chair of St. Peter | 1.2, IV class | Mass only | [01-18](../../web/www/Tabulae/Propria/institute/fssp/01-18.txt) |
| 11-05 | Daily Mass of the Dead for the Fraternity's dead | 1.2, IV class | Mass only | [11-05](../../web/www/Tabulae/Propria/institute/fssp/11-05.txt) |

## Diocese — Harrisburg

Selectable version: **Rubrics 1960 - Harrisburg**. Adds layer `harrisburg`
on top of the Fraternity layer.

| Date | Title | Rank | Office / Mass | Record |
|---|---|---|---|---|
| 03-17 | St. Patrick | 6, I class | Both. Upstream rank is Duplex, numeric 3 | [03-17](../../web/www/Tabulae/Propria/diocese/harrisburg/03-17.txt) |
| 05-14 | Dedication of the cathedral | 6, I class | Both, from the common of the Dedication | [05-14](../../web/www/Tabulae/Propria/diocese/harrisburg/05-14.txt) |
| 04-25 | Collect pro Episcopo | not a feast | Mass collect | [04-25](../../web/www/Tabulae/Propria/diocese/harrisburg/04-25.txt) |
| 07-31 | Collect pro Episcopo | not a feast | Mass collect, same file | [07-31](../../web/www/Tabulae/Propria/diocese/harrisburg/07-31.txt) |

## Apostolate — St. Lawrence Church

Selectable version: **Rubrics 1960 - St. Lawrence**. This is the full
stack. The worked example is [St. Lawrence](st-lawrence.md). The longer
rubrical notes already in the repository are
[St. Lawrence particular calendar](../st-lawrence-calendar.md).

| Date | Title | Rank | Office / Mass | Record |
|---|---|---|---|---|
| 04-20 | Dedication of the church | 6, I class | Both, from the common of the Dedication | [04-20](../../web/www/Tabulae/Propria/apostolate/st-lawrence/04-20.txt) |
| 08-10 | St. Lawrence | 6, I class | Both. USA 1962 keeps the upstream II class | [08-10](../../web/www/Tabulae/Propria/apostolate/st-lawrence/08-10.txt) |
| 10-11 | Maternity of the Blessed Virgin | 6, I class | Both. Upstream rubrica 196 rank is numeric 5 | [10-11](../../web/www/Tabulae/Propria/apostolate/st-lawrence/10-11.txt) |

## Office and Mass

A record with `office: yes` and `mass: shared` is a kalendar line. The
Office and the Mass of the day both follow `occurrence()`, unless a
mass-only file replaces the Mass text.

A record with `office: no` and `mass: yes` does not take the Office. The
Ordo names it, and `precedence()` in `horascommon.pl` swaps the Mass file
when the occurring rank is below 5.

A record with `mass: collect` is added to the Mass under one conclusion.
`impedes_anniversary_collect()` can move 25 April and 31 July off the
precedence days that function lists. It does not replace the Office.

## Checks

From the repository root:

```
prove -Iweb/cgi-bin t/DivinumOfficium/ParticularCalendar.t t/DivinumOfficium/Propria.t t/DivinumOfficium/StLawrenceOccurrence.t
```

`perl web/cgi-bin/horas/stlawrence-check.pl --scan` prints 2025–2027.
`perl web/cgi-bin/horas/stlawrence-check.pl --transfers` reprints transfer
lines and does not write them.

The workflow **Particular calendar** runs that `prove` command on pull
requests that touch these files. It is not a required status check.

How to add a later calendar: [contributing](contributing.md).
Licenses already in the tree: [fork provenance](../fork-provenance.md).
