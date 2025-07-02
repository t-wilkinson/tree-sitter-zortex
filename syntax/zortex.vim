" Vim syntax file for Zortex
" Language: Zortex (Extended Markdown)
" Maintainer: Your Name
" Latest Revision: 2024

if exists("b:current_syntax")
  finish
endif

" Article headers - most prominent
syn match zortexArticleHeader "^@@.*$" contains=zortexArticleMarker
syn match zortexArticleMarker "^@@" contained

" Tags - secondary importance
syn match zortexTag "^@\S\+$" contains=zortexTagMarker
syn match zortexTagMarker "^@" contained

" Headings with different levels
syn match zortexH1 "^#\s.*$" contains=zortexH1Marker
syn match zortexH2 "^##\s.*$" contains=zortexH2Marker
syn match zortexH3 "^###\s.*$" contains=zortexH3Marker
syn match zortexH4 "^####\s.*$" contains=zortexH4Marker
syn match zortexH5 "^#####\s.*$" contains=zortexH5Marker
syn match zortexH6 "^######\s.*$" contains=zortexH6Marker

syn match zortexH1Marker "^#\s" contained
syn match zortexH2Marker "^##\s" contained
syn match zortexH3Marker "^###\s" contained
syn match zortexH4Marker "^####\s" contained
syn match zortexH5Marker "^#####\s" contained
syn match zortexH6Marker "^######\s" contained

" Labels
syn match zortexLabel "^[A-Za-z0-9][A-Za-z0-9 ]*:$"

" Lists
syn match zortexListMarker "^\s*[-*+]\s" 
syn match zortexOrderedListMarker "^\s*\d\+\.\s"

" Links - all types
syn region zortexLink start="\[" end="\]" nextgroup=zortexURL
syn region zortexURL start="(" end=")" contained

" Code
syn region zortexInlineCode start="`" end="`" keepend
syn region zortexCodeBlock start="^```.*$" end="^```$" keepend

" LaTeX
syn region zortexInlineMath start="\$" end="\$" skip="\\\$" keepend
syn region zortexDisplayMath start="^\$\$" end="^\$\$" keepend

" Bold and Italic
syn region zortexBoldItalic start="\*\*\*" end="\*\*\*" keepend
syn region zortexBold start="\*\*" end="\*\*" keepend contains=zortexBoldItalic
syn region zortexItalic start="\*" end="\*" keepend contains=zortexBold,zortexBoldItalic

" Define highlighting
hi def link zortexArticleMarker Keyword
hi def link zortexArticleHeader Title
hi def link zortexTagMarker Special  
hi def link zortexTag Tag

" Headings - graduated colors
hi def link zortexH1Marker Title
hi def link zortexH1 Title
hi def link zortexH2Marker Title
hi def link zortexH2 Title
hi def link zortexH3Marker Title
hi def link zortexH3 Title
hi def link zortexH4Marker Title
hi def link zortexH4 Title
hi def link zortexH5Marker Title
hi def link zortexH5 Title
hi def link zortexH6Marker Title
hi def link zortexH6 Title

hi def link zortexLabel Identifier
hi def link zortexListMarker Special
hi def link zortexOrderedListMarker Special

hi def link zortexLink Underlined
hi def link zortexURL String

hi def link zortexInlineCode String
hi def link zortexCodeBlock String

hi def link zortexInlineMath Special
hi def link zortexDisplayMath Special

hi zortexBold term=bold cterm=bold gui=bold
hi zortexItalic term=italic cterm=italic gui=italic
hi zortexBoldItalic term=bold,italic cterm=bold,italic gui=bold,italic

" Conceal settings for cleaner look (optional)
if has('conceal')
  syn match zortexBoldDelimiter "\*\*" contained conceal
  syn match zortexItalicDelimiter "\*" contained conceal
  setlocal conceallevel=2
endif

let b:current_syntax = "zortex"
