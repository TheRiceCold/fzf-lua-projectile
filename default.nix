{ lib, buildVimPlugin, fetchFromGitHub }:

buildVimPlugin {
  pname = "fzf-lua-projectile";
  version = "1.0.0";

  src = ./lua/fzf-lua-projectile/init.lua;

  meta = with lib; {
    description = "A Neovim plugin for searching projects using fzf-lua";
    homepage = "https://github.com/thericecold/fzf-lua-projectile";
    license = licenses.mit;
    maintainers = [ maintainers.thericecold ];
  };
}
