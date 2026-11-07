#!/bin/bash
# Builds placeholder EPUBs (no office text) and checks the generated contents.
# Monthly, yearly, and a two-year run are separate books. The native menu is
# month then date. Hour names stay as links in the contents page.
set -euo pipefail

ROOT=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
GEN="$ROOT/standalone/tools/epubgen2"
command -v cal >/dev/null
command -v python3 >/dev/null
command -v zip >/dev/null

build() {
	local out=$1
	shift
	mkdir -p "$out"
	(
		cd "$GEN"
		EPUBGEN_NAV_ONLY=1 ./epubgen2.sh -o "$out" "$@"
	)
}

A=$(mktemp -d)
B=$(mktemp -d)
P=$(mktemp -d)
M=$(mktemp -d)
trap 'rm -rf "$A" "$B" "$P" "$M"' EXIT

echo "build 2023-2024"
build "$A" -y 2023 -t 2024
echo "rebuild 2023"
build "$B" -y 2023 -t 2023
echo "build 2023 priest"
build "$P" -y 2023 -t 2023 -p
echo "build 2023 with Mass"
build "$M" -y 2023 -t 2023 -m

python3 - "$A" "$B" "$P" "$M" <<'PY'
import sys, zipfile, re
from collections import Counter
from pathlib import Path
from xml.etree import ElementTree as ET

A, B, P, M = map(Path, sys.argv[1:])
NS = {"n": "http://www.daisy.org/z3986/2005/ncx/"}
OPF = {"o": "http://www.idpf.org/2007/opf", "dc": "http://purl.org/dc/elements/1.1/"}
HOURS = ["Matutinum", "Laudes", "Prima", "Tertia", "Sexta", "Nona", "Vespera", "Completorium"]
OLD_UUID = "f85e2f34-fa9b-4211-ad58-2c74dc43861f"

def epub(directory, name):
    path = directory / name
    assert path.is_file(), path
    return zipfile.ZipFile(path)

def ncx_tree(zf):
    return ET.fromstring(zf.read("toc.ncx"))

def text_of(point):
    return point.find("n:navLabel/n:text", NS).text

def src_of(point):
    return point.find("n:content", NS).get("src")

def children(point):
    return point.findall("n:navPoint", NS)

def uid_of(zf):
    root = ncx_tree(zf)
    ncx_uid = root.find("n:head/n:meta[@name='dtb:uid']", NS).get("content")
    opf = ET.fromstring(zf.read("content.opf"))
    opf_uid = opf.find(".//dc:identifier", OPF).text
    assert ncx_uid == opf_uid, (ncx_uid, opf_uid)
    assert ncx_uid != OLD_UUID
    assert re.fullmatch(r"[0-9a-f]{8}-[0-9a-f]{4}-5[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}", ncx_uid), ncx_uid
    depth = root.find("n:head/n:meta[@name='dtb:depth']", NS).get("content")
    assert depth == "2", depth
    return ncx_uid

def tops(zf):
    return ncx_tree(zf).find("n:navMap", NS).findall("n:navPoint", NS)

def month_node(zf, label):
    found = [p for p in tops(zf) if text_of(p) == label]
    assert len(found) == 1, (label, [text_of(p) for p in tops(zf)])
    return found[0]

def assert_day(day, year, month):
    assert text_of(day).endswith(str(year)), text_of(day)
    assert children(day) == []
    src = src_of(day)
    assert src.startswith(f"{month:02d}-") and f"-{year}-" in src and src.endswith("-1-Matutinum.html"), src

def assert_month_book(directory, year, month, days, hours, toc_name):
    name = f"breviarium{year}-{month:02d}.epub"
    with epub(directory, name) as zf:
        uid = uid_of(zf)
        names = set(zf.namelist())
        top = tops(zf)
        assert [text_of(p) for p in top] == ["Title", "TOC", f"{month_name(month)} {year}", "About"], [text_of(p) for p in top]
        month_point = top[2]
        assert src_of(month_point) == f"{toc_name}#m{month:02d}"
        day_points = children(month_point)
        assert len(day_points) == days, (name, len(day_points))
        assert_day(day_points[0], year, month)
        assert_day(day_points[-1], year, month)
        points = list(ncx_tree(zf).iter(f"{{{NS['n']}}}navPoint"))
        labels = {text_of(p) for p in points}
        assert labels.isdisjoint(hours)
        counts = Counter(p.get("playOrder") for p in points)
        assert set(counts.values()) == {1}
        ids = [p.get("id") for p in points]
        assert len(ids) == len(set(ids))
        toc = zf.read(toc_name).decode("utf-8")
        assert f'id="m{month:02d}"' in toc
        assert "<a name=" not in toc
        assert ">M</a>" not in toc and ">L</a>" not in toc
        for hour in hours:
            assert f">{hour}</a>" in toc
        # Every contents target is a packed file, and the fragment is in that contents page.
        for point in month_point.iter(f"{{{NS['n']}}}navPoint"):
            src = src_of(point)
            path, _, frag = src.partition("#")
            assert path in names, src
            if frag:
                assert f'id="{frag}"' in zf.read(path).decode("utf-8"), src
        return uid

def month_name(month):
    names = ["Ianuarius", "Februarius", "Martius", "Aprilis", "Maius", "Iunius",
             "Iulius", "Augustus", "September", "October", "November", "December"]
    return names[month - 1]

def assert_year_book(directory, year, feb_days):
    with epub(directory, f"breviarium{year}.epub") as zf:
        uid = uid_of(zf)
        top = tops(zf)
        labels = [text_of(p) for p in top]
        assert labels[0:2] == ["Title", "TOC"], labels
        assert labels[-1] == "About"
        assert labels[2:-1] == [f"{month_name(m)} {year}" for m in range(1, 13)], labels
        feb = month_node(zf, f"Februarius {year}")
        assert len(children(feb)) == feb_days
        assert_day(children(feb)[0], year, 2)
        texts = [text_of(p) for p in ncx_tree(zf).iter(f"{{{NS['n']}}}navPoint")]
        assert not any(t in HOURS for t in texts)
        blob = zf.read("toc.ncx").decode("utf-8")
        other = "2024" if year == 2023 else "2023"
        assert f"-{other}-" not in blob
        assert f"-{year}-" in blob
        toc = zf.read(f"toc{year}.html").decode("utf-8")
        assert "<a name=" not in toc
        for m in range(1, 13):
            assert f'href="#m{m:02d}"' in toc
            assert f'id="m{m:02d}"' in toc
            assert f">{month_name(m)}</a>" in toc
        return uid

jan_a = assert_month_book(A, 2023, 1, 31, HOURS, "toc2023-01.html")
feb23 = assert_month_book(A, 2023, 2, 28, HOURS, "toc2023-02.html")
feb24 = assert_month_book(A, 2024, 2, 29, HOURS, "toc2024-02.html")
year23 = assert_year_book(A, 2023, 28)
year24 = assert_year_book(A, 2024, 29)
assert len({jan_a, feb23, feb24, year23, year24}) == 5

jan_b = assert_month_book(B, 2023, 1, 31, HOURS, "toc2023-01.html")
year_b = assert_year_book(B, 2023, 28)
assert jan_a == jan_b
assert year23 == year_b

jan_p = assert_month_book(P, 2023, 1, 31, HOURS, "toc2023-01.html")
assert jan_p != jan_a

missa = HOURS + ["Missa"]
feb_m = assert_month_book(M, 2023, 2, 28, missa, "toc2023-02.html")
assert feb_m != feb23
print("navigation checks passed")
print("uuids", jan_a, year23, year24, jan_p, feb_m)
PY

if [[ -f /tmp/epubcheck-5.1.0/epubcheck.jar ]]; then
	for book in "$A/breviarium2023-02.epub" "$A/breviarium2024-02.epub" "$A/breviarium2023.epub"; do
		echo "epubcheck $book"
		java -jar /tmp/epubcheck-5.1.0/epubcheck.jar "$book"
	done
else
	echo "epubcheck skipped: jar not present"
fi
echo "ok"
