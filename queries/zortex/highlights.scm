; Article headers and tags
(article_header) @keyword
(article_name) @title
(tag_line) @keyword
(tag_name) @tag

; Headings
(heading_marker) @punctuation.special
(heading_content) @title

; Labels
(label_line) @label

; Lists
(list_marker) @punctuation.special

; Code
(code_block) @markup.raw.block
(language) @type
(code_content) @markup.raw.block
(inline_code) @markup.raw.inline

; LaTeX
(latex_block) @markup.math.block
(latex_content) @markup.math.block
(inline_latex) @markup.math.inline

; Links
(zortex_link) @markup.link
(markdown_link) @markup.link
(link_text) @markup.link.label
(url) @markup.link.url

; Formatting
(bold) @markup.bold
(italic) @markup.italic
(bolditalic) @markup.bold @markup.italic

; General text
(text) @text

; Punctuation
"@@" @punctuation.special
"@" @punctuation.special
"[" @punctuation.bracket
"]" @punctuation.bracket
"(" @punctuation.bracket
")" @punctuation.bracket
"```" @punctuation.delimiter
"`" @punctuation.delimiter
"$$" @punctuation.delimiter
"$" @punctuation.delimiter
"**" @punctuation.delimiter
"***" @punctuation.delimiter
"*" @punctuation.delimiter
":" @punctuation.delimiter


; ; Article headers - bright/special color
; (article_header
;   "@@" @keyword.directive
;   (article_name) @title)
; 
; ; Tags - different color than headers
; (tag_line
;   "@" @tag.delimiter
;   (tag_name) @tag)
; 
; ; Headings - graduated colors
; (heading
;   (heading_marker) @punctuation.special
;   (heading_content) @text.title)
; 
; ; Differentiate heading levels
; ((heading_marker) @text.title.1 (#eq? @text.title.1 "#"))
; ((heading_marker) @text.title.2 (#eq? @text.title.2 "##"))
; ((heading_marker) @text.title.3 (#eq? @text.title.3 "###"))
; ((heading_marker) @text.title.4 (#eq? @text.title.4 "####"))
; ((heading_marker) @text.title.5 (#eq? @text.title.5 "#####"))
; ((heading_marker) @text.title.6 (#eq? @text.title.6 "######"))
; 
; ; Labels - semantic identifier
; (label
;   (label_name) @label
;   ":" @punctuation.delimiter)
; 
; ; Lists
; (list_marker) @punctuation.special
; 
; ; Formatting
; (bold) @text.strong
; (italic) @text.emphasis
; (bolditalic) @text.strong @text.emphasis
; 
; ; Code
; (inline_code) @text.literal
; (code_block
;   "```" @punctuation.delimiter
;   (language)? @label
;   (code_content)? @text.literal
;   "```" @punctuation.delimiter)
; 
; ; LaTeX
; (inline_latex) @text.math
; (latex_block
;   "$$" @punctuation.delimiter
;   (latex_content)? @text.math
;   "$$" @punctuation.delimiter)
; 
; ; Links
; (article_link
;   "[" @punctuation.bracket
;   (link_text) @text.reference
;   "]" @punctuation.bracket)
; 
; (subpath_link
;   "[" @punctuation.bracket
;   (link_text) @text.reference
;   "]" @punctuation.bracket)
; 
; (markdown_link
;   "[" @punctuation.bracket
;   (link_text) @text.reference
;   "]" @punctuation.bracket
;   "(" @punctuation.bracket
;   (url) @text.uri
;   ")" @punctuation.bracket)
; 
; ; Text
; (text) @text
; (paragraph) @text
; 
; ; Comments (if you add them later)
; ; (comment) @comment
; 
; ; Special punctuation
; "**" @punctuation.delimiter
; "***" @punctuation.delimiter
; "*" @punctuation.delimiter
; "`" @punctuation.delimiter
; "$" @punctuation.delimiter
; 
; ; Errors
; (ERROR) @error
