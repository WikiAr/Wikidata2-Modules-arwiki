-- This module implements [[قالب:تصنيف كائن/تصنيف علمي ويكي بيانات]].

local p = {}

local data = require("Module:Wikidata2 sub modules/tax/cash")
local Cash = data.Cash
local colors = data.colors
local taxP105 = data.taxP105
local Cash2 = {}

local function isvalid(x)
	if x and x ~= nil and x ~= "" then return x end
	return nil
end

local function add_Tracking_Category(prop, options)
	return prop .. addTrackingCategory(options)
end

local function FindInCash(id, prop)
	local ca = Cash[id]
	if ca and ca[prop] and ca[prop] ~= "" then
		--mw.log(id .. " : " .. prop .. " : " .. ca[prop])
		return ca[prop]
	end
	return nil
end

local function foo(iid, formatting, p)
	if not isvalid(iid) then
		return nil
	end

	local so = nil
	local st = formatStatements({
		property = p,
		entityId = iid,
		enlabelcate = "t",
		noref = "t",
		firstvalue = "true",
		formatting = formatting
	})

	if isvalid(st) then
		so = st
	end

	return so
end

local function GetP171id(id)
	if not isvalid(id) then
		return nil
	end

	if not Cash2[id] then
		Cash2[id] = {}
	end

	local P171id = FindInCash(id, "P171")
	if not P171id then
		P171id = formatStatements({
			property = "P171",
			entityId = id,
			rank = "best",
			noref = "t",
			firstvalue = "true",
			formatting = "raw"
		})
		if isvalid(P171id) then
			Cash2[id]["P171"] = P171id
		end
	end
	return P171id
end

local function taxcolours2(id, options)
	local i = 0
	local ccc = ""
	while ccc == "" and i < 30 do
		local e = foo(id, "raw", "P105")
		if isvalid(e) then
			if e == "Q36732" then
				ccc = colors[id] or ""
			end
		end
		id = GetP171id(id)
		i = i + 1
	end

	if ccc == "" and options.colour and options.colour ~= "" then
		ccc = options.colour
	end

	return ccc
end

local function taxonrank(iid)
	local vvv = nil
	if not isvalid(iid) then
		return nil
	end

	local rank_raw = FindInCash(iid, "P105")
	if not rank_raw then
		rank_raw = formatStatements({
			property = "P105",
			entityId = iid,
			enlabelcate = "t",
			noref = "t",
			firstvalue = "true",
			formatting = "raw"
		})

		if not Cash2[iid] then
			Cash2[iid] = {}
		end
		Cash2[iid]["P105"] = rank_raw
	end

	if not isvalid(rank_raw) then
		return nil
	end

	if isvalid(taxP105[rank_raw]) then
		vvv = add_Tracking_Category(taxP105[rank_raw], { property = "P105", entityId = iid, noicon = "t" })
	else
		local rank_lab = formatStatements({
			property = "P105",
			entityId = iid,
			enlabelcate = "t",
			noref = "t",
			firstvalue = "true",
			formatting = ""
		})

		if isvalid(rank_lab) then
			mw.log("Module:Wikidata2 sub modules/tax: taxP105['" .. rank_raw .. "'] = '" .. rank_lab .. "'")
			vvv = add_Tracking_Category(rank_lab .. "", { property = "P105", entityId = iid, noicon = "t" })
		end
	end

	return vvv
end

local function pro1(id)
	if not isvalid(id) then
		return nil
	end

	local label
	local id_r = formatStatements({
		property = "P171",
		entityId = id,
		enlabelcate = "t",
		noref = "t",
		firstvalue = "true",
		formatting = "raw"
	}) or ""


	if isvalid(id_r) then
		label = FindInCash(id_r, "label")
		if not label then
			label = formatStatements({
				property = "P171",
				entityId = id,
				enlabelcate = "t",
				noref = "e",
				firstvalue = "true"
			})

			if not Cash2[id_r] then
				Cash2[id_r] = {}
			end
			if isvalid(label) then
				Cash2[id_r]["label"] = label
			end
		end
	end

	return label
end

local function dd(id, taxo_id)
	-- taxolabel : الكائن
	-- d : المرتبة التصنيفية
	if isvalid(id) then
		local taxolabel = pro1(taxo_id)
		local d = taxonrank(id) -- المرتبة التصنيفية

		if not isvalid(d) then
			--d = foo( id , '' , 'P31' )
			--mw.log( "Module:Wikidata2 sub modules/tax: foo[" .. id .. "] = " .. d)
			return nil
		end

		if isvalid(taxolabel) then
			if isvalid(d) then
				return d .. "||" .. taxolabel
			else
				return taxolabel
			end
		end
	end
end

local function dd_old(id, taxolabel)
	-- taxolabel : الكائن
	-- d : المرتبة التصنيفية
	if isvalid(id) then
		local d = taxonrank(id) -- المرتبة التصنيفية

		if not isvalid(d) then
			return nil --'' -- nil
		end

		if isvalid(taxolabel) then
			if isvalid(d) then
				return d .. "||" .. taxolabel
			else
				return taxolabel
			end
		end
	end
end

local function gettax(value_id, coo, lll, options)
	local P = {}
	local id_1 = value_id or ""

	-- mw.log("id_1: " .. id_1)
	P[0] = dd_old(value_id, lll)

	for number = 1, 35 do
		local s_id = GetP171id(id_1)
		P[number] = dd(s_id, id_1)
		id_1 = s_id
	end

	for k, v in pairs(Cash2) do
		if isvalid(v["P171"]) and v["P105"] and v["P105"] ~= "" then
			mw.log(
				string.format(
					"Module:Wikidata2 sub modules/tax: Cash['%s'] = {['P105'] = '%s', ['P171'] = '%s', ['label'] = '%s'}",
					k,
					v["P105"] or "",
					v["P171"] or "",
					v["label"] or ""
				)
			)
		end
	end

	local ti = "[[التصنيف العلمي]]"
	local title =
		string.format(
			'colspan="2" style="text-align: center;background-color:%s;" | %s',
			coo,
			add_Tracking_Category(ti, options)
		)
	local head = '{| class="infobox biota" style="text-align: right; width: 200px; font-size: 100%%"'
	local End = "}"

	local taxon1 = {}
	for i = 35, 0, -1 do
		table.insert(taxon1, P[i] or "")
	end

	local q = { title }
	for _, j in ipairs(taxon1) do
		if j ~= "" then
			table.insert(q, j)
		end
	end

	local taxonSections = table.concat(q, "\n|-\n|")
	local result = string.format([[%s\n|-\n!%s\n|-\n|%s\n%s]], head, title, taxonSections, End)

	return taxonSections --result
end

function p.tax(datavalue, datatype, options)
	local value_id = datavalue.value.id
	local colour = taxcolours2(value_id, options)
	local lll = formatEntityId(value_id, options).value
	return gettax(value_id, colour, lll, options)
end

function p.taxcolour(datavalue, datatype, options)
	return taxcolours2(datavalue.value.id, options)
end

function p.gg(frame)
	local value_id = frame.args[1]
	local colour = "#ffffff" -- default color
	local lll = "test"    -- default value for lll
	return gettax(value_id, colour, lll, frame.args)
end

return p
