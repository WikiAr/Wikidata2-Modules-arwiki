local p = {}

local sandbox = "ملعب"
local sandbox_added = ""
if nil ~= string.find(mw.getCurrentFrame():getTitle(), sandbox, 1, true) then
	sandbox_added = "/" .. sandbox
end
local config = mw.loadData('Module:Wikidata2/config' .. sandbox_added)

local function isvalid(x)
	if x and x ~= nil and x ~= "" and x ~= config.i18n.no then return x end
	return nil
end

function p.Subclass(options)
	local parent = options.parent or ""
	local id = isvalid(options.id) or mw.wikibase.getEntityIdForCurrentPage()

	local property = options.property or "P31"
	if not isvalid(parent) or not isvalid(id) or not isvalid(property) then
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
