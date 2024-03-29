-- Simple
require("hover").register({
	name = "Bible",
  priority = 110,
	--- @param bufnr integer
	enabled = function(bufnr)
		return true
	end,
	--- @param opts Hover.Options
	--- @param done fun(result: any)
	execute = function(opts, done)
		local current_line = vim.api.nvim_get_current_line()

		current_line = string.gsub(current_line, "^%s*(.-)%s*$", "%1")
		-- match reference
		local pattern = "(%d? ?%w+ [:;, %d%-]+%d+)"
		local reference = string.match(current_line, pattern)
		-- no reference, try other hover
		if reference == nil then
			done()
			return
		end
		-- run local script
		local handle = io.popen("/home/dgmastertemple/bible.sh " .. vim.fn.shellescape(reference))
		local result = handle:read("*a")
		handle:close()
		
		result = vim.split(result, "\n")
		local lines = { "# " .. reference, "" }
		for _, line in ipairs(result) do
			line = string.gsub(line, "%[[^:]+:", "`[")
			line = string.gsub(line, "%]", "]`")
			table.insert(lines, line)
		end
		
		done({ lines = lines, filetype = "markdown", })
	end,
})
