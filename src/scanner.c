#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <tree_sitter/parser.h>

#ifdef _MSC_VER
#pragma warning(disable : 4244)
#endif

enum TokenType { INDENT, DEDENT, NEWLINE_TOKEN, EOF_TOKEN };

typedef struct {
  uint8_t indent_stack[256];
  uint8_t indent_stack_size;
  int32_t queued_dedent_count;
} Scanner;

static inline void advance(TSLexer *lexer) { lexer->advance(lexer, false); }

static inline void skip(TSLexer *lexer) { lexer->advance(lexer, true); }

bool tree_sitter_zortex_external_scanner_scan(void *payload, TSLexer *lexer,
                                              const bool *valid_symbols) {
  Scanner *scanner = (Scanner *)payload;

  if (valid_symbols[EOF_TOKEN] && lexer->eof(lexer)) {
    lexer->result_symbol = EOF_TOKEN;
    return true; // we are *exactly* at end-of-file
  }

  if (valid_symbols[NEWLINE_TOKEN] && lexer->lookahead == '\n') {
    advance(lexer);
    lexer->mark_end(lexer);
    lexer->result_symbol = NEWLINE_TOKEN;
    return true;
  }

  // Handle queued dedents
  if (scanner->queued_dedent_count > 0) {
    if (valid_symbols[DEDENT]) {
      scanner->queued_dedent_count--;
      scanner->indent_stack_size--;
      lexer->result_symbol = DEDENT;
      return true;
    }
  }

  // Only check indentation at the beginning of a line
  if (lexer->get_column(lexer) > 0) {
    return false;
  }

  // Skip any whitespace
  uint32_t indent_length = 0;
  for (;;) {
    if (lexer->lookahead == ' ') {
      indent_length++;
      skip(lexer);
    } else if (lexer->lookahead == '\t') {
      indent_length += 8;
      skip(lexer);
    } else {
      break;
    }
  }

  // Don't handle indentation for blank lines
  if (lexer->lookahead == '\n' || lexer->lookahead == '\r' ||
      lexer->eof(lexer)) {
    return false;
  }

  uint8_t current_indent =
      scanner->indent_stack[scanner->indent_stack_size - 1];

  if (indent_length > current_indent) {
    if (valid_symbols[INDENT]) {
      scanner->indent_stack[scanner->indent_stack_size] = indent_length;
      scanner->indent_stack_size++;
      lexer->result_symbol = INDENT;
      return true;
    }
  } else if (indent_length < current_indent) {
    // Count how many dedents we need
    uint8_t dedent_count = 0;
    uint8_t i = scanner->indent_stack_size - 1;

    while (i > 0) {
      if (scanner->indent_stack[i] <= indent_length) {
        break;
      }
      dedent_count++;
      i--;
    }

    if (dedent_count > 0) {
      scanner->queued_dedent_count = dedent_count - 1;
      scanner->indent_stack_size--;
      if (valid_symbols[DEDENT]) {
        lexer->result_symbol = DEDENT;
        return true;
      }
    }
  }

  return false;
}

void *tree_sitter_zortex_external_scanner_create() {
  Scanner *scanner = calloc(1, sizeof(Scanner));
  scanner->indent_stack[0] = 0;
  scanner->indent_stack_size = 1;
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
}

unsigned tree_sitter_zortex_external_scanner_serialize(void *payload,
                                                       char *buffer) {
  Scanner *scanner = (Scanner *)payload;

  if (scanner->indent_stack_size * sizeof(uint8_t) + 2 >
      TREE_SITTER_SERIALIZATION_BUFFER_SIZE) {
    return 0;
  }

  buffer[0] = scanner->indent_stack_size;
  buffer[1] = scanner->queued_dedent_count;

  memcpy(&buffer[2], scanner->indent_stack, scanner->indent_stack_size);

  return scanner->indent_stack_size + 2;
}

void tree_sitter_zortex_external_scanner_deserialize(void *payload,
                                                     const char *buffer,
                                                     unsigned length) {
  Scanner *scanner = (Scanner *)payload;

  if (length < 2) {
    tree_sitter_zortex_external_scanner_reset(payload);
    return;
  }

  scanner->indent_stack_size = buffer[0];
  scanner->queued_dedent_count = buffer[1];

  if (length < scanner->indent_stack_size + 2) {
    tree_sitter_zortex_external_scanner_reset(payload);
    return;
  }

  memcpy(scanner->indent_stack, &buffer[2], scanner->indent_stack_size);
}
