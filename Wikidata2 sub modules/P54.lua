local p = {}
local wl = require("وحدة:ص.م")
local track = require("وحدة:Wikidata2/تتبع").makecategory1
local i18n = {
	file_prefix = mw.site.namespaces[6].name,
	edit_at_wd_link = "[تعديل في ويكي بيانات]",
	professional_career = "المسيرة&nbsp;الاحترافية",
	national_team = "المنتخب&nbsp;الوطني",
	youth = "الشباب",
	teams = "الفرق",
	years = "سنوات",
	team = "فريق",
	matches = "مباريات",
	goals = "أهداف",
	edit_at_wikidata = "[تعديل في ويكي بيانات]",
	category_tracking = "[[تصنيف:فرق لاعب كرة من ويكي بيانات]][[تصنيف:صفحات تستخدم خاصية P54]]"
}

local teams_id = {
	"Q476028",
	"Q847017",
	"Q28140340"
}

local youth_ids = {
	"Q131453774" -- under-19 football team
}

local national_id = {
	"Q23895910",
	"Q23847779",
	"Q6979593",
	"Q21945604",
	"Q23759293",
	"Q23905105",
	"Q3874020",
	"Q1194951",
	"Q6979740",
	"Q23901137",
	"Q23904672", -- national under-16 football team
	"Q23901123", -- national under-17 football team
	"Q23904671" -- national under-18 football team
}

local flags = {
	Q16 = { "CAN", { "Flag of Canada.svg", "+1965-02-15" } },
	Q17 = { "JPN", { "Flag of Japan.svg", "+1999-08-13" } },
	Q20 = { "NOR", { "Flag of Norway.svg", "+1821-07-13" } },
	Q27 = { "IRL", { "Flag of Ireland.svg", "+1937-12-29" } },
	Q28 = { "HUN", { "Flag of Hungary.svg", "+1957-05-23" } },
	Q29 = {
		"ESP",
		{ "Flag of Spain.svg", "+1981-12-06" },
		{ "Flag of Spain (1977–1981).svg", "+1977-01-21", "+1981-12-06" },
		{ "Flag of Spain (1945–1977).svg", "+1945-10-11", "+1977-01-21" },
		{ "Flag of Spain (1938–1945).svg", "+1939", "+1945-10-11" },
		{ "Flag of the Second Spanish Republic.svg", "+1931-04-14", "+1939" },
		{ "Flag of Spain (1785–1873, 1875–1931).svg", "+1874", "+1931-04-13" }
	},
	Q30 = { "USA", { "Flag of the United States.svg", "+1960-07-04" } },
	Q31 = { "BEL", { "Flag of Belgium (civil).svg" } },
	Q32 = { "LUX", { "Flag of Luxembourg.svg" } },
	Q33 = { "FIN", { "Flag of Finland.svg", "+1918-05-29" } },
	Q34 = { "SWE", { "Flag of Sweden.svg" } },
	Q35 = { "DEN", { "Flag of Denmark.svg" } },
	Q36 = { "POL", { "Flag of Poland.svg" } },
	Q37 = {
		"LTU",
		{ "Flag of Lithuania.svg",             "+2004-09-01" },
		{ "Flag of Lithuania (1988-2004).svg", "+1990-03-11", "+2004-09-01" }
	},
	Q38 = {
		"ITA",
		{ "Flag of Italy.svg", "+1946-06-19" },
		{ "Flag of Italy (1861–1946).svg", "+1861", "+1946-06-19" }
	},
	Q39 = { "SUI", { "Flag of Switzerland.svg", "+1889-12-12" } },
	Q40 = { "AUT", { "Flag of Austria.svg", "+1945-05-01" } },
	Q41 = { "GRE", { "Flag of Greece.svg", "+1978" } },
	Q43 = { "TUR", { "Flag of Turkey.svg" } },
	Q45 = { "POR", { "Flag of Portugal.svg", "+1911-06-30" } },
	Q55 = { "NED", { "Flag of the Netherlands.svg", "+1806" } },
	Q77 = { "URU", { "Flag of Uruguay.svg" } },
	Q96 = {
		"MEX",
		{ "Flag of Mexico.svg",             "+1968-09-16" },
		{ "Flag of Mexico (1934-1968).svg", "+1934",      "+1968-09-16" }
	},
	Q114 = { "KEN", { "Flag of Kenya.svg" } },
	Q115 = { "ETH", { "Flag of Ethiopia.svg", "+1996-10-31" } },
	Q142 = { "FRA", { "Flag of France.svg", "+1794-05-20" } },
	Q145 = { "GBR", { "Flag of the United Kingdom.svg" } },
	Q148 = { "CHN", { "Flag of the People's Republic of China.svg", "+1985" } },
	Q155 = {
		"BRA",
		{ "Flag of Brazil.svg", "+1992-05-11" },
		{ "Flag of Brazil (1968–1992).svg", "+1968-05-28", "+1992-05-11" }
	},
	Q159 = {
		"RUS",
		{ "Flag of Russia.svg", "+1993-12-11" },
		{ "Flag of Russia (1991–1993).svg", "+1991-08-22", "+1993-12-11" },
		{ "Flag of the Russian Soviet Federative Socialist Republic.svg", "+1954", "+1991-08-22" },
		{ "Flag of the Russian Soviet Federative Socialist Republic (1937–1954).svg", "+1937", "+1954" }
	},
	Q183 = {
		"GER",
		{ "Flag of Germany.svg", "+1949-05-23" },
		{ "Flag of the German Reich (1935–1945).svg", "+1935-09-15", "+1945-05-23" },
		{ "Flag of the German Reich (1933–1935).svg", "+1933-03-12", "+1935-09-15" },
		{ "Flag of Germany (3-2 aspect ratio).svg", "+1919-04-11", "+1933-03-12" },
		{ "Flag of the German Empire.svg", "+1871-04-16", "+1919-04-11" }
	},
	Q184 = {
		"BLR",
		{ "Flag of Belarus.svg", "+2012-05-11" },
		{ "Flag of Belarus (1995–2012).svg", "+1995-06-07", "+2012-05-11" }
	},
	Q191 = { "EST", { "Flag of Estonia.svg" } },
	Q211 = { "LAT", { "Flag of Latvia.svg" } },
	Q212 = { "UKR", { "Flag of Ukraine.svg", "+1992-01-28" } },
	Q213 = { "CZE", { "Flag of the Czech Republic.svg", "+1920-03-30" } },
	Q214 = { "SVK", { "Flag of Slovakia.svg" } },
	Q215 = { "SLO", { "Flag of Slovenia.svg" } },
	Q217 = { "MDA", { "Flag of Moldova.svg" } },
	Q218 = {
		"ROU",
		{ "Flag of Romania.svg",             "+1989-12-27" },
		{ "Flag of Romania (1965-1989).svg", "+1989-12-27",          "+1965" },
		{ "Flag of Romania (1952-1965).svg", "+1952",                "+1965" },
		{ "Flag of Romania (1948-1952).svg", "+1948-01-08",          "+1952" },
		{ "Flag of Romania.svg",             "12. april 1867-04-12", "+1948-01-08" }
	},
	Q219 = {
		"BUL",
		{ "Flag of Bulgaria.svg", "+1990-11-22" },
		{ "Flag of Bulgaria (1971 – 1990).svg", "+1971-05-18", "+1990-11-22" }
	},
	Q222 = { "ALB", { "Flag of Albania.svg", "+1992" } },
	Q224 = {
		"CRO",
		{ "Flag of Croatia.svg",                "+1990-12-21" },
		{ "Flag of Croatia (white chequy).svg", "+1990-06-27", "+1990-12-21" }
	},
	Q227 = { "AZE", { "Flag of Azerbaijan.svg" } },
	Q228 = { "AND", { "Flag of Andorra.svg" } },
	Q229 = {
		"CYP",
		{ "Flag of Cyprus.svg",             "+2006-08-20" },
		{ "Flag of Cyprus (1960-2006).svg", "+1960-08-16", "+2006-08-20" }
	},
	Q232 = { "KAZ", { "Flag of Kazakhstan.svg" } },
	Q238 = { "SMR", { "Flag of San Marino.svg" } },
	Q241 = { "CUB", { "Flag of Cuba.svg" } },
	Q252 = { "INA", { "Flag of Indonesia.svg" } },
	Q258 = {
		"RSA",
		{ "Flag of South Africa.svg", "+1994-04-27" },
		{ "Flag of South Africa (1928–1994).svg", "+1928-05-31", "+1994-04-27" }
	},
	Q262 = { "ALG", { "Flag of Algeria.svg" } },
	Q265 = { "UZB", { "Flag of Uzbekistan.svg" } },
	Q298 = { "CHI", { "Flag of Chile.svg" } },
	Q334 = { "SGP", { "Flag of Singapore.svg" } },
	Q347 = { "LIE", { "Flag of Liechtenstein.svg" } },
	Q398 = { "BRN", { "Flag of Bahrain.svg", "+2002-02-14" } },
	Q403 = {
		"SRB",
		{ "Flag of Serbia.svg", "+2004-08-18" },
		{ "Flag of Serbia (1992–2004).svg", "+1992-04-27", "+2004-08-17" }
	},
	Q408 = { "AUS", { "Flag of Australia.svg" } },
	Q414 = { "ARG", { "Flag of Argentina.svg" } },
	Q664 = { "NZL", { "Flag of New Zealand.svg" } },
	Q711 = { "MGL", { "Flag of Mongolia.svg" } },
	Q717 = { "VEN", { "Flag of Venezuela.svg", "+2006" } },
	Q736 = { "ECU", { "Flag of Ecuador.svg" } },
	Q739 = { "COL", { "Flag of Colombia.svg" } },
	Q750 = { "BOL", { "Flag of Bolivia.svg", "+1851-10-31" } },
	Q786 = { "DOM", { "Flag of the Dominican Republic.svg" } },
	Q794 = {
		"IRI",
		{ "Flag of Iran.svg", "+1980-07-29" },
		{ "Flag of Iran (1964–1980).svg", "+1964", "+1980-07-29" }
	},
	Q800 = { "CRC", { "Flag of Costa Rica (state).svg", "+1906-11-27" } },
	Q801 = { "ISR", { "Flag of Israel.svg" } },
	Q817 = { "KUW", { "Flag of Kuwait.svg", "+1961-09-07" } },
	Q833 = { "MAS", { "Flag of Malaysia.svg", "+1963-09-16" } },
	Q842 = { "OMA", { "Flag of Oman.svg", "+1995" } },
	Q846 = { "QAT", { "Flag of Qatar.svg" } },
	Q865 = { "TPE", { "Flag of the Republic of China.svg", "+1928-12-17" } },
	Q869 = { "THA", { "Flag of Thailand.svg" } },
	Q878 = { "UAE", { "Flag of the United Arab Emirates.svg" } },
	Q884 = { "KOR", { "Flag of South Korea.svg", "+1997-10" } },
	Q928 = { "PHI", { "Flag of the Philippines.svg", "+1998" } },
	Q948 = { "TUN", { "Flag of Tunisia.svg", "+1999-07-03" } },
	Q965 = { "BUR", { "Flag of Burkina Faso.svg" } },
	Q986 = { "ERI", { "Flag of Eritrea.svg" } },
	Q1000 = { "GAB", { "Flag of Gabon.svg", "+1960-08-09" } },
	Q1008 = { "CIV", { "Flag of Côte d'Ivoire.svg" } },
	Q1009 = { "CMR", { "Flag of Cameroon.svg" } },
	Q1028 = { "MAR", { "Flag of Morocco.svg" } },
	Q1036 = { "UGA", { "Flag of Uganda.svg", "+1962-10-09" } },
	Q1037 = {
		"RWA",
		{ "Flag of Rwanda.svg", "+2001-10-25" },
		{ "Flag of Rwanda (1962–2001).svg", "+1962", "+2001-10-25" }
	},
	Q9676 = { "IMN", { "Flag of the Isle of Man.svg" } },
	Q15180 = {
		"URS",
		{ "Flag of the Soviet Union.svg", "+1980-08-15", "+1991-12-25" },
		{ "Flag of the Soviet Union (1955–1980).svg", "+1955-08-19", "+1980-08-14" }
	},
	Q16957 = {
		"GDR",
		{ "Flag of East Germany.svg", "+1959-10-01" },
		{ "Flag of Germany.svg",      "+1949-10-07", "+1959-10-01" }
	},                                                              --German Democratic Republic
	Q8646 = { "HKG", { "Flag of Hong Kong.svg" } },
	Q29999 = { "NED", { "Flag of the Netherlands.svg", "+1690" } }, --Kingdom of the Netherlands
	Q33946 = { "TCH", { "Flag of the Czech Republic.svg", "+1920" } }, -- Czechoslovakia (1918–1992)
	Q36704 = {
		"YUG",
		{ "Flag of Yugoslavia (1992–2003).svg", "+1992-04-27", "+2003-02-04" }, --Yugoslavia
		{ "Flag of Yugoslavia (1943–1992).svg", "+1946", "+1992-04-27" }
	},
	Q83286 = { "YUG", { "Flag of Yugoslavia (1943–1992).svg" } }, --Socialist Federal Republic of Yugoslavia
	Q172579 = { "ITA", { "Flag of Italy (1861–1946).svg" } }, --Kingdom of Italy (1861-1946)
	Q713750 = { "FRG", { "Flag of Germany.svg" } }, --West Germany
	Q13474305 = {
		"ESP",
		{ "Flag of Spain (1945–1977).svg", "+1945-10-11", "+1977-01-21" }, -- Francoist Spain (1935-1976)
		{ "Flag of Spain (1938–1945).svg", "+1939", "+1945-10-11" },
		{ "Flag of the Second Spanish Republic.svg", "+1931-04-14", "+1939" }
	}
}

local function value_valid(x)
	if x and x ~= nil and x ~= "" then return x end
	return nil
end

-- Update make_sub_title calls and table headers
local function make_sub_title(title)
	return wl.SubTitle({
		title = title,
		showTitle = "-",
		bg_color = "b0c4de",
		txt_color = "000000",
		colspan = 5
	})
end

local function get_flag(countryID, date)
	if not value_valid(countryID) then
		return ""
	end

	local entry = flags[countryID]
	local IOC
	local file
	if entry then
		for i, v in ipairs(entry) do
			if i == 1 then
				IOC = v
			end
			if not value_valid(date) then
				file = v[1]
				break
			else
				-- mw.log("Module:Wikidata2 sub modules/P54: date: " .. date)
				local from = v[2]
				local to = v[3]
				if (not from or from <= date) and (not to or to > date) then
					file = v[1]
					break
				end
			end
		end
	end
	if file then
		return "[[ملف:" .. file .. "|border|20px|" .. IOC .. "]]"
	elseif not date then
		local p41 = mw.wikibase.getBestStatements(countryID, "P41") -- P41 is flag image
		if p41[1] and p41[1].mainsnak.snaktype == "value" then
			return "[[ملف:" .. p41[1].mainsnak.datavalue.value .. "|border|20px|(Wikidata:" .. countryID .. ")]]"
		end
	end
	return ""
end

local function format_label(label)
	local lab = label
	lab = mw.ustring.gsub(lab, " لكرة القدم%]%]", "]]")
	lab = mw.ustring.gsub(lab, " لكرة القدم %[%[", "[[")
	lab = mw.ustring.gsub(lab, "%|نادي ", "|")
	lab = mw.ustring.gsub(lab, "%|منتخب ", "|")
	lab = mw.ustring.gsub(lab, "^منتخب ", "")
	lab = mw.ustring.gsub(lab, " لكرة القدم$", "")
	lab = mw.ustring.gsub(lab, " F%.C%. %[%[", "[[")
	lab = mw.ustring.gsub(lab, " S%.A%. %[%[", "[[")

	--mw.log('"' .. lab .. '"')
	return lab
end

local function template1(start1, finish1, s, amatch, goal, P1642)
	if not value_valid(s) then
		return ""
	end
	if not value_valid(start1) and not value_valid(finish1) then
		return ""
	end
	local rows = mw.html.create("tr")
		:attr("colspan", 5)
		:css('font-size', '90%')

	local years = (start1 or "") .. "–" .. (finish1 or "")
	rows:tag("td")
		:css('background-color', '#F3F3F3')
		:tag("span"):addClass("nowrap"):wikitext(years)

	local name = s

	-- mw.log(#name)

	if value_valid(P1642) then
		name = "← " .. name .. " (" .. P1642 .. ")"
	end
	if #name > 70 then
		rows:tag("td"):tag("span"):addClass("nowrap"):wikitext(name)
	else
		rows:tag("td"):tag("span"):wikitext(name)
	end

	rows:tag("td"):tag("span"):addClass("nowrap"):wikitext(amatch or "")

	local goals = goal
	if value_valid(amatch) then
		goals = "(" .. mw.text.trim(goal) .. ")"
	end

	rows:tag("td"):tag("span"):addClass("nowrap"):wikitext(goals or "-")
	return tostring(rows)
end

local function get_type(entit)
	local tt = "o"
	local fii = formatStatements({
		property = "P31",
		entityId = entit,
		noref = "true",
		-- rank = "all",
		firstvalue = "true",
		separator = "",
		conjunction = "",
		formatting = "raw"
	})
	for k, id in pairs(teams_id) do
		if fii == id then
			return "team"
		end
	end
	for k, Qid in pairs(national_id) do
		if fii == Qid then
			return "national"
		end
	end
	--[[
	for k, Qid in pairs(youth_ids) do
		if fii == Qid then
			return "youth"
		end
	end
	]]
	return tt
end

local function get_countryID(entit)
	local countryID = formatStatements({
		property = "P1532",
		entityId = entit,
		noref = "true",
		rank = "all", --,pattern =options.pattern
		--,size ='20',image ='image' ,propertyimage ='P41'
		formatting = "raw",
		firstvalue = "true",
		separator = "",
		conjunction = ""
	})
	if not value_valid(countryID) then
		countryID = formatStatements({
			property = "P17",
			entityId = entit,
			noref = "true",
			rank = "all", --,pattern =options.pattern
			--,size ='20',image ='image'	,propertyimage ='P41'
			formatting = "raw",
			firstvalue = "true",
			separator = "",
			conjunction = ""
		})
	end
	return countryID
end

function p.football(statement, options)
	if not statement or not statement.type or statement.type ~= "statement" or statement.mainsnak.snaktype ~= "value" then
		return nil
	end

	local value = statement.mainsnak.datavalue.value
	local entit = value.id
	local s = formatSnak(statement.mainsnak, options).value
	local type_ = get_type(entit)

	if not value_valid(s) or not value_valid(type_) then
		return nil
	end

	local countryID = get_countryID(entit)

	local Flag = get_flag(countryID, nil)
	local label = formatEntityId(entit, options).value

	label = format_label(label)

	if value_valid(label) then
		if value_valid(Flag) then
			s = Flag .. " " .. label
		else
			s = label
		end
	end

	if statement.references then
		if value_valid(options.reff) then
			s = s .. formatReferences(statement, options)
		end
	end

	local amatch, goal, start1, finish1, P1642
	if statement.qualifiers then
		if
			statement.qualifiers.P1350 or statement.qualifiers.P1351 or statement.qualifiers.P580 or
			statement.qualifiers.P582
		then
			amatch = formatStatements({ property = "P1350", firstvalue = "true" }, statement.qualifiers)
			goal = formatStatements({ property = "P1351", firstvalue = "true", formatting = "raw" }, statement
				.qualifiers)
			start1 = formatStatements(
				{ property = "P580", firstvalue = "true", modifytime = "y" }, statement.qualifiers)
			finish1 = formatStatements(
				{ property = "P582", firstvalue = "true", modifytime = "y" }, statement.qualifiers)
			P1642 = formatStatements({ property = "P1642", firstvalue = "true", modifytime = "y" }, statement.qualifiers)
		end
	end
	s = template1(start1, finish1, s, amatch, goal, P1642)
	return { value = s, Type = type_ }
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

local function make_table(result)
	return "<td colspan='5'><table width=100% text-size=90%>" .. result .. "</table>"
end

function p.foot(claims, options)
	local qid = value_valid(options.entityId) or mw.wikibase.getEntityIdForCurrentPage()
	local icon = track({
		property = "P54",
		id = qid,
		category = i18n.category_tracking
	}) .. "&nbsp;"
	local Nationals = {}
	local Youths = {}
	local Other = {}
	local Teams = {}
	--table.insert( Other, make_sub_title('-') )
	--table.insert( Teams, make_sub_title('المسيرة الاحترافية') )
	--table.insert( Nationals , make_sub_title('المنتخب الوطني') )
	--==========================================
	for i, statement in pairs(claims) do
		local stat = p.football(statement, options)
		if stat then
			local s_value = stat.value
			local Type = stat.Type
			if value_valid(s_value) then
				if Type == "team" then
					table.insert(Teams, s_value)
				elseif Type == "national" then
					table.insert(Nationals, s_value)
				elseif Type == "youth" then
					table.insert(Youths, s_value)
				else
					table.insert(Other, s_value)
				end
			end
		end
	end

	local fs = {}
	local head = mw.html.create("tr")
	head:attr("colspan", 5)
	head:tag("td"):wikitext("'''" .. i18n.years .. "'''")
	head:tag("td"):wikitext("'''" .. i18n.team .. "'''")
	head:tag("td"):wikitext("'''" .. i18n.matches .. "'''")
	head:tag("td"):wikitext("'''" .. i18n.goals .. "'''")
	local head_done = false

	if #Other > 0 then
		table.insert(fs, make_sub_title(i18n.teams .. icon))
		if not head_done then
			head_done = true
			table.insert(fs, tostring(head))
		end
		table.insert(fs, mw.text.listToText(Other, options.separator, options.conjunction))
	end

	if #Youths > 0 then
		table.insert(fs, make_sub_title(i18n.youth .. icon))
		if not head_done then
			head_done = true
			table.insert(fs, tostring(head))
		end
		table.insert(fs, mw.text.listToText(Youths, options.separator, options.conjunction))
	end

	if #Teams > 0 then
		local subtitle = make_sub_title(i18n.professional_career .. icon)
		table.insert(fs, subtitle)
		if not head_done then
			head_done = true
			table.insert(fs, tostring(head))
		end
		local Teams_tot = mw.text.listToText(Teams, options.separator, options.conjunction)
		table.insert(fs, Teams_tot)
	end

	if #Nationals > 0 then
		table.insert(fs, make_sub_title(i18n.national_team .. icon))
		if not head_done then
			head_done = true
			table.insert(fs, tostring(head))
		end
		local Nationals_tot = mw.text.listToText(Nationals, options.separator, options.conjunction)
		table.insert(fs, Nationals_tot)
	end

	if #fs > 0 then
		local edit_at_wd = create_edit_at_wd(qid)
		table.insert(fs, edit_at_wd)
		local result = table.concat(fs)
		return make_table(result)
	end
	return ""
end

return p
