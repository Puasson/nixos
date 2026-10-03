{ ... }:
{
  programs.nixvim.keymaps = [
    {
      mode = [
        "n"
        "x"
      ];
      key = "j";
      action = "v:count == 0 ? 'gj' : 'j'";
      options = {
        desc = "Down";
        silent = true;
        expr = true;
      };
    }
    {
      mode = [
        "n"
        "x"
      ];
      key = "k";
      action = "v:count == 0 ? 'gk' : 'k'";
      options = {
        desc = "Up";
        silent = true;
        expr = true;
      };
    }
    {
      mode = [
        "n"
        "x"
      ];
      key = "<Down>";
      action = "v:count == 0 ? 'gj' : 'j'";
      options = {
        desc = "Down";
        silent = true;
        expr = true;
      };
    }
    {
      mode = [
        "n"
        "x"
      ];
      key = "<Up>";
      action = "v:count == 0 ? 'gk' : 'k'";
      options = {
        desc = "Up";
        silent = true;
        expr = true;
      };
    }

    # ── windows: C-hjkl mover, C-Arrows resize ──────────────────
    {
      mode = "n";
      key = "<C-h>";
      action = "<C-w>h";
      options = {
        desc = "Go to Left Window";
        silent = true;
        remap = true;
      };
    }
    {
      mode = "n";
      key = "<C-j>";
      action = "<C-w>j";
      options = {
        desc = "Go to Lower Window";
        silent = true;
        remap = true;
      };
    }
    {
      mode = "n";
      key = "<C-k>";
      action = "<C-w>k";
      options = {
        desc = "Go to Upper Window";
        silent = true;
        remap = true;
      };
    }
    {
      mode = "n";
      key = "<C-l>";
      action = "<C-w>l";
      options = {
        desc = "Go to Right Window";
        silent = true;
        remap = true;
      };
    }
    {
      mode = "n";
      key = "<C-Up>";
      action = "<cmd>resize +2<CR>";
      options = {
        desc = "Increase Window Height";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<C-Down>";
      action = "<cmd>resize -2<CR>";
      options = {
        desc = "Decrease Window Height";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<C-Left>";
      action = "<cmd>vertical resize -2<CR>";
      options = {
        desc = "Decrease Window Width";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<C-Right>";
      action = "<cmd>vertical resize +2<CR>";
      options = {
        desc = "Increase Window Width";
        silent = true;
      };
    }
    # grupo windows (<leader>w, como LazyVim; <C-w> sigue valiendo)
    {
      mode = "n";
      key = "<leader>ww";
      action = "<C-w>p";
      options = {
        desc = "Other Window";
        silent = true;
        remap = true;
      };
    }
    {
      mode = "n";
      key = "<leader>wd";
      action = "<C-w>c";
      options = {
        desc = "Delete Window";
        silent = true;
        remap = true;
      };
    }
    {
      mode = "n";
      key = "<leader>ws";
      action = "<cmd>split<CR>";
      options = {
        desc = "Split Below";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>wv";
      action = "<cmd>vsplit<CR>";
      options = {
        desc = "Split Right";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>wm";
      action = "<cmd>only<CR>";
      options = {
        desc = "Maximize (only)";
        silent = true;
      };
    }

    # ── move lines A-j/k ────────────────────────────────────────
    {
      mode = "n";
      key = "<A-j>";
      action = "<cmd>execute 'move .+' . v:count1<CR>==";
      options = {
        desc = "Move Down";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<A-k>";
      action = "<cmd>execute 'move .-' . (v:count1 + 1)<CR>==";
      options = {
        desc = "Move Up";
        silent = true;
      };
    }
    {
      mode = "i";
      key = "<A-j>";
      action = "<esc><cmd>m .+1<CR>==gi";
      options = {
        desc = "Move Down";
        silent = true;
      };
    }
    {
      mode = "i";
      key = "<A-k>";
      action = "<esc><cmd>m .-2<CR>==gi";
      options = {
        desc = "Move Up";
        silent = true;
      };
    }
    {
      mode = "v";
      key = "<A-j>";
      action = ":<C-u>execute \"'<,'>move '>+\" . v:count1<CR>gv=gv";
      options = {
        desc = "Move Down";
        silent = true;
      };
    }
    {
      mode = "v";
      key = "<A-k>";
      action = ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<CR>gv=gv";
      options = {
        desc = "Move Up";
        silent = true;
      };
    }

    # ── buffers (LazyVim + Tab heredado) ────────────────────────
    {
      mode = "n";
      key = "<S-h>";
      action = "<cmd>bprevious<CR>";
      options = {
        desc = "Prev Buffer";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<S-l>";
      action = "<cmd>bnext<CR>";
      options = {
        desc = "Next Buffer";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "[b";
      action = "<cmd>bprevious<CR>";
      options = {
        desc = "Prev Buffer";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "]b";
      action = "<cmd>bnext<CR>";
      options = {
        desc = "Next Buffer";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<Tab>";
      action = "<cmd>BufferLineCycleNext<CR>";
      options = {
        desc = "Next Buffer";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<S-Tab>";
      action = "<cmd>BufferLineCyclePrev<CR>";
      options = {
        desc = "Prev Buffer";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>bb";
      action = "<cmd>e #<CR>";
      options = {
        desc = "Switch to Other Buffer";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>`";
      action = "<cmd>e #<CR>";
      options = {
        desc = "Switch to Other Buffer";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>bd";
      action = "<cmd>bdelete<CR>";
      options = {
        desc = "Delete Buffer";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>bD";
      action = "<cmd>bd<CR>";
      options = {
        desc = "Delete Buffer and Window";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>bo";
      action = "<cmd>BufferLineCloseOthers<CR>";
      options = {
        desc = "Delete Other Buffers";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>bl";
      action = "<cmd>BufferLineCloseLeft<CR>";
      options = {
        desc = "Delete Buffers to the Left";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>br";
      action = "<cmd>BufferLineCloseRight<CR>";
      options = {
        desc = "Delete Buffers to the Right";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>bp";
      action = "<cmd>BufferLineTogglePin<CR>";
      options = {
        desc = "Toggle Pin";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>bj";
      action = "<cmd>BufferLinePick<CR>";
      options = {
        desc = "Pick Buffer";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "[B";
      action = "<cmd>BufferLineMovePrev<CR>";
      options = {
        desc = "Move buffer prev";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "]B";
      action = "<cmd>BufferLineMoveNext<CR>";
      options = {
        desc = "Move buffer next";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>be";
      action = "<cmd>Neotree buffers toggle<CR>";
      options = {
        desc = "Buffer Explorer";
        silent = true;
      };
    }

    # ── save (C-s + fs, LazyVim) ────────────────────────────────
    {
      mode = [
        "n"
        "i"
        "x"
        "s"
      ];
      key = "<C-s>";
      action = "<cmd>w<CR><esc>";
      options = {
        desc = "Save File";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>fs";
      action = "<cmd>w<CR><esc>";
      options = {
        desc = "Save File";
        silent = true;
      };
    }

    # ── file/find (Telescope, centralizado aquí) ────────────────
    {
      mode = "n";
      key = "<leader><leader>";
      action = "<cmd>Telescope find_files<CR>";
      options = {
        desc = "Find Files (Root)";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>fF";
      action = "<cmd>Telescope find_files cwd=%:p:h<CR>";
      options = {
        desc = "Find Files (cwd)";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>fg";
      action = "<cmd>Telescope live_grep<CR>";
      options = {
        desc = "Live Grep";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>fr";
      action = "<cmd>Telescope oldfiles<CR>";
      options = {
        desc = "Recent";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>fb";
      action = "<cmd>Telescope buffers<CR>";
      options = {
        desc = "Buffers";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>fh";
      action = "<cmd>Telescope help_tags<CR>";
      options = {
        desc = "Help";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>fn";
      action = "<cmd>enew<CR>";
      options = {
        desc = "New File";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>fe";
      action = "<cmd>Neotree toggle<CR>";
      options = {
        desc = "Explorer NeoTree";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>fE";
      action = "<cmd>Neotree toggle dir=%:p:h<CR>";
      options = {
        desc = "Explorer NeoTree (cwd)";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>e";
      action = "<cmd>Neotree toggle<CR>";
      options = {
        desc = "Explorer NeoTree";
        silent = true;
        remap = true;
      };
    }
    {
      mode = "n";
      key = "<leader>E";
      action = "<cmd>Neotree toggle dir=%:p:h<CR>";
      options = {
        desc = "Explorer NeoTree (cwd)";
        silent = true;
        remap = true;
      };
    }
    {
      mode = "n";
      key = "<leader>ge";
      action = "<cmd>Neotree git_status toggle<CR>";
      options = {
        desc = "Git Explorer";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>ft";
      action = "<cmd>split | terminal<CR>";
      options = {
        desc = "Terminal";
        silent = true;
      };
    }

    # ── search extra (LazyVim grupo s, con Telescope actual) ────
    {
      mode = "n";
      key = "<leader>sg";
      action = "<cmd>Telescope live_grep<CR>";
      options = {
        desc = "Grep (cwd)";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>sr";
      action = "<cmd>Telescope oldfiles<CR>";
      options = {
        desc = "Recent";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>sd";
      action = "<cmd>Telescope diagnostics<CR>";
      options = {
        desc = "Diagnostics";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>sh";
      action = "<cmd>Telescope help_tags<CR>";
      options = {
        desc = "Help Pages";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>sk";
      action = "<cmd>Telescope keymaps<CR>";
      options = {
        desc = "Keymaps";
        silent = true;
      };
    }

    # ── code / LSP (grupo c) ────────────────────────────────────
    {
      mode = "n";
      key = "gd";
      action = "<cmd>lua vim.lsp.buf.definition()<CR>";
      options = {
        desc = "Goto Definition";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "gr";
      action = "<cmd>Telescope lsp_references<CR>";
      options = {
        desc = "References";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "gy";
      action = "<cmd>lua vim.lsp.buf.type_definition()<CR>";
      options = {
        desc = "Goto Type Definition";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "gI";
      action = "<cmd>Telescope lsp_implementations<CR>";
      options = {
        desc = "Goto Implementation";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "K";
      action = "<cmd>lua vim.lsp.buf.hover()<CR>";
      options = {
        desc = "Hover";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>ca";
      action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
      options = {
        desc = "Code Action";
        silent = true;
      };
    }
    {
      mode = [
        "n"
        "x"
      ];
      key = "<leader>cf";
      action = "<cmd>lua vim.lsp.buf.format({ async = true })<CR>";
      options = {
        desc = "Format";
        silent = true;
      };
    }
    {
      mode = [
        "n"
        "x"
      ];
      key = "<leader>cF";
      action = "<cmd>lua require('conform').format({ formatters = { 'injected' } })<CR>";
      options = {
        desc = "Format Injected Langs";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>cs";
      action = "<cmd>Trouble symbols toggle<CR>";
      options = {
        desc = "Symbols (Trouble)";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>cS";
      action = "<cmd>Trouble lsp toggle<CR>";
      options = {
        desc = "LSP references/definitions/... (Trouble)";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>cr";
      action = "<cmd>lua vim.lsp.buf.rename()<CR>";
      options = {
        desc = "Rename";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>K";
      action = "<cmd>norm! K<CR>";
      options = {
        desc = "Keywordprg";
        silent = true;
      };
    }

    # ── diagnostics / quickfix (grupo x, trouble) ───────────────
    {
      mode = "n";
      key = "<leader>xx";
      action = "<cmd>Trouble diagnostics toggle<CR>";
      options = {
        desc = "Diagnostics (Trouble)";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>xX";
      action = "<cmd>Trouble diagnostics toggle filter.buf=0<CR>";
      options = {
        desc = "Buffer Diagnostics (Trouble)";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>xL";
      action = "<cmd>Trouble loclist toggle<CR>";
      options = {
        desc = "Location List (Trouble)";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>xQ";
      action = "<cmd>Trouble qflist toggle<CR>";
      options = {
        desc = "Quickfix List (Trouble)";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "[q";
      action.__raw = ''
        function()
          if require("trouble").is_open() then
            require("trouble").prev({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cprev)
            if not ok then vim.notify(err, vim.log.levels.ERROR) end
          end
        end
      '';
      options = {
        desc = "Previous Trouble/Quickfix Item";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "]q";
      action.__raw = ''
        function()
          if require("trouble").is_open() then
            require("trouble").next({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cnext)
            if not ok then vim.notify(err, vim.log.levels.ERROR) end
          end
        end
      '';
      options = {
        desc = "Next Trouble/Quickfix Item";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "[d";
      action = "<cmd>lua vim.diagnostic.goto_prev()<CR>";
      options = {
        desc = "Prev Diagnostic";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "]d";
      action = "<cmd>lua vim.diagnostic.goto_next()<CR>";
      options = {
        desc = "Next Diagnostic";
        silent = true;
      };
    }

    # ── quit / session (grupo q) ────────────────────────────────
    {
      mode = "n";
      key = "<leader>qq";
      action = "<cmd>qa<CR>";
      options = {
        desc = "Quit All";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>qs";
      action = "<cmd>lua require('auto-session').SaveSession()<CR>";
      options = {
        desc = "Save Session";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>ql";
      action = "<cmd>lua require('auto-session').RestoreSession()<CR>";
      options = {
        desc = "Restore Session";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>qd";
      action = "<cmd>Dashboard<CR>";
      options = {
        desc = "Dashboard";
        silent = true;
      };
    }

    # ── tabs (grupo <tab>) ──────────────────────────────────────
    {
      mode = "n";
      key = "<leader><tab>l";
      action = "<cmd>tablast<CR>";
      options = {
        desc = "Last Tab";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader><tab>o";
      action = "<cmd>tabonly<CR>";
      options = {
        desc = "Close Other Tabs";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader><tab>f";
      action = "<cmd>tabfirst<CR>";
      options = {
        desc = "First Tab";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader><tab><tab>";
      action = "<cmd>tabnew<CR>";
      options = {
        desc = "New Tab";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader><tab>]";
      action = "<cmd>tabnext<CR>";
      options = {
        desc = "Next Tab";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader><tab>d";
      action = "<cmd>tabclose<CR>";
      options = {
        desc = "Close Tab";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader><tab>[";
      action = "<cmd>tabprevious<CR>";
      options = {
        desc = "Previous Tab";
        silent = true;
      };
    }

    # ── UI (grupo u, LazyVim ur) ────────────────────────────────
    {
      mode = "n";
      key = "<leader>ur";
      action = "<cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>";
      options = {
        desc = "Redraw / Clear hlsearch / Diff Update";
        silent = true;
      };
    }

    # ── misc LazyVim ────────────────────────────────────────────
    {
      mode = "n";
      key = "<esc>";
      action = "<cmd>nohlsearch<CR><esc>";
      options = {
        desc = "Escape and Clear hlsearch";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "n";
      action = "'Nn'[v:searchforward] . 'zv'";
      options = {
        desc = "Next Search Result";
        silent = true;
        expr = true;
      };
    }
    {
      mode = "x";
      key = "n";
      action = "'Nn'[v:searchforward]";
      options = {
        desc = "Next Search Result";
        silent = true;
        expr = true;
      };
    }
    {
      mode = "o";
      key = "n";
      action = "'Nn'[v:searchforward]";
      options = {
        desc = "Next Search Result";
        silent = true;
        expr = true;
      };
    }
    {
      mode = "n";
      key = "N";
      action = "'nN'[v:searchforward] . 'zv'";
      options = {
        desc = "Prev Search Result";
        silent = true;
        expr = true;
      };
    }
    {
      mode = "x";
      key = "N";
      action = "'nN'[v:searchforward]";
      options = {
        desc = "Prev Search Result";
        silent = true;
        expr = true;
      };
    }
    {
      mode = "o";
      key = "N";
      action = "'nN'[v:searchforward]";
      options = {
        desc = "Prev Search Result";
        silent = true;
        expr = true;
      };
    }
    {
      mode = "i";
      key = ",";
      action = ",<c-g>u";
      options = {
        desc = "Add undo break-point";
        silent = true;
      };
    }
    {
      mode = "i";
      key = ".";
      action = ".<c-g>u";
      options = {
        desc = "Add undo break-point";
        silent = true;
      };
    }
    {
      mode = "i";
      key = ";";
      action = ";<c-g>u";
      options = {
        desc = "Add undo break-point";
        silent = true;
      };
    }
    {
      mode = "x";
      key = "<";
      action = "<gv";
      options = {
        desc = "Better indenting";
        silent = true;
      };
    }
    {
      mode = "x";
      key = ">";
      action = ">gv";
      options = {
        desc = "Better indenting";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "gco";
      action = "o<esc>Vcx<esc><cmd>normal gcc<CR>fxa<bs>";
      options = {
        desc = "Add Comment Below";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "gcO";
      action = "O<esc>Vcx<esc><cmd>normal gcc<CR>fxa<bs>";
      options = {
        desc = "Add Comment Above";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>?";
      action = "<cmd>WhichKey<CR>";
      options = {
        desc = "Buffer Keymaps (which-key)";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "gx";
      action = "<cmd>lua vim.ui.open(vim.fn.expand('<cfile>'))<CR>";
      options = {
        desc = "Open with system app";
        silent = true;
      };
    }
  ];
}
