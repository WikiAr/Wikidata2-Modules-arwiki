local p = {}
local ModuleGlobes = require("Module:Wikidata2/Globes")

function p.coordinates_wd2(datavalue, datatype, options)
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

	return pro
end

function p.coordinates(datavalue, datatype, options)
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
	if pro then return pro end

	local precision, unitsPerDegree, numDigits, strFormat, value
	local latitude, latConv, latValue, latLink
	local longitude, lonConv, lonValue, lonLink
	local latDirection, latDirectionEN
	local lonDirection, lonDirectionEN
	local degSymbol, minSymbol, secSymbol, separator

	local latDegrees = nil
	local latMinutes = nil
	local latSeconds = nil
	local lonDegrees = nil
	local lonMinutes = nil
	local lonSeconds = nil

	local latDegSym = ""
	local latMinSym = ""
	local latSecSym = ""
	local lonDegSym = ""
	local lonMinSym = ""
	local lonSecSym = ""

	local latDirectionN = "N"
	local latDirectionS = "S"
	local lonDirectionE = "E"
	local lonDirectionW = "W"
	local latDirectionEN_N = "N"
	local latDirectionEN_S = "S"
	local lonDirectionEN_E = "E"
	local lonDirectionEN_W = "W"
	degSymbol = "/"
	minSymbol = "/"
	secSymbol = "/"
	separator = "/"

	latitude = datavalue.value['latitude']
	longitude = datavalue.value['longitude']

	if latitude < 0 then
		latDirection = latDirectionS
		latDirectionEN = latDirectionEN_S
		latitude = math.abs(latitude)
	else
		latDirection = latDirectionN
		latDirectionEN = latDirectionEN_N
	end

	if longitude < 0 then
		lonDirection = lonDirectionW
		lonDirectionEN = lonDirectionEN_W
		longitude = math.abs(longitude)
	else
		lonDirection = lonDirectionE
		lonDirectionEN = lonDirectionEN_E
	end

	precision = datavalue.value['precision']

	if not precision or precision <= 0 then
		precision = 1 / 3600 -- precision not set (correctly), set to arcsecond
	end

	-- remove insignificant detail
	latitude = math.floor(latitude / precision + 0.5) * precision
	longitude = math.floor(longitude / precision + 0.5) * precision

	if precision >= 1 - (1 / 60) and precision < 1 then
		precision = 1
	elseif precision >= (1 / 60) - (1 / 3600) and precision < (1 / 60) then
		precision = 1 / 60
	end

	if precision >= 1 then
		unitsPerDegree = 1
	elseif precision >= (1 / 60) then
		unitsPerDegree = 60
	else
		unitsPerDegree = 3600
	end

	numDigits = math.ceil(-math.log10(unitsPerDegree * precision))

	if numDigits <= 0 then
		numDigits = tonumber("0") -- for some reason, 'numDigits = 0' may actually store '-0', so parse from string instead
	end

	strFormat = "%." .. numDigits .. "f"

	if precision >= 1 then
		latDegrees = strFormat:format(latitude)
		lonDegrees = strFormat:format(longitude)

		latDegSym = latDegrees .. degSymbol
		lonDegSym = lonDegrees .. degSymbol
	else
		latConv = math.floor(latitude * unitsPerDegree * 10 ^ numDigits + 0.5) / 10 ^ numDigits
		lonConv = math.floor(longitude * unitsPerDegree * 10 ^ numDigits + 0.5) / 10 ^ numDigits

		if precision >= (1 / 60) then
			latMinutes = latConv
			lonMinutes = lonConv
		else
			latSeconds = latConv
			lonSeconds = lonConv

			latMinutes = math.floor(latSeconds / 60)
			lonMinutes = math.floor(lonSeconds / 60)

			latSeconds = strFormat:format(latSeconds - (latMinutes * 60))
			lonSeconds = strFormat:format(lonSeconds - (lonMinutes * 60))

			latSecSym = latSeconds .. secSymbol
			lonSecSym = lonSeconds .. secSymbol
		end

		latDegrees = math.floor(latMinutes / 60)
		lonDegrees = math.floor(lonMinutes / 60)

		latDegSym = latDegrees .. degSymbol
		lonDegSym = lonDegrees .. degSymbol

		latMinutes = latMinutes - (latDegrees * 60)
		lonMinutes = lonMinutes - (lonDegrees * 60)

		if precision >= (1 / 60) then
			latMinutes = strFormat:format(latMinutes)
			lonMinutes = strFormat:format(lonMinutes)
		end
		latMinSym = latMinutes .. minSymbol
		lonMinSym = lonMinutes .. minSymbol
	end

	latValue = latDegSym .. latMinSym .. latSecSym .. latDirection
	lonValue = lonDegSym .. lonMinSym .. lonSecSym .. lonDirection

	value = latValue .. separator .. lonValue

	if globe then
		globe = ModuleGlobes[globe] or ""
	else
		globe = "earth"
	end

	latLink = table.concat({ latDegrees, latMinutes, latSeconds }, "_")
	lonLink = table.concat({ lonDegrees, lonMinutes, lonSeconds }, "_")

	value = "[https://geohack.toolforge.org/geohack.php?language=ar" ..
		"&params=" .. latLink .. "_" .. latDirectionEN ..
		"_" .. lonLink .. "_" .. lonDirectionEN .. "_globe:" .. globe .. " " .. value .. "]"

	return value .. catewikidatainfo(options)
end

return p
