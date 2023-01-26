" Copyright (c) Pim Snel 2019-2023

if !hlexists('markdownLinkText')
  syn match markdownValid '[<>]\c[a-z/$!]\@!'
  syn match markdownValid '&\%(#\=\w*;\)\@!'

  syn match markdownLineStart "^[<@]\@!" nextgroup=@markdownBlock,htmlSpecialChar

  syn cluster markdownBlock contains=markdownH1,markdownH2,markdownH3,markdownH4,markdownH5,markdownH6,markdownBlockquote,markdownListMarker,markdownOrderedListMarker,markdownCodeBlock,markdownRule,markdownGithubAutoLink
  syn cluster markdownInline contains=markdownLineBreak,markdownLinkText,markdownItalic,markdownBold,markdownCode,markdownEscape,@htmlTop,markdownError,markdownGithubAutoLink,markdownGithubStrikeThrough

  syn match markdownH1 "^.\+\n=\+$" contained contains=@markdownInline,markdownHeadingRule,markdownAutomaticLink
  syn match markdownH2 "^.\+\n-\+$" contained contains=@markdownInline,markdownHeadingRule,markdownAutomaticLink

  syn match markdownHeadingRule "^[=-]\+$" contained

  syn region markdownH1 matchgroup=markdownHeadingDelimiter start="##\@!"      end="#*\s*$" keepend oneline contains=@markdownInline,markdownAutomaticLink contained
  syn region markdownH2 matchgroup=markdownHeadingDelimiter start="###\@!"     end="#*\s*$" keepend oneline contains=@markdownInline,markdownAutomaticLink contained
  syn region markdownH3 matchgroup=markdownHeadingDelimiter start="####\@!"    end="#*\s*$" keepend oneline contains=@markdownInline,markdownAutomaticLink contained
  syn region markdownH4 matchgroup=markdownHeadingDelimiter start="#####\@!"   end="#*\s*$" keepend oneline contains=@markdownInline,markdownAutomaticLink contained
  syn region markdownH5 matchgroup=markdownHeadingDelimiter start="######\@!"  end="#*\s*$" keepend oneline contains=@markdownInline,markdownAutomaticLink contained
  syn region markdownH6 matchgroup=markdownHeadingDelimiter start="#######\@!" end="#*\s*$" keepend oneline contains=@markdownInline,markdownAutomaticLink contained

  syn match markdownBlockquote ">\%(\s\|$\)" contained nextgroup=@markdownBlock

  syn region markdownCodeBlock start="    \|\t" end="$" contained

  syn match markdownListMarker "\%(\t\| \{0,4\}\)[-*+]\%(\s\+\S\)\@=" contained
  syn match markdownOrderedListMarker "\%(\t\| \{0,4}\)\<\d\+\.\%(\s\+\S\)\@=" contained

  syn match markdownRule "\* *\* *\*[ *]*$" contained
  syn match markdownRule "- *- *-[ -]*$" contained

  syn match markdownLineBreak " \{2,\}$"

  syn region markdownIdDeclaration matchgroup=markdownLinkDelimiter start="^ \{0,3\}!\=\[" end="\]:" oneline keepend nextgroup=markdownUrl skipwhite
  syn match markdownUrl "\S\+" nextgroup=markdownUrlTitle skipwhite contained
  syn region markdownUrl matchgroup=markdownUrlDelimiter start="<" end=">" oneline keepend nextgroup=markdownUrlTitle skipwhite contained
  syn region markdownUrlTitle matchgroup=markdownUrlTitleDelimiter start=+"+ end=+"+ keepend contained
  syn region markdownUrlTitle matchgroup=markdownUrlTitleDelimiter start=+'+ end=+'+ keepend contained
  syn region markdownUrlTitle matchgroup=markdownUrlTitleDelimiter start=+(+ end=+)+ keepend contained

  syn region markdownLinkText matchgroup=markdownLinkTextDelimiter start="!\=\[\%(\_[^]]*]\%( \=[[(]\)\)\@=" end="\]\%( \=[[(]\)\@=" keepend nextgroup=markdownLink,markdownId skipwhite contains=@markdownInline,markdownLineStart
  syn region markdownLink matchgroup=markdownLinkDelimiter start="(" end=")" contains=markdownUrl keepend contained
  syn region markdownAutomaticLink matchgroup=markdownUrlDelimiter start="<\%(\w\+:\|[[:alnum:]_+-]\+@\)\@=" end=">" keepend oneline

  hi def link LinnyLinkText             htmlLink
  hi def link LinnyId                   Type

  syn region LinnyLinkText matchgroup=markdownLinkTextDelimiter start="!\=[[(]\@=" end="\]\%( \=[[(]\)\@=" nextgroup=markdownLink,LinnyId skipwhite contains=@markdownInline,markdownLineStart
  syn region LinnyId matchgroup=markdownIdDelimiter start="\[\[" end="\]\]" keepend contained

else

  syn clear markdownLinkText
  syn clear markdownId

  syn region markdownLinkText matchgroup=markdownLinkTextDelimiter start="!\=[[(]\@=" end="\]\%( \=[[(]\)\@=" nextgroup=markdownLink,markdownId skipwhite contains=@markdownInline,markdownLineStart
  syn region markdownId matchgroup=markdownIdDelimiter start="\[\[" end="\]\]" keepend contained

endif

hi def link LinnyTestFileExist        Keyword
hi def link LinnyTestFileNotExist     Comment

syn keyword LinnyTestFileExist FILEEXISTS
syn keyword LinnyTestFileNotExist FILENOTEXIST

unlet b:current_syntax

syn include @Yaml syntax/yaml.vim
syn region yamlFrontmatter start=/\%^---$/ end=/^---$/ keepend contains=@Yaml
