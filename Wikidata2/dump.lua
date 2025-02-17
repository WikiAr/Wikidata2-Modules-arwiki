local p = {}

local config_title = 'Module:Wikidata2/config'
local sandbox = "ملعب"
if nil ~= string.find(mw.getCurrentFrame():getTitle(), sandbox, 1, true) then
	config_title = config_title .. "/" .. sandbox
end
local config = mw.loadData(config_title)


local function isvalid(x)
	if x and x ~= nil and x ~= "" and x ~= config.i18n.no then return x end
	return nil
end

local function isntvalid(x)
	if not x or x == nil or x == "" then return true end
	return false
end

local function getEntityFromId(id)
	return isvalid(id) and mw.wikibase.getEntity(id) or mw.wikibase.getEntity()
end

function p.Subclass(options)
	local parent = options.parent or ""
	local id = options.id or ""
	local Entity = getEntityFromId(id)
	if Entity then
		id = Entity.id
	end
	local property = options.property or "P31"
	if isntvalid(parent) or isntvalid(id) or isntvalid(property) then
		return false
	end
	local tab = mw.text.split(options.parent, ",")
	local result = mw.wikibase.getReferencedEntityId(id, property, tab) -- { "Q5", "Q2095" } )
	if result == nil and property == "P31" then
		result = mw.wikibase.getReferencedEntityId(id, "P279", tab)
	end
	if result then
		return true
	end
end

function p.isSubclass(frame)
	return p.Subclass(frame.args)
end

function p.ViewSomething(frame) -- from en:Module:Wikidata
	local MAX_ITERATIONS = 100  -- Prevent infinite loops
	local f_args = (frame.args[1] or frame.args.id) and frame or frame:getParent()
	local aa
	if isvalid(f_args.id) then
		aa = f_args.id
	end
	local data = mw.wikibase.getEntity(aa)
	if data == nil then
		return nil
	end
	local i = 1
	while i <= MAX_ITERATIONS do
		local index = f_args[i]
		if index == nil then
			if type(data) == "table" then
				return mw.text.jsonEncode(data, mw.text.JSON_PRESERVE_KEYS + mw.text.JSON_PRETTY)
			else
				return tostring(data)
			end
		end
		data = data[index] or data[tonumber(index)]
		if data == nil then
			return
		end
		i = i + 1
	end
end

function p.Dump(frame)
	local MAX_ITERATIONS = 100 -- Prevent infinite loops
	local warnDump = "[[" .. config.i18n.categories.dump_warn_category .. "]]"
	local f_args = (frame.args[1] or frame.args.id) and frame or frame:getParent()
	local aa
	if isvalid(f_args.id) then
		aa = f_args.id
	end
	local data = mw.wikibase.getEntity(aa)
	if data == nil then
		return warnDump
	end
	local i = 1
	while i <= MAX_ITERATIONS do
		local index = f_args[i]
		if index == nil then
			return frame:extensionTag("source", mw.dumpObject(data), { lang = "lua" }) .. warnDump
		end
		data = data[index] or data[tonumber(index)]
		if data == nil then
			return warnDump
		end
		i = i + 1
	end
end

return p
