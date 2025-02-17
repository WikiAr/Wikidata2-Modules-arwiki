local p = {}
local config_title = 'Module:Wikidata2/config'
local sandbox = "ملعب"
if nil ~= string.find(mw.getCurrentFrame():getTitle(), sandbox, 1, true) then
	config_title = config_title .. "/" .. sandbox
end
local config = mw.loadData(config_title)

local function isvalid(x)
	if x and x ~= nil and x ~= "" then return x end
	return nil
end

local function isntvalid(x)
	if not x or x == nil or x == "" then return true end
	return false
end


local function getEntityFromId(id)
	return isvalid(id) and mw.wikibase.getEntityObject(id) or mw.wikibase.getEntityObject()
end

function p.get_snak_id(snak)
	if
		snak and snak.type and snak.type == "statement" and snak.mainsnak and snak.mainsnak.snaktype and
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

local function avoidvalue(claims, options)
	local avoidvalue = options.avoidvalue
	if type(avoidvalue) == "string" then
		avoidvalue = mw.text.split(avoidvalue, ",")
	elseif type(avoidvalue) ~= "table" then
		return claims
	end

	local claims4 = {}
	for i, j in pairs(claims) do
		local ID = p.get_snak_id(j)
		if ID and not table_contains(avoidvalue, ID) then
			table.insert(claims4, j)
		end
	end
	return claims4
end

local function prefervalue(claims, options)
	local prefervalue = options.prefervalue
	if type(prefervalue) == "string" then
		prefervalue = mw.text.split(prefervalue, ",")
	elseif type(prefervalue) ~= "table" then
		return claims
	end

	local claims3 = {}
	for _, claim in pairs(claims) do
		local ID = p.get_snak_id(claim)
		if ID and table_contains(prefervalue, ID) then
			table.insert(claims3, claim)
		end
	end

	return claims3
end

local function preferqualifier(claims, options)
	--[[
	-- options.preferqualifier
	-- options.preferqualifiervalue
	]]
	local preferqualifiers = options.preferqualifier:upper()

	local claims2 = {}
	local preferq_values = mw.text.split(options.preferqualifiervalue or "", ",")

	for _, statement in pairs(claims) do
		if statement.qualifiers and statement.qualifiers[preferqualifiers] then
			if isvalid(options.preferqualifiervalue) then
				for _, quall in pairs(statement.qualifiers[preferqualifiers]) do
					if quall.snaktype == "value" and table_contains(preferq_values, quall.datavalue.value["id"]) then
						table.insert(claims2, statement)
						break
					end
				end
			else
				table.insert(claims2, statement)
			end
		end
	end
	return claims2
end

local function avoidqualifier(claims, options)
	-- options.avoidqualifier
	-- options.avoidqualifiervalue
	if isntvalid(options.avoidqualifier) then
		return claims
	end

	local av = options.avoidqualifier:upper()
	local avoidqualifiervalue_values =
		type(options.avoidqualifiervalue) == "string" and mw.text.split(options.avoidqualifiervalue, ",") or
		options.avoidqualifiervalue
	local claims2 = {}

	for _, statement in pairs(claims) do
		if not statement.qualifiers or not statement.qualifiers[av] then
			table.insert(claims2, statement)
		elseif isvalid(options.avoidqualifiervalue) then
			local active = true
			for _, quall in pairs(statement.qualifiers[av]) do
				if
					quall.snaktype == "value" and quall.datavalue and quall.datavalue.value and
					quall.datavalue.value["id"] and
					table_contains(avoidqualifiervalue_values, quall.datavalue.value["id"])
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

	return claims2
end

local function claims_limit(claims, limit)
	local newclaims = {}
	if type(limit) ~= "number" then
		limit = tonumber(limit)
	end
	if #claims > limit then -- limit is not 0
		for i = 1, #claims do
			if i <= limit then
				newclaims[#newclaims + 1] = claims[i]
			end
		end
		return newclaims
	end
	return claims
end

local function claims_offset(claims, offset)
	local offsetclaims = {}
	if type(offset) ~= "number" then
		offset = tonumber(offset)
	end
	if #claims > offset then -- offset is not 0
		for i = offset + 1, #claims do
			offsetclaims[#offsetclaims + 1] = claims[i]
		end
		return offsetclaims
	end
	return claims
end

local function filter_langs(claims)
	local claims7 = {}
	local arabic_id = config.local_lang_qids

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

local function getonly(claims, options)
	--[[
	-- options.getonly
	-- options.getonlyproperty
	]]
	local claims2 = {}
	local getonly_values = mw.text.split(options.getonly, ",")

	for _, claim in pairs(claims) do
		local id = p.get_snak_id(claim)
		if id then
			-- local t2 = formatStatements({ property = (options.getonlyproperty or "P31"), entityId = id, noref = "t", raw = "t" })
			local entity = getEntityFromId(id)
			local t2 = entity:getBestStatements(options.getonlyproperty or "P31")
			if t2 and #t2 > 0 then
				for _, claim2 in pairs(t2) do
					local snak2 = p.get_snak_id(claim2)
					-- if table_contains(getonly_values, state.item) then
					if snak2 and table_contains(getonly_values, snak2) then
						table.insert(claims2, claim)
						break
					end
				end
			end
		end
	end

	return claims2
end

local function dontget(claims, options)
	--[[
	options.dontget
	options.dontgetproperty
	]]
	local claims2 = {}
	local dontget_values = mw.text.split(options.dontget, ",")

	for _, claim in pairs(claims) do
		local id = p.get_snak_id(claim)
		if id then
			local valid = true
			-- local t2 = formatStatements({ property = (options.dontgetproperty or "P31"), entityId = id, noref = "t", raw = "t" })
			local entity = getEntityFromId(id)
			local t2 = entity:getBestStatements(options.dontgetproperty or "P31")
			if t2 and #t2 > 0 then
				for _, claim2 in pairs(t2) do
					local snak2 = p.get_snak_id(claim2)
					-- if table_contains(dontget_values, state.item) then
					if snak2 and table_contains(dontget_values, snak2) then
						valid = false
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
		claims = getonly(claims, options)
	end

	-- options.dontget
	if isvalid(options.dontget) then
		claims = dontget(claims, options)
	end

	local offset = options.offset
	if isvalid(offset) then
		claims = claims_offset(claims, offset)
	end

	local limit = options.limit
	if isvalid(limit) then
		claims = claims_limit(claims, limit)
	end

	if isvalid(options.avoidqualifier) then -- to avoid value with a given qualifier
		claims = avoidqualifier(claims, options)
	end

	if isvalid(options.preferqualifier) then
		claims = preferqualifier(claims, options)
	end

	-- options.avoidvalue
	if isvalid(options.avoidvalue) then
		claims = avoidvalue(claims, options)
	end

	-- options.prefervalue
	if isvalid(options.prefervalue) then
		claims = prefervalue(claims, options)
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
