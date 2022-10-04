require('core')
require('keymap')
require('plugins')

vim.cmd[[autocmd BufWritePost plugins.lua PackerCompile]]
