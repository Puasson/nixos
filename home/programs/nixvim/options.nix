{ ... }:
{
  programs.nixvim.opts = {
    number = true;
    relativenumber = true;
    cursorline = true;
    signcolumn = "yes";
    termguicolors = true;
    background = "dark";

    expandtab = true;
    shiftwidth = 2;
    tabstop = 2;
    softtabstop = 2;
    smartindent = true;

    ignorecase = true;
    smartcase = true;
    hlsearch = true;
    incsearch = true;

    undofile = true;
    swapfile = false;
    backup = false;

    splitright = true;
    splitbelow = true;
    wrap = false;
    scrolloff = 8;
    sidescrolloff = 8;

    updatetime = 250;
    timeoutlen = 300;

    completeopt = "menu,menuone,noselect";
    pumheight = 10;

    list = true;
    listchars = "tab:» ,trail:·,nbsp:␣";

    foldlevel = 99;
  };
}
