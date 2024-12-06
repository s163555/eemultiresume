# Main LaTeX file (without .tex extension)
MAIN_FILE = main

# Output directory
OUTPUT_DIR = output

# Flavors to build
FLAVORS = hw sw ic

# Latexmk command
LATEXMK = latexmk
LATEXMK_FLAGS = -lualatex -interaction=nonstopmode

# Default target to build all flavors
.PHONY: all
all: $(FLAVORS)

# Rule to build each flavor
.PHONY: $(FLAVORS)
$(FLAVORS): %: $(OUTPUT_DIR)/cv-%.pdf

# Rule to generate PDF for each flavor
$(OUTPUT_DIR)/cv-%.pdf: $(MAIN_FILE).tex | $(OUTPUT_DIR)
	@echo "Building flavor: $*"
	@printf "\\def\\conditionmacro{%s} \\input{%s.tex}\\n" "$*" "$(MAIN_FILE)" > temp-$*.tex
	$(LATEXMK) $(LATEXMK_FLAGS) -f -jobname=$(OUTPUT_DIR)/cv-$* temp-$*.tex
	rm -f temp-$*.tex

# Ensure output directory exists
$(OUTPUT_DIR):
	mkdir -p $(OUTPUT_DIR)

# Clean up auxiliary files
.PHONY: clean
clean:
	$(LATEXMK) -C
	rm -rf $(OUTPUT_DIR) temp-*.tex

# Full rebuild
.PHONY: rebuild
rebuild: clean all
