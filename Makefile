#
# Chapters in order
# 
# SRC = $(wildcard *.md)
#
TARGET_NAME = Sepro

CHAPTERS = \
	  introduction \
	  model \
	  simulation \
	  language \
	  example-linker \
	  rejected_ideas \
	  appendix-symbols

TEXT_DIR := text
IMAGES_DIR := images

INPUT_FORMAT = markdown+backtick_code_blocks

# Flags common to all types of targets
FLAGS = --highlight-style pygments \
		-V site-title="Sepro18" \
		-V reference-section-title="References" \
		-V link-citations=true

PANDOC := pandoc

IMAGES = $(wildcard images/*.pdf)

#
# Do not edit below this line
# -----------------------------------------------------------------------

OUTPUT_DIR = docs
HTML_DIR = $(OUTPUT_DIR)

MATHJAX = "http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"

CHAPTER_FILES = $(addprefix $(TEXT_DIR)/,$(addsuffix .md, $(CHAPTERS)))
HTML_SOURCES = $(CHAPTER_FILES) $(TEXT_DIR)/index.md
PDF_SOURCES = $(TEXT_DIR)/index-tex.md $(CHAPTER_FILES) 
HTML_FILES = $(subst $(TEXT_DIR), $(HTML_DIR), $(patsubst %.md, %.html, $(HTML_SOURCES)))

# Styles and Templates
# -----------------------------------------------------------------------

STYLE = css/style.css
STYLE_DIR = style
TEMPLATE_HTML = template.html

# TEMPLATE_TEX = template.latex
.PHONY: all pdf html clean

#
# HTML Output
# -----------------------------------------------------------------------
HTML_FLAGS = --toc \
			 --toc-depth=2 \
			 --standalone \
			 --default-image-extension=png \
			 --template="$(STYLE_DIR)/template.html" \
			 --mathjax=$(MATHJAX) \
			 -c "css/style.css" \

HTML_IMAGES_DIR = $(OUTPUT_DIR)/images
HTML_IMAGES = $(addprefix $(OUTPUT_DIR)/,$(patsubst %.pdf,%.png,$(IMAGES)))

$(HTML_DIR):
	mkdir -p $(HTML_DIR)
	mkdir -p $(HTML_DIR)/css
	mkdir -p $(HTML_DIR)/images

$(HTML_IMAGES_DIR)/%.png: images/%.pdf  | $(HTML_DIR)
	convert -density 150 $< $@

html_resources: $(HTML_IMAGES)  | $(HTML_DIR)
	cp style/*.css $(OUTPUT_DIR)/css

$(HTML_DIR)/%.html: $(TEXT_DIR)/%.md $(STYLE_DIR)/template.html | $(HTML_DIR)
	@echo Creating $@
	@$(PANDOC) -s -f $(INPUT_FORMAT) -t html $(FLAGS) $(HTML_FLAGS) \
		-V date="$$(date -r $< +%Y-%m-%d)"\
		-V source_file=$< \
		-o $@ $< $(NODE_LINKS_FILE)

html: $(HTML_FILES) html_resources

index: $(HTML_DIR)/index.html

# PDF Output
# -----------------------------------------------------------------------
PDF_FLAGS = --default-image-extension=pdf \
			-V classoption=onecolumn \
			-V listings \
			-V papersize=a4paper \
			-V documentclass:article \
			-H "$(STYLE_DIR)/listings.tex" \
			--listings \
			$(FLAGS)

pdf: 
	$(PANDOC) -f $(INPUT_FORMAT) -t latex $(FLAGS) $(PDF_FLAGS) \
		-o $(OUTPUT_DIR)/$(TARGET_NAME).pdf $(PDF_SOURCES)

# epub Output
# -----------------------------------------------------------------------
EPUB_FLAGS = --default-image-extension=svg

%.pdf: %.md $(FILTER)
	$(PANDOC) --filter ${FILTER} -f $(IFORMAT) $(PDF_FLAGS) -o $(OUTPUT_DIR)/$@ $<

%.epub: %.md $(FILTER)
	$(PANDOC) -f $(IFORMAT) $(FLAGS) -o $@ $<

epub: $(FILTER) 
	$(PANDOC) -f $(IFORMAT) -t epub3 $(EPUB_FLAGS) -o $(OUTPUT_DIR)/$(TARGET_NAME).epub $(ALL_SRC)

docx: $(FILTER) dirs
	$(PANDOC) -f $(IFORMAT) -t docx $(FLAGS) -o $(OUTPUT_DIR)/$(TARGET_NAME).docx $(ALL_SRC)

clean:
	-rm -rf $(OUTPUT_DIR)/*

all: html pdf
