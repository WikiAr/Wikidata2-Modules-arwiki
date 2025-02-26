local p = {}

p.typeOfKit = {
	["Q170494"] = "body",
	["Q223269"] = "shorts",
	["Q24206679"] = "right_arm",
	["Q3643394"] = "left_arm",
	["Q43663"] = "socks"
}

local function isvalid(x)
	if x and x ~= nil and x ~= "" then return x end
	return nil
end

local function get_snak_id(snak)
	if
		snak and snak.type and snak.type == "statement" and snak.mainsnak and snak.mainsnak.snaktype and
		snak.mainsnak.snaktype == "value" and
		snak.mainsnak.datavalue and
		snak.mainsnak.datavalue.type and
		snak.mainsnak.datavalue.type == "wikibase-entityid" and
		snak.mainsnak.datavalue.value and
		snak.mainsnak.datavalue.value.id
	then
		return snak.mainsnak.datavalue.value.id
	end
end

local function get_qualifiers_id(snak)
	if
		snak and snak[1] and snak[1].snaktype == "value" and snak[1].datavalue and
		snak[1].datavalue.type == "wikibase-entityid" and
		snak[1].datavalue.value and
		snak[1].datavalue.value.id
	then
		return snak[1].datavalue.value.id
	end
end

local function find_Kit_type(claims, id)
	local kitId = ""
	mw.log("Module:Wikidata2/P3828: id : " .. id)

	-- Loop through each claim
	for _, statement in pairs(claims) do
		local statementId = get_snak_id(statement)

		-- Check if the statement has qualifiers and the qualifier "P1013"
		if statement.qualifiers and statement.qualifiers["P1013"] then
			local id2 = get_qualifiers_id(statement.qualifiers["P1013"])

			-- If the id matches the given id, set the kitId to the statementId
			if id2 == id then
				kitId = statementId
			end
		end
	end

	-- Return the found kitId
	return kitId
end

local function getQualifierValue(qualifiers, key)
	if qualifiers[key] and qualifiers[key][1] and qualifiers[key][1].snaktype == "value" then
		return qualifiers[key][1].datavalue.value
	end
end

local function Get_image_color(statement)
	local result = { image = "", color = "" }

	if statement.qualifiers then
		result.image = getQualifierValue(statement.qualifiers, "P18") or ""
		result.color = getQualifierValue(statement.qualifiers, "P465") or ""
	end

	return result
end

local function find_team_Kit(claims, id, title, options)
	local kitClaims = {
		body = { image = "", color = "" },
		shorts = { image = "", color = "" },
		right_arm = { image = "", color = "" },
		left_arm = { image = "", color = "" },
		socks = { image = "", color = "" }
	}

	local kitId = find_Kit_type(claims, id)
	local property_claims = mw.wikibase.getBestStatements(kitId, "P527") or {}

	if not property_claims or #property_claims == 0 then
		return ""
	end

	for _, statement in pairs(property_claims) do
		local ssId = get_snak_id(statement)
		if p.typeOfKit[ssId] then
			ssId = p.typeOfKit[ssId]
		end
		kitClaims[ssId] = Get_image_color(statement)
	end

	local mainArgs = {
		qid = kitId,
		leftarm_color = kitClaims.left_arm.color or "",
		Kit_left_arm = kitClaims.left_arm.image or "",
		body_color = kitClaims.body.color or "",
		Kit_body = kitClaims.body.image or "",
		rightarm_color = kitClaims.right_arm.color or "",
		Kit_right_arm = kitClaims.right_arm.image or "",
		shorts_color = kitClaims.shorts.color or "",
		Kit_shorts = kitClaims.shorts.image or "",
		socks_color = kitClaims.socks.color or "",
		Kit_socks = kitClaims.socks.image or "",
		title = title
	}

	local s = mw.getCurrentFrame():expandTemplate { title = "طقم_كرة_قدم/ويكي بيانات/نواة", args =
		mainArgs }
	s = s .. addTrackingCategory(options)

	return s
end

function p.P3828(claims, options)
	options.noicon = "t"

	local Main_Table = {
		find_team_Kit(claims, "Q45321977", "الطقم الأساسي", options),
		find_team_Kit(claims, "Q45321990", "الطقم الاحتياطي", options),
		find_team_Kit(claims, "Q45322173", "الطقم الثالث", options)
	}

	return mw.text.listToText(Main_Table, "", "")
end

return p
