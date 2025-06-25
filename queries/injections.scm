; Code block injections - inject based on language specified
((code_block 
   language: (language) @injection.language
   content: (content) @injection.content)
 (#set! injection.include-children))

; LaTeX block injections
((latex_block 
   content: (content) @injection.content)
 (#set! injection.language "latex")
 (#set! injection.include-children))

; URL injections in links
((link url: (url) @injection.content)
 (#set! injection.language "uri"))
