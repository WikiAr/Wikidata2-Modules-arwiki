local p = {}
local track = require("وحدة:Wikidata/تتبع").makecategory1

local function isvalid(x)
	if x and x ~= nil and x ~= "" then return x end
	return nil
end

local function comparedates2(a, b)
	if a.year and b.year then
		return a.year > b.year
	elseif a.year then
		return true
	end
end

local function normalizeDate(date)
	date = mw.text.trim(date, "+")
	local yearstr = mw.ustring.match(date, "^-?%d+")
	local year = yearstr
	return year
end

local function sp(p, y)
	local p = tonumber(mw.text.trim(p))
	if isvalid(p) then
		local pup = mw.getContentLanguage():formatNum(p)
		return y and y ~= "" and (pup .. " <small>(إحصاء " .. y .. ")</small>") or pup
	else
		return ""
	end
end

function p.P1082(claims, options)
	local icon = track({ property = "P1082", id = options.entityId or "" })
	local Teams = {}
	options.reff = ""
	options.noref = "r"

	if isvalid(options.pup) then
		table.insert(Teams, { value = options.pup, year = options.year })
	end

	for _, statement in pairs(claims) do
		local tab = { ref = "", year = "", value = "" }
		local va = formatOneStatement(statement, "", options)

		if statement and statement.qualifiers and statement.qualifiers.P585 then
			if statement.qualifiers.P585[1].snaktype == "value" then
				tab.year = normalizeDate(statement.qualifiers.P585[1].datavalue.value.time)
			end
		end

		if statement.references then
			tab.references = statement.references
		end

		if va and va.v and va.v ~= "" then
			tab.value = va.v
			table.insert(Teams, tab)
		end
	end

	table.sort(
		Teams,
		function(a, b)
			return comparedates2(a, b)
		end
	)

	if #Teams == 0 then
		return ""
	end

	local tables = { Teams[1] }

	local tables2 = {}
	for _, ss in pairs(tables) do
		local ba = ss.value
		local ref = ""

		if ss.references then
			ref = formatReferences(ss, options)
		end

		if isvalid(ss.year) then
			ba = sp(ss.value, ss.year) .. ref
			if ss.value ~= options.pup then
				ba = ba .. icon
			end
		end

		table.insert(tables2, ba)
	end

	return mw.text.listToText(tables2, options.separator, options.conjunction)
end

return p
