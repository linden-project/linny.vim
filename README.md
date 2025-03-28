# Linny.vim

*Update 22 August 2024 - As the creator of Linny.vim has switched to NeoVim.
Linny is now fully compatible with NeoVim* 

**RIP Bram Molenaar**

Personal wiki and document database powered by Markdown and Front Matter.

![](linny-vim1.gif)

# Quickstart

Read the [Linny.vim + Notes Boilerplate quick start tutorial](https://linden-project.github.io/posts/tutorial-linny-and-carl/)

# Installation

Use your favorite package manager.

Using vim-plug:

```vim
Plug 'linden-project/linny.vim'
```

Using Lazy:

```lua
{
  'linden-project/linny.vim',
  enabled = true,
  config = function()
    vim.fn['linny#Init']()
  end,
}
```

## NeoVim

More instructions will follow but you can checkout [my neovim configuration](https://github.com/mipmip/nixos/tree/main/home/pim/files-main/nvim)
as example.

## Install fred

Some features for linny require [fred](https://github.com/linden-project/fred).

Install the latest version on your system. Linny will show the version in the
linny menu.

# Documentation

The official manual can be read directly in Vim/NeoVim:

```
:help linny
```

Alternatively, you can read
[linny.txt](https://github.com/linden-project/linny.vim/blob/master/doc/linny.txt)
in your browser.

# Release Notes

first update CHANGELOG.md with new version.

```bash
rake bump\[0.8.0\]
git commit -m "version bump" -a
rake release\[0.8.0\]
```

# Credits

- [vimwiki](https://github.com/vimwiki/vimwiki) - The most popular Wiki plugin for Vim
- [mmai/vim-markdown-wiki](https://github.com/mmai/vim-markdown-wiki) - A simple Wiki plugin for vim made with a few Markdown additions
- [Kiwi](https://github.com/landakram/kiwi) - An iOS Wiki App using dropbox for synchronization and Markdown as wiki documents.
- [skywind3000/quickmenu](https://github.com/skywind3000/quickmenu.vim) - Side panel menu plugin with customizable shortcuts.

# License

MIT - Copyright 2019-2025 (c) Pim Snel.
