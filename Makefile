# Main LaTeX file (without .tex extension)
MAIN_FILE = main

# Output directory
OUTPUT_DIR = output

# Flavors to build
FLAVORS = hw sw ic

# Latex command
COMPILER = lualatex
COMPILER_FLAGS = -interaction=nonstopmode -halt-on-error

# Default target to build all flavors
.PHONY: all
all: $(FLAVORS)

# Rule to build each flavor
.PHONY: $(FLAVORS)
$(FLAVORS): %: $(OUTPUT_DIR)/cv-%.pdf

# Rule to generate PDF for each flavor
$(OUTPUT_DIR)/cv-%.pdf: $(MAIN_FILE).tex | $(OUTPUT_DIR)
	@echo "Building flavor: $*"
	$(COMPILER) $(COMPILER_FLAGS) -jobname=$(OUTPUT_DIR)/cv-$* "\def\Flavor{$*} \input{$(MAIN_FILE).tex}"

# Ensure output directory exists
$(OUTPUT_DIR):
	mkdir -p $(OUTPUT_DIR)

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
# Clean up auxiliary files
.PHONY: clean
clean:
	rm -rf $(OUTPUT_DIR)/*.pdf $(OUTPUT_DIR)/*.log $(OUTPUT_DIR)/*.aux $(OUTPUT_DIR)

# Full rebuild
.PHONY: rebuild
rebuild: clean all
