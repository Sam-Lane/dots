-- Silence bare leader
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Yank to end of line
vim.keymap.set("n", "Y", "y$")

-- Buffer swap
vim.keymap.set("n", "<C-s>", "<C-^>")

-- Terminal escape
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")

-- Disable arrow keys (break bad habits)
local directions = { "<Left>", "<Right>", "<Up>", "<Down>" }
for _, dir in ipairs(directions) do
  vim.keymap.set({ "n", "v", "i" }, dir, "<Nop>")
end

-- Base64 encode/decode (visual mode)
vim.keymap.set("v", "<leader>64", function()
  -- yank selection into unnamed register, then replace with encoded result
  vim.cmd('normal! "zy')
  local text = vim.fn.getreg("z")
  local encoded = vim.fn.system("base64", text):gsub("\n", "")
  vim.fn.setreg("z", encoded)
  vim.cmd('normal! gv"zp')
end, { desc = "Base64 encode selection" })

vim.keymap.set("v", "<leader>d64", function()
  vim.cmd('normal! "zy')
  local text = vim.fn.getreg("z")
  local decoded = vim.fn.system("base64 --decode", text):gsub("\n", "")
  vim.fn.setreg("z", decoded)
  vim.cmd('normal! gv"zp')
end, { desc = "Base64 decode selection" })
