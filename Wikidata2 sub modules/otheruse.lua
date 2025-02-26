local p = {}
local sortclaims

local sandbox = "ملعب"
local sandbox_added = ""
if nil ~= string.find(mw.getCurrentFrame():getTitle(), sandbox, 1, true) then
	sandbox_added = "/" .. sandbox
end

local function isvalid(x)
	if x and x ~= nil and x ~= "" then return x end
	return nil
end

function p.foot(claims, options)
	local formattedStatements = {}
	local statementsraw = {}
	if sortclaims == nil then
		sortclaims = require("Module:Wikidata2/sort_claims" .. sandbox_added)
	end
	if isvalid(options.sortingproperty) and sortclaims.sorting_methods[options.sortbynumber] then
		claims = sortclaims.sortbyqualifiernumber(claims, {}, options.sortingproperty, options.sortbynumber)
	end
	if claims then
		for i, statement in pairs(claims) do
			options.num = i
			local va = formatOneStatement(statement, options)
			if va.v then
				table.insert(formattedStatements, va.v)
			end
			table.insert(statementsraw, va.raw)
		end
	end
	local tot = mw.text.listToText(formattedStatements, options.separator, options.conjunction)
	if tot == "" then tot = nil end
	if isvalid(options.raw) then
		return statementsraw
	end
	if isvalid(options.numberofclaims) then
		return #formattedStatements
	end
	return tot
end

function p.awards(datavalue, datatype, options) -- used by template:ص.م/سطر جوائز ويكي بيانات
	if datatype ~= 'wikibase-item' then
		return "datatype isn't wikibase-item"
	end

	local value = datavalue.value
	local image = formatStatements({
		property = 'P2425',
		qid = value.id,
		size = '30',
		image = 'yes',
		noref = 'true',
		firstvalue = 'true'
	})
	local image2 = formatStatements({
		property = 'P154',
		qid = value.id,
		size = '30',
		image = 'yes',
		noref = 'true',
		firstvalue = 'true'
	})
	local categoryid = formatStatements({
		property = 'P2517',
		qid = value.id,
		noref = 'true',
		firstvalue = 'true',
		separator = "",
		conjunction = "",
		formatting = 'raw'
	})
	local categoryid2 = formatStatements({
		property = 'P910',
		qid = value.id,
		noref = 'true',
		firstvalue = 'true',
		separator = "",
		conjunction = "",
		formatting = 'raw'
	})

	if not isvalid(image) then image = image2 end
	if not isvalid(categoryid) then categoryid = categoryid2 end

	local category = mw.wikibase.sitelink(categoryid)
	local s = formatEntityId(value.id, options).value
	if isvalid(s) then
		if isvalid(image) then
			s = image .. '&nbsp;' .. s
		end
		if isvalid(category)
		then
			return s .. '&nbsp;[[' .. category .. ']]'
		else
			return s
		end
	end
end

function p.getpropertyfromvalue(datavalue, datatype, options)
	if datatype ~= 'wikibase-item' then
		return "datatype isn't wikibase-item"
	end

	local value = datavalue.value
	local caca = formatStatements({
		property = options.prop2,
		qid = value.id,
		rank = options.rank,
		size = options.size,
		image = options.image,
		noref = 'true',
		firstvalue = 'true',
		propertyimage = options.prop3
	}
	)
	local asdf = formatEntityId(value.id, options).value
	if isvalid(asdf) then
		if isvalid(caca)
		then
			return caca .. ' ' .. asdf
		else
			return asdf
		end
	end
end

local function Statements(params, options)
	local result = formatStatements({
		property = params.property,
		qid = params.qid,
		noref = 't',
		firstvalue = 'true',
		illwd2noarlabel = options.illwd2noarlabel,
		illwd2 = options.illwd2,
		formatting = params.formatting,
		raw = true
	})
	if type(result) == "table" then
		-- mw.log(mw.dumpObject(result[1]))
		for k, v in pairs(result) do
			if isvalid(v.value) and isvalid(v.item) then
				return v
			end
		end
		-- return result[1]
	end

	return {}
end

function p.PlacesWithLocatedIn(datavalue, datatype, options)
	if datatype ~= 'wikibase-item' then
		return "datatype isn't wikibase-item"
	end

	local value = datavalue.value
	local formattedValue = formatEntityId(value.id, options).value
	local pid_to_search = isvalid(options.pid_to_search) or 'P131'

	local tab = {}
	--
	if isvalid(formattedValue) then
		table.insert(tab, formattedValue)
	end
	--
	local last_id = value.id
	--
	local i = 1
	--
	local max_items = isvalid(tonumber(options.max_items)) or 10
	--
	local no_limits = isvalid(options.no_limits)
	--
	while isvalid(last_id) do
		--
		if i >= max_items and not no_limits then
			break
		end
		--
		local value_x = Statements({ qid = last_id, formatting = "", property = pid_to_search }, options)
		if isvalid(value_x.value) then
			table.insert(tab, value_x.value)
		end
		last_id = value_x.item
		i = i + 1
	end
	--
	local country = Statements({ qid = last_id, formatting = "", property = 'P17' }, options)

	if isvalid(country) then
		table.insert(tab, country.value)
	end
	--
	local options2 = options
	options2.separator = isvalid(options2.separator) or '، '
	local result = value_table_to_text(options2, tab)
	--
	-- if #tab > 15 then result = add_box(result) end
	--
	return result
end

return p
