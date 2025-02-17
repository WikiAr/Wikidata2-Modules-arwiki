local p = {}
local sandbox = "ملعب"
local sandbox_added = ""
if nil ~= string.find(mw.getCurrentFrame():getTitle(), sandbox, 1, true) then
	sandbox_added = "/" .. sandbox
end
local config = mw.loadData('Module:Wikidata2/config' .. sandbox_added)
local i18n = config.i18n

local to_skip = config.skip_items["P106"] or {}

local function formatGenderLabelForEntityId(jobqid, isFemale, options)
	local joblabel = formatStatements({
		property = 'P2521',
		entityId = jobqid,
		noref = 'true',
		langpref = i18n.local_lang,
		formatting = 'text',
		rank = "all"
	}) or ""
	local vv = formatEntityId(jobqid, options)
	if isFemale and (isFemale == 'Q6581072' or isFemale == 'Q1052281') then
		vv = formatEntityId(jobqid, { female_label = joblabel })
	end
	return vv
end

function p.formatEntityWithGenderClaim(datavalue, datatype, options)
	-- local value = datavalue.value
	local jobqid = datavalue.value.id

	for k, v in pairs(to_skip) do
		if jobqid == v then
			mw.log("P106:" .. jobqid .. " undisplayed.")
			return ""
		end
	end

	local personqid = options.entityId or options.qid
	local gender = formatStatements({
		property = 'P21',
		entityId = personqid,
		noref = 't',
		rank = 'all',
		firstvalue = 't',
		formatting = 'raw'
	})
	local s = formatGenderLabelForEntityId(jobqid, gender, options).value
	return s
end

return p
