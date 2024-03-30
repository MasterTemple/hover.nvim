local util = require('hover.util')
-- Simple
require("hover").register({
	name = "Cross References",
  priority = 109,
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
			table.insert(lines, "**" .. reference .. "** - Cross References")
			table.insert(lines, "")
			-- run local script
			local file = io.open("/home/dgmastertemple/crs.txt", "r")
			if file == nil then
				print("you lack the file :(")
				done()
			end

			local cross_refs = {}
			for line in file:lines() do
				if string.match(line, reference .. "#") then
					local cross_refs_str = string.gsub(line, ".*#", "")
					cross_refs = vim.split(cross_refs_str, "&")
					break
				end
			end

			for _, cr in ipairs(cross_refs) do
				local handle = io.popen("/home/dgmastertemple/bible.sh " .. vim.fn.shellescape(cr))
				local result = handle:read("*a")
				handle:close()
				result = vim.split(result, "\n")
				table.insert(lines, "# " .. cr)
				table.insert(lines, "")
				for _, res in ipairs(result) do
					res = string.gsub(res, "%[[^:]+:", "`[")
					res = string.gsub(res, "%]", "]`")
					table.insert(lines, res)
				end
			end

			-- local result = vim.split(, "\n")
		-- 	table.insert(lines, "# " .. full_reference)
		-- 	table.insert(lines, "")
		-- 	-- vim.api.nvim_echo({results}, false, {})
		-- 	table.insert(logs, reference)
		-- 	-- apply formatting
		-- 	for _, line in ipairs(result) do
		-- 		line = string.gsub(line, "%[[^:]+:", "`[")
		-- 		line = string.gsub(line, "%]", "]`")
		-- 		table.insert(lines, line)
		-- 	end
		end

		done({ lines = lines, filetype = "markdown"})
		util.switch_to_preview()
		-- print(res)
		-- if res ~= {} and res ~= nil then
		-- end
		-- done({ lines = logs, filetype = "markdown"})
	end,
})
