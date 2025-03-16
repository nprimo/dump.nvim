local M = {}

local memory_path = "~/dump/"

M.new = function()
	local fname = vim.fn.localtime() .. ".md"
	local ok, err = vim.uv.fs_mkdir(vim.fn.expand(memory_path), 0755)
	if not ok then
		---@diagnostic disable-next-line: param-type-mismatch
		if not string.find(err, "EEXIST") then
			vim.notify("error creating file: " .. err, vim.log.levels.ERROR)
			return
		end
	end

	local fpath = memory_path .. fname
	vim.cmd.e(fpath)
end

M.list = function()
	require("telescope.builtin").find_files({
		cwd = vim.fn.expand(memory_path),
	})
end

M.setup = function(opts)
	opts = opts or {}

	vim.api.nvim_create_user_command("Dump", M.new, {})
	vim.api.nvim_create_user_command("DumpList", M.list, {})
end

return M
