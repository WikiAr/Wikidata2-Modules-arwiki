local p = {}

local sandbox = "ملعب"
local sandbox_added = ""
if nil ~= string.find(mw.getCurrentFrame():getTitle(), sandbox, 1, true) then
	sandbox_added = "/" .. sandbox
end
local config = mw.loadData('Module:Wikidata2/config' .. sandbox_added)

local function isvalid(x)
	if x and x ~= nil and x ~= "" then return x end
	return nil
end

local function getEntityFromId(id)
	return isvalid(id) and mw.wikibase.getEntityObject(id) or mw.wikibase.getEntityObject()
end

function p.get_snak_id(snak)
	if snak and snak.type and
		snak.type == "statement" and snak.mainsnak and snak.mainsnak.snaktype and
		snak.mainsnak.snaktype == "value" and
		snak.mainsnak.datavalue and
		snak.mainsnak.datavalue.type and
		snak.mainsnak.datavalue.type == "wikibase-entityid" and
		snak.mainsnak.datavalue.value and
		snak.mainsnak.datavalue.value.id
	then
		--ID = 'Q' .. snak.datavalue.value['numeric-id']
		return snak.mainsnak.datavalue.value.id
	end
end

local function table_contains(table, element)
	for _, value in pairs(table) do
		if value == element then
			return true
		end
	end
	return false
end

local function filter_by_value(claims, option, mode)
	if type(option) == "string" then
		option = mw.text.split(option, ",")
	elseif type(option) ~= "table" then
		return claims
	end

	local filterd_claims = {}
	for _, claim in pairs(claims) do
		local ID = p.get_snak_id(claim)
		local id_in = table_contains(option, ID)
		if ID then
			if (not id_in and mode == "avoid") or (id_in and mode == "prefer") then
				table.insert(filterd_claims, claim)
			end
		end
	end
	return filterd_claims
end

local function filter_by_qualifier(claims, option, values, mode)
	if not isvalid(option) then
		return claims
	end

	local av = option:upper()
	values = type(values) == "string" and mw.text.split(values, ",") or values
	local claims2 = {}

	for _, statement in pairs(claims) do
		if mode == "prefer" then
			if statement.qualifiers and statement.qualifiers[av] then
				if isvalid(values) then
					for _, quall in pairs(statement.qualifiers[av]) do
						if quall.snaktype == "value" and table_contains(values, quall.datavalue.value["id"]) then
							table.insert(claims2, statement)
							break
						end
					end
				else
					table.insert(claims2, statement)
				end
			end
		elseif mode == "avoid" then
			if not statement.qualifiers or not statement.qualifiers[av] then
				table.insert(claims2, statement)
			elseif isvalid(values) then
				local active = true
				for _, quall in pairs(statement.qualifiers[av]) do
					if
						quall.snaktype == "value" and quall.datavalue and quall.datavalue.value and
						quall.datavalue.value["id"] and
						table_contains(values, quall.datavalue.value["id"])
					then
						active = false
						break
					end
				end
				if active then
					table.insert(claims2, statement)
				end
			end
		end
	end

	return claims2
end
local function parse_number(value)
	return (type(value) == "number") and value or tonumber(value)
end

local function claims_limit(claims, maxCount)
	if #claims <= maxCount then return claims end
	return { unpack(claims, 1, maxCount) }
end

local function claims_offset(claims, startOffset)
	if #claims <= startOffset then return claims end
	return { unpack(claims, startOffset + 1, #claims) }
end

local function filter_langs(claims)
	local claims7 = {}
	local arabic_id = config.i18n.local_lang_qids

	for _, statement in pairs(claims) do
		for prop, id in pairs(arabic_id) do
			if statement.qualifiers and statement.qualifiers[prop] then
				for _, v in pairs(statement.qualifiers[prop]) do
					if v.snaktype == "value" and v.datavalue.value["numeric-id"] == id then
						table.insert(claims7, statement)
						break
					end
				end
			end
		end
	end

	if #claims7 > 0 then
		claims = claims7
	end

	return claims
end

local function filter_get_only_or_dont(claims, option, f_property, mode)
	f_property = f_property or "P31"
	local claims2 = {}
	local values = mw.text.split(option, ",")

	for _, claim in pairs(claims) do
		local id = p.get_snak_id(claim)
		if id then
			local valid = false
			if mode == "dont" then
				valid = true
			end
			local entity = getEntityFromId(id)
			local t2 = entity:getBestStatements(f_property)
			if t2 and #t2 > 0 then
				for _, claim2 in pairs(t2) do
					local snak2 = p.get_snak_id(claim2)
					-- if table_contains(values, state.item) then
					if snak2 and table_contains(values, snak2) then
						if mode == "dont" then
							valid = false
						else
							valid = true
						end
						break
					end
				end
			end

			if valid then
				table.insert(claims2, claim)
			end
		end
	end

	return claims2
end

function p.filter_claims(claims, options)
	local claims = claims

	-- options.getonly
	if isvalid(options.getonly) then
		claims = filter_get_only_or_dont(claims, options.getonly, options.getonlyproperty, "get")
	end

	-- options.dontget
	if isvalid(options.dontget) then
		claims = filter_get_only_or_dont(claims, options.dontget, options.dontgetproperty, "dont")
	end

	local offset = isvalid(parse_number(options.offset))
	if offset then
		claims = claims_offset(claims, offset)
	end

	local limit = isvalid(parse_number(options.limit))
	if limit then
		claims = claims_limit(claims, limit)
	end

	if isvalid(options.avoidqualifier) then -- to avoid value with a given qualifier
		claims = filter_by_qualifier(claims, options.avoidqualifier, options.avoidqualifiervalue, "avoid")
	end

	if isvalid(options.preferqualifier) then
		claims = filter_by_qualifier(claims, options.preferqualifier, options.preferqualifiervalue, "prefer")
	end

	-- options.avoidvalue
	if isvalid(options.avoidvalue) then
		claims = filter_by_value(claims, options.avoidvalue, "avoid")
	end

	-- options.prefervalue
	if isvalid(options.prefervalue) then
		claims = filter_by_value(claims, options.prefervalue, "prefer")
	end

	if not isvalid(options.langpref) then
		claims = filter_langs(claims)
	end

	local firstvalue = options.enbarten or options.firstvalue
	local first = isvalid(tonumber(firstvalue))
	if isvalid(first) and #claims > 1 then
		if #claims > 0 then
			first = tonumber(first) or 1
			if first > 0 and first <= #claims then
				claims = { claims[first] }
			else
				claims = { claims[1] }
			end
		end
	elseif isvalid(firstvalue) and #claims > 0 then
		claims = { claims[1] }
	end

	local numval = options.numval
	if numval and type(numval) ~= "number" then
		numval = tonumber(numval)
	end
	if numval and type(numval) == "number" and #claims > 1 and #claims > numval then
		local claimsnumval = {}
		local ic = 1

		while (numval >= ic) and (#claims >= ic) do
			table.insert(claimsnumval, claims[ic])
			ic = ic + 1
		end
		claims = claimsnumval
	end

	return claims
end

return p
