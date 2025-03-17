local pickers = require("telescope.pickers")
local previewers = require("telescope.previewers")
local utils = require("telescope.previewers.utils")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}

-- TODO: make it come from config
local memory_path = "~/dump/"
local archive_path = memory_path .. ".archive/"

local function md(path)
	local ok, err = vim.uv.fs_mkdir(vim.fn.expand(path), 493) -- 0755 (octal notation)
	if not ok then
		---@diagnostic disable-next-line: param-type-mismatch
		if not string.find(err, "EEXIST") then
			vim.notify("error creating file: " .. err, vim.log.levels.ERROR)
			return
		end
	end
end

M.new = function()
	local curr_date = os.date("%Y%m%d")
	local fname = curr_date .. ".md"
	md(memory_path)

	local fpath = memory_path .. fname
	vim.cmd.e(fpath)
end

local previewer_opts = {
	title = "preview",
	define_preview = function(self, entry)
		local cmd = "cat " .. vim.fn.expand(memory_path) .. entry.value
		local handle = io.popen(cmd)
		if not handle then
			vim.notify("error executing cat: ", vim.log.levels.ERROR)
			return
		end
		local lines = {}
		for line in handle:lines() do
			table.insert(lines, line)
		end
		handle:close()

		vim.api.nvim_buf_set_lines(self.state.bufnr, 0, 0, true, lines)
		utils.highlighter(self.state.bufnr, "markdown")
	end,
}

M.list = function(opts)
	opts = opts or {}
	pickers
		.new(opts, {
			prompt_title = "Dump files",
			finder = finders.new_oneshot_job({ "ls", vim.fn.expand(memory_path) }, {
				make_entry = function(entry)
					return {
						value = entry,
					}
				end,
			}),

			sorter = conf.generic_sorter(opts),

			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					local og_fpath = vim.fn.expand(memory_path) .. selection[1]
					vim.cmd.e(og_fpath)
				end)
				return true
			end,

			previewer = previewers.new_buffer_previewer(previewer_opts),
		})
		:find()
end

M.archive = function(opts)
	opts = opts or {}
	pickers
		.new(opts, {
			prompt_title = "Dump files",
			finder = finders.new_oneshot_job({ "ls", vim.fn.expand(memory_path) }, {
				make_entry = function(entry)
					return {
						value = entry,
					}
				end,
			}),

			sorter = conf.generic_sorter(opts),

			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					local og_fpath = vim.fn.expand(memory_path) .. selection[1]
					md(archive_path)
					local ok, err = vim.uv.fs_rename(og_fpath, vim.fn.expand(archive_path) .. selection[1])
					if not ok then
						vim.notify("error renaming file: " .. err, vim.log.levels.ERROR)
						return false
					end
				end)
				return true
			end,

			previewer = previewers.new_buffer_previewer(previewer_opts),
		})
		:find()
end

M.setup = function(opts)
	opts = opts or {}

	vim.api.nvim_create_user_command("Dump", M.new, {})
	vim.api.nvim_create_user_command("DumpList", M.list, {})
	vim.api.nvim_create_user_command("DumpArchive", M.archive, {})
end

return M
