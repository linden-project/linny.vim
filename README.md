vim-markdown-wiki
================

*vim-markdown-kiwi* is a Vim plugin which eases the navigation between files in
a personal wiki based on markdown and can work brilliantly together with the personal
wiki app for iOS app https://github.com/landakram/kiwi

Installation
-------------

Add the line `Bundle 'mipmip/vim-markdown-kiwi'` in your .vimrc if you use *Vundle* or a similar plugin manager
Or copy the after/ftplugin/markdown.vim file into the $HOME/.vim/after/ftplugin/ directory

Usage
-----

With the default key mappings :

**Link creation:**

 - Hit the ENTER key when the cursor is on a text between double brackets : `[[a title]]`
 - The link will be created and the corresponding file will be loaded in the buffer.

**Navigation:**

 - Hit the ENTER key when the cursor is on a wiki link
 - The corresponding link file is loaded in the current buffer.
 - Hit Leader key + ENTER to go back

Change key mappings in your vim config file
--------

Create or go to link :
`nnoremap  <CR> :MdwiGotoLink`

Return to previous page  :
`nnoremap  <Leader><CR> :MdwiReturn`

Tips
----

### Convert []() style links to [[]]

use this vim replace regex to convert your links if you want to switch from []() links to [[]]

```
:%s/\[\([a-zA-Z0-9+,:@&'_\.\-\ ]*\)](.*)/[[\1]]/gc
```

### Use GNU rename to convert your markdown files

Convert dashes to underscores:

```
rename 's/-/_/g' *.md
```

Convert files to lowercase names

```
rename -fn 'y/A-Z/a-z/' *.md
```

### Make shortcuts for your starting point files. I have them mapped like this:

nmap \w :e $HOME/Dropbox/Apps/KiwiApp/wiki/home.md<CR>


### Use a helper script which dynamically creates an index listing of all .md-files


I've created this ruby script:

```ruby
body  = "WIKI INDEX\n"
body += "==========\n"
body += "\n"

Dir.entries("#{Dir.home}/Dropbox/Life").sort.each do |item|
  if File.extname(item) == '.md'
    body += "[[#{File.basename(item,'.md').capitalize.gsub("_", " ")}]]\n"
  end
end

File.open("#{Dir.home}/Dropbox/Life/index.md", 'w') { |file| file.write(body) }

```

... and glued it together using this mapping:

```
nmap \i :!ruby ~/.vim/helpers/make_wiki_index.rb<CR><CR>:e $HOME/Dropbox/Apps/KiwiApp/wiki/index.md<CR>
```

### Use Dropbox

Store your wiki files in Dropbox so it is available on your devices and can
work with [Kiwi App](https://itunes.apple.com/us/app/kiwi-personal-wiki/id1158640011?mt=8).

### Other great markdown vim plugins

- https://github.com/tpope/vim-markdown
- https://github.com/dhruvasagar/vim-table-mode

## Acknowledgements

This plugin it almost heavily based on
[mmai/vim-markdown-wiki](https://github.com/mmai/vim-markdown-wiki). Main
difference is the wiki-links format.

vim-markdown-kiwi uses [[some page]] and vim-markdown-wiki uses [some
page](some-page.md)
