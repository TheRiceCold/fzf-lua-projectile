## fzf-lua-projectile

An extension of [fzf-lua](https://github.com/ibhagwan/fzf-lua) that allows you to switch between projects. Inspired by emacs projectile.

### Demo
https://github.com/user-attachments/assets/098eced5-4774-4fc6-8db0-b53c6eed9c43

### Installation
- [vim-plug](https://github.com/junegunn/vim-plug)
```vim
Plug 'TheRiceCold/fzf-lua-projectile'
lua << EOF
require('fzf-lua-projectile').setup()
EOF
```
- [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use { "TheRiceCold/fzf-lua-projectile", config = function() require('fzf-lua-projectile').setup() end }
```
- [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{ "TheRiceCold/fzf-lua-projectile", config = true }
```

### Configuration

``` lua
require'fzf-lua-projectile'.setup {
  path_level_label = 2,                        -- Show up to 2 levels of the directory path
  project_directory = 'path/to/your/projects'  -- Set the desired path here
}
```

### Usage
**Find projects**
```
:FzfProjectile
```
**Refresh project list**
```
:FzfProjectileRefresh
```
