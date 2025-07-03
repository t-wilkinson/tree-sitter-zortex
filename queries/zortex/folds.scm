; Fold article headers and tags together
(article_headers) @fold
(tags) @fold

; Fold heading content (from heading to next heading or block)
(heading) @fold

; Fold label blocks (container behavior)
(label_block) @fold

; Fold list items with nested content
(list_item
  (list_nested_content) @fold)

; Fold code blocks
(code_block) @fold

; Fold LaTeX blocks
(latex_block) @fold

; Fold indented content
((indent) . (_)* . (dedent)) @fold
