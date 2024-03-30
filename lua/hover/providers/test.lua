local util = require('hover.util')
-- Simple
require("hover").register({
	name = "Test",
  priority = 105,
	--- @param bufnr integer
	enabled = function(bufnr)
		return true
	end,
	--- @param opts Hover.Options
	--- @param done fun(result: any)
	execute = function(opts, done)
		local current_line = vim.api.nvim_get_current_line()
		local word = vim.fn.expand('<cword>')
		local current_buf = vim.api.nvim_get_current_buf()
		local lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)

		local output = {""}
		local results = 0

		for _, line in ipairs(lines) do
			if string.match(line, word) then
				line = string.gsub(line, word, "`" .. word .. "`")
				table.insert(output, line)
				results = results + 1
			end
		end

		table.insert(output, 1, "# Results: " .. results)

		done({ lines = output, filetype = "markdown"})
		util.switch_to_preview()
		-- done({ lines = logs, filetype = "markdown"})
	end,
})
