-- Pi AI coding assistant side panel
-- Toggle with <leader>aa (Space a a)

local M = {}

local pi_buf = nil
local pi_win = nil
local pi_chan = nil

local function is_valid()
  return pi_buf and vim.api.nvim_buf_is_valid(pi_buf) and pi_win and vim.api.nvim_win_is_valid(pi_win)
end

local function close()
  if pi_win and vim.api.nvim_win_is_valid(pi_win) then
    vim.api.nvim_win_close(pi_win, true)
  end
  pi_win = nil
end

local function kill_terminal()
  if pi_buf and vim.api.nvim_buf_is_valid(pi_buf) then
    vim.api.nvim_buf_delete(pi_buf, { force = true })
  end
  pi_buf = nil
  pi_win = nil
  pi_chan = nil
end

local function open(file_ref, cmd)
  cmd = cmd or "pi --continue"

  -- If buffer exists and is valid, just reopen the window with it
  if pi_buf and vim.api.nvim_buf_is_valid(pi_buf) then
    vim.cmd("botright vsplit")
    pi_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(pi_win, pi_buf)
    vim.api.nvim_win_set_width(pi_win, math.floor(vim.o.columns * 0.4))
  else
    -- Create a new vertical split on the right
    vim.cmd("botright vsplit")
    pi_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_width(pi_win, math.floor(vim.o.columns * 0.4))

    -- Create a terminal buffer running the specified command
    pi_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(pi_win, pi_buf)
    pi_chan = vim.fn.termopen(cmd, {
      on_exit = function()
        pi_buf = nil
        pi_win = nil
        pi_chan = nil
      end,
    })
  end

  -- Set buffer-local options for a clean look
  vim.wo[pi_win].number = false
  vim.wo[pi_win].relativenumber = false
  vim.wo[pi_win].signcolumn = "no"
  vim.wo[pi_win].winfixwidth = true

  -- Terminal-mode keymaps to navigate away from the pi panel
  local nav_maps = {
    ["<C-h>"] = "<C-\\><C-n><C-w>h",
    ["<C-j>"] = "<C-\\><C-n><C-w>j",
    ["<C-k>"] = "<C-\\><C-n><C-w>k",
    ["<C-l>"] = "<C-\\><C-n><C-w>l",
    ["<C-;>"] = "<C-\\><C-n><C-w>l",
  }
  for lhs, rhs in pairs(nav_maps) do
    vim.api.nvim_buf_set_keymap(pi_buf, "t", lhs, rhs, { noremap = true, silent = true })
  end

  -- Use line cursor in terminal mode for this buffer
  vim.api.nvim_create_autocmd("TermEnter", {
    buffer = pi_buf,
    callback = function()
      vim.opt.guicursor:append("t:ver25")
    end,
  })
  vim.api.nvim_create_autocmd("TermLeave", {
    buffer = pi_buf,
    callback = function()
      vim.opt.guicursor:remove("t:ver25")
    end,
  })

  -- Enter terminal (insert) mode so you can type immediately
  vim.cmd("startinsert")

  -- If we have a file reference, send it to the terminal input after a short delay
  if file_ref and pi_chan then
    vim.defer_fn(function()
      if pi_chan then
        vim.api.nvim_chan_send(pi_chan, file_ref)
        -- Send space after another delay to avoid triggering pi's autocomplete dropdown
        vim.defer_fn(function()
          if pi_chan then
            vim.api.nvim_chan_send(pi_chan, " ")
          end
        end, 100)
      end
    end, 200)
  end
end

--- Get the file reference string from visual selection: @filepath:startLine-endLine
local function get_visual_file_ref()
  -- Use "v" (visual start) and "." (cursor) to get the selection
  -- while still in visual mode. '</'> marks are only set after leaving
  -- visual mode, so they return 0 on first use.
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  local bufnr = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(bufnr)

  if filepath == "" then
    return nil
  end

  -- Make path relative to cwd if possible
  local cwd = vim.fn.getcwd()
  if filepath:sub(1, #cwd + 1) == cwd .. "/" then
    filepath = filepath:sub(#cwd + 2)
  end

  if start_line == end_line then
    return "@" .. filepath .. ":" .. start_line
  else
    return "@" .. filepath .. ":" .. start_line .. "-" .. end_line
  end
end

function M.toggle()
  if is_valid() then
    close()
  else
    open()
  end
end

function M.new_session()
  close()
  kill_terminal()
  open(nil, "pi")
end

function M.resume_session()
  close()
  kill_terminal()
  open(nil, "pi --resume")
end

function M.open_with_selection()
  local file_ref = get_visual_file_ref()
  -- Exit visual mode
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  if is_valid() then
    -- Panel already open, just send the reference
    vim.api.nvim_set_current_win(pi_win)
    vim.cmd("startinsert")
    if file_ref and pi_chan then
      vim.api.nvim_chan_send(pi_chan, file_ref)
      -- Send space after a delay to avoid triggering pi's autocomplete dropdown
      vim.defer_fn(function()
        if pi_chan then
          vim.api.nvim_chan_send(pi_chan, " ")
        end
      end, 100)
    end
  else
    open(file_ref)
  end
end

return {
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>a", group = "ai", icon = "🤖" },
      },
    },
  },
  {
    dir = vim.fn.stdpath("config"),
    name = "pi-panel",
    keys = {
      {
        "<leader>aa",
        function()
          M.toggle()
        end,
        desc = "Toggle Pi AI panel",
      },
      {
        "<leader>aa",
        function()
          M.open_with_selection()
        end,
        mode = "v",
        desc = "Open Pi AI panel with selection",
      },
      {
        "<leader>an",
        function()
          M.new_session()
        end,
        desc = "Pi: New session",
      },
      {
        "<leader>at",
        function()
          M.resume_session()
        end,
        desc = "Pi: Session tree (resume)",
      },
    },
  },
}
