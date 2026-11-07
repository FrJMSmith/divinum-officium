Files in this directory are not part of the runtime calendar.

Copy EXAMPLE-NOT-A-CALENDAR.txt when drafting a future layer. Leave
status as proposed. Do not use the name of a real diocese, institute,
seminary, or church in an example. Do not add the draft to versions.txt,
data.txt, a Kalendaria file, or a version menu until a later pull request
has evidence and deliberately marks the entry in-use.

The checks in validate_propria() reject a proposal whose status is in-use,
a proposal that reuses an in-use layer name, and a proposal id that appears
in data.txt, the version menus, or any Kalendaria file.
