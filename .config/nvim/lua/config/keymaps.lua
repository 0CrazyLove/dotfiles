-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- Forzar Ctrl+L = "clear" solo en buffers de terminal (tiene prioridad sobre Snacks)
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "term://*",
  callback = function(ev)
    -- por si acaso, elimina un mapeo local previo sin romper si no existe
    pcall(vim.keymap.del, 't', '<C-l>', { buffer = ev.buf })

    -- envía literalmente "clear<Enter>" al shell del terminal embebido
    vim.keymap.set('t', '<C-l>', [[clear<CR>]], {
      buffer = ev.buf,      -- ***clave***: local al buffer ⇒ prioridad sobre globales
      noremap = true,
      silent = true,
      nowait = true,
      desc = "Terminal: clear screen",
    })
  end,
})
