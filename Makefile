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
	@echo "CONDITION=$$CONDITION"

	@case "$*" in \
		hw) export CONDITION=1;; \
		sw) export CONDITION=2;; \
		ic) export CONDITION=3;; \
	esac; \
	CONDITION=$$CONDITION $(LATEXMK) $(LATEXMK_FLAGS) -f -jobname=$(OUTPUT_DIR)/cv-$* $(MAIN_FILE).tex

# Ensure output directory exists
$(OUTPUT_DIR):
	mkdir -p $(OUTPUT_DIR)

# Clean up auxiliary files
.PHONY: clean
clean:
	$(LATEXMK) -C
	rm -rf $(OUTPUT_DIR)

# Full rebuild
.PHONY: rebuild
rebuild: clean all
