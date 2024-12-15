# Main LaTeX file (without .tex extension)
MAIN_FILE = main

# Output directory for PDF and auxiliary files
OUTPUT_DIR = output

# Dependency directory (only needed for latexmk)
DEPS_DIR = $(OUTPUT_DIR)/deps

# Bibliography file
BIB_FILE = $(MAIN_FILE).bib

# Flavors to build
FLAVORS = yara

# Default compiler (can be overridden with `make COMPILER=lualatex`)
DEFAULT_COMPILER = latexmk
COMPILER ?= $(DEFAULT_COMPILER)

# Compiler flags for latexmk
LATEXMK_FLAGS = -pdf -pdflua -interaction=nonstopmode -halt-on-error -use-make \
                -output-directory=$(OUTPUT_DIR)

# Compiler flags for lualatex
LUALATEX_FLAGS = -interaction=nonstopmode -halt-on-error

# Default target to build all flavors
.PHONY: all
all: $(FLAVORS)

# Rule to build each flavor
.PHONY: $(FLAVORS)
$(FLAVORS): %: $(OUTPUT_DIR)/cv-%.pdf

# Rule to generate PDF for each flavor
$(OUTPUT_DIR)/cv-%.pdf: $(MAIN_FILE).tex $(BIB_FILE) | $(OUTPUT_DIR) $(if $(filter latexmk,$(COMPILER)),$(DEPS_DIR))
	@echo "Building flavor: $*"
ifeq ($(COMPILER),latexmk)
	$(COMPILER) $(LATEXMK_FLAGS) \
		-jobname=cv-$* \
		-deps-out=$(DEPS_DIR)/cv-$*.d \
		-usepretex="\def\Flavor{$*}" $(MAIN_FILE).tex
else ifeq ($(COMPILER),lualatex)
	$(COMPILER) $(LUALATEX_FLAGS) -jobname=$(OUTPUT_DIR)/cv-$* "\def\Flavor{$*} \input{$(MAIN_FILE).tex}"
	if [ -f $(OUTPUT_DIR)/cv-$*.bcf ]; then biber $(OUTPUT_DIR)/cv-$*; fi
	$(COMPILER) $(LUALATEX_FLAGS) -jobname=$(OUTPUT_DIR)/cv-$* "\def\Flavor{$*} \input{$(MAIN_FILE).tex}"
endif

# Include dependency files for latexmk
ifeq ($(COMPILER),latexmk)
-include $(wildcard $(DEPS_DIR)/*.d)
endif

# Ensure output directory exists
$(OUTPUT_DIR):
	mkdir -p $(OUTPUT_DIR)

# Ensure dependency directory exists (only for latexmk)
$(DEPS_DIR):
	mkdir -p $(DEPS_DIR)

# Run checks on output
.PHONY: check
check:
	@echo "Checking output files..."
	@all_present=true; \
	for flavor in $(FLAVORS); do \
		if [ ! -f "$(OUTPUT_DIR)/cv-$$flavor.pdf" ]; then \
			echo "Error: Output PDF not found for flavor $$flavor"; \
			all_present=false; \
		fi; \
	done; \
	if [ "$$all_present" = false ]; then \
		echo "One or more output files are missing!"; \
		exit 1; \
	else \
		echo "All output files exist!"; \
	fi

# Clean up biber-related files
.PHONY: clean_biber
clean_biber:
	rm -rf $(OUTPUT_DIR)/*.bcf $(OUTPUT_DIR)/*.bbl $(OUTPUT_DIR)/*.blg $(OUTPUT_DIR)/*.run.xml

# Clean up auxiliary files (keep PDFs)
.PHONY: clean_aux
clean_aux:
	rm -rf $(OUTPUT_DIR)/*.log $(OUTPUT_DIR)/*.aux $(OUTPUT_DIR)/*.out $(OUTPUT_DIR)/*.toc $(OUTPUT_DIR)/*.snm $(OUTPUT_DIR)/*.nav $(OUTPUT_DIR)/*.xmpdata $(OUTPUT_DIR)/*.fls $(OUTPUT_DIR)/*.fdb_latexmk $(OUTPUT_DIR)/*.xmpi $(DEPS_DIR)

# Clean up all files (including PDFs and biber files)
.PHONY: clean
clean: clean_aux clean_biber
	rm -rf $(OUTPUT_DIR)/*.pdf

# Full rebuild
.PHONY: rebuild
rebuild: clean all
