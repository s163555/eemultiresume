# Main LaTeX file (without .tex extension)
MAIN_FILE = main

# Output directory
OUTPUT_DIR = output

# Flavors to build
FLAVORS = hw sw ic

# Default compiler (can be overridden with `make COMPILER=lualatex`)
DEFAULT_COMPILER = latexmk
COMPILER ?= $(DEFAULT_COMPILER)

# Compiler flags for each compiler
ifeq ($(COMPILER),latexmk)
	COMPILER_FLAGS = -lualatex -interaction=nonstopmode -halt-on-error -outdir=$(OUTPUT_DIR)
else ifeq ($(COMPILER),lualatex)
	COMPILER_FLAGS = -interaction=nonstopmode -halt-on-error
else
	$(error Unsupported compiler: $(COMPILER))
endif

# Default target to build all flavors
.PHONY: all
all: $(FLAVORS)

# Rule to build each flavor
.PHONY: $(FLAVORS)
$(FLAVORS): %: $(OUTPUT_DIR)/cv-%.pdf

# Rule to generate PDF for each flavor using a wrapper file
$(OUTPUT_DIR)/cv-%.pdf: $(MAIN_FILE).tex | $(OUTPUT_DIR)
	@echo "Building flavor: $*"
	@echo "\\def\\Flavor{$*} \\input{$(MAIN_FILE).tex}" > $(OUTPUT_DIR)/temp-$*.tex
ifeq ($(COMPILER),latexmk)
	$(COMPILER) $(COMPILER_FLAGS) -jobname=cv-$* $(OUTPUT_DIR)/temp-$*.tex
else
	$(COMPILER) $(COMPILER_FLAGS) -jobname=$(OUTPUT_DIR)/cv-$* "\def\Flavor{$*} \input{$(MAIN_FILE).tex}"
endif
	rm $(OUTPUT_DIR)/temp-$*.tex

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

# Clean up auxiliary files (keep PDFs)
.PHONY: clean_aux
clean_aux:
	rm -rf $(OUTPUT_DIR)/*.log $(OUTPUT_DIR)/*.aux $(OUTPUT_DIR)/*.out $(OUTPUT_DIR)/*.toc $(OUTPUT_DIR)/*.snm $(OUTPUT_DIR)/*.nav $(OUTPUT_DIR)/*.xmpdata $(OUTPUT_DIR)/*.fls $(OUTPUT_DIR)/*.fdb_latexmk $(OUTPUT_DIR)/*.xmpi 

# Clean up all files (including PDFs)
.PHONY: clean
clean: clean_aux
	rm -rf $(OUTPUT_DIR)/*.pdf

# Full rebuild
.PHONY: rebuild
rebuild: clean all
