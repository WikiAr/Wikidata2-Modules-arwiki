local p = {}
local table_maker = require("Module:ص.م")

local sandbox = "ملعب"
local sandbox_added = ""
if nil ~= string.find(mw.getCurrentFrame():getTitle(), sandbox, 1, true) then
	sandbox_added = "/" .. sandbox
end
local config = mw.loadData('Module:Wikidata2/config' .. sandbox_added)
local i18n = config.i18n

local p39_labels = {
	from = "'''منذ''' ",
	to = "'''حتى''' ",
	electedin = "الانتخابات",
	president = "الرئيس",
	premier = "رئيس الوزراء",
	P5054 = "مجلس الوزراء",
	constituency = "الدائرة الإنتخابية",
	P2937 = "فترة برلمانية",
	jurisdiction = "الاختصاص",
	employer = "في مكتب",
}

local function valid_value(x)
	if x and x ~= nil and x ~= "" and x ~= i18n.no then return x end
	return nil
end

local function valid_values(xs)
	for _, x in pairs(xs) do
		if valid_value(x) then
			return x
		end
	end
	return nil
end

local function notvalid_value(x)
	if not x or x == nil or x == "" then return true end
	return false
end

local function render_infobox(args)
	local colspan = valid_value(args.colspan) or 2

	local output = "</tr>"

	local series_line = ""

	if valid_value(args.series) then
		-- remove &nbsp; form it
		args.series = args.series:gsub("&nbsp;", "")
		series_line = "(" .. args.series .. ")"
	end

	-- ص.م/عنوان فرعي
	local head_title = (args.office_img or "") .. (args.office or "") .. " " .. series_line
	local head_row = table_maker.SubTitle({
		title = head_title,
		showTitle = head_title,
		bg_color = "E1E1E1",
		txt_color = "000000",
		colspan = colspan,
	})

	output = output .. head_row

	-- ص.م/سطر
	local term_content = ""
	if valid_value(args.termstart) then
		if valid_value(args.termend) then
			term_content = args.termstart .. " – " .. args.termend
		else
			term_content = p39_labels.from .. args.termstart
		end
	else
		if valid_value(args.termend) then
			term_content = p39_labels.to .. args.termend
		end
	end

	local date_line = table_maker.Line({
		showLine = term_content,
		content = term_content,
		textAlign = "center",
		bg_color = "f9f9f9",
		txt_color = "000000",
		colspan = colspan,
	})

	output = output .. date_line
	-- أسطر مختلطة شرطية
	local mixed_rows = {
		{ label = p39_labels.electedin,    param = args.electedin },
		{ label = p39_labels.president,    param = args.president },
		{ label = p39_labels.premier,      param = args.premier },
		{ label = p39_labels.P5054,        param = args.P5054 },
		{ label = p39_labels.constituency, param = args.constituency },
		{ label = p39_labels.P2937,        param = args.P2937 },
		{ label = p39_labels.jurisdiction, param = args.jurisdiction },
		{ label = p39_labels.employer,     param = valid_values({ args.of, args.employer }) }
	}

	for _, row in ipairs(mixed_rows) do
		if valid_value(row.param) then
			local mixed_row = table_maker.MixedLine({
				title = row.label,
				showLine = row.param,
				content = row.param,
				colspan = colspan,
				bg_color = "f9f9f9"
			})
			output = output .. mixed_row
		end
	end

	local before_after_row = table_maker.PrevNextLine1({
		dprev = args.predecessor,
		dnext = args.successor,
		bg_color = "f9f9f9",
		colspan = colspan,
		right_arrow = "Fleche-defaut-droite-gris-32.png",
		left_arrow = "Fleche-defaut-gauche-gris-32.png",
		arrowSize = 8
	})

	output = output .. before_after_row
	output = output .. "<tr>"

	return output
end

local function result_table(s, office_img, personqid, entity_id, options, qualifiers)
	local args = {
		office = s,
		office_img = office_img,
		entityId = personqid,
		q = entity_id,
		colspan = valid_value(options.co) or valid_value(options.colspan),
		termstart = qualifiers.start,
		termend = qualifiers.finish,
		constituency = qualifiers.constituency,
		predecessor = qualifiers.before,
		successor = qualifiers.after,
		president = qualifiers.president,
		premier = qualifiers.premier,
		series = qualifiers.series,
		electedin = qualifiers.electedin,
		jurisdiction = qualifiers.P1001,
		employer = qualifiers.P108,
		of = qualifiers.P642,
		P2937 = qualifiers.P2937,
		P5054 = qualifiers.p5054
	}
	local result1 = render_infobox(args)
	return result1
end

local function get_office_img(qid)
	local ca1 = formatStatements({
		property = "P154",
		otherproperty = "P41",
		entityId = qid,
		noref = "true",
		rank = "all",
		size = "25",
		image = "image",
		firstvalue = "true",
		separator = "",
		conjunction = ""
	})
	return ca1
end

local function get_female_label(office_id, personqid)
	local gender = formatStatements({
		property = 'P21',
		entityId = personqid,
		noref = 't',
		rank = 'all',
		firstvalue = 't',
		formatting = 'raw'
	})

	if gender and (gender == 'Q6581072' or gender == 'Q1052281') then
		local fem_label = formatStatements({
			property = 'P2521',
			entityId = office_id,
			noref = 'true',
			langpref = i18n.local_lang,
			formatting = 'text',
			rank = "all"
		})
		return fem_label
	end
	return ""
end

local function get_qua(property, enbarten, modifytime, statement)
	local ca = formatStatements({ property = property, illwd2 = "t", firstvalue = enbarten, modifytime = modifytime },
		statement.qualifiers) or ""
	if ca ~= "" then
		return ca .. addTrackingCategory({ property = property, noicon = "t" })
	end
	return ca
end

local function process_qualifiers(statement)
	return {
		img = formatStatements({
			property = "P94",
			otherproperty = "P41",
			noref = "true",
			rank = "all",
			size = "25",
			image = "image",
			firstvalue = "true",
			separator = "",
			conjunction = ""
		}, statement.qualifiers),
		P108 = get_qua("P108", "", "", statement),
		P108_raw = formatStatements({
			property = "P108",
			noref = "true",
			rank = "all",
			firstvalue = "true",
			formatting = 'raw'
		}, statement.qualifiers),
		start = get_qua("P580", "true", "longdate", statement),
		finish = get_qua("P582", "true", "longdate", statement),
		before = get_qua("P1365", "true", "", statement),
		after = get_qua("P1366", "true", "", statement),
		constituency = get_qua("P768", "", "", statement),
		series = get_qua("P1545", "true", "", statement),
		electedin = get_qua("P2715", "", "", statement),
		P1001 = get_qua("P1001", "", "", statement),
		P642 = get_qua("P642", "", "", statement),
		president = get_qua("P325", "", "", statement),
		premier = get_qua("P6", "", "", statement),
		p5054 = get_qua("P5054", "", "", statement),
		P2937 = get_qua("P2937", "", "", statement)
	}
end

local function office_is_okay(qualifiers, statement)
	if notvalid_value(statement.qualifiers.P108) and notvalid_value(statement.qualifiers.P642) then
		return true
	end
	if statement.qualifiers.P108 and valid_value(qualifiers.P108) then
		return true
	end
	if statement.qualifiers.P642 and valid_value(qualifiers.P642) then
		return true
	end
	return false
end

function p.office3(statement, options)
	local s_tab = formatSnak(statement.mainsnak, options)
	local s = s_tab.value
	local sqid = s_tab.item

	if notvalid_value(s) then
		return ""
	end

	local qualifiers = {}
	if statement.qualifiers then
		qualifiers = process_qualifiers(statement)
	end
	if not valid_values({ qualifiers.start, qualifiers.finish, qualifiers.constituency, qualifiers.before, qualifiers.after, qualifiers.electedin, qualifiers.P1001, qualifiers.president, qualifiers.P5054 }) then
		return ""
	end
	if not office_is_okay(qualifiers, statement) then
		return ""
	end

	local entity_id = statement.mainsnak.datavalue.value.id

	local personqid = options.entityId or options.qid

	local female_label = get_female_label(sqid, personqid)

	local office_label = formatEntityId(entity_id, options).value

	if valid_value(female_label) then
		office_label = formatEntityId(entity_id, { female_label = female_label }).value
	end

	mw.log("s: ", s, "office_label: ", office_label)

	if valid_value(office_label) then
		s = office_label
	end

	if statement.references and options.reff and options.reff ~= "" then
		s = s .. formatReferences(statement, options)
	end

	local office_img

	if valid_value(qualifiers.img) then
		office_img = qualifiers.img
	else
		office_img = get_office_img(entity_id)
	end

	local result = result_table(s, office_img, personqid, entity_id, options, qualifiers)
	return result
end

return p
