local p = {}

local function formatcharacters_(label, options)
	local formatc = options.formatcharacters

	if options.illwd2y and options.illwd2y ~= '' then
		return mw.ustring.match(label, "%d%d%d%d", 1) or label
	end
	if not formatc or formatc == '' then
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
	local ret = ""
	if datatype == 'wikibase-item' then
		local id = datavalue.value.id
		-- local value = formatEntityId(id, options).value
		local label = options.label or mw.wikibase.label(id)
		if label == '' then
			label = mw.wikibase.label(id) or nil
		end
		local link = mw.wikibase.sitelink(id)
		if link and (not options.nolink or options.nolink == '') then
			if label and label ~= '' then
				ret = '[[:' .. link .. '|' .. formatcharacters_(label, options) .. ']]' .. catewikidatainfo(options)
			else
				ret = '[[:' .. link .. '|' .. formatcharacters_(link, options) .. ']]' .. catewikidatainfo(options)
			end
		else
			if label and label ~= '' then
				ret = Labelfunction(id, label, options)
			end
		end
	end
	return ret
end

return p
