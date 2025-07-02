#!/bin/bash

# Clean and rebuild
echo "Cleaning..."
rm -f src/parser.c
rm -rf build

# Build the parser
echo "Building parser..."
tree-sitter generate

# Test parsing simple file
echo -e "\n=== Parsing simple_test.zortex ==="
tree-sitter parse simple_test.zortex

# Run specific test
echo -e "\n=== Running specific test: Labels ==="
tree-sitter test -f "Labels"

echo -e "\n=== Running specific test: Formatting ==="
tree-sitter test -f "Formatting"

# Run all tests
echo -e "\n=== Running all tests ==="
tree-sitter test

# Test highlighting
echo -e "\n=== Testing highlighting ==="
tree-sitter highlight simple_test.zortex
