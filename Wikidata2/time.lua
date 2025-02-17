local p = {}

local wiki = {
	langcode = mw.language.getContentLanguage().code
}

local i18n = {
	precisions     = {
		billion_year         = 0,
		hundred_million_year = 1,
		x10_million_year     = 2,
		million_year         = 3,
		x100_000_year        = 4,
		x10_000_year         = 5,
		millennium           = 6,
		century              = 7,
		decade               = 8,
		year                 = 9,
		month                = 10,
		day                  = 11,
		hour                 = 12,
		minute               = 13,
		second               = 14
	},
	datetime       = {
		-- $1 is a placeholder for the actual number
		[0]  = "$1 مليار سنة", --a الدقة:مليار سنة
		[1]  = "$100 مليون سنة", --a الدقة: مئات من ملايين السنين
		[2]  = "$10 مليون سنة", --a الدقة: عشرة ملايين سنة
		[3]  = "$1 مليون سنة", --a الدقة: مليون سنة
		[4]  = "$100,000 سنة", --a الدقة: مئات آلاف السنين
		[5]  = "$10,000 سنة", --a الدقة: عشرة آلاف سنة
		[6]  = "$1 ألفية", --a الدقة: ألفية
		[7]  = "القرن $1", --a الدقة: قرن
		[8]  = "العقد $1", --a الدقة: عقد
		-- the following use the format of #time parser function
		[9]  = "Y", -- الدقة: سنة,
		[10] = "F Y", -- الدقة: شهر
		[11] = "j F Y", -- الدقة: يوم
		[12] = "j F Y ga", -- الدقة: ساعة
		[13] = "j F Y g:ia", -- الدقة: دقائق
		[14] = "j F Y g:i:sa", -- الدقة: ثواني
	},
	format         = { -- options of the 3rd argument
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
	},
	ordinal        = {
		[1] = "", --st
		[2] = "", --nd
		[3] = "", --rd
		default = "" --th
	},
	beforenow      = "$1 ق.م", -- how to format negative numbers for precisions 0 to 5
	afternow       = "$1", -- how to format positive numbers for precisions 0 to 5

	bc             = '$1 "ق.م"', -- كيف طباعة السنوات السلبية
	ad             = "$1", -- كيف طباعة سنوات الإيجابية

	-- the following are for function getDateValue()

	default_format = "dmy", -- القيمة الافتراضية ل #3 (getDateValue)
	default_addon  = "ق.م", -- default value of the #4 (getDateValue)
	prefix_addon   = false, -- set to true for languages put "BC" in front of the
	-- datetime string; or the addon will be suffixed
	addon_sep      = " ", -- separator between datetime string and addon (or inverse)
}

local function isvalid(x)
	if x and x ~= nil and x ~= "" then return x end
	return nil
end

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
	local prefix_addon = i18n.prefix_addon
	local addon_sep = i18n.addon_sep
	local addon = ""

	-- check for negative date
	if string.sub(timestamp, 1, 1) == '-' then
		timestamp = '+' .. string.sub(timestamp, 2)
		addon = date_addon
	end
	-- get the next four characters after the + (should be the year now in all cases)
	-- ok, so this is dirty, but let's get it working first
	local YEAR_START_INDEX = 2
	local YEAR_LENGTH = 4
	local intyear = tonumber(string.sub(timestamp, YEAR_START_INDEX, YEAR_START_INDEX + YEAR_LENGTH - 1))
	if intyear == 0 and precision <= i18n.precisions.year then
		return ""
	end

	-- precision is 10000 years or more
	if precision <= i18n.precisions.x10_000_year then
		local factor = 10 ^ ((i18n.precisions.x10_000_year - precision) + 4)
		local y2 = math.ceil(math.abs(intyear) / factor)
		if precision == 2 then y2 = intyear / 10 end
		if precision == 3 then y2 = intyear / 100 end
		local relative = mw.ustring.gsub(i18n.datetime[precision], "$1", tostring(y2))
		--mw.log("وحدة:Wikidata2/time:" .. i18n.datetime[precision] .. " timestamp: " .. timestamp  .. " intyear: " .. intyear )
		if addon ~= "" then
			-- negative date
			relative = mw.ustring.gsub(i18n.beforenow, "$1", relative)
		else
			relative = mw.ustring.gsub(i18n.afternow, "$1", relative)
		end
		return relative
	end

	-- precision is decades (8), centuries (7) and millennia (6)
	local era, card
	if precision == i18n.precisions.millennium then
		card = math.floor((intyear - 1) / 1000) + 1
		era = mw.ustring.gsub(i18n.datetime[i18n.precisions.millennium], "$1", makeOrdinal(card))
	end
	if precision == i18n.precisions.century then
		card = math.floor((intyear - 1) / 100) + 1
		era = mw.ustring.gsub(i18n.datetime[i18n.precisions.century], "$1", makeOrdinal(card))
	end
	if precision == i18n.precisions.decade then
		era = mw.ustring.gsub(i18n.datetime[i18n.precisions.decade], "$1",
			tostring(math.floor(math.abs(intyear) / 10) * 10))
	end
	if era then
		if addon ~= "" then
			era = mw.ustring.gsub(mw.ustring.gsub(i18n.bc, '"', ""), "$1", era)
		else
			era = mw.ustring.gsub(mw.ustring.gsub(i18n.ad, '"', ""), "$1", era)
		end
		return era
	end

	local _date_format = i18n.format[date_format]
	if _date_format ~= nil then
		-- check for precision is year and override supplied date_format
		if precision == i18n.precisions.year then
			_date_format = i18n.datetime[i18n.precisions.year]
		end
		if precision == i18n.precisions.month and date_format ~= "y" then
			_date_format = i18n.datetime[i18n.precisions.month]
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
	if not time1 or not time1.time or not time1.precision then
		return ""
	end

	local formatd
	if isvalid(options.modifytime)
	then
		formatd = options.modifytime
	else
		formatd = i18n.default_format
	end
	local date_format = mw.text.trim(formatd)
	local timestamp = time1.time
	if time1.precision > i18n.precisions.x10_000_year then
		timestamp = mw.ustring.gsub(timestamp, '%-00%-', '-01-')
	end
	if time1.precision == i18n.precisions.year or time1.precision == i18n.precisions.month then
		timestamp = mw.ustring.gsub(timestamp, '%-00T', '-01T')
	end

	local date_addon = mw.text.trim(options.date_addon or i18n.default_addon)
	local tid = parseDateFull(timestamp, time1.precision, date_format, date_addon)
	return tid
end

return p
