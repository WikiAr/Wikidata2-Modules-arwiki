local wd2 = {}
local Frame_args = {}
local Moduleill_wd2, Moduledump, ModuleTime, Moduletext, Modulecite, Moduleflags, ModuleGlobes, Moduletrack
-- local formatera

local sandbox = "ملعب"
local sandbox_added = ""

if nil ~= string.find(mw.getCurrentFrame():getTitle(), sandbox, 1, true) then
	sandbox_added = "/" .. sandbox
end

wd2.track_cat_done = false

local config = mw.loadData('Module:Wikidata2/config' .. sandbox_added)
local filterclaims = require("Module:Wikidata2/filter_claims" .. sandbox_added)
local sortclaims = require("Module:Wikidata2/sort_claims" .. sandbox_added)

local Modules = {
	CiteQ           = "Module:Cite Q" .. sandbox_added,
	WD2             = "Module:wikidata2/Ill-WD2" .. sandbox_added,
	monolingualtext = "Module:wikidata2/monolingualtext" .. sandbox_added,
	time            = "Module:wikidata2/time" .. sandbox_added,
	dump            = "Module:wikidata2/dump" .. sandbox_added,
	track           = "Module:wikidata2/تتبع" .. sandbox_added,
}

local i18n = config.i18n

local function anyvalid(x)
	if x and x ~= nil and x ~= "" then return x end
	return nil
end

local function isvalid(x)
	if x and x ~= nil and x ~= "" and x ~= i18n.no then return x end
	return nil
end

local function isvalids(xs)
	for _, x in pairs(xs) do
		if isvalid(x) then
			return x
		end
	end
	return nil
end

local function formatFromPattern(str, options)
	-- [[  function to replace $1 with string  ]]
	if isvalid(options.pattern) then
		str = string.gsub(str, "%%", "%%%%")
		str = mw.ustring.gsub(options.pattern, "$1", str)
	end
	return str
end

local function No_Tracking_cat(options)
	if isvalid(options.formatting) == "raw" or isvalid(options.formatting) == "sitelink" then
		return true
	end
	local notracking = isvalids({ options.nocate, options.notracking, Frame_args.notracking })
	local raw = isvalids({ options.raw, Frame_args.raw, options.raw2, Frame_args.raw2 })
	local nolink = isvalids({ options.nolink, Frame_args.nolink })

	if notracking or raw or nolink then
		return true
	end
	local pagetitle = mw.title.getCurrentTitle().text
	for _, title in pairs(config.falsetitles) do
		if string.find(pagetitle, title, 1, true) then
			--mw.log("notracking for title with: " .. title)
			return true
		end
	end
	return false
end

function addTrackingCategory(options)
	if No_Tracking_cat(options) then
		return ""
	end
	if Moduletrack == nil then
		Moduletrack = require(Modules.track)
	end
	local category = Moduletrack.makecategory1(options)
	local nbsp = "&nbsp;"
	if isvalid(options.nbsp) or isvalid(options.image) then
		nbsp = ""
	end
	if isvalid(category) then
		return nbsp .. category
	end
	return ""
end

function catewikidatainfo(options)
	--[[  function to add tracking category ]]
	if No_Tracking_cat(options) then
		return ""
	end
	local cat = ""
	local prop = options.property
	cat = cat .. " [[" .. i18n.categories.tracking_category .. "|" .. (prop or "wikidata") .. "]]"
	if not isvalid(options.nolink) then
		return cat
	else
		return ""
	end
end

function get_entityId(options)
	-- local id = isvalid(options.entityId) or isvalid(options.id) or isvalid(options.qid)
	local id = isvalids({ options.entityId, options.id, options.qid })
	if id then
		return id
	end
	if isvalid(options.page) then
		id = mw.wikibase.getEntityIdForTitle(options.page)
	else
		id = mw.wikibase.getEntityIdForCurrentPage()
	end
	return id or ""
end

function wd2.countSiteLinks(id)
	local numb = 0
	local entity = mw.wikibase.getEntity(id)
	if entity and entity.sitelinks then
		for i, v in pairs(entity.sitelinks) do
			numb = numb + 1
		end
	end
	return numb
end

function make_format_num(String)
	local line = String
	line = mw.getCurrentFrame():preprocess("{{ {{{|safesubst:}}}formatnum: " .. String .. " }}")
	line = mw.ustring.gsub(line, "٫", ".")
	line = mw.ustring.gsub(line, "٬", ",")
	return line
end

function formatcharacters(label, options)
	local formatch = options.formatcharacters
	--if options.FormatfirstCharacter and options.num == 1 then
	--formatch = options.FormatfirstCharacter
	--end

	local String2 = mw.ustring.gsub(label, "–", "-")
	local match_y =
		mw.ustring.match(String2, "%d%d%d%d%-%d%d%d%d", 1) or mw.ustring.match(String2, "%d%d%-%d%d%d%d", 1) or
		mw.ustring.match(String2, "%d%d%d%d", 1) or
		mw.ustring.match(String2, "%d%d%d%d%-%d%d", 1) or
		mw.ustring.match(String2, "%d%d%d%d", 1)

	if isvalid(options.illwd2y) then
		return match_y or label
	end
	if isvalid(options.illwd2noy) and match_y then
		label = mw.ustring.gsub(label, match_y, "")
		return label
	end

	if not isvalid(formatch) then
		return label
	end

	local prepr = {
		["lcfirst"] = "{{lcfirst: " .. label .. " }}",
		["lc"] = "{{lc: " .. label .. " }}",
		["uc"] = "{{uc: " .. label .. " }}"
	}
	if prepr[formatch] then
		return mw.getCurrentFrame():preprocess(prepr[formatch])
	elseif formatch == "ucfirst" then
		return mw.language.getContentLanguage():ucfirst(label)
	elseif formatch == "formatnum" then
		return make_format_num(label)
	end
	return label
end

function descriptionIn(langcode, id) -- returns item description for a given language
	if not isvalid(langcode) then
		langcode = i18n.local_lang
	end
	langcode = mw.text.trim(langcode or "")
	id = mw.text.trim(id or "")
	return mw.wikibase.getDescriptionByLang(id, langcode) or ""
end

function labelIn(langcode, id) -- returns item label for a given language
	if not isvalid(langcode) then
		langcode = i18n.local_lang
	end

	if type(id) ~= "string" then
		id = tostring(id)
	end

	langcode = mw.text.trim(langcode or "")
	id = mw.text.trim(id or "")

	return mw.wikibase.getLabelByLang(id, langcode) or nil
end

local function filter_langs(claims)
	local claims7 = {}
	local local_lang_qids = config.i18n.local_lang_qids

	for _, statement in pairs(claims) do
		for prop, id in pairs(local_lang_qids) do
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
		return claims7
	end

	return claims
end

local function formatError(key)
	return i18n.errors[key]
end

function formatDatavalue(datavalue, datatype, options)
	-- Use the customize handler if provided
	if isvalid(options["value-module"]) and isvalid(options["value-function"]) then
		local formatter = require("Module:" .. options["value-module"])
		if not formatter then
			return { value = formatError("value_module_not_found") }
		end

		local fun = formatter[options["value-function"]]
		if not fun then
			return { value = formatError("value_function_not_found") }
		end

		return { value = fun(datavalue, datatype, options) }
	end

	-- Default dataformatters
	local dataformatters = {
		["wikibase-item"] = formatwikibaseitem,
		["wikibase-property"] = formatwikibaseproperty,
		["commonsMedia"] = formatcommonsMedia,
		["math"] = formatmath,
		["time"] = formattime,
		["external-id"] = formatexternalid,
		["string"] = formatstring,
		["globe-coordinate"] = formatcoordinate,
		["quantity"] = formatquantity,
		["url"] = formaturl,
		["monolingualtext"] = formatmonolingualtext,
		["geo-shape"] = formatgeoshape,
		["tabular-data"] = formattabulardata
	}

	local dataformatter = dataformatters[datatype]
	if not dataformatter then
		return { value = formatError("unknown-data-type") }
	end

	return dataformatter(datavalue, datatype, options)
end

function formatSnak(snak, options)
	if snak.snaktype == "somevalue" then
		local somevalue = options.somevalue or i18n["somevalue"]
		return { value = somevalue }
	elseif snak.snaktype == "novalue" then
		local novalue = options.novalue or i18n["novalue"]
		return { value = novalue }
	elseif snak.snaktype == "value" then
		local s = formatDatavalue(snak.datavalue, snak.datatype, options)
		if s and s.value and isvalid(s.value) then
			s.value = (options.prefix or "") .. s.value .. (options.suffix or "")
		end
		return s
	else
		return { value = formatError("unknown_snak_type") }
	end
end

function formatStatement(statement, options)
	local claimModule = options["claim-module"]
	local claimFunction = options["claim-function"]

	if isvalid(claimModule) and isvalid(claimFunction) then
		local formatter = require("Module:" .. claimModule)
		if not formatter then
			return { value = formatError("claim_module_not_found") }
		end

		local fun = formatter[claimFunction]
		if not fun then
			return { value = formatError("claim_function_not_found") }
		end

		return { value = fun(statement, options) }
	elseif statement.type == "statement" then
		local s = formatSnak(statement.mainsnak, options)
		s.formated_quals = {}
		if isvalid(s) then
			if statement.qualifiers then
				s.formated_quals = formatqualifiers(statement, options)
				--if isvalid(qualu) then table.insert(qualu) end
			end

			if statement.references and isvalid(options.reff) then
				s.reff = formatReferences(statement, options)
			end
		end

		return s
	elseif not statement.type then
		return formatSnak(statement, options)
	end

	return { value = formatError("unknown_claim_type") }
end

function formatOneStatement(statement, options, ref)
	local value = nil
	local stat = formatStatement(statement, options)
	if not stat then
		return { v = value, raw = stat }
	end

	local s = stat.value
	if not isvalid(s) then
		return { v = value, raw = stat }
	end

	if isvalid(options.reff) and stat.reff then
		s = s .. stat.reff
	end

	local function qoo(Prefix, qualpref, p, Suffix)
		if isvalid(p) then
			local stri = (Prefix or " (") .. (qualpref or "") .. p .. (Suffix or ")")
			return mw.text.tag("small", {}, stri)
		end
	end

	local QPrefix = isvalid(options.qualifierprefix)
	local QSuffix = isvalid(options.qualifiersuffix)

	local function addQualifier(qual_value, numb, qpPrefix, qpSuffix)
		local qual_option = "qual" .. numb
		local qual_pref_option = options[qual_option .. "pref"] or ""
		if isvalid(qual_value) and isvalid(qual_option) then
			local stri = (qpPrefix or " (") .. qual_pref_option .. qual_value .. (qpSuffix or ")")
			-- s = s .. qoo(qpPrefix, qual_pref_option, qual_value, qpSuffix)
			s = s .. mw.text.tag("small", {}, stri)
		end
	end
	local formated_quals = stat.formated_quals or {}
	addQualifier(formated_quals.qual1, "1", QPrefix, QSuffix)

	if isvalid(formated_quals.qual1a) and isvalid(options.qual1a) then
		local qual1apref = isvalids({ options.qual1apref, options.qp1apref })
		s = s .. qoo(QPrefix, qual1apref, formated_quals.qual1a, QSuffix)
	end

	addQualifier(formated_quals.qual2, "2", QPrefix, QSuffix)
	addQualifier(formated_quals.qual3, "3", QPrefix, QSuffix)
	addQualifier(formated_quals.qual4, "4", QPrefix, QSuffix)
	addQualifier(formated_quals.qual5, "5", QPrefix, QSuffix)

	if isvalid(options.justthisqual) then
		s = formated_quals.justthisqual or nil -- We need only the qualifier
	end

	if not isvalid(s) then
		return { v = value, raw = stat }
	end

	if isvalid(formated_quals.P585) and isvalid(options.withdate) then
		if options.withdate == "y" then
			s = s .. qoo(QPrefix, i18n.year_, formated_quals.P585, QSuffix)
		elseif options.withdate == "before" then
			s = "*" .. formated_quals.P585 .. ":" .. s .. "\n"
		else
			s = s .. qoo(QPrefix, "", formated_quals.P585, QSuffix)
		end
	end

	local bothdates = options.bothdates
	if isvalid(formated_quals.start_end) and isvalid(bothdates) then
		local dateStr = qoo(QPrefix, "", formated_quals.start_end, QSuffix)
		if bothdates == "line" then
			s = s .. mw.text.tag("br") .. dateStr
		elseif bothdates == "before" then
			s = dateStr .. s
		else
			s = s .. dateStr
		end
	end

	if type(ref) == "table" or isvalids({ options.noref, options.justthisqual }) then
		value = s
	else
		local t = formatReferences(statement, options)
		stat.ref = t
		if isvalid(options.justref) then
			value = t
		elseif isvalid(options.onlyvaluewithref) and isvalid(t) then
			value = s .. t
		else
			value = s .. t
		end
	end
	stat.value = value
	return { v = value, raw = stat }
end

function get_claims(entity, qid, property, options)
	property = property:upper()
	--property = mw.wikibase.resolvePropertyId( property )
	local claims = {}
	--Format statement and concat them cleanly
	if options.rank == "best" or not isvalid(options.rank) then
		--claims = entity:getAllStatements( property )
		if entity then
			claims = entity:getBestStatements(property)
		else
			claims = mw.wikibase.getBestStatements(qid, property)
		end
		return claims
	end
	local allclaims = {}

	if entity then
		allclaims = entity:getAllStatements(property)
	else
		allclaims = mw.wikibase.getAllStatements(qid, property)
	end
	if not allclaims or #allclaims == 0 then
		return {}
	end
	for i, statement in pairs(allclaims) do
		local valid_st = (statement.rank == "preferred" or statement.rank == "normal") and options.rank == "valid"
		if valid_st or (options.rank == "all") or (statement.rank == options.rank) then
			table.insert(claims, statement)
		end
	end
	return claims
end

function add_box(value)
	local formattedvalue = mw.html.create('div')
		:wikitext(value)
	local divNavHead = mw.html.create('div')
		:attr({
			class = "",
			style =
			"text-align:right; padding: 0; font-size: 75%;"
		})
		:wikitext("&nbsp;[[" .. "File:Incomplete list.svg|20x20px|link=]] " .. i18n.list .. " ...")
	formattedvalue
		:addClass('mw-collapsible-content')
	divNavHead = mw.html.create('div'):node(divNavHead)

	formattedvalue = mw.html.create('div')
		:attr({ class = "mw-collapsible mw-collapsed ", style = "border: none; padding: 0;" })
		:node(divNavHead)
		:node(formattedvalue)

	return tostring(formattedvalue)
end

function value_table_to_text(options, valuetable)
	local priff = ""
	local Separator = isvalid(options.separator) or isvalid(options.conjunction)

	if Separator == "br" then
		Separator = mw.text.tag("br")
	end
	if Separator == "empty" or options.separator == "" then
		priff = ""
		Separator = ""
	end
	if Separator == "*" then
		priff = "\n*"
		Separator = "\n*"
	end
	if Separator == "#" then
		priff = "\n#"
		Separator = "\n#"
	end
	if isvalid(options.justref) then
		priff = ""
		Separator = ""
	end
	if isvalid(options.justonevalue) then
		-- only one value
		valuetable = { valuetable[1] }
	end
	local result = mw.text.listToText(valuetable, Separator, Separator)
	if isvalid(priff) and #valuetable > 1 then
		result = priff .. result
	end
	local max_num = tonumber(isvalid(options.hidden)) or config.max_claims_to_use_hidelist
	if isvalids({ options.hidden, options.barlist }) and not isvalid(options["claim-function"]) and not isvalid(options["property-function"]) and #valuetable > max_num then
		if isvalid(options.addTrackingCat) then
			wd2.track_cat_done = true
			result = result .. addTrackingCategory(options)
		end
		result = add_box(result)
	end
	return result
end

function add_suffix_pprefix(options, prop)
	if isvalid(options.mainprefix) then -- mainprefix
		prop = options.mainprefix .. prop
	end
	if isvalid(options.mainsuffix) then -- mainsuffix
		prop = prop .. options.mainsuffix
	end
	if isvalid(options.addTrackingCat) and not wd2.track_cat_done then -- add tracking cat
		prop = prop .. addTrackingCategory(options)
	end
	if isvalid(options.mainsuffixAfterIcon) then -- another suffix but after wikidata icon
		prop = prop .. options.mainsuffixAfterIcon
	end
	return prop
end

function formatStatements(options, LuaClaims)
	if not isvalid(options.property) and isvalid(options.pid) then
		options.property = options.pid
	end

	if not isvalid(options.property) then
		return formatError("property_param_not_provided")
	end
	local option1 = options.option1
	if option1 and options.option1value then
		options[option1] = options.option1value
		options['"' .. option1 .. '"'] = options.option1value
		--mw.log( "option1: " .. option1 .. "value: " .. options.option1value  )
	end
	local claims = {}
	local entity = nil
	local qid = nil

	if type(LuaClaims) == "table" then
		claims = LuaClaims[options.property] or {}
		if #claims == 0 and isvalid(options.otherproperty) then
			claims = LuaClaims[options.otherproperty:upper()] or {}
		end
		--mw.log("module:wikidata2: claims = LuaClaims[options.property]")
	else
		--Get entity
		if options.entity and type(options.entity) == "table" then
			entity = options.entity
		else
			qid = get_entityId(options)
			if isvalid(qid) then
				--mw.ustring.match(qid, "Q%d+") or mw.ustring.match(qid, "P%d+")
				if mw.wikibase.isValidEntityId(qid) and mw.wikibase.entityExists(qid) then
					options.entityId = qid
					options.qid = qid
				else
					mw.addWarning(qid .. i18n.not_valid_qid)
					qid = nil
				end
			end
		end
		if isvalid(entity) or isvalid(qid) then
			claims = get_claims(entity, qid, options.property, options)
			if #claims == 0 and isvalid(options.otherproperty) then
				options.property = options.otherproperty
				claims = get_claims(entity, qid, options.property, options)
			end
		end
	end

	if not claims or #claims == 0 then
		return ""
	end
	if not isvalid(options.langpref) then
		claims = filter_langs(claims)
	end
	if isvalid(options.sort_before_filter) then
		claims = sortclaims.sort_claims(claims, options)
		claims = filterclaims.filter_claims(claims, options)
	else
		claims = filterclaims.filter_claims(claims, options)
		claims = sortclaims.sort_claims(claims, options)
	end

	local statementsraw = {}
	if isvalid(options.numberofclaims) then
		return #claims
	end
	local valuetable = {} -- formattedStatements
	if claims then
		if isvalid(options["property-module"]) and isvalid(options["property-function"]) then
			local formatter = require("Module:" .. options["property-module"])
			if not formatter then
				return formatError("property_module_not_found")
			end
			local fun = formatter[options["property-function"]]
			if not fun then
				return formatError("property_function_not_found")
			end

			mw.log("work with property-module: " .. options["property-module"] .. "|" .. options["property-function"])
			return fun(claims, options)
		else
			for i, statement in pairs(claims) do
				options.num = i
				local va = formatOneStatement(statement, options, LuaClaims)
				if va.v then
					table.insert(valuetable, va.v)
				end
				table.insert(statementsraw, va.raw)
			end
		end
	end

	if isvalid(options.raw) then
		if isvalid(options.rawtolua) then
			return mw.getCurrentFrame():extensionTag("source", mw.dumpObject(statementsraw), { lang = "lua" })
		end
		return statementsraw
	end
	local result = ""
	if #valuetable > 0 then
		result = value_table_to_text(options, valuetable) or ""
	end
	if not isvalid(result) then
		return nil
	end
	return result
end

function formatReferences(statement, options)
	local ic = 1
	local reference = {}
	local numberofref = tonumber(options.numberofreferences) or config.max_number_of_ref
	local qid = get_entityId(options)
	local statementreferences = statement.references

	if statementreferences then
		if Modulecite == nil then
			Modulecite = require(Modules.CiteQ)
		end
		for i, ref in ipairs(statementreferences) do
			if ref.snaks and numberofref >= ic then
				local s = Modulecite._cite_wikidata(ref, qid)
				if isvalid(s) then
					ic = ic + 1
					table.insert(reference, s)
				end
			end
		end
	end

	local final = table.concat(reference)
	if isvalid(final) then
		final = final .. ("[[%s]]"):format(i18n.categories.cateref)
	end
	return final or ""
end

function formatqualifiers(statement, options)
	local qualifiers = {}

	local function get_qualifier(p, firstvalue, modifytime)
		local vvv
		if isvalid(p) then
			vvv = formatStatements({
				property = p,
				enlabelcate = "t",
				firstvalue = (firstvalue or ""),
				modifytime = (modifytime or "longdate"),
				noref = "t"
			}, statement.qualifiers) or ""
			return vvv
		end
	end


	local function quaaal(opti, options)
		if isvalid(opti) and statement.qualifiers[opti] then
			local kkk = formatStatements({
					property = opti,
					noref = "t",
					separator = options.qualifierseparator,
					conjunction = options.qualifierconjunction,
					size = options.size,
					image = options.image,
					modifytime = options.modifyqualifiertime,
					enlabelcate = "t",
					langpref = options.langpref,
					showlang = options.showlang
				},
				statement.qualifiers) or ""
			return kkk
		end
	end
	local function oneQualifier(suffix)
		local qual_option = isvalid(options["qual" .. suffix])
		if qual_option and statement.qualifiers[qual_option] then
			qualifiers["qual" .. suffix] = quaaal(qual_option, options)
		end
	end
	if isvalid(options.withdate) then
		--if statement.qualifiers.P585 then
		qualifiers.P585 = get_qualifier("P585", "true", options.modifyqualifiertime)
	end

	local bothdates_option = options.bothdates
	if isvalid(bothdates_option) then
		if statement.qualifiers.P580 or statement.qualifiers.P582 then
			local f = get_qualifier("P580", "true", options.modifyqualifiertime)
			local t = get_qualifier("P582", "true", options.modifyqualifiertime)
			qualifiers.start_end = f .. "–" .. t
		end
	end

	if isvalid(options.justthisqual) and statement.qualifiers[options.justthisqual] then
		qualifiers.justthisqual = quaaal(options.justthisqual, options)
	end


	oneQualifier("1") -- options.qual1
	oneQualifier("1a") -- options.qual1a
	oneQualifier("2") -- options.qual2
	oneQualifier("3") -- options.qual3
	oneQualifier("4") -- options.qual4
	oneQualifier("5") -- options.qual5

	return qualifiers
end

function get_property1(options, item)
	--[[ function to get countries flags without reload large countries items ]]
	local flagprop = { "p27", "p1532", "p17", "p495", "p1376" }
	local work_flag = false
	if string.lower(options.property1) == "p41" then
		for k, l in pairs(flagprop) do
			if string.lower(options.property) == l then
				work_flag = true
			end
		end
	end
	local caca = ""
	local size = options.size or ""
	if not isvalid(size) then
		size = "20"
	end
	if work_flag then
		if Moduleflags == nil then
			Moduleflags = require("Module:Wikidata2/Flags")
		end
		local flag = Moduleflags[item]
		if not isvalid(flag) then
			flag = formatStatements({
				property = options.property1,
				otherproperty = options.otherproperty1,
				entityId = item,
				rank = options.property1rank,
				pattern = options.property1pattern,
				formatting = options.property1formatting,
				noref = "t",
				firstvalue = "t"
			})
			--mw.log("get flag2 :" .. flag .. ", for item ".. item )
		end
		if isvalid(flag) then     -- return real image
			if isvalid(options.image) then -- return real image
				caca = "[[" .. "File:" .. flag .. "|" .. size .. "px|" .. "border" .. "]]"
			end
		end
	end
	if not isvalid(caca) then
		return formatStatements({
			property = options.property1,
			otherproperty = options.otherproperty1,
			entityId = item,
			rank = options.property1rank,
			pattern = options.property1pattern,
			formatting = options.property1formatting,
			size = options.size,
			image = options.image,
			noref = "t",
			firstvalue = "t"
		})
	end
	return caca
end

function formatsitelink(entityId, options)
	--[[ function to get only the value with link ]]
	local link = sitelink(entityId)
	if isvalid(link) and not isvalid(options.nolink) then
		return "[[" .. link .. "]]" .. catewikidatainfo(options)
	end
	return link
end

function formatwikibaseitem(datavalue, datatype, options)
	--[[  datatype	wikibase-item	]]
	local value
	local itemqid = datavalue.value.id
	local Skipped = config.skip_items[options.property] or {}
	for k, v in pairs(Skipped) do
		if datavalue.value.id == v then
			return { value = "", item = "" }
		end
	end
	if isvalid(options.formatting) then
		if options.formatting == "raw" then
			return { value = itemqid, item = itemqid }
		elseif options.formatting == "rawtotemplate" and isvalid(options.rawtotemplate) then
			local args = { q = itemqid, no1 = options.no1 or "", no2 = options.no2 or "" }
			value = mw.getCurrentFrame():expandTemplate { title = options.rawtotemplate, args = args } .. "\n"
			return { value = value, item = itemqid }
		elseif options.formatting == "sitelink" then
			value = formatsitelink(datavalue.value.id, options)
			return { value = value, item = itemqid }
		else
			value = formatcharacters(datavalue.value, options)
			if isvalid(options.pattern) then
				value = formatFromPattern(value, options)
			end
			return { value = value, item = itemqid }
		end
	end

	local itemValue = formatEntityId(itemqid, options).value
	if isvalid(itemValue) then
		if isvalid(options.property1) and options.property1:upper():sub(1, 1) == "P" then
			local prop1value = get_property1(options, itemqid)
			if isvalid(prop1value) then
				prop1value = (options.property1pref or "") .. "" .. prop1value .. "" .. (options.property1suff or "")
				value = prop1value .. " " .. itemValue
				if isvalid(options.property1after) then
					value = itemValue .. prop1value
				end
			else
				value = itemValue
			end
			return { value = value, item = itemqid }
		elseif isvalid(options.propertyimage) then
			local p_f = options.propertyimageformatting or options.formattingpropertyimage
			local vas = formatStatements({
				property = options.propertyimage,
				formatting = p_f,
				entityId = itemqid,
				rank = options.rank,
				pattern = options.pattern,
				size = options.size,
				image = options.image,
				noref = "t",
				avoidvalue = options.avoidvaluepropertyimage,
				firstvalue = "t",
				nolink = options.nolink
			})
			if isvalid(vas) then
				return { value = vas, item = itemqid }
			end
		elseif isvalid(options.property2) then
			local caca = formatStatements({
				property = options.property2,
				entityId = itemqid,
				noref = options.noref,
				rank = options.rank,
				pattern = options.property2pattern,
				size = options.size,
				image = options.image,
				propertyimage = (options.property3 or ""),
				firstvalue = "t"
			})
			if isvalid(caca) then
				return { value = caca .. " " .. itemValue, item = itemqid }
			end
		end
	end
	return { value = itemValue, item = itemqid }
end

function formatwikibaseproperty(datavalue, datatype, options)
	--[[  datatype	wikibase-property	]]
	local tid = ""
	if isvalid(options.formatting) then
		if options.formatting == "raw" then
			tid = datavalue.value.id
		end
	else
		tid = formatEntityId(datavalue.value.id, options).value
	end
	return { value = tid }
end

function formattabulardata(datavalue, datatype, options)
	--[[  tabular-data ]]
	local data = "[[commons:" .. datavalue.value .. "|" .. datavalue.value .. "]]"
	return { value = data }
end

function formatgeoshape(datavalue, datatype, options)
	--[[  geo-shape	 ]]
	local shape = "[[commons:" .. datavalue.value .. "|" .. datavalue.value .. "]]"
	return { value = shape }
end

function formatcommonsMedia(datavalue, datatype, options)
	local tid
	--[[ commonsMedia ]]
	local size = isvalid(options.size) or "280x330px"
	-- add px to size if just a number
	if (tonumber(size) or 0) > 0 then
		size = size .. "px";
	end
	if isvalid(options.image) then -- return real image
		tid = "[[" .. "File:" .. datavalue.value .. "|" .. size .. ""
		if isvalid(options.center) then
			tid = tid .. "|center"
		end
		-- |class=skin-invert
		if options.property == "P109" then
			tid = tid .. "|class=skin-invert"
		end
		tid = tid .. "]]"
	else
		tid = formatcharacters(datavalue.value, options)
	end
	return { value = tid }
end

function formatmath(datavalue, datatype, options)
	--[[datatype math ]]
	--return	{value=mw.text.tag("math", {}, "".. datavalue.value.."") } -- that doesn't work well
	local result = mw.getCurrentFrame():callParserFunction("#tag:math", datavalue.value)
	return { value = result }
end

function formatstring(datavalue, datatype, options)
	--[[  datatype string ]]
	local par = options.pattern
	local result = formatcharacters(datavalue.value, options)
	local tid = result

	if isvalid(options.stringpattern) then
		tid = mw.ustring.gsub(options.stringpattern, "$1", datavalue.value)
	elseif isvalid(par) then
		if par ~= "autourl" and par ~= "autourl2" and par ~= "autourl3" and par ~= "autourl4" then
			tid = formatFromPattern(result, options)
		end
	end
	return { value = tid }
end

function formatexternalid(datavalue, datatype, options)
	local result = formatcharacters(datavalue.value, options)
	if not isvalid(options.pattern) then
		return { value = result } --just return value
	end
	local patter =
		formatStatements({ property = "P1630", entityId = options.property, firstvalue = "t", noref = "t", rank = "all" }) -- get formatter URL

	local par = options.pattern
	local tid = result

	if isvalid(patter) then -- if P1630 are there
		local pp = formatFromPattern(datavalue.value, { pattern = patter })
		local plabel = mw.wikibase.getLabel(options.property) or pp
		local ppp = mw.ustring.gsub(pp, " ", "_")

		local results = {
			["autourl"] = ppp,                                 -- like http://example.com/$1.html
			["autourl2"] = "[" .. ppp .. " " .. datavalue.value .. "]", -- like [http://example.com/$1.html $1]
			["autourl3"] = "[" .. ppp .. " " .. ppp .. "]",    -- like [http://example.com/$1.html http://example.com/$1.html]
			["autourl4"] = "[" .. ppp .. " " .. plabel .. "]"
		}
		if results[par] then
			tid = results[par]
		else
			tid = formatFromPattern(result, options)
		end
	elseif isvalid(par) then
		if par ~= "autourl" and par ~= "autourl2" and par ~= "autourl3" and par ~= "autourl4" then
			tid = formatFromPattern(result, options)
		end
	end
	return { value = tid }
end

function formattime(datavalue, datatype, options)
	--[[  datatype	time  ]]
	if ModuleTime == nil then
		ModuleTime = require(Modules.time)
	end
	local timen = datavalue.value
	local tid = ModuleTime.getdate(timen, options)
	-- local tid = mw.getCurrentFrame():preprocess(mall)
	if isvalid(options.modifytime) then
		if options.modifytime == "q" then
			local mall = datavalue.value.time
			tid = mw.getCurrentFrame():preprocess(mall)
		elseif options.modifytime == "precision" then
			local mall = datavalue.value.precision
			tid = mw.getCurrentFrame():preprocess(mall)
		end
	end
	return { value = tid }
end

function formatcoordinate(datavalue, datatype, options)
	--[[  datatype	globe-coordinate  ]]
	--local GlobeCoordinate = require "Module:GlobeCoordinate"
	--return {value=GlobeCoordinate.newFromWikidataValue( datavalue.value ):toHtml()}
	if ModuleGlobes == nil then
		ModuleGlobes = require("Module:Wikidata2/Globes")
	end
	local coord = datavalue.value
	local globe = datavalue.value.globe
	local globe2 = ModuleGlobes[globe] or ""
	local results = {
		latitude = coord.latitude,
		longitude = coord.longitude,
		dimension = coord.dimension,
		precision = coord.precision,
		globe = globe:match("Q%d+"),
		globe2 = globe2
	}

	local pro = options.formatting and results[options.formatting]
	if pro == nil then
		pro =
			mw.getCurrentFrame():preprocess(
				"{{ {{{|safesubst:}}}#invoke:Coordinates|coord" ..
				"|" .. coord.latitude ..
				"|" .. coord.longitude ..
				"|display=inline" ..
				"|globe:" .. globe2 .. "_type:landmark" ..
				"|format=" .. (options.formatcoord or "") .. "}}"
			) .. catewikidatainfo(options)
	end

	return { value = pro }
end

function formatquantity(datavalue, datatype, options)
	--[[  datatype quantity	 ]]
	local amount, unit = datavalue.value.amount, datavalue.value.unit
	amount = mw.ustring.gsub(amount, "+", "")
	if unit then
		unit = unit:match("Q%d+")
	end
	--[[
	if formatera == nil then
		formatera = require("Module:Wikidata2/Math")
	end
	local number = formatera.newFromWikidataValue(datavalue.value)
	]]
	--mw.log("number: " .. number)
	local unitraw = unit
	if unit and isvalid(options.unitshort) then
		local lab = isvalid(options.label)
		if not isvalid(lab) then
			lab = formatStatements({
				property = "P5061",
				entityId = unit,
				justonevalue = "t",
				textformat = "text",
				langpref = isvalid(options.langpref) or i18n.local_lang,
				noref = "t"
			})
		end
		if not isvalid(lab) then
			lab = formatStatements({
				property = "P498",
				entityId = unit,
				justonevalue = "t",
				textformat = "text",
				langpref = isvalid(options.langpref) or i18n.local_lang,
				noref = "t"
			})
		end
		lab = lab or ""
		local s = formatEntityId(unit,
			{ label = lab, enlabelcate = "t", nolink = (options.nounitlink or options.nolink) })
		unit = s.value
	elseif unit then
		local s = formatEntityId(unit, { nolink = options.nounitlink, enlabelcate = "t" })
		unit = s.value
	end
	if options.formatcharacters and options.formatcharacters == "formatnum" then
		amount = make_format_num(amount)
	end
	local Value = amount .. " " .. (unit or "")
	if isvalid(options.nounit) then
		Value = amount
	end
	return { value = Value, amount = amount, unit = unit, unitraw = unitraw }
end

function formaturl(datavalue, datatype, options)
	--[[  datatype	url	 ]]
	local label = options.label
	if isvalid(options.urllabel) then
		label = options.urllabel
	end
	local va = mw.ustring.gsub(datavalue.value, " ", "_")
	if label == nil and options.property == "P856" then
		label = i18n.official_site
	end
	if isvalid(options.formatting) == "raw" then
		return { value = va }
	end
	local pro = va
	if isvalid(label) then
		pro = "[" .. va .. " " .. label .. "]"
	end
	return { value = pro }
end

function formatmonolingualtext(datavalue, datatype, options) -- showlang
	local text = datavalue.value.text
	if Moduletext == nil then
		Moduletext = require(Modules.monolingualtext)
	end
	local tid = Moduletext._main(datavalue, datatype, options)
	return { value = tid }
end

function Labelfunction(qid, arlabel, options) -- label with no arwiki sitelink
	local value
	local cat = ""
	local en_label = mw.wikibase.getLabel(qid) or ""

	if isvalid(options.illwd2) then
		if Moduleill_wd2 == nil then
			Moduleill_wd2 = require(Modules.WD2)
		end
		value = Moduleill_wd2.Ill_WD2_label(qid, arlabel, options)
		--
	elseif isvalid(arlabel) then
		value = arlabel
		--
	elseif not isvalid(options.justarabic) then
		local use_en_label = isvalids({ options.enlabelcate, options.use_en_labels })
		if isvalid(en_label) and use_en_label then
			value = en_label
		end
	end

	return { value = value or "", cat = cat }
end

function formatEntityId(qid, options)
	local label = ""
	local value
	local arlabel = labelIn(i18n.local_lang, qid) or "" -- The arabic label
	local link = mw.wikibase.getSitelink(qid)

	if isvalid(options.label) then
		label = options.label
	elseif isvalid(options.female_label) then
		label = options.female_label
	elseif isvalid(arlabel) then
		--mw.log("arlabel" .. arlabel)
		label = arlabel
	elseif isvalid(link) then
		label = link
		arlabel = link
	end

	if isvalid(link) then
		local linklabel = isvalid(label) or link
		if (not isvalid(options.nolink)) then
			value = "[[:" .. link .. "|" .. formatcharacters(linklabel, options) .. "]]"
			label = linklabel
		else
			value = formatcharacters(linklabel, options)
			label = linklabel
		end
	else
		if isvalid(options.female_label) then
			arlabel = options.female_label
		end
		local va = Labelfunction(qid, arlabel, options)
		label = va.value
		value = va.value -- .. va.cat
	end
	return { value = value or "", label = label or "" }
end

function sitelink(id, wikisite)
	local site = wikisite or mw.wikibase.getGlobalSiteId() -- "arwiki"
	local link = mw.wikibase.getSitelink(id, site) or ""
	return link
end

function wd2.formatAndCat(args)
	if args == nil then
		return nil
	end

	Frame_args = args
	args.linkback = args.linkback or true
	args.addcat = true
	if isvalid(args.value) and args.value == "-" then
		return nil
	end
	if isvalid(args.value) then
		local val = args.value .. addTrackingCategory(args)
		val = wd2.addLinkBack(val, args.entity, args.property)
		return val
	end
	return wd2.formatStatementsFromLua(args)
end

function wd2.translate(str, rep1, rep2)
	str = i18n[str] or str
	if rep1 and (type(rep1) == "string") then
		str = str:gsub("$1", rep1)
	end
	if rep2 and (type(rep2) == "string") then
		str = str:gsub("$2", rep2)
	end
	return str
end

function wd2.getId(snak)
	if (snak.snaktype == "value") then
		if snak.datavalue.type == "wikibase-entityid" then
			return "Q" .. snak.datavalue.value["numeric-id"]
		end
	end
end

function wd2.addLinkBack(str, id, property)
	if type(id) == "table" then
		id = id.id
	end
	if not isvalid(id) then
		id = mw.wikibase.getEntityIdForCurrentPage()
	end
	if not isvalid(id) then
		return str
	end
	if type(property) == "table" then
		property = property[1]
	end
	local class = ""
	if property then
		class = "wd_" .. string.lower(property)
	end
	local icon = "[[" .. "File:Blue pencil.svg|%s|10px|baseline|class=noviewer|link=%s]]"
	local title = i18n["see-wikidata-value"]
	local url = mw.uri.fullUrl("d:" .. id, "uselang=" .. i18n.local_lang)
	url.fragment = property
	url = tostring(url)
	local v =
		mw.html.create("span"):addClass(class):wikitext(str):tag("span"):addClass("noprint wikidata-linkback"):css(
			"padding-left",
			"0.5em"
		):wikitext(icon:format(title, url)):allDone()
	return tostring(v)
end

function wd2.formatSnak(snak, options)
	return formatSnak(snak, options)
end

function wd2.formatEntityId(entityId, options)
	return formatEntityId(entityId, (options or {}))
end

function wd2.formatStatements(frame, key)
	-- {{#invoke:Wikidata2|formatStatements|entityId=Q76|property=P19}}
	-- {{#invoke:Wikidata2|fs|qid={{{qid|}}}|pid=P19}}
	if frame.args then
		if type(key) == "table" and key ~= {} then
		else
			Frame_args = frame.args
		end
	end
	--[[ The main function ]]
	local args = frame.args
	--If a value if already set, use it
	if isvalid(args.value) then
		return args.value
	end
	-- arg used to ban wikidata value
	local wd_arg = frame:getParent().args["ويكي بيانات"] or frame.args["ويكي بيانات"] or frame:getParent().args.no_wd or
		frame.args.no_wd

	if anyvalid(wd_arg) == i18n.no then
		return ""
	end

	local prop = formatStatements(args, key)

	if isvalid(prop) then
		prop = add_suffix_pprefix(args, prop)
	elseif isvalid(args.NoPropValue) then -- value if no local value and no wikidata value
		prop = args.NoPropValue
	end
	return prop
end

function wd2.formatStatementsFromLua(options, key) --	 main function but to use from lua module
	if options then
		if type(key) == "table" and key ~= {} then
		else
			Frame_args = options
		end
	end

	--If a value if already set, use it
	if isvalid(options.value) then
		return options.value
	end
	local s = formatStatements(options, key)
	if not isvalid(s) then
		s = nil
	end
	if isvalid(s) then
		s = add_suffix_pprefix(options, s)
	else
		if isvalid(options.NosValue) then -- value if no local value and no wikidata value
			s = options.NosValue
		end
	end
	return s
end

function wd2.fs(frame, key)
	-- {{#invoke:Wikidata2|formatStatements|entityId=Q76|property=P19}}
	-- {{#invoke:Wikidata2|fs|qid={{{qid|}}}|pid=P19}}
	return wd2.formatStatements(frame, key)
end

function wd2.getLabel(entity, lang)
	return labelIn(lang, entity)
end

-- Return the site link for a given data item and a given site (the current site by default)

function wd2.getSiteLink(frame)
	local site = frame.args[2] or frame.args.site
	local id = frame.args[1] or frame.args.id
	local count = frame.args.countsitelinks
	if not isvalid(id) then
		if isvalid(frame.args.page) then
			id = mw.wikibase.getEntityIdForTitle(frame.args.page)
		end
	end
	if isvalid(count) then
		return wd2.countSiteLinks(id)
	end
	local link = sitelink(id, site)
	if isvalid(link) then
		return link
	end
end

-- returns the page id (Q...) of the current page or nothing of the page is not connected to Wikidata
function wd2.pageId(frame)
	return mw.wikibase.getEntityIdForCurrentPage()
end

function wd2.descriptionIn(frame)
	local langcode = frame.args[1] or frame.args["lang"]
	local id = frame.args[2] or frame.args["id"]
	return descriptionIn(langcode, id)
end

function wd2.labelIn(frame)
	local langcode = frame.args[1] or frame.args["lang"]
	local id = frame.args[2] or frame.args["id"]
	return labelIn(langcode, id)
end

function wd2.EntityIdForTitle(frame)
	local title = frame.args[1]
	local str = mw.wikibase.getEntityIdForTitle(title)
	--mw.log(str)
	return str
end

function wd2.Qidfortitleandwiki(frame)
	local title = mw.text.trim(frame.args[1] or "")
	local wiki = mw.text.trim(frame.args[2] or "")
	local str = mw.wikibase.getEntityIdForTitle(title, wiki)
	return str
end

function wd2.isSubclass(frame)
	Moduledump = require(Modules.dump)
	return Moduledump.isSubclass(frame)
end

function wd2.ViewSomething(frame)
	Moduledump = require(Modules.dump)
	return Moduledump.ViewSomething(frame)
end

function wd2.Dump(frame)
	Moduledump = require(Modules.dump)
	return Moduledump.Dump(frame)
end

return wd2
