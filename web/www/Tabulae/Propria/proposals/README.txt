Files in this directory are not part of the runtime calendar.

`country/` and `diocese/` are different places. A draft may name a real country or diocese. The example template must not. Leave `status` as `proposed`, `activates` as `no`, and `inherits_usa` as `no` on a country or diocese draft. Do not add the draft to versions.txt, data.txt, a Kalendaria file, or a version menu until a later pull request has evidence and deliberately marks the entry in-use.

The checks in validate_propria() reject a proposal whose status is in-use, a proposal that reuses an in-use layer name, a country or diocese draft that claims the usa layer, and a proposal id that appears in data.txt, the version menus, or any Kalendaria file.

