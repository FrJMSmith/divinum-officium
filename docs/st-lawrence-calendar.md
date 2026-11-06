# St. Lawrence particular calendar (1962)

Parish calendar of St. Lawrence Church (FSSP, Diocese of Harrisburg), on the 1962 class system. `master` is unchanged. Select the calendar in the version menu of the Office or the Mass.

## How to select it

| Menu name | What it is |
|---|---|
| Rubrics 1960 - USA 1962 | United States days from the parish list only |
| Rubrics 1960 - FSSP | that layer, plus the Fraternity |
| Rubrics 1960 - Harrisburg | those, plus the diocese |
| Rubrics 1960 - St. Lawrence | the full stack (this is the one to use) |

Later layers win. Each layer is a kalendar file that records only its own days. `web/www/Tabulae/data.txt` chains them:

`1960` → `USA1962` → `FSSP` → `Harrisburg` → `StLawrence`

The engine reads the selected kalendar first and walks `base` for every other day (`get_from_directorium` in `Directorium.pm`). Rank and texts still come from the saint or common file the kalendar names. Upstream Sancti files are not edited. A day that only changes rank is a short file under `Sancti/overlay/` whose first line is `@Sancti/…` or `@Commune/C8`, so the existing proper is reused.

This is not `Kalendaria/NC.txt` (“Rubrics 1960 - 2020 USA”). That file adds later optional feasts (Fatima, Goretti, Padre Pio, and others) which are not on this list.

## What each layer does

**USA** (`Kalendaria/USA1962.txt`): 9 September Peter Claver, 26 September North American Martyrs, 25 October Isidore, 13 November Cabrini, 12 December Guadalupe. These point at the existing `*n` files. Under the 1960 rank table their numbers (2 or 3) are III class. Guadalupe’s Secret and Postcommunion are not in `12-12n`, so they come from the Common of the Blessed Virgin (`vide C11`).

**FSSP**: 22 February Chair of St. Peter raised to I class; 7 March St. Thomas Aquinas raised to II class; 1 August St. Peter in Chains (`08-01`) instead of the 1962 Holy Machabees (`08-01r`).

**Harrisburg**: 17 March St. Patrick, principal patron, I class; 14 May Dedication of the cathedral, I class, from the Common of the Dedication of a Church (C8). The universal saint that day is St. Boniface; the I class dedication replaces him.

**Parish**: 20 April Dedication of the church, I class, from C8 (there is no stock `04-20`); 10 August St. Lawrence, titular, I class; 11 October Maternity of the Blessed Virgin (Mater Dei) kept as I class. The parish table treats that I class as optional and uses it in every listed year, so the layer does too.

## Occurrence

Feasts stay on their dates in the kalendar. A clash is computed, not stored as a deletion.

- A I class feast impeded by a higher day is transferred to the next day that is not I or II class (General Rubrics n. 96). The lines are in `Tabulae/Transfer/`, tagged `FSSP`, `Harrisburg`, or `StLawrence`. A 1960 calendar does not read those tags. In a leap year the loader reads 1 January–23 February from the next Easter file, and the February lines are placed there.
- II and III class feasts on a higher Sunday are omitted, not transferred. Checked against the parish’s own examples: 2026-02-22 Chair of Peter (now I class) moves to 23 February; 2027-03-07 Aquinas is omitted on Laetare; 2027-08-01 Peter in Chains, 2027-09-26 the North American Martyrs, and 2027-12-12 Guadalupe are omitted on Sundays; 2026-10-25 Isidore is omitted on Christ the King.
- On a transferred I class day the engine still commemorates a privileged feria (Lent, Advent). The displaced III or IV class saint is not kept (Rubric 111a).

Two dates where the parish spreadsheet names the standing day and the rubrics move the feast:

- 20 April 2025 is Easter. The Dedication is transferred to 28 April. Easter Sunday shows “Transfer”.
- 14 May 2026 is the Ascension. The cathedral dedication is transferred to 15 May.

26 September 2025 is Ember Friday, a II class feria. The North American Martyrs remain III class and are commemorated; the Ember day is the office. The spreadsheet names the feast.

`web/cgi-bin/horas/stlawrence-check.pl` reprints a day’s winner. `perl stlawrence-check.pl --scan` covers the sample dates in 2025–2027. `perl stlawrence-check.pl --transfers` reprints the I class transfer lines (it does not write them).

## Masses that are not an office

These stay off the kalendar so the Office remains the occurring day. The Ordo line names them. On a I or II class day (rank 5 or higher) they are not said.

- **22 January, Votive Mass for Peace, IV class** (USA, at the request of the USCCB). Text is the Missale Romanum *Missa votiva pro pace*: introit and collect already in the database, the rest from that Mass. No Gloria and no Creed (nn. 389, 432). Vestments violet. The universal office that day is still Ss. Vincent and Anastasius. A IV class votive is normally allowed only on a IV class day (n. 387); the parish table assigns this Mass to the date whenever the day is below II class, and that is what the Mass page does.
- **18 January, Chair of St. Peter, IV class votive** (FSSP). The propers are the existing 18 January Mass (`Sancti/01-18`). The Roman books call that day the Chair at Rome; the parish preamble calls it the Chair at Antioch. The votive is titled with the parish’s name. No Gloria and no Creed.
- **5 November, daily Mass for the dead** for deceased FSSP and Confraternity members (C9). The three prayers are C9’s *Oratio2* / *Secreta2* / *Postcommunio2* (“nostrae congregationis fratres, propinquos et benefactores”). *Dies irae* comes with C9. Rubric n. 399 allows omitting it in a daily requiem.

## Collects under one conclusion

- **25 April and 31 July, pro Episcopo.** Added to every Mass that is not a requiem, for Harrisburg and St. Lawrence only. The three prayers are the Missal’s anniversary of the election or consecration of the bishop, with the name in Latin: Timotheum Christianum Seniorem, Ecclesiae Harrisburgensis. Missal n. 449 withholds the collect on precedence days 1, 2, 3 and 8 (Christmas, the Triduum, Easter, Pentecost, Epiphany, Ascension, Trinity, Corpus Christi, Sacred Heart, Christ the King, and All Souls when it is not a Sunday). It is then said on the next day that is not one of those. A Sunday that is not Easter does not move it, which matches 25 April 2027.
- **18 May, pro Papa.** Already in the program for every calendar: `check_coronatio` in `Directorium.pm` appends `Commune/Coronatio` on 18 May. The conclusion is the one the Missal uses for an anniversary. The name is the Mass option “Pope”. Enter `Leone` (the form the program declines): the accusative becomes Leonem. That hook does not apply n. 449’s exception for days 1, 2, 3 and 8. It was left as it is, because changing it would change every calendar, not only this one.

## Gaps left on purpose

- Guadalupe’s introit is not in `12-12n.txt`. The Mass introit therefore comes from the Common of the Blessed Virgin, together with the Secret and Postcommunion. The briefing says the old green missal’s introit is proper. No introit was written in, because the stock file does not contain one.
- New overlay files are Latin. Another language falls back to Latin for those sections.
- The full-year Ordo cache is not prebuilt for these four version names.
- The numeric rank in a few universal files still prints oddly under 1960 (Cabrini and Didacus are stored as Semiduplex 2.2, which the 1960 table indexes as III class). Those files were not rewritten.
