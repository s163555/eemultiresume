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
	@echo "Running checks for all flavors..."
	# Ensure the main LaTeX file exists
	@if [ ! -f $(MAIN_FILE).tex ]; then \
		echo "Error: $(MAIN_FILE).tex not found!"; \
		exit 1; \
	fi
	# Test build for each flavor
	@for flavor in $(FLAVORS); do \
		echo "Testing flavor: $$flavor"; \
		$(LUALATEX) $(LUALATEX_FLAGS) -jobname=$(OUTPUT_DIR)/cv-$$flavor "\def\Flavor{$$flavor} \input{$(MAIN_FILE).tex}"; \
		if [ $$? -ne 0 ]; then \
			echo "Error: Build failed for flavor $$flavor"; \
			exit 1; \
		fi; \
	done
	@echo "All flavors built successfully!"


# Clean up auxiliary files
.PHONY: clean
clean:
	rm -rf $(OUTPUT_DIR)/*.pdf $(OUTPUT_DIR)/*.log $(OUTPUT_DIR)/*.aux $(OUTPUT_DIR)

# Full rebuild
.PHONY: rebuild
rebuild: clean all
