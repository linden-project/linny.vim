
"syn cluster markdownInline contains=markdownLineBreak,markdownLinkText,markdownItalic,markdownBold,markdownCode,markdownEscape,@htmlTop,markdownError,markdownLinkText2

"syn region markdownLinkText2 matchgroup=markdownLinkTextDelimiter start="!\=\[\%(\_[^]]*]\%( \=[[(]\)\)\@=" end="\]\%( \=[[(]\)\@=" nextgroup=markdownLink,markdownId skipwhite contains=@markdownInline,markdownLineStart
"syn region markdownId2 matchgroup=markdownIdDelimiter start="\[\[" end="\]\]" keepend contained

"hi def link markdownId2                    Type
"#hi def link markdownLinkText2              htmlLink

syn clear markdownLinkText
syn region markdownLinkText matchgroup=markdownLinkTextDelimiter start="!\=[[(]\@=" end="\]\%( \=[[(]\)\@=" nextgroup=markdownLink,markdownId skipwhite contains=@markdownInline,markdownLineStart

syn clear markdownId
syn region markdownId matchgroup=markdownIdDelimiter start="\[\[" end="\]\]" keepend contained
