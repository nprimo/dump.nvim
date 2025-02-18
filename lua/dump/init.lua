local M = {}

-- TODO: make it come from config?
local memory_path = "~/dump/"

local function dump(topic)
	local fname = vim.fn.localtime() .. ".md"
	-- Is there a better way to create new file?
	vim.cmd("! mkdir -p " .. memory_path .. topic.args)
	local cmd = "e " .. memory_path .. topic.args .. fname
	vim.cmd(cmd)
end

local function dump_clean()
	local nvim_dump_buffs = vim.api.nvim_list_bufs()
	for _, v in ipairs(nvim_dump_buffs) do
		local buf_name = vim.api.nvim_buf_get_name(v)
		if string.find(buf_name, "/dump/", 1, true) then
			print("removing " .. buf_name)
			vim.api.nvim_buf_delete(v, {})
		end
	end
end

-- TODO: find a better way to open the dump directory
local function dump_list()
	local cmd = "e " .. memory_path
	vim.cmd(cmd)
end

function M.setup(opts)
	opts = opts or {}

	vim.api.nvim_create_user_command("Dump", dump, { nargs = "?" })
	vim.api.nvim_create_user_command("DumpList", dump_list, {})
	vim.api.nvim_create_user_command("DumpClean", dump_clean, {})
end

return M
