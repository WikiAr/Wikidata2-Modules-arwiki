local p = {}

local function isvalid(x)
	if x and x ~= nil and x ~= "" then return x end
	return nil
end

local function formatcharacters_(label, options)
	if not label then
		return ""
	end
	label = mw.text.trim(label)
	local formatc = options.formatcharacters

	if isvalid(options.illwd2y) then
		return mw.ustring.match(label, "%d%d%d%d", 1) or label
	end
	if not isvalid(formatc) then
		return label
	end

	local prepr = {
		["lcfirst"] = "{{lcfirst: " .. label .. " }}",
		["lc"] = "{{lc: " .. label .. " }}",
		["uc"] = "{{uc: " .. label .. " }}",
		["formatnum"] = "{{formatnum: " .. label .. " }}"
	}
	if prepr[formatc] then
		return mw.getCurrentFrame():preprocess(prepr[formatc])
	elseif formatc == 'ucfirst' then
		return mw.language.getContentLanguage():ucfirst(label)
	end
	return label
end

function p.year(datavalue, datatype, options)
	if datatype ~= 'wikibase-item' then
		return ""
	end
	local id = datavalue.value.id
	-- local value = formatEntityId(id, options).value
	local label = isvalid(options.label) or mw.wikibase.label(id) or nil
	local link = mw.wikibase.sitelink(id)

	local ret = ""
	if link and not isvalid(options.nolink) then
		local label_link = formatcharacters_(link, options)

		if isvalid(label) then
			label_link = formatcharacters_(label, options)
		end

		ret = '[[:' .. link .. '|' .. label_link .. ']]' .. catewikidatainfo(options)
	elseif isvalid(label) then
		ret = Labelfunction(id, label, options)
	end
	return ret
end

return p
