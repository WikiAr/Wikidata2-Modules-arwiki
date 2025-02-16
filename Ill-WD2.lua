local p = {}

local function is_valid(x)
	if x and x ~= "" then return x end
	return nil
end

function p.Ill_WD2_label(qid, arlabel, options)
	local temp_args = { fromlua = "t", ["المعرف"] = qid, nocat = "t" }

	local en_label = mw.wikibase.label(qid) or ""
	if is_valid(options.illwd2noy) then temp_args.noy = "t" end
	if is_valid(options.illwd2y) then temp_args.y = "t" end
	if is_valid(arlabel) then temp_args.label = arlabel end

	if is_valid(en_label) and is_valid(options.illwd2noarlabel) then
		temp_args.enlabel = en_label
	end

	if is_valid(options.illwd2label) then
		temp_args.text = options.illwd2label
	end
	--local jlabel = mw.getCurrentFrame():expandTemplate { title = "Ill-WD2", args = temp_args }

	local wd2_module = require("Module:Ill-WD2").link_from_lua

	local jlabel = wd2_module(temp_args)

	return jlabel
end

return p
