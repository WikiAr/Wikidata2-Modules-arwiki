--[[

This module provides a number of basic mathematical operations.

]]

local yesno, getArgs -- lazily initialized

local p = {}         -- Holds functions to be returned from #invoke, and functions to make available to other Lua modules.
local wrap = {}      -- Holds wrapper functions that process arguments from #invoke. These act as intemediary between functions meant for #invoke and functions meant for Lua.

function p._round(value, precision)
	local rescale = math.pow(10, precision or 0);
	return math.floor(value * rescale + 0.5) / rescale;
end

function p.newFromWikidataValue(frame)
	if not tonumber(frame.amount) then
		return "" -- Error: Non-numeric amount.
	end
	local upperBound = frame.upperBound or frame.amount
	local lowerBound = frame.lowerBound or frame.amount
	local diff = math.abs(tonumber(upperBound) - tonumber(frame.amount))
	local diff2 = math.abs(tonumber(lowerBound) - tonumber(frame.amount))
	if diff2 > diff then
		diff = diff2
	end

	local lang = mw.language.new(mw.getContentLanguage():getCode())
	if diff == 0 then
		return lang:formatNum(tonumber(frame.amount))
	else
		local log = -math.log10(diff)
		return lang:formatNum(p._round(frame.amount, math.ceil(log)))
	end
end

local mt = {
	__index = function(t, k)
		return function(frame)
			if not getArgs then
				getArgs = require('Module:Arguments').getArgs
			end
			return wrap[k](getArgs(frame)) -- Argument processing is left to Module:Arguments. Whitespace is trimmed and blank arguments are removed.
		end
	end
}

return setmetatable(p, mt)
