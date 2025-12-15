.PHONY: test test-all install deps check build clean help

# Default target
help:
	@echo "Protobi R Package - Available Commands"
	@echo "======================================="
	@echo "make test        - Run all tests (no install needed)"
	@echo "make deps        - Install only test dependencies"
	@echo "make install     - Full install of package"
	@echo "make check       - Run R CMD check"
	@echo "make build       - Build package tarball"
	@echo "make clean       - Clean build artifacts"
	@echo ""
	@echo "Or use directly:"
	@echo "  Rscript test.R"
	@echo "  ./test.R"

# Run tests (no install needed)
test:
	@Rscript test.R

# Install just the test dependencies (not the whole package)
deps:
	@echo "Installing dependencies..."
	@Rscript -e "install.packages(c('testthat', 'devtools', 'dotenv', 'Hmisc', 'httr', 'jsonlite'), repos='https://cran.rstudio.com/')"

# Quick test without package reload
test-quick:
	@echo "Running tests (quick mode)..."
	Rscript -e "testthat::test_dir('tests/testthat')"

# Install package locally
install:
	@echo "Installing package..."
	Rscript -e "devtools::install()"

# Run R CMD check
check:
	@echo "Running R CMD check..."
	R CMD check .

# Build package
build:
	@echo "Building package..."
	R CMD build .

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf *.tar.gz
	rm -rf *.Rcheck
	rm -rf man/*.Rd~
