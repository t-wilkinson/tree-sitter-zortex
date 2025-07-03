module.exports = grammar({
  name: "zortex",

  externals: ($) => [$.indent, $.dedent, $._eof],

  extras: ($) => [/[ \t\f\r]/],

  precedences: ($) => [
    ["label", "heading", "list", "paragraph"],
    ["bolditalic", "bold", "italic", "text"],
  ],

  conflicts: ($) => [
    [$.paragraph_content, $.list_item],
    [$._inline_content, $.text],
    [$.body, $.label_content, $.list_nested_content],
  ],

  rules: {
    document: ($) =>
      seq(
        $.article_headers,
        optional($.tags),
        repeat($._blank_line), // Allow blank lines between sections
        optional($.body),
      ),

    article_headers: ($) => repeat1($.article_header),

    article_header: ($) => seq("@@", $.article_name, $._line_ending),

    article_name: ($) => /[^\n]+/,

    tags: ($) => repeat1($.tag_line),

    tag_line: ($) => seq("@", $.tag_name, $._line_ending),

    tag_name: ($) => /[^\s\n]+/,

    _blank_line: ($) => /\n/,

    // Body contains blocks
    body: ($) => repeat1($._body_element),

    _body_element: ($) => choice($.block, $._blank_line),

    // A block is a section of content at a particular indentation level
    // Order matters here - try to match more specific blocks first
    block: ($) =>
      choice(
        $.heading,
        $.code_block,
        $.latex_block,
        $.list_block,
        $.label_block,
        $.paragraph_block,
      ),

    // Headings
    heading: ($) =>
      prec.left(
        "heading",
        seq($.heading_marker, /[ \t]+/, $.heading_content, $._line_ending),
      ),

    heading_marker: ($) => /#{1,6}/,
    heading_content: ($) => repeat1($._inline),

    // Label blocks - labels that end with colon and newline act as containers
    label_block: ($) =>
      prec.left(
        "label",
        seq(
          $.label_line,
          optional(
            choice(
              seq($.indent, $.label_content, $.dedent),
              $.label_content, // Allow content at same level for implicit folding
            ),
          ),
        ),
      ),

    label_line: ($) =>
      seq(/[A-Za-z0-9][^:\n]*[A-Za-z0-9]/, ":", $._line_ending),

    label_content: ($) => repeat1($._body_element),

    // List blocks - contain multiple list items at same or deeper indentation
    list_block: ($) => prec.right("list", repeat1($.list_item)),

    list_item: ($) =>
      prec.right(
        "list",
        seq(
          $.list_marker,
          /[ \t]+/,
          $.list_item_content,
          optional(seq($.indent, $.list_nested_content, $.dedent)),
        ),
      ),

    list_marker: ($) => choice("-", /\d+\./),

    list_item_content: ($) => seq(repeat1($._inline), $._line_ending),

    list_nested_content: ($) => repeat1($._body_element),

    // Code blocks
    code_block: ($) =>
      seq(
        "```",
        optional($.language),
        $._line_ending,
        optional($.code_content),
        "```",
        $._line_ending,
      ),

    language: ($) => /[a-zA-Z0-9_+-]+/,
    code_content: ($) => /[^`]*(?:`[^`]|``[^`])*[^`]*/,

    // LaTeX blocks - support both $ and $$
    latex_block: ($) =>
      choice(
        seq(
          "$$",
          $._line_ending,
          optional($.latex_content),
          "$$",
          $._line_ending,
        ),
        seq(
          "$",
          $._line_ending,
          optional($.latex_content),
          "$",
          $._line_ending,
        ),
      ),

    latex_content: ($) => /[^$]+/,

    // Paragraph blocks - consecutive lines without blank lines
    paragraph_block: ($) => $.paragraph_content,

    // This tells the parser to group sequences of lines from the left.
    paragraph_content: ($) =>
      prec.left(
        "paragraph",
        repeat1(
          seq(
            repeat1($._inline),
            choice(
              seq($._line_ending, /[ \t]*\n/), // End with blank line
              seq($._line_ending, $._eof), // End at EOF
              $._line_ending, // Continue to next line
            ),
          ),
        ),
      ),

    // Inline content
    _inline: ($) =>
      choice(
        $.formatted_text,
        $.inline_code,
        $.inline_latex,
        $.link,
        $._inline_content,
      ),

    _inline_content: ($) => choice($.text, $._soft_line_break),

    // Formatting
    formatted_text: ($) => choice($.bolditalic, $.bold, $.italic),

    bolditalic: ($) =>
      prec.left("bolditalic", seq("***", repeat1($._inline_bolditalic), "***")),

    bold: ($) => prec.left("bold", seq("**", repeat1($._inline_bold), "**")),

    italic: ($) =>
      prec.left("italic", seq("*", repeat1($._inline_italic), "*")),

    _inline_bolditalic: ($) =>
      choice($.inline_code, $.inline_latex, $.link, alias(/[^*\n]+/, $.text)),

    _inline_bold: ($) =>
      choice(
        $.italic,
        $.inline_code,
        $.inline_latex,
        $.link,
        alias(/[^*\n]+/, $.text),
      ),

    _inline_italic: ($) =>
      choice($.inline_code, $.inline_latex, $.link, alias(/[^*\n]+/, $.text)),

    // Inline code
    inline_code: ($) => seq("`", /[^`\n]+/, "`"),

    // Inline LaTeX
    inline_latex: ($) => seq("$", /[^$\n]+/, "$"),

    // Links
    link: ($) => choice($.zortex_link, $.markdown_link),

    zortex_link: ($) => seq("[", $.link_text, "]"),
    markdown_link: ($) => seq("[", $.link_text, "]", "(", $.url, ")"),
    link_text: ($) => /[^\]]+/,
    url: ($) => /[^)]+/,

    // Text
    text: ($) => token(prec(-1, /[^*`$\[\]\n]+/)),

    _soft_line_break: ($) => " ",

    // Line endings
    _line_ending: ($) => choice("\n", $._eof),
  },
});
