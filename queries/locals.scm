; Document scope
(document) @local.scope

; Article headers create scopes
(article_header) @local.scope

; Code blocks create local scopes
(code_block) @local.scope

; LaTeX blocks create local scopes  
(latex_block) @local.scope

; Labels are definitions in their scope
(label name: (label_name) @local.definition)

; Article names are definitions
(article_header name: (line_content) @local.definition)

; Tag names are definitions
(tag_line name: (line_content) @local.definition)
