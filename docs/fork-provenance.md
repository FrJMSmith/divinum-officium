# Fork provenance and contributions

This repository is the public fork [FrJMSmith/divinum-officium](https://github.com/FrJMSmith/divinum-officium) of [DivinumOfficium/divinum-officium](https://github.com/DivinumOfficium/divinum-officium). GitHub lists it as public. Anyone who can clone it can read the files and the git history, so keep credentials, access tokens, and private correspondence out of commits and pull requests.

`master` in this fork is the upstream line, currently `22e1722c2fcdb4965229b72775c00830aecc141a`. St. Lawrence calendar work and the XHTML/EPUB heading fixes are on `st-lawrence`. The open branch `cursor/epubgen-stlawrence-b640` is the epubgen2 follow-up and is not in `st-lawrence`.

GitHub reports the repository license as the MIT License because of the root `LICENSE` file. That file is unchanged from upstream. The fork-only commits below do not add a license, a copyright line, or a replacement for any notice already in the tree. Choosing terms for those additions remains a decision for the maintainer of this fork. This note does not make that choice, and it does not name a copyright holder or year for them.

## Notices already in the tree

Leave these in place. This fork does not replace them.

- `LICENSE` is the MIT License. Its copyright line reads `Copyright (c) 2026 Divinum Officium`. Upstream added the file in `2e2ddf979451ff46f15017c937149c310071099c`.
- `README.md` includes an MIT permission notice, added upstream in `de5ab3648ba4060d45c137812bb44dff92e747ab`. That notice does not repeat the copyright line from `LICENSE`.
- `web/www/horas/Help/credits.html` states that the code and data are licensed under the MIT License, and that the liturgical texts on the site are, to the best of the project's knowledge, from the public domain. The same page records source permissions and exceptions in its language sections. Those include English hymns used with the permission of Jeffrey Tucker, Italian material used with permission, Hungarian scripture described there as free to fair use, the Polish-Newer transcription C used by permission of the copyright holder, and a note that one Internet Archive set of the English breviary is apparently copyrighted.
- `web/www/horas/Help/technical.html` gives the project's own account of the MIT License and names the chant sources it builds on (exsurge, jgabc, and GregoBase transcriptions described there as public domain).
- Two rubrics pages carry a Creative Commons Attribution-ShareAlike 2.5 permit line, `http://creativecommons.org/licenses/by-sa/2.5/`:
  - `web/www/horas/Help/Rubrics/Rubricarum Instructum.html`, with the source URL printed on that page
  - `web/www/horas/Help/Rubrics/General Rubrics.html`, with the citation of Fr. Kevin Seasoltz, *The New Liturgy: A Documentation, 1903-1966*, and the source URL printed on that page
- Vendored copies keep their own MIT notices:
  - `web/www/js/exsurge.js` and `web/www/js/exsurge3.js` include `Copyright (c) 2008-2016 Fr. Matthew Spencer, OSJ`
  - `web/www/js/exsurge3.js` also includes a separate MIT notice, `Copyright (c) 2019`, beside the Benjamin Bloomfield author line
  - `web/www/js/jquery.min.js` is jQuery v1.7 and its header points to `jquery.org/license`
- `web/cgi-bin/horas/webdia.pl` contains `<META NAME="Copyright" CONTENT="Like GNU">`. That element is not the `LICENSE` file.
- `.github/CODEOWNERS` names `@DivinumOfficium/infrastructure-team` for `Dockerfile`, `docker`, and `.github`. That file is unchanged.

## Fork-only commits

These commits are reachable from this fork's branches and are not in `master`:

| Commit | Subject |
|---|---|
| `3f6d51fb3bbb4cabbaccce6840429bbf79eb86fb` | Add the St. Lawrence 1962 calendar as stacked kalendar layers. |
| `d857d87c28430c94fc03eb879728ccca19aa4600` | Merge pull request #1 from FrJMSmith/cursor/st-lawrence-calendar-b551 |
| `96eb3ef6e94624e55a1a43e95c7ee3597d08676a` | Escape ampersands in Office heading comments for XHTML. |
| `a9fc05e0423b5219d717df8fe1b597b9b9adb29e` | Escape ampersands in EPUB Office headings |
| `f0db63e69be78287638a4a418d87ef2fc5a13da1` | Add epubgen2 -r codes for the St. Lawrence calendar stack. (branch `cursor/epubgen-stlawrence-b640` only) |

`docs/st-lawrence-calendar.md` describes the calendar layers, ranks, dates, and generators those commits add. Keep the liturgical texts, ranks, dates, generators, and the notices above when changing them.

## Proposing a change

Open a pull request against `st-lawrence` for work on this fork. Keep `master` for the upstream line.

Use a pull request to update `st-lawrence` or `master`. Do not force-push those branches, delete them, or rewrite published history.

Preserve the notices listed above. Preserve liturgical texts, calendar ranks and dates, and generators. Add a copyright line or a new license file only when it records a decision the maintainer has actually made.

The "Contributing to the project" section of `README.md` is the upstream project's process. It refers to `https://github.com/DivinumOfficium/divinum-officium`.
