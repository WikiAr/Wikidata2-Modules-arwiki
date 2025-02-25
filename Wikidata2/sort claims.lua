local p = {}

local i18n = {
	chronological = "تصاعدي",
	ascending = "تصاعدي",
	inverted = "تنازلي",
	descending = "تنازلي",
	no = "لا"
}

p.sortingproperties = { "P585", "P571", "P580", "P569", "P582", "P570" }
p.sorting_methods = {
	["chronological"] = "chronological",
	[i18n.chronological] = "chronological",
	["asc"] = "chronological",
	["inverted"] = "inverted",
	[i18n.inverted] = "inverted",
	["desc"] = "inverted"
}

local function isvalid(x)
	if x and x ~= nil and x ~= "" and x ~= i18n.no then return x end
	return nil
end

local function comparedates(a, b) -- returns true if a is earlier than b or if a but not b
	if a and b then
		return a > b
	elseif a then
		return true
	end
end

local function getqualifierbysortingproperty(claim, sortingproperty)
	for k, v in pairs(sortingproperty) do
		if claim and claim.qualifiers and claim.qualifiers[v] and claim.qualifiers[v][1].snaktype == "value" then
			local vali = claim.qualifiers[v][1].datavalue.value.time or claim.qualifiers[v][1].datavalue.value.amount
			if vali:sub(1, 1) == "+" then
				vali = vali:sub(2)
			end
			--mw.log(vali)
			return vali
		end
	end
	return nil
end

local function get_sorting_properties(sorting_properties_option)
	if type(sorting_properties_option) == "table" then
		return sorting_properties_option
	elseif type(sorting_properties_option) == "string" and sorting_properties_option ~= "" then
		return mw.text.split(sorting_properties_option, ",")
	else
		return p.sortingproperties
	end
end

function p.sortbyqualifiernumber(claims, sorting_properties, sortingproperty_option, sort_by)
	if not sorting_properties or #sorting_properties == 0 then
		sorting_properties = get_sorting_properties(sortingproperty_option)
	end

	local sort_by = p.sorting_methods[sort_by] or sort_by

	table.sort(
		claims,
		function(a, b)
			local timeA = getqualifierbysortingproperty(a, sorting_properties)
			local timeB = getqualifierbysortingproperty(b, sorting_properties)
			if sort_by == "inverted" then
				return comparedates(timeB, timeA)
			else
				return comparedates(timeA, timeB)
			end
		end
	)
	return claims
end

local function getDateArb(claim, sorting_properties)
	local sortingproperty = sorting_properties
	if claim.mainsnak.snaktype == "value" then
		local item = claim.mainsnak.datavalue.value["numeric-id"]
		if claim.mainsnak.datavalue.value["entity-type"] == "item" then
			item = "Q" .. item
		elseif claim.mainsnak.datavalue.value["entity-type"] == "property" then
			item = "P" .. item
		end
		for k, prop in pairs(sortingproperty) do
			local date =
				formatStatements({ property = prop, entityId = item, firstvalue = "t", noref = "t", modifytime = "q" })
			if isvalid(date) then
				--mw.log("item:".. item .. ", prop:".. prop .. ", date:".. date)
				return date
			end
		end
	end
end

local function sortbyarb(claims, sorting_properties, sortingproperty_option, sortingmethod)
	if not sorting_properties or #sorting_properties == 0 then
		sorting_properties = get_sorting_properties(sortingproperty_option)
	end
	table.sort(
		claims,
		function(a, b)
			local timeA = getDateArb(a, sorting_properties)
			local timeB = getDateArb(b, sorting_properties)
			if sortingmethod == "inverted" or p.sorting_methods[sortingmethod] == "inverted" then
				return comparedates(timeB, timeA)
			else
				return comparedates(timeA, timeB)
			end
		end
	)
	return claims
end

function p.sort_claims(claims, options)
	local sortingmethod = options.sortbyarbitrary or options.sortingmethod
	local sorting_properties = get_sorting_properties(options.sortingproperty)

	if not sorting_properties or #sorting_properties == 0 then
		sorting_properties = p.sortingproperties
	end

	if isvalid(options.sortbytime) and p.sorting_methods[options.sortbytime] then
		claims = p.sortbyqualifiernumber(claims, sorting_properties, options.sortingproperty, options.sortbytime)
		--
	elseif isvalid(options.sortbynumber) and p.sorting_methods[options.sortbynumber] then
		claims = p.sortbyqualifiernumber(claims, sorting_properties, options.sortingproperty, options.sortbynumber)
		--
	elseif isvalid(sortingmethod) and p.sorting_methods[sortingmethod] then
		claims = sortbyarb(claims, sorting_properties, options.sortingproperty, sortingmethod)
	end
	return claims
end

return p
