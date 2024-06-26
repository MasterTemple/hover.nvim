local util = require('hover.util')
-- Simple
require("hover").register({
	name = "Bible",
  priority = 110,
	--- @param bufnr integer
	enabled = function(bufnr)
		-- return true
		local current_line = vim.api.nvim_get_current_line()
		local pattern = "(%d? ?%w+ [:;, %d%-]+%d+)"
		return string.match(current_line, pattern)
	end,
	--- @param opts Hover.Options
	--- @param done fun(result: any)
	execute = function(opts, done)
		local current_line = vim.api.nvim_get_current_line()
		current_line = string.gsub(current_line, "^%s*(.-)%s*$", "%1")
		-- put in bars so that 1 John 1:1, 1 Peter 1:1 can work (because the 1 in 1 Peter would be taken)
		-- '1 John 1:1, 1 Peter 1:1' -> '1 John 1:1, |1 Peter 1:1'
		current_line = string.gsub(current_line, "%d %a", "|%0")
		-- match reference
		-- local pattern = "(%d? ?%w+ [:;, %d%-]+%d+)"
		local pattern = "(%d? ?%w+ [:;, %d%-]+%d+)"
		-- local pattern = "(((Song of|1|2) )?%w+ [:;, %d%-]+%d+)"
		local references = {}
		for ref in string.gmatch(current_line, pattern) do
			ref = string.gsub(ref, "^%s+", "")
			table.insert(references, ref)
		end
		-- no references, try other hover
		if #references == 0 then
			done()
			return
		end

		local lines = {}
		local logs = {}
		for _, reference in ipairs(references) do
			-- run local script
			local handle = io.popen("/home/dgmastertemple/bible.sh " .. vim.fn.shellescape(reference))
			local result = handle:read("*a")
			handle:close()

			result = vim.split(result, "\n")
			-- replace abbreviation with full book name
			local full_reference = string.gsub(result[1], "%[(%d?[^%d]+).*", "%1") .. string.match(reference, "%d+:.*")
			table.insert(lines, "# " .. full_reference)
			table.insert(lines, "")
			-- vim.api.nvim_echo({results}, false, {})
			table.insert(logs, reference)
			-- apply formatting
			for _, line in ipairs(result) do
				line = string.gsub(line, "%[[^:]+:", "`[")
				line = string.gsub(line, "%]", "]`")
				table.insert(lines, line)
			end
		end

		done({ lines = lines, filetype = "markdown"})
		util.switch_to_preview()
		-- print(res)
		-- if res ~= {} and res ~= nil then
		-- end
		-- done({ lines = logs, filetype = "markdown"})
	end,
})
