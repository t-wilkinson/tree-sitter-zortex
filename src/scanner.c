#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <tree_sitter/parser.h>

#ifdef _MSC_VER
#pragma warning(disable : 4244)
#endif

enum TokenType { INDENT, DEDENT, EOF_TOKEN };

typedef struct {
  uint8_t indent_stack[256];
  uint8_t indent_stack_size;
  int32_t queued_dedent_count;
  bool saw_eof;
  bool last_was_newline;
} Scanner;

static inline void advance(TSLexer *lexer) { lexer->advance(lexer, false); }

static inline void skip(TSLexer *lexer) { lexer->advance(lexer, true); }

bool tree_sitter_zortex_external_scanner_scan(void *payload, TSLexer *lexer,
                                              const bool *valid_symbols) {
  Scanner *scanner = (Scanner *)payload;

  // If we've already seen EOF, don't process again
  if (scanner->saw_eof) {
    return false;
  }

  // Handle EOF
  if (lexer->eof(lexer)) {
    scanner->saw_eof = true;

    // Emit any remaining dedents before EOF
    if (scanner->indent_stack_size > 1 && valid_symbols[DEDENT]) {
      scanner->queued_dedent_count = scanner->indent_stack_size - 2;
      scanner->indent_stack_size = 1;
      lexer->result_symbol = DEDENT;
      return true;
    }

    if (valid_symbols[EOF_TOKEN]) {
      lexer->result_symbol = EOF_TOKEN;
      return true;
    }
  }

  // Handle queued dedents
  if (scanner->queued_dedent_count > 0 && valid_symbols[DEDENT]) {
    scanner->queued_dedent_count--;
    lexer->result_symbol = DEDENT;
    return true;
  }

  // Only check indentation at the beginning of a line
  if (lexer->get_column(lexer) != 0) {
    scanner->last_was_newline = false;
    return false;
  }

  // Mark start position
  lexer->mark_end(lexer);

  // Count indentation
  uint32_t indent_length = 0;
  uint32_t space_count = 0;

  for (;;) {
    if (lexer->lookahead == ' ') {
      space_count++;
      skip(lexer);
    } else if (lexer->lookahead == '\t') {
      space_count += 8 - (space_count % 8);
      skip(lexer);
    } else {
      break;
    }
  }

  indent_length = space_count;

  // Skip blank lines completely - don't emit indent/dedent for them
  if (lexer->lookahead == '\n' || lexer->lookahead == '\r') {
    scanner->last_was_newline = true;
    return false;
  }

  // Check for EOF after consuming whitespace
  if (lexer->eof(lexer)) {
    return false;
  }

  uint8_t current_indent =
      scanner->indent_stack[scanner->indent_stack_size - 1];

  // Handle indentation changes
  if (indent_length > current_indent) {
    if (valid_symbols[INDENT] && scanner->indent_stack_size < 255) {
      scanner->indent_stack[scanner->indent_stack_size] = indent_length;
      scanner->indent_stack_size++;
      lexer->result_symbol = INDENT;
      scanner->last_was_newline = false;
      return true;
    }
  } else if (indent_length < current_indent) {
    // Count how many dedents we need
    uint8_t dedent_count = 0;
    uint8_t i = scanner->indent_stack_size - 1;

    while (i > 0 && scanner->indent_stack[i] > indent_length) {
      dedent_count++;
      i--;
    }

    // Make sure we found the exact indentation level
    if (scanner->indent_stack[i] != indent_length) {
      return false; // Invalid dedent
    }

    if (dedent_count > 0 && valid_symbols[DEDENT]) {
      scanner->queued_dedent_count = dedent_count - 1;
      scanner->indent_stack_size -= dedent_count;
      lexer->result_symbol = DEDENT;
      scanner->last_was_newline = false;
      return true;
    }
  }

  scanner->last_was_newline = false;
  return false;
}

void *tree_sitter_zortex_external_scanner_create() {
  Scanner *scanner = calloc(1, sizeof(Scanner));
  scanner->indent_stack[0] = 0;
  scanner->indent_stack_size = 1;
  scanner->saw_eof = false;
  scanner->last_was_newline = false;
  return scanner;
}

void tree_sitter_zortex_external_scanner_destroy(void *payload) {
  free(payload);
}

void tree_sitter_zortex_external_scanner_reset(void *payload) {
  Scanner *scanner = (Scanner *)payload;
  scanner->indent_stack[0] = 0;
  scanner->indent_stack_size = 1;
  scanner->queued_dedent_count = 0;
  scanner->saw_eof = false;
  scanner->last_was_newline = false;
}

unsigned tree_sitter_zortex_external_scanner_serialize(void *payload,
                                                       char *buffer) {
  Scanner *scanner = (Scanner *)payload;

  if (scanner->indent_stack_size * sizeof(uint8_t) + 4 >
      TREE_SITTER_SERIALIZATION_BUFFER_SIZE) {
    return 0;
  }

  buffer[0] = scanner->indent_stack_size;
  buffer[1] = scanner->queued_dedent_count;
  buffer[2] = scanner->saw_eof ? 1 : 0;
  buffer[3] = scanner->last_was_newline ? 1 : 0;

  memcpy(&buffer[4], scanner->indent_stack, scanner->indent_stack_size);

  return scanner->indent_stack_size + 4;
}

void tree_sitter_zortex_external_scanner_deserialize(void *payload,
                                                     const char *buffer,
                                                     unsigned length) {
  Scanner *scanner = (Scanner *)payload;

  if (length < 4) {
    tree_sitter_zortex_external_scanner_reset(payload);
    return;
  }

  scanner->indent_stack_size = buffer[0];
  scanner->queued_dedent_count = buffer[1];
  scanner->saw_eof = buffer[2] != 0;
  scanner->last_was_newline = buffer[3] != 0;

  if (length < scanner->indent_stack_size + 4) {
    tree_sitter_zortex_external_scanner_reset(payload);
    return;
  }

  memcpy(scanner->indent_stack, &buffer[4], scanner->indent_stack_size);
}
