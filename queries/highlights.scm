; Structural markers
"@@" @punctuation.special
"@" @punctuation.special

; Article and tag headers
(article_header name: (line_content) @title)
(tag_line name: (line_content) @tag)

; Headings
(heading_marker) @punctuation.special
(heading text: (line_content) @title)

; Labels
(label name: (label_name) @label)
":" @punctuation.delimiter

; Lists
(list_item marker: "-" @punctuation.special)
(ordered_marker) @punctuation.special

; Code blocks
"```" @punctuation.special
(code_block language: (language) @tag)

; LaTeX blocks
"$$" @punctuation.special

; Inline formatting
(bold "**" @punctuation.special)
(italic "*" @punctuation.special)
(bolditalic "***" @punctuation.special)

; Inline code
(inline_code "`" @punctuation.special)

; Links
(link "[" @punctuation.bracket)
(link "]" @punctuation.bracket)
(link "(" @punctuation.bracket)
(link ")" @punctuation.bracket)
(link text: (text) @string)
(link url: (url) @string.special.url)

; General text content
(text) @string
(line_content) @string
(code_line) @string

; Whitespace and structure
(blank_line) @none
