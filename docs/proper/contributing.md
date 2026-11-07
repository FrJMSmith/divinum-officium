# Adding a particular day

One small pull request. Open it against `st-lawrence`. Do not force-push
`st-lawrence` or `master`.

The runtime calendar is only what `versions.txt`, `data.txt`, the
`Kalendaria` files, and the version menus already name. `occurrence()` is
the rubrics engine. Do not replace it with a last-match rule, and do not
copy `Kalendaria/1960.txt` into a new file.

## A proposal is not selectable

1. Copy [`EXAMPLE-NOT-A-CALENDAR.txt`](../../web/www/Tabulae/Propria/proposals/EXAMPLE-NOT-A-CALENDAR.txt) to a new file in that same `proposals/` directory.
2. Replace the example id, title, and date. Leave `status: proposed`.
3. Do not use the example id. Do not leave the title saying `EXAMPLE ONLY` on a file you hope to activate. Do not invent a diocese, institute, seminary, or church to fill the blanks.
4. Set `independent_source: pending` until the pull request can name a public source or a file already in this repository. `evidence: owner-supplied` is the right evidence line when the maintainer supplied the list and no external instrument is cited.
5. Do not add prayers, readings, or homilies. Point `kalendar` or `file` at a common or an existing Sancti file (`@Sancti/…`, `@Commune/…`).

`layers()`, `ordo_note()`, `mass_file()`, and `episcopal_collect_file()` do
not read `proposals/`. `validate_propria()` fails if a proposal is
`in-use`, if it reuses an in-use layer name, or if its id appears in
`data.txt`, a version menu, or any kalendar file.

## Marking a day in use

Do this only in the pull request that should change the calendar, and only
for a day whose record is no longer the example template.

- Add or extend a layer under `country/`, `institute/`, `diocese/`, `seminary/`, or `apostolate/`. A seminary directory does not exist yet. Create one only for a real seminary layer.
- Put `status: in-use` on the record. `office: yes` requires the same `MM-DD=` line in that layer's `Kalendaria` file. `mass: yes` requires `office: no`, a `note`, and a Mass file under `web/www/missa/Latin/`. `mass: collect` is a Mass addition, not an Office.
- Add the version to `web/www/Tabulae/Propria/versions.txt` if it is a new menu name. The `layers` field is the parent's layers plus this layer. `base` is the parent version, or `Rubrics 1960 - 1960` for a country layer.
- Add the same version, kalendar, transfer tag, `1960` scripture tag, and base to `web/www/Tabulae/data.txt`.
- Add the menu string to both `horas.dialog` and `missa.dialog` if both should offer it. Say in the pull request if one of them should not.
- Keep the universal files, the existing St. Lawrence lines, and the license notices unchanged unless the pull request is explicitly about one of those lines.

## Fields

| Field | What to write |
|---|---|
| id | Stable token. Not `EXAMPLE-NOT-A-CALENDAR`. |
| layer | Short token shared with `versions.txt`. |
| scope | `country`, `institute`, `diocese`, `seminary`, or `apostolate`. |
| date | `MM-DD`, or `00-00` only on the example template. |
| title | Name as in the file's Officium or Rank, not a new composition. |
| rank | Numeric rank from the assigning file. `n/a` for a collect. |
| rank_name | Class words from that file, if it has them. |
| office | `yes` or `no`. |
| mass | `shared`, `yes`, `collect`, or `no`. |
| kalendar | The right-hand side of the kalendar line when `office` is `yes`. |
| file | Mass path relative to `missa/Latin/` when the Mass is not the Office. |
| note | Ordo sentence for a mass-only day. |
| provenance | `owner-supplied`, `upstream-text`, or `mixed`. |
| status | `proposed` or `in-use`. |
| evidence | Who supplied the assignment, in a few words. |
| independent_source | `pending`, or `pending` plus the upstream path, until an external source is actually cited. |
| source | Repository paths and what those files say. |

## Command

From the repository root:

```
prove -Iweb/cgi-bin t/DivinumOfficium/ParticularCalendar.t t/DivinumOfficium/Propria.t t/DivinumOfficium/StLawrenceOccurrence.t
```

That is 137 tests on this tree: the older particular-calendar checks, the
registry check, and the Office/Mass days in ordinary and collision years
(2025–2027 and Holy Saturday 2030). It does not scan every Easter date.
`stlawrence-check.pl --transfers` still only prints.

The GitHub workflow file `.github/workflows/propria.yml` runs the same
command. Its name is `Particular calendar` and its job is `propria-tests`.
Nothing in the ruleset requires that job.
