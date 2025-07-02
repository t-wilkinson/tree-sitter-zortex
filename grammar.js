module.exports = grammar({
  name: "zortex",

  externals: ($) => [$.indent, $.dedent, $._newline_token, $._eof],

  extras: ($) => [/[ \t\f\r]/],

  precedences: ($) => [
    ["heading", "label", "list", "paragraph"],
    ["bolditalic", "bold", "italic", "text"],
  ],

  conflicts: ($) => [
    [$.paragraph, $.list],
    [$._inline_content, $.text],
  ],

  rules: {
    document: ($) =>
      seq(
        $.article_headers,
        optional($.tags),
        // optional($._blank_lines),
        optional($.body),
      ),

    article_headers: ($) => repeat1($.article_header),

    article_header: ($) => seq("@@", $.article_name, $._line_ending),

    article_name: ($) => /[^\n]+/,

    tags: ($) => repeat1($.tag_line),

    tag_line: ($) => seq("@", $.tag_name, $._line_ending),

    tag_name: ($) => /[^\s\n]+/,

    _blank_lines: ($) => repeat1($._blank_line),
    _blank_line: ($) => /\n/,

    body: ($) => repeat1($.block),

    block: ($) =>
      choice(
        $.heading,
        $.label,
        $.list,
        $.code_block,
        $.latex_block,
        $.paragraph,
        $._blank_line,
      ),

    // Headings
    heading: ($) =>
      prec.left(
        "heading",
        seq($.heading_marker, " ", $.heading_content, $._line_ending),
      ),

    heading_marker: ($) => /#{1,6}/,
    heading_content: ($) => repeat1($._inline),

    // Labels
    label: ($) => prec.left("label", seq($.label_name, ":", $._line_ending)),

    label_name: ($) => /[A-Za-z0-9][A-Za-z0-9 ]*/,

    // Lists with indentation support
    list: ($) =>
      prec.left("list", repeat1(choice($.list_item, $.nested_list_item))),

    list_item: ($) => seq($.list_marker, " ", $.list_content, $._line_ending),

    nested_list_item: ($) => seq($.indent, $.list_item, $.dedent),

    list_marker: ($) => choice("-", /\d+\./),

    list_content: ($) => repeat1($._inline),

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
    code_content: ($) => repeat1(choice($.code_line, $._blank_line)),
    code_line: ($) => seq(/[^\n]+/, $._line_ending),

    // LaTeX blocks
    latex_block: ($) =>
      seq(
        "$$",
        $._line_ending,
        optional($.latex_content),
        "$$",
        $._line_ending,
      ),

    latex_content: ($) => repeat1(choice($.latex_line, $._blank_line)),
    latex_line: ($) => seq(/[^\n]+/, $._line_ending),

    // Paragraphs
    paragraph: ($) =>
      prec.left(
        "paragraph",
        seq(repeat1($.paragraph_line), choice($._blank_line, $._eof)),
      ),

    paragraph_line: ($) => seq(repeat1($._inline), $._line_ending),

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
    _line_ending: ($) => choice("\n", $._newline_token, $._eof),
  },
});
