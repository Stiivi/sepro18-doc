#
# Chapters in order
# 
# SRC = $(wildcard *.md)
#
SRC = 00_title.md \
	  introduction.md \
	  model.md \
	  simulation.md \
	  language.md \
	  example-linker.md \
	  rejected_ideas.md \
	  appendix-symbols.md


TARGET_NAME = Sepro
PANDOC = pandoc
IFORMAT = markdown+backtick_code_blocks
MATHJAX = "http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"
FLAGS = --standalone \
		--highlight-style pygments
STYLE = css/style.css
TEMPLATE_HTML = template.html
# TEMPLATE_TEX = template.latex
STYLE_DIR = style
HTML_FLAGS = --toc \
			 --toc-depth=2 \
			 --default-image-extension=png \
			 --template="$(STYLE_DIR)/template.html" \
			 --mathjax=$(MATHJAX) \
			 -c "css/style.css" \
			 -c "css/bootstrap.min.css"

PDF_FLAGS = --default-image-extension=pdf \
			-V classoption=onecolumn \
			-V listings \
			-V papersize=a4paper \
			-V documentclass:article \
			-H "$(STYLE_DIR)/listings.tex" \
			--listings \
			$(FLAGS)

OUTPUT_DIR = docs

# Do not edit below this line
# -----------------------------------------------------------------------

# Text sources
# 
SRC_DIR = text
HTML_IMAGES_DIR = $(OUTPUT_DIR)/images

ALL_SRC = $(addprefix $(SRC_DIR)/,$(SRC))

# Images
#

IMAGES = $(wildcard images/*.pdf)
HTML_IMAGES = $(addprefix $(OUTPUT_DIR)/,$(patsubst %.pdf,%.png,$(IMAGES)))

OBJ = $(addprefix $(OUTPUT_DIR)/,$(SRC:.md=.html))

all: dirs $(OBJ) # top

dirs: 
	mkdir -p $(OUTPUT_DIR)
	mkdir -p $(OUTPUT_DIR)/css
	mkdir -p $(OUTPUT_DIR)/images

index: index.html

$(OUTPUT_DIR)/images/%.png: images/%.pdf 
	convert -density 150 $< $@

html_resources: $(HTML_IMAGES) 
	cp style/*.css $(OUTPUT_DIR)/css

$(OUTPUT_DIR)/%.html: $(SRC_DIR)/%.md $(FILTER) html_resources
	$(PANDOC) -s -f $(IFORMAT) -t html $(FLAGS) $(HTML_FLAGS) -o $@ $<

%.pdf: %.md $(FILTER)
	$(PANDOC) --filter ${FILTER} -f $(IFORMAT) $(PDF_FLAGS) -o $(OUTPUT_DIR)/$@ $<

%.epub: %.md $(FILTER)
	$(PANDOC) -f $(IFORMAT) $(FLAGS) -o $@ $<

pdf: $(FILTER) dirs
	$(PANDOC) -f $(IFORMAT) $(PDF_FLAGS) -o $(OUTPUT_DIR)/$(TARGET_NAME).pdf $(ALL_SRC)

tex: $(FILTER) dirs
	$(PANDOC) -f $(IFORMAT) $(PDF_FLAGS) -o $(OUTPUT_DIR)/$(TARGET_NAME).tex $(ALL_SRC)

epub: $(FILTER) dirs
	$(PANDOC) -f $(IFORMAT) -t epub3 $(FLAGS) -o $(OUTPUT_DIR)/$(TARGET_NAME).epub $(ALL_SRC)

docx: $(FILTER) dirs
	$(PANDOC) -f $(IFORMAT) -t docx $(FLAGS) -o $(OUTPUT_DIR)/$(TARGET_NAME).docx $(ALL_SRC)

clean:
	-rm $(OUTPUT_DIR)/*
