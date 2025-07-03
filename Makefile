# Makefile for tree-sitter-zortex

.PHONY: all generate test highlight install clean debug

# Default target
all: generate

# Generate parser from grammar
generate:
	tree-sitter generate

# Run tests
test: generate
	tree-sitter test

test-l: generate
	tree-sitter test -i "Lists"

# Test highlighting on example file
highlight: generate
	tree-sitter highlight test.zortex

# Parse a specific file (usage: make parse FILE=myfile.zortex)
parse: generate
	tree-sitter parse $(FILE)

# Install for local development
install: generate
	npm install

# Build WASM for web playground (optional)
wasm: generate
	tree-sitter build-wasm

# Clean generated files
clean:
	rm -rf build
	rm -rf node_modules
	rm -f src/parser.c
	rm -f src/tree_sitter/parser.h
	rm -f binding.gyp
	rm -f compile_commands.json
	rm -f package-lock.json

# Format C code (requires clang-format)
format:
	clang-format -i src/scanner.c

# Quick test - generate and test
quick: generate test highlight

# Debug - clean, build, and test specific cases
debug: clean generate
	@echo "=== Testing label vs paragraph disambiguation ==="
	@tree-sitter test -i "Formatting"
	@echo ""
	@echo "=== Testing nested lists ==="
	@tree-sitter test -i "Lists"

# Help
help:
	@echo "Available targets:"
	@echo "  make generate  - Generate parser from grammar.js"
	@echo "  make test      - Run all tests"
	@echo "  make highlight - Test syntax highlighting"
	@echo "  make parse FILE=<file> - Parse a specific file"
	@echo "  make install   - Install dependencies"
	@echo "  make clean     - Remove generated files"
	@echo "  make quick     - Generate, test, and highlight"
	@echo "  make debug     - Clean build and test specific cases"
