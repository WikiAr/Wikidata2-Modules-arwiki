local p = {}

--[[
{{#invoke:Wikidata2
|formatStatements
|entityId={{{1|}}}
|property=P527
|rank=all
|value-module=Module:Wikidata2/cycling
|value-function=template_stages
|cy_type=1
|separator=
|conjunction=
}}
]]

function p.template_stages(datavalue, datatype, options)
	local item = datavalue.value.id
	local template = "Cycling race/stageclassification2"

	local cy_type = options.cy_type or options["cy_type"]

	return mw.getCurrentFrame():expandTemplate { title = template, args = { item, type = cy_type } }
end

return p
