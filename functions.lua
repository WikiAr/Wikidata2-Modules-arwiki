--[[

Link of copy of main module used (Module:Wikidata2/functions):
https://ar.wikipedia.org/w/index.php?title=وحدة:Wikidata2/ملعب&oldid=58189763

]]

local help_functions = {}
local ModuleTime = require "Module:wikidata2/time"
help_functions.Frame_args = {}
help_functions.i18n = {
	["errors"] = {
		["property-param-not-provided"] = "وسيط property غير متوفر.",
		["entity-not-found"] = "الكيان غير موجود.",
		["unknown-claim-type"] = "نوع claim غير معروف.",
		["unknown-snak-type"] = "نوع snak غير معروف.",
		["unknown-datatype"] = "نوع data غير معروف.",
		["unknown-entity-type"] = "نوع entity غير معروف.",
		["unknown-value-module"] = "يجب عليك تعيين كل من  value-module و value-function.",
		["unknown-claim-module"] = "يجب عليك تعيين كل من claim-module و claim-function.",
		["unknown-property-module"] = "يجب عليك تعيين كل من property-module و property-function.",
		["property-module-not-found"] = "الوحدة المستخدمة في وسيط property-module غير موجودة.",
		["property-function-not-found"] = "الوظيفة المستخدمة في وسيط property-function غير موجودة.",
		["value-module-not-found"] = "الوحدة المستخدمة في وسيط value-module غير موجودة.",
		["value-function-not-found"] = "الوظيفة المستخدمة في وسيط value-function غير موجودة.",
		["claim-module-not-found"] = "الوحدة المستخدمة في وسيط claim-module غير موجودة.",
		["claim-function-not-found"] = "الوظيفة المستخدمة في وسيط claim-function غير موجودة."
	},
	["noarabiclabel"] = "تصنيف:صفحات_ويكي_بيانات_بحاجة_لتسمية_عربية",
	["warnDump"] = "[[تصنيف:Called function 'Dump' from module Wikidata]]",
	["somevalue"] = "", --''غير محدد''
	["novalue"] = "",   --قيمة مجهولة
	["cateref"] = "[[" .. "تصنيف:صفحات بها مراجع ويكي بيانات" .. "]]",
	["to translate"] = "صفحات تستعمل معطيات من ويكي بيانات بحاجة لترجمة",
	["trackingcat"] = "صفحات تستخدم خاصية $1",
	["see-wikidata-value"] = "الاطلاع ومراجعة البيانات على ويكي داتا",
	["see-wikidata"] = "راجع العنصر من ويكي بيانات المقابل",
	["see-another-project"] = "مقالة على $1",
	["see-another-language"] = "مقالة على ويكيبيديا $1"
}
help_functions.skiip = {
	["P106"] = {
		"Q42857",    -- prophet
		"Q14886050", -- terrorist
		"Q2159907"   -- criminal
	}
}

local function isvalid(x)
	if x and x ~= "" then
		return x
	end
	return nil
end

function help_functions.formatFromPattern(str, options)
	-- [[	function to replace $1 with string	]]
	local str = string.gsub(str, "%%", "%%%%")
	if options.pattern and options.pattern ~= "" then
		str = mw.ustring.gsub(options.pattern, "$1", str) --الحصول على اول نتيجة للدالة
	end
	return str
end

function help_functions.formatError(key)
	return help_functions.i18n.errors[key]
end

function help_functions.count_Site_Links(id)
	numb = 0
	Table = {}
	local entity = mw.wikibase.getEntityObject(id)
	if entity and entity.sitelinks then
		for i, v in pairs(entity.sitelinks) do
			Table[v.site] = v.title
			numb = numb + 1
		end
		--return Frame:extensionTag("source", mw.dumpObject( Table ),{ lang= 'lua'})
	end
	return numb
end

function help_functions.make_format_num(String)
	local line = String
	line = mw.getCurrentFrame():preprocess("{{ {{{|safesubst:}}}formatnum: " .. String .. " }}")
	line = mw.ustring.gsub(line, "٫", ".")
	line = mw.ustring.gsub(line, "٬", ",")
	return line
end

function help_functions.formatcharacters(label, options)
	local formatcharacters = options.formatcharacters
	--if options.FormatfirstCharacter and options.num == 1 then
	--formatcharacters = options.FormatfirstCharacter
	--end
	if not label then
		return label
	end
	local String2 = mw.ustring.gsub(label, "–", "-")
	local march_y =
		mw.ustring.match(String2, "%d%d%d%d%-%d%d%d%d", 1) or mw.ustring.match(String2, "%d%d%-%d%d%d%d", 1) or
		mw.ustring.match(String2, "%d%d%d%d", 1) or
		mw.ustring.match(String2, "%d%d%d%d%-%d%d", 1) or
		mw.ustring.match(String2, "%d%d%d%d", 1)

	if options.illwd2y and options.illwd2y ~= "" then
		ca = march_y or label
		return ca
	end
	if options.illwd2noy and options.illwd2noy ~= "" and march_y then
		label = mw.ustring.gsub(label, march_y, "")
		return label
	end
	if not formatcharacters or formatcharacters == "" then
		return label
	end
	function preproces(Type, label)
		return mw.getCurrentFrame():preprocess("{{ {{{|safesubst:}}}" .. Type .. ":" .. label .. " }}")
	end

	if formatcharacters == "lcfirst" then
		return preproces("lcfirst", label)
	elseif formatcharacters == "ucfirst" then
		return mw.language.getContentLanguage():ucfirst(label)
	elseif formatcharacters == "lc" then
		return preproces("lc", label)
	elseif formatcharacters == "uc" then
		return preproces("uc", label)
	elseif formatcharacters == "formatnum" then
		return help_functions.make_format_num(label)
	end
	return label
end

function help_functions.get_entityId(options)
	local id = options.entityId or options.entityid or options.id or options.qid
	if isvalid(id) == nil then
		if isvalid(options.page) then
			id = mw.wikibase.getEntityIdForTitle(options.page)
		end
	end
	--mw.log("id :" .. id)
	return id or ""
end

function help_functions.descriptionIn(langcode, id) -- returns item description for a given language
	local lan = langcode
	if not lan or lan == "" then
		lan = "ar"
	end

	if lan == "ar" then
		local description, lange = mw.wikibase.getDescriptionWithLang(id)
		if lange == lan then
			return description
		else
			return nil
		end
	else
		local entity = help_functions.getEntityFromId(id)
		if entity and entity.descriptions then
			local description = entity.descriptions[lan]
			if description and description.value then
				if description["language"] == lan then
					return description.value
				else
					return nil
				end
			end
		end
	end
end

function help_functions.labelIn(langcode, id) -- returns item label for a given language
	local lang = langcode
	if not langcode or langcode == "" then
		lang = "ar"
	end
	if type(id) ~= "string" then
		id = tostring(id)
	end
	local label = mw.wikibase.getLabelByLang(id, lang) or nil
	return label
end

function help_functions.get_snak_id(snak)
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
		ID = snak.mainsnak.datavalue.value.id
		return ID
	end
end

function help_functions.comparedates(a, b) -- returns true if a is earlier than B or if a has a date but not b
	local a = tonumber(a) or a
	local b = tonumber(b) or b
	if a and b then
		return a > b
	elseif a then
		return true
	end
end

function help_functions.getEntityIdFromValue(value)
	if value then
		if value["entity-type"] == "item" then
			return "Q" .. value["numeric-id"]
		elseif value["entity-type"] == "property" then
			return "P" .. value["numeric-id"]
		end
	end
	return help_functions.formatError("unknown-entity-type")
end

function help_functions.getEntityFromId(id)
	if id and id ~= "" then
		--	if not(mw.wikibase.isValidEntityId(id)) or not(mw.wikibase.entityExists(id)) then
		--	return false
		--end
		return mw.wikibase.getEntityObject(id)
	else
		return mw.wikibase.getEntityObject()
	end
end

function help_functions.formattabulardata(datavalue, datatype, options)
	--[[ tabular-data]]
	data = "[[commons:" .. datavalue.value .. "|" .. datavalue.value .. "]]"
	return { value = data }
end

function help_functions.formatgeoshape(datavalue, datatype, options)
	--[[ geo-shape ]]
	shape = "[[commons:" .. datavalue.value .. "|" .. datavalue.value .. "]]"
	return { value = shape }
end

function help_functions.formatmath(datavalue, datatype, options)
	--[[ datatype math ]]
	--return	{value = mw.text.tag('math', {}, ''.. datavalue.value..'') } -- that doesn't work well
	return { value = mw.getCurrentFrame():callParserFunction("#tag:math", "" .. datavalue.value .. "") }
end

function help_functions.formatstring(datavalue, datatype, options)
	--[[ datatype	string	-  external-id ]]
	local par = options.pattern
	if options.stringpattern and options.stringpattern ~= "" then
		--mw.log(options.stringpattern)
		tid = mw.ustring.gsub(options.stringpattern, "$1", datavalue.value)
	elseif par and par ~= "" then
		if par == "autourl" or par == "autourl2" or par == "autourl3" or par == "autourl4" then
			tid = help_functions.formatcharacters(datavalue.value, options)
		else
			tid = help_functions.formatFromPattern(help_functions.formatcharacters(datavalue.value, options), options)
		end
	else
		tid = help_functions.formatcharacters(datavalue.value, options)
	end
	return { value = tid }
end

function help_functions.formattime(datavalue, datatype, options)
	--[[  datatype	 time  ]]
	local timen = datavalue.value
	local modifytime = (options.modifytime or "")
	local tid = ModuleTime.getdate(timen, options)
	-- local tid =	mw.getCurrentFrame():preprocess(mall)
	if options.modifytime and options.modifytime ~= "" then
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

function help_functions.get_site_link(id, wikisite)
	local site = wikisite or "arwiki"
	--local link = mw.wikibase.getSitelink( id , site ) or ""
	--return link

	local entity = mw.wikibase.getEntityObject(id)
	if
		entity and entity.sitelinks and entity.sitelinks["" .. site .. ""] and entity.sitelinks["" .. site .. ""].site and
		entity.sitelinks["" .. site .. ""].title
	then
		if entity.sitelinks["" .. site .. ""].site == site then
			return entity.sitelinks["" .. site .. ""].title
		else
			return ""
		end
	end
end

function help_functions.getId(snak)
	if (snak.snaktype == "value") then
		if snak.datavalue.type == "wikibase-entityid" then
			return "Q" .. snak.datavalue.value["numeric-id"]
		end
	end
end

function help_functions.addLinkBack(str, id, property)
	if not id then
		id = help_functions.getEntity()
	end
	if not id then
		return str
	end
	if type(property) == "table" then
		property = property[1]
	end
	if type(id) == "table" then
		id = id.id
	end
	local class = ""
	if property then
		class = "wd_" .. string.lower(property)
	end
	local icon = "[[ملف:Blue pencil.svg|%s|10px|baseline|class=noviewer|link=%s]]"
	local title = help_functions.i18n["see-wikidata-value"]
	local url = mw.uri.fullUrl("d:" .. id, "uselang=ar")
	url.fragment = property
	url = tostring(url)
	local v =
		mw.html.create("span"):addClass(class):wikitext(str):tag("span"):addClass("noprint wikidata-linkback"):css(
			"padding-left",
			"0.5em"
		):wikitext(icon:format(title, url)):allDone()
	return tostring(v)
end

function help_functions.property_module_function(options, claims)
	if not options["property-module"] or not options["property-function"] then
		return help_functions.formatError("unknown-property-module")
	end
	local formatter = require("Module:" .. options["property-module"])
	if not formatter then
		return help_functions.formatError("property-module-not-found")
	end
	local fun = formatter[options["property-function"]]
	if not fun then
		return help_functions.formatError("property-function-not-found")
	end

	mw.log("work with property-module: " .. options["property-module"] .. "|" .. options["property-function"])

	return fun(claims, options)
end

return help_functions
