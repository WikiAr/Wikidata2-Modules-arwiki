local p = {}
------------------------------------------------------------------------------
-- module local variables and functions

local wiki =
{
	langcode = mw.language.getContentLanguage().code
}

-- internationalisation
local i18n =
{
	["datetime"] =
	{
		-- $1 is a placeholder for the actual number
		[0]                = "$1 مليار سنة", --a الدقة:مليار سنة
		[1]                = "$100 مليون سنة", --a الدقة: مئات من ملايين السنين
		[2]                = "$10 مليون سنة", --a الدقة: عشرة ملايين سنة
		[3]                = "$1 مليون سنة", --a الدقة: مليون سنة
		[4]                = "$100,000 سنة", --a الدقة: مئات آلاف السنين
		[5]                = "$10,000 سنة", --a الدقة: عشرة آلاف سنة
		[6]                = "$1 ألفية", --a الدقة: ألفية
		[7]                = "القرن $1", --a الدقة: قرن
		[8]                = "العقد $1", --a الدقة: عقد
		-- the following use the format of #time parser function
		[9]                = "Y", -- الدقة: سنة,
		[10]               = "F Y", -- الدقة: شهر
		[11]               = "j F Y", -- الدقة: يوم
		[12]               = "j F Y ga", -- الدقة: ساعة
		[13]               = "j F Y g:ia", -- الدقة: دقائق
		[14]               = "j F Y g:i:sa", -- الدقة: ثواني
		["beforenow"]      = "$1 ق.م", -- how to format negative numbers for precisions 0 to 5
		["afternow"]       = "$1", -- how to format positive numbers for precisions 0 to 5
		["bc"]             = '$1 "ق.م"', -- كيف طباعة السنوات السلبية
		["ad"]             = "$1", -- كيف طباعة سنوات الإيجابية
		-- the following are for function getDateValue()
		["default-format"] = "dmy", -- القيمة الافتراضية ل #3 (getDateValue)
		["default-addon"]  = "ق.م", -- default value of the #4 (getDateValue)
		["prefix-addon"]   = false, -- set to true for languages put "BC" in front of the
		-- datetime string; or the addon will be suffixed
		["addon-sep"]      = " ", -- separator between datetime string and addon (or inverse)
		["format"]         = -- options of the 3rd argument
		{
			["j F Y"] = "j F Y",
			["dmy"] = "j F Y",
			["dmY"] = "dmY",
			["j F"] = "j F",
			["longdate"] = "j F Y",
			["my"] = "F Y",
			["y"] = "Y",
			["Y"] = "Y",
			["F"] = "F",
			["n"] = "n",
			["m"] = "F",
			["j"] = "j",
			["d"] = "j",
			["ymd"] = "Y-m-d",
			["ym"] = "Y-m"
		}
	},
	["ordinal"] =
	{
		[1] = "",  --st
		[2] = "",  --nd
		[3] = "",  --rd
		["default"] = "" --th
	}
}
-- this function needs to be internationalised along with the above:
-- we need three exceptions in English for 1st, 2nd, 3rd
-- takes cardinal numer as a numeric and returns the ordinal as a string
local function makeOrdinal(cardinal)
	local ordsuffix = i18n.ordinal.default
	if cardinal % 10 == 1 then
		ordsuffix = i18n.ordinal[1]
	elseif cardinal % 10 == 2 then
		ordsuffix = i18n.ordinal[2]
	elseif cardinal % 10 == 3 then
		ordsuffix = i18n.ordinal[3]
	end
	return tostring(cardinal) .. ordsuffix
end

local function parseDateFull(timestamp, precision, date_format, date_addon)
	local prefix_addon = i18n["datetime"]["prefix-addon"]
	local addon_sep = i18n["datetime"]["addon-sep"]
	local addon = ""

	-- check for negative date
	if string.sub(timestamp, 1, 1) == '-' then
		timestamp = '+' .. string.sub(timestamp, 2)
		addon = date_addon
	end
	-- get the next four characters after the + (should be the year now in all cases)
	-- ok, so this is dirty, but let's get it working first
	local intyear = tonumber(string.sub(timestamp, 2, 5))
	if intyear == 0 and precision <= 9 then
		return ""
	end

	-- precision is 10000 years or more
	if precision <= 5 then
		local factor = 10 ^ ((5 - precision) + 4)
		local y2 = math.ceil(math.abs(intyear) / factor)
		if precision == 2 then y2 = intyear / 10 end
		if precision == 3 then y2 = intyear / 100 end
		local relative = mw.ustring.gsub(i18n.datetime[precision], "$1", tostring(y2))
		--mw.log("وحدة:Wikidata2/time:" .. i18n.datetime[precision] .. " timestamp: " .. timestamp  .. " intyear: " .. intyear )
		if addon ~= "" then
			-- negative date
			relative = mw.ustring.gsub(i18n.datetime.beforenow, "$1", relative)
		else
			relative = mw.ustring.gsub(i18n.datetime.afternow, "$1", relative)
		end
		return relative
	end

	-- precision is decades (8), centuries (7) and millennia (6)
	local era, card
	if precision == 6 then
		card = math.floor((intyear - 1) / 1000) + 1
		era = mw.ustring.gsub(i18n.datetime[6], "$1", makeOrdinal(card))
	end
	if precision == 7 then
		card = math.floor((intyear - 1) / 100) + 1
		era = mw.ustring.gsub(i18n.datetime[7], "$1", makeOrdinal(card))
	end
	if precision == 8 then
		era = mw.ustring.gsub(i18n.datetime[8], "$1", tostring(math.floor(math.abs(intyear) / 10) * 10))
	end
	if era then
		if addon ~= "" then
			era = mw.ustring.gsub(mw.ustring.gsub(i18n.datetime.bc, '"', ""), "$1", era)
		else
			era = mw.ustring.gsub(mw.ustring.gsub(i18n.datetime.ad, '"', ""), "$1", era)
		end
		return era
	end

	local _date_format = i18n["datetime"]["format"][date_format]
	if _date_format ~= nil then
		-- check for precision is year and override supplied date_format
		if precision == 9 then
			_date_format = i18n["datetime"][9]
		end
		if precision == 10 and date_format ~= "y" then
			_date_format = i18n["datetime"][10]
		end
		local year_suffix
		local tstr = ""
		local lang_obj = mw.language.new(wiki.langcode)
		local f_parts = mw.text.split(_date_format, 'Y', true)
		for idx, f_part in pairs(f_parts) do
			year_suffix = ''
			if string.match(f_part, "x[mijkot]$") then
				-- for non-Gregorian year
				f_part = f_part .. 'Y'
			elseif idx < #f_parts then
				-- supress leading zeros in year
				year_suffix = lang_obj:formatDate('Y', timestamp)
				year_suffix = string.gsub(year_suffix, '^0+', '', 1)
			end
			tstr = tstr .. lang_obj:formatDate(f_part, timestamp) .. year_suffix
		end
		local fdate
		if addon ~= "" and prefix_addon then
			fdate = addon .. addon_sep .. tstr
		elseif addon ~= "" then
			fdate = tstr .. addon_sep .. addon
		else
			fdate = tstr
		end

		--mw.log("وحدة:Wikidata2/time:" .. timestamp .. " precision: " .. precision .. " fdate: " .. fdate )
		return fdate
	else
		return '<span class="error">unknown-datetime-format</span>'
	end
end

function p.getdate(time1, options)
	local formatd
	if options.modifytime and options.modifytime ~= ""
	then
		formatd = options.modifytime
	else
		formatd = i18n["datetime"]["default-format"]
	end
	local date_format = mw.text.trim(formatd)
	local timestamp = time1.time
	local dateprecision = time1.precision
	if dateprecision > 5 then
		timestamp = mw.ustring.gsub(timestamp, '%-00%-', '-01-')
	end
	if dateprecision == 9 or dateprecision == 10 then
		timestamp = mw.ustring.gsub(timestamp, '%-00T', '-01T')
	end

	local date_addon = mw.text.trim(options.date_addon or i18n["datetime"]["default-addon"])
	local tid = parseDateFull(timestamp, dateprecision, date_format, date_addon)
	return tid
end

return p
