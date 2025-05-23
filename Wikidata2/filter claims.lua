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

local function table_or_nil(values)
	local q_values = {}
	if not isvalid(values) then return nil end
	if type(values) == "string" then
		q_values = mw.text.split(values, ",")
	elseif type(values) == "table" then
		q_values = values
	end

	if #q_values == 0 then q_values = nil end
	return q_values
end

local function parse_number(value)
	return (type(value) == "number") and value or tonumber(value)
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
	option = table_or_nil(option)
	if not isvalid(option) then
		return claims
	end

	local filtered_claims = {}

	for _, claim in pairs(claims) do
		local snak_id = p.get_snak_id(claim)
		local is_included = table_contains(option, snak_id)

		if snak_id and ((mode == "avoid" and not is_included) or (mode == "prefer" and is_included)) then
			table.insert(filtered_claims, claim)
		end
	end

	return filtered_claims
end

local function any_qualifier_matches(qualifiers, values)
	if not qualifiers then return false end

	for _, qual in pairs(qualifiers) do
		if qual.snaktype == "value"
			and qual.datavalue
			and qual.datavalue.value
			and qual.datavalue.value.id
			and table_contains(values, qual.datavalue.value.id) then
			return true
		end
	end
	return false
end

local function filter_by_qualifier(claims, option, values, mode)
	if not isvalid(option) then return claims end

	local qualifier_id = option:upper()
	local q_values = table_or_nil(values)

	local filtered_claims = {}

	for _, statement in pairs(claims) do
		local qualifiers = statement.qualifiers and statement.qualifiers[qualifier_id]

		if mode == "prefer" then
			if qualifiers then
				if isvalid(q_values) then
					if any_qualifier_matches(qualifiers, q_values) then
						table.insert(filtered_claims, statement)
					end
				else
					table.insert(filtered_claims, statement)
				end
			end
		elseif mode == "avoid" then
			if not qualifiers then
				table.insert(filtered_claims, statement)
			elseif isvalid(q_values) then
				if not any_qualifier_matches(qualifiers, q_values) then
					table.insert(filtered_claims, statement)
				end
			end
		end
	end

	return filtered_claims
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
	local filtered_claims = {}
	local arabic_ids = config.i18n.local_lang_qids

	for _, statement in pairs(claims) do
		if statement.qualifiers then
			for prop, id in pairs(arabic_ids) do
				local qualifier_values = statement.qualifiers[prop]
				if qualifier_values then
					for _, v in pairs(qualifier_values) do
						if v.snaktype == "value" and v.datavalue.value["numeric-id"] == id then
							table.insert(filtered_claims, statement)
							break
						end
					end
				end
			end
		end
	end

	if #filtered_claims > 0 then
		claims = filtered_claims
	end

	return claims
end

local function filter_get_only_or_dont(claims, option, f_property, mode)
	f_property = f_property or "P31"
	local claims2 = {}
	local values = table_or_nil(option) or {}
	local is_dont_mode = (mode == "dont")

	for _, claim in pairs(claims) do
		local id = p.get_snak_id(claim)
		if id then
			local valid = is_dont_mode
			local t2 = mw.wikibase.getBestStatements(id, f_property)

			if t2 and #t2 > 0 then
				for _, claim2 in pairs(t2) do
					local snak2 = p.get_snak_id(claim2)
					if snak2 and table_contains(values, snak2) then
						valid = not is_dont_mode
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

local function filter_numval(claims, numval)
	if #claims > 1 and #claims > numval then
		local claimsnumval = { unpack(claims, 1, numval) }
		return claimsnumval
	end
	return claims
end

local function filter_first(claims, firstvalue)
	local first = tonumber(firstvalue)
	if isvalid(first) and #claims > 1 then
		local va = math.max(1, math.min(first, #claims)) -- Ensure 'first' is within bounds
		return { claims[va] }
	elseif isvalid(firstvalue) and #claims > 0 then
		return { claims[1] }
	end
	return claims
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

	local offset = parse_number(options.offset)
	if isvalid(offset) then
		claims = claims_offset(claims, offset)
	end

	local limit = parse_number(options.limit)
	if isvalid(limit) then
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

	local firstvalue = isvalid(options.enbarten) or isvalid(options.firstvalue)
	if firstvalue then
		claims = filter_first(claims, firstvalue)
	end

	local numval = parse_number(options.numval)
	if isvalid(numval) then
		claims = filter_numval(claims, numval)
	end

	return claims
end

return p
