local p = {}

local function valid_v(x)
	if x and x ~= nil and x ~= "" then return x end
	return nil
end

function p.awards(datavalue, datatype, options) -- used by template:ص.م/سطر جوائز ويكي بيانات
	if datatype ~= 'wikibase-item'
	then
		return ''
	end
	local value = datavalue.value
	local image = formatStatements({
		pid = 'P2425',
		qid = value.id,
		size = '30',
		image = 'yes',
		noref = 'true',
		firstvalue =
		'true'
	})
	local categoryid = formatStatements({
		pid = 'P2517',
		qid = value.id,
		noref = 'true',
		firstvalue = 'true',
		formatting =
		'raw'
	})
	--[[
	if not valid_v(categoryid) then
		categoryid = formatStatements({ pid = 'P910', qid = value.id, noref = 'true', firstvalue = 'true', formatting = 'raw' })
	end
	if not valid_v(image) then
		image = formatStatements({ pid = 'P154', qid = value.id, size = '30', image = 'yes', noref = 'true', firstvalue = 'true' })
	end
	]]
	local category = valid_v(categoryid) and mw.wikibase.sitelink(categoryid) or false
	local s = formatEntityId(value.id, options).value
	if valid_v(s) then
		if valid_v(image) then
			s = image .. ' ' .. s
		end
		if valid_v(category) then
			s = s .. ' [[' .. category .. ']]'
		end
	end
	return s
end

return p
