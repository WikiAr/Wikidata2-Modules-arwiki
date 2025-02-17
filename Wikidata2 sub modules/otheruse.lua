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
			local va = formatOneStatement(statement, nil, options)
			if va.v then
				table.insert(formattedStatements, va.v)
			end
			table.insert(statementsraw, va.raw)
		end
	end
	local tot = mw.text.listToText(formattedStatements, options.separator, options.conjunction)
	if tot == '' then tot = nil end
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
		separator = '',
		conjunction = '',
		formatting = 'raw'
	})
	local categoryid2 = formatStatements({
		property = 'P910',
		qid = value.id,
		noref = 'true',
		firstvalue = 'true',
		separator = '',
		conjunction = '',
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

--[[
	this is like p.formatPlaceWithQualifiers in ru:Модуль:Wikidata/Places
]]

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

local function concatenateStrings(s1, s2, s3)
	if isvalid(s1) then
		if isvalid(s2) then
			return s1 .. '، ' .. s2
		elseif s1 ~= s3 then
			return s1 .. '، ' .. s3
		else
			return s1
		end
	end
end

function p.PlacesWithLocatedIn(datavalue, datatype, options)
	if datatype ~= 'wikibase-item' then
		return "datatype isn't wikibase-item"
	end

	local value = datavalue.value
	local formattedValue = formatEntityId(value.id, options).value

	local pid_to_search = isvalid(options.pid_to_search) or 'P131'

	local P1 = Statements({ qid = value.id, formatting = '', property = pid_to_search }, options)
	local P2 = Statements({ qid = P1.item, formatting = '', property = pid_to_search }, options)
	local P3 = Statements({ qid = P2.item, formatting = '', property = pid_to_search }, options)
	local P4 = Statements({ qid = P3.item, formatting = '', property = pid_to_search }, options)

	local country1 = Statements({ qid = P3.item, formatting = '', property = 'P17' }, options)
	local country2 = Statements({ qid = P2.item, formatting = '', property = 'P17' }, options)
	local country3 = Statements({ qid = P1.item, formatting = '', property = 'P17' }, options)
	local country4 = Statements({ qid = value.id, formatting = '', property = 'P17' }, options)

	local result = formattedValue
	local tab = {}
	table.insert(tab, formattedValue)

	if isvalid(formattedValue) then
		local first_value = concatenateStrings(P3.value, P4.value, country1)
		local second_value = concatenateStrings(P2.value, first_value, country2)
		local third_value = concatenateStrings(P1.value, second_value, country3)
		result = concatenateStrings(formattedValue, third_value, country4)
	end

	return result
end

return p
