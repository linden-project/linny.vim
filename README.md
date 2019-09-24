wimpi-vim
=========

Soon to be renamed.

Installation
-------------

Install using your favorite package manager. 'mipmip/wimpi-vim'

Usage
-----

With the default key mappings :

**Link creation:**

 - Hit the ENTER key when the cursor is on a text between double brackets : [[a title]]
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

### Depends on

- https://github.com/tpope/vim-markdown

## Acknowledgements

[mmai/vim-markdown-wiki](https://github.com/mmai/vim-markdown-wiki).

License

Copyright (c) Pim Snel. Distributed under the same terms as Vim itself. See :help license.
