local p = {}
local track = require('وحدة:Wikidata2/تتبع').makecategory1

local i18n = {
	file_prefix = mw.site.namespaces[6].name,
	edit_at_wd_link = "[تعديل في ويكي بيانات]",
	default_value_label = "قيمة",
}

local function isvalid(x)
	if x and x ~= nil and x ~= "" then return x end
	return nil
end

local function one_temp(statement, options)
	local Args = {}
	local opts = options
	opts.enbarten = 'true'

	local s = formatSnak(statement.mainsnak, options).value

	if not isvalid(s) then return "" end

	if statement.references and isvalid(options.reff) then
		s = s .. formatReferences(statement, options)
	end

	local function tato(number, Q_n)
		if Q_n then
			opts["property"] = Q_n
			Args[number] = formatStatements({
				property = Q_n,
				firstvalue = "t",
				illwd2 = options.illwd2,
				enlabelcate = options.enlabelcate,
			}, statement.qualifiers) or ''
		end
	end

	if statement.qualifiers then
		tato(0, options.Q0)
		Args[1] = s
		tato(2, options.Q1)
		tato(3, options.Q2)
		tato(4, options.Q3)
		tato(5, options.Q4)
		tato(6, options.Q5)
		tato(7, options.Q6)
		tato(8, options.Q7)
		tato(9, options.Q8)
		tato(10, options.Q9)
		tato(11, options.Q10)
	end
	return Args
end

local function create_edit_at_wd(qid)
	local content = ("[[%s:Wikidata-logo.svg|20px|link=d:%s#P54]] [[d:%s#P54|%s]]")
		:format(i18n.file_prefix, qid, qid, i18n.edit_at_wd_link)
	local edit_at_wd = mw.html.create("tr")
		:tag("td"):attr("scope", "col")
		:css("background-color", "#F9F9F9")
		:css("color", "#000000")
		:css("text-align", "left")
		:attr("colspan", 5)
		:wikitext(content):done()
	return tostring(edit_at_wd)
end

function p.temp(claims, options)
	local op = options
	op.noicon = "t"
	local icon = track(op)

	local Other = {}
	for i, statement in pairs(claims) do
		options.num = i
		--if statement and statement.type and statement.type == 'statement' then
		local stat = one_temp(statement, options)
		table.insert(Other, stat)
		--end
	end
	local Labs = {}
	local lenth = 0

	local function make_lab(numb, q)
		local val = options[q]
		if isvalid(options[val]) then
			Labs[numb] = options[val]
		elseif isvalid(val) then
			Labs[numb] = mw.wikibase.label(val)
		end
		if isvalid(val) then lenth = lenth + 1 end
	end

	make_lab(0, "Q0")
	Labs[1] = options.Q1_lab or i18n.default_value_label
	make_lab(2, "Q1")
	make_lab(3, "Q2")
	make_lab(4, "Q3")
	make_lab(5, "Q4")
	make_lab(6, "Q5")
	make_lab(7, "Q6")
	make_lab(8, "Q7")
	make_lab(9, "Q8")
	make_lab(10, "Q9")
	make_lab(11, "Q10")

	local tab = mw.html.create('table')
	tab:addClass('wikitable sortable')
	local head = tab:tag('tr')
	head:attr('colspan', lenth)
	local i = 0
	while true do
		if Labs[i] then head:tag('th'):wikitext(Labs[i]) end
		i = i + 1
		if i == 11 then break end
	end
	for _, v in ipairs(Other) do
		local ii = 0
		if v[0] then
			local ca = tab:tag('tr')
			while true do
				if Labs[ii] and v[ii] then
					ca:tag('td'):wikitext(v[ii])
				end
				ii = ii + 1
				if ii == 11 then break end
			end
		end
	end
	local content = create_edit_at_wd(options.entityId)

	if #Other > 0 then
		tab:tag('tr')
			:tag('td')
			:attr('scope', 'col')
			:css('background-color', '#F9F9F9')
			:css('color', '#000000')
			:css('text-align', "left")
			:attr('colspan', lenth + 1)
			:wikitext(content .. icon)
			:done()
	end
	local result = tostring(tab)
	return result
end

return p
