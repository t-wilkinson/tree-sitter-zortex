; Language injections for code blocks
(code_block
  (language) @injection.language
  (code_content) @injection.content)

; LaTeX math injections  
(latex_block
  (latex_content) @injection.content
  (#set! injection.language "latex"))

(inline_latex
  (#set! injection.language "latex"))
