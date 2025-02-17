local p = {}
local Module_sortclaims

local sandbox = "ملعب"
local sandbox_added = ""
if nil ~= string.find(mw.getCurrentFrame():getTitle(), sandbox, 1, true) then
	sandbox_added = "/" .. sandbox
end

local function is_valid(x)
	if x and x ~= nil and x ~= "" then return x end
	return nil
end

local function qua(p, qualifiers)
	local vvv
	if is_valid(p) then
		vvv = formatStatements({
			property = p,
			enlabelcate = "t",
			modifytime = "longdate",
			noref = "t"
		}, qualifiers) or ""
		return vvv
	end
end

local function format_One_Statement(statement, options)
	if statement.type ~= "statement" then
		return ""
	end

	local stat = formatSnak(statement.mainsnak, options)

	if not is_valid(stat.value) then
		return ""
	end
	if is_valid(stat) then
		if statement.qualifiers then
			stat.ID = statement.mainsnak.datavalue.value.id
			for i = 1, 10 do
				stat["QQ" .. i] = qua(options["Q" .. i], statement.qualifiers)
			end
		end
	end

	return mw.getCurrentFrame():expandTemplate {
		title = options.template,
		args = {
			stat.QQ1, stat.value, stat.QQ2, stat.QQ3, stat.QQ4, stat.QQ5, stat.QQ6, stat.QQ7, stat.QQ8, stat.QQ9, stat.QQ10,
			entityId = options.entityId, v1 = options.v1, id = stat.ID
		}
	}
end

function p.foot(claims, options)
	local tab = {}
	if Module_sortclaims == nil then
		Module_sortclaims = require("Module:Wikidata2/sort_claims" .. sandbox_added)
	end
	if is_valid(options.sortingproperty) and Module_sortclaims.sorting_methods[options.sortbynumber] then
		claims = Module_sortclaims.sortbyqualifiernumber(claims, {}, options.sortingproperty, options.sortbynumber)
	end
	if claims then
		for i, statement in pairs(claims) do
			options.num = i
			local va = format_One_Statement(statement, options)
			if va then
				table.insert(tab, va)
			end
		end
	end
	local tot = mw.text.listToText(tab, options.separator, options.conjunction)
	return tot
end

return p
