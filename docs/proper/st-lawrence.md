# St. Lawrence, worked example

Menu name, in the Office and in the Mass: **Rubrics 1960 - St. Lawrence**.

The stack, bottom to top:

1. `Rubrics 1960 - 1960`, the universal calendar. Its kalendar file is not copied.
2. `Rubrics 1960 - USA 1962`, country layer `usa`.
3. `Rubrics 1960 - FSSP`, institute layer `fssp`.
4. `Rubrics 1960 - Harrisburg`, diocese layer `harrisburg`.
5. `Rubrics 1960 - St. Lawrence`, apostolate layer `stlawrence`.

`web/www/Tabulae/data.txt` stores that chain. `versions.txt` stores the
same four selectable names. `ParticularCalendar::layers()` reads
`versions.txt`. The tests fail if the two disagree.

A layer file such as `Kalendaria/StLawrence.txt` has three date lines. It
does not contain the sanctoral cycle. For every other date,
`get_from_directorium()` walks `base`.

## What the engine does with a clash

`occurrence()` compares the temporal day with the sanctoral day and applies
the transfer table for that Easter date. Lines tagged `FSSP`, `Harrisburg`,
or `StLawrence` are the I class transfers. A II or III class day on a higher
Sunday is omitted by that comparison. The tests lock the outputs the engine
already returns, including:

- 22 February 2026, Chair of St. Peter, moved to 23 February, feria commemorated.
- 7 March 2027, Aquinas omitted on Laetare. Headline color `deeppink` (rose, optional in the engine).
- 1 August 2027, Peter in Chains omitted on the Sunday.
- 26 September 2027 and 12 December 2027 omitted on Sundays.
- 25 October 2026, Isidore omitted on Christ the King.
- 20 April 2025, Easter, dedication named as a transfer and kept on 28 April.
- 20 April 2030, Holy Saturday, dedication named as a transfer and kept on 29 April.
- 14 May 2026, Ascension, cathedral dedication kept on 15 May.
- 26 September 2025, Ember Friday, North American Martyrs commemorated at Lauds. Headline color `purple`.

The longer account of ranks, votive Masses, and collects is
[St. Lawrence particular calendar](../st-lawrence-calendar.md).

## Office and Mass on the same day

8 August is not a parish day. 10 August is. On the parish version the
Office and the Mass are both the I class overlay. On `Rubrics 1960 - USA 1962`
both stay the upstream II class file `Sancti/08-10.txt`.

22 January keeps the Office of Ss. Vincent and Anastasius. The peace Mass
is a separate file, used only when the occurring rank is below 5. The
Office headline colors as red because the title says Martyrum.
`liturgical_color('Missa votiva pro pace')` is purple. Those are two
titles, not one color.

25 April keeps the Office of St. Mark, or the Sunday when St. Mark is only
commemorated. The collect pro Episcopo is a Mass addition for Harrisburg
and St. Lawrence. FSSP does not have it. A Sunday that is not Easter does
not move it. Easter does.

5 November keeps the Office of the feria. The daily requiem is the Mass
note and the Mass file.

## Observed, and left as the engine has them

These are not changed here.

- `liturgical_color()` returns `black` for white vestments, including the
  dedication and Easter's title `Dominica Resurrectionis`. Peter in Chains
  on 1 August 2026 is `red` because the headline contains `Apostolorum`.
- On Saturday 1 August 2026 the universal 1960 Office is `Commune/` (Our
  Lady on Saturday) commemorating the Machabees in `08-01r`. The FSSP line
  `08-01` makes the Office St. Peter in Chains. That is the engine for that
  Saturday, not a second kalendar rule.
- Cabrini's upstream file still says Semiduplex, numeric 2.2. The parish
  document already records that the 1960 table prints this oddly. The file
  was not rewritten.
- Guadalupe's Mass still takes the introit from the common. No introit was
  added.
- No external instrument is cited for these assignments. The records say
  `independent_source: pending` and stay in use.
