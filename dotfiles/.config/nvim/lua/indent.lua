local cmd = vim.cmd

cmd [[
augroup fileTypeIndent
    autocmd!
    autocmd BufNewFile,BufRead *.py setlocal tabstop=4 softtabstop=4 shiftwidth=4
    autocmd BufNewFile,BufRead *.cs setlocal tabstop=4 softtabstop=4 shiftwidth=4
    autocmd BufNewFile,BufRead *.xaml setlocal tabstop=4 softtabstop=4 shiftwidth=4
    autocmd BufNewFile,BufRead *.lua setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufNewFile,BufRead *.cu setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufNewFile,BufRead *.c  setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufNewFile,BufRead *.h  setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufNewFile,BufRead *.cpp  setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufNewFile,BufRead *.hpp  setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufNewFile,BufRead *.rb setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufNewFile,BufRead *.elm setlocal tabstop=4 softtabstop=4 shiftwidth=4
    autocmd BufRead,BufNewFile *.js setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufRead,BufNewFile *.jsx setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufRead,BufNewFile *.tsx setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufRead,BufNewFile *.ts setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufRead,BufNewFile *.html setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufRead,BufNewFile *.css setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufRead,BufNewFile *.json setlocal tabstop=4 softtabstop=4 shiftwidth=4
    autocmd BufRead,BufNewFile *.tex setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufRead,BufNewFile *.fsx setlocal tabstop=4 softtabstop=4 shiftwidth=4
    autocmd BufRead,BufNewFile *.fs setlocal tabstop=4 softtabstop=4 shiftwidth=4
    autocmd BufRead,BufNewFile *.sql setlocal tabstop=2 softtabstop=2 shiftwidth=2
augroup END

]]

vim.opt.list = true
vim.opt.listchars:append("space:⋅")
vim.opt.listchars:append("eol:↴")

require("indent_blankline").setup {
    space_char_blankline = " ",
    show_current_context = true,
    show_current_context_start = true,
}
