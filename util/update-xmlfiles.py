#! /usr/bin/env python3

"""
Update XMLDIR/schemas.xml in place to list each of the .xml files
in that directory, *other than* schemas.xml itself, as having the
schema SCHEMA, which should be a Relax-NG compact schema (.rnc).
XMLDIR and SCHEMA are both understood relative to this script's
working directory.
"""

import argparse
import os
import io
import sys
import tempfile
import xml.etree.ElementTree as ET

from pathlib import Path


ME = "update-schemas.py"

# this is hardcoded because it is also hardcoded into nxml-mode
SCHEMAS_FILE = "schemas.xml"


def compute_new_locating_rules(xmldir: Path, schema: Path) -> bytes:
    """
    Calculate a set of "locating rules", as expected by emacs' nxml-mode,
    that says that each .xml file in XMLDIR, except for SCHEMAS_FILE,
    has the schema SCHEMA.  Return the byte serialization of an XML document
    describing those locating rules.
    """
    xml_files = sorted(
        f.name
        for f in xmldir.glob("*.xml")
        if f.name != SCHEMAS_FILE
    )
    last = len(xml_files) - 1
    schema = str(schema)

    root = ET.Element(
        "locatingRules",
        xmlns="http://thaiopensource.com/ns/locating-rules/1.0",
    )
    root.text = "\n  "
    for i, f in enumerate(xml_files):
        uri = ET.Element("uri", resource=f, uri=schema)
        uri.tail = "\n" if i == last else "\n  "
        root.append(uri)

    sink = io.BytesIO()
    sink.write(
        b'<?xml version="1.0" encoding="utf-8"?>\n'
        b'<!-- This file is read by the Makefile to determine the set of\n'
        b'     XML files that make up the DHS document.  It is also used by\n'
        b'     editors to locate the schema for each XML file. -->\n'
    )
    ET.ElementTree(root).write(
        sink,
        encoding="utf-8",
        xml_declaration=False,
    )
    sink.write(b'\n')
    return sink.getvalue().replace(b' />', b'/>')


def update_if_changed(old_file: Path, new_contents: bytes, *,
                      error_if_changed: bool = False) -> None:
    """
    If OLD_FILE does not exist, or if its contents are different
    from NEW_CONTENTS, atomically replace OLD_FILE with a new one
    containing NEW_CONTENTS.

    If ERROR_IF_CHANGED is true, instead exit the program with an
    error whenever OLD_FILE needs to be updated.
    """
    try:
        with open(old_file, "rb") as old_fp:
            old_contents = old_fp.read()
        if old_contents == new_contents:
            sys.stderr.write(f"{ME}: {old_file} is up to date\n")
            return

        if error_if_changed:
            sys.stderr.write(f"{ME}: error: {old_file} is outdated\n")
            sys.exit(1)

        sys.stderr.write(f"{ME}: updating {old_file}\n")

    except FileNotFoundError:
        if error_if_changed:
            sys.stderr.write(f"{ME}: error: {old_file} is missing\n")
            sys.exit(1)

        sys.stderr.write(f"{ME}: creating {old_file}\n")

    try:
        tmp_fd, tmp_file = tempfile.mkstemp(
            dir = old_file.parent,
            prefix = old_file.name + '.new.'
        )
        with open(tmp_fd, 'wb', closefd=True) as tmp_fp:
            tmp_fp.write(new_contents)
        os.rename(tmp_file, old_file)

    except:
        os.unlink(tmp_file)
        raise


def main() -> None:
    global ME
    ME = Path(sys.argv[0]).name

    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "XMLDIR", type=Path,
        help="Directory containing schemas.xml and other XML files"
    )
    ap.add_argument(
        "SCHEMA", type=Path,
        help="Relax-NG schema to be used for all the XML files"
    )
    ap.add_argument(
        "--stdout", action="store_true",
        help="print the new schemas.xml to stdout, instead of updating"
        " XMLDIR/schemas.xml"
    )
    ap.add_argument(
        "--error-if-changed", action="store_true",
        help="issue an error if there are changes to XMLDIR/schemas.xml,"
        " instead of updating it"
    )
    args = ap.parse_args()

    if args.stdout and args.error_if_changed:
        ap.error("--stdout and --error-if-changed are mutually exclusive")

    if not args.XMLDIR.is_dir():
        sys.stderr.write(
            f"{ME}: error: {args.XMLDIR}: missing or not a directory\n"
        )
        sys.exit(1)

    if not args.SCHEMA.is_file():
        sys.stderr.write(
            f"{ME}: error: {args.SCHEMA}: missing or not a regular file\n"
        )
        sys.exit(1)

    xmldir = args.XMLDIR.resolve()

    # Path.relative_to() refuses to compute a relative path from a
    # directory that is not a parent of the target.  os.path.relpath,
    # however, will do the job just fine.
    schema = Path(os.path.relpath(args.SCHEMA.resolve(), start=xmldir))

    # we are now done needing xmldir to be absolute
    xmldir = Path(os.path.relpath(xmldir, start=os.getcwd()))

    new_contents = compute_new_locating_rules(xmldir, schema)

    if args.stdout:
        sys.stdout.buffer.write(new_contents)
    else:
        update_if_changed(xmldir / SCHEMAS_FILE, new_contents,
                          error_if_changed = args.error_if_changed)

    sys.exit(0)

main()
