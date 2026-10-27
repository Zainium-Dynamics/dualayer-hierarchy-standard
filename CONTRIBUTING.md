# Contributing to the Dualayer Hierarchy Standard

The standard is written in DocBook 5 XML under `xml/`. One file per chapter;
`xml/dhs.xml` is the book that includes them.

## Proposing a change

1. Open an issue that describes the problem: what an implementation, a package
   manager or an application cannot do with the current text.
2. Send a pull request against `main`. Keep normative language
   (**MUST**, **SHOULD**, **MAY**, RFC 2119) for requirements and put examples
   from one implementation in an *Implementation note*.
3. Run `make valid` and `make html` before sending; CI runs both.

## Style

- Plain, short sentences. Say what a directory holds and who may change it.
- Paths in `<filename>`, commands in `<command>`, variables of a path in
  `<replaceable>`.
- A new requirement needs a reason in the text or in the pull request.

## Versions

The standard uses `MAJOR.MINOR`. A change that makes an existing conforming
system non-conforming needs a new major version.

By contributing you agree that your contribution is licensed under
CC BY-SA 4.0, like the rest of the text.
