-- ~/.config/nvim/lua/plugins/presence.lua
return {
  "andweeb/presence.nvim",
  event = "VeryLazy",
  config = function()
    require("presence").setup({
      -- Configuración básica (SIN log_level)
      auto_update = true,
      neovim_image_text = "Neovim",
      main_image = "neovim",
      client_id = "793271441293967371",
      debounce_timeout = 1,
      
      -- Textos para diferentes estados
      editing_text = "Editando %s",
      file_explorer_text = "Navegando archivos", 
      git_commit_text = "Commiteando cambios",
      plugin_manager_text = "Gestionando plugins",
      reading_text = "Leyendo %s",
      workspace_text = "Trabajando en %s",
      line_number_text = "Línea %s de %s",
      
      -- Mostrar incluso en buffers sin nombre
      enable_line_number = true,
      blacklist = {},  -- No excluir ningún tipo de buffer
      
      -- Sin botones por ahora (puede causar problemas)
      buttons = nil,
    })
  end,
}