# Build the Dualayer Hierarchy Standard from its DocBook 5 sources.
# The build layout follows the FHS project's (gitlab.freedesktop.org/FHS/fhs-spec);
# HTML is rendered with xsltproc and the DocBook XSL stylesheets kept in docbook/.

XSLTPROC = xsltproc
XMLLINT  = xmllint
WEASYPRINT = weasyprint
PYTHON3  = python3

BUILDDIR = build
OUTDIR   = build/dhs
XMLBOOK  = xml/dhs.xml
XMLFILES = $(wildcard xml/*.xml)

DOCBOOK_XSL_SHTML = docbook/docbook-html-utf8.xsl
DOCBOOK_XSL_MHTML = docbook/dhs-chunk.xsl
DOCBOOK_RNG       = docbook/schemas/rng/docbookxi.rng
DOCBOOK_RNC       = docbook/schemas/rng/docbookxi.rnc

COMMON = --xinclude \
	--stringparam section.autolabel 1 \
	--stringparam section.label.includes.component.label 1 \
	--stringparam chunker.output.encoding UTF-8 \
	--stringparam html.stylesheet dhs.css \
	--stringparam generate.toc "book toc,title"

default: html single
all: html single pdf

html:   $(OUTDIR)/html/index.html   $(OUTDIR)/html/dhs.css
single: $(OUTDIR)/single/index.html $(OUTDIR)/single/dhs.css
pdf:    $(OUTDIR)/dhs.pdf

$(OUTDIR)/html/index.html: $(XMLFILES) $(DOCBOOK_XSL_MHTML)
	mkdir -p $(@D)
	$(XSLTPROC) $(COMMON) --stringparam base.dir $(@D)/ \
	    --stringparam use.id.as.filename 1 $(DOCBOOK_XSL_MHTML) $(XMLBOOK)

$(OUTDIR)/single/index.html: $(XMLFILES) $(DOCBOOK_XSL_SHTML)
	mkdir -p $(@D)
	$(XSLTPROC) $(COMMON) -o $@ $(DOCBOOK_XSL_SHTML) $(XMLBOOK)

$(OUTDIR)/%/dhs.css: docbook/dhs.css
	mkdir -p $(@D)
	cp $< $@

# The PDF is the single-page HTML printed with WeasyPrint, so it keeps the same design.
$(OUTDIR)/dhs.pdf: $(OUTDIR)/single/index.html $(OUTDIR)/single/dhs.css
	$(WEASYPRINT) $< $@

# Validate every source file against the DocBook 5 RELAX NG schema.
valid:
	$(XMLLINT) --xinclude --noout --relaxng $(DOCBOOK_RNG) $(XMLBOOK)

update-xmlfiles:
	$(PYTHON3) util/update-xmlfiles.py xml $(DOCBOOK_RNC)

clean:
	rm -rf $(BUILDDIR)

.PHONY: default all html single pdf valid update-xmlfiles clean
