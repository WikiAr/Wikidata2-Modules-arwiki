local p = {}
local lang_module = require("وحدة:لغات")

local config_title = 'Module:Wikidata2/config'
local sandbox = "ملعب"
if nil ~= string.find(mw.getCurrentFrame():getTitle(), sandbox, 1, true) then
    config_title = config_title .. "/" .. sandbox
end
local config = mw.loadData(config_title)

local function isvalid(value)
    return value and value ~= "" and value or nil
end

local function full_temp(lang_code, lang_name, text)
    -- local template = mw.getCurrentFrame():expandTemplate { title = "رمز لغة واسمها", args = { lang_code, "", text } }
    local lang_name = lang_module["اسم لغة"]({ args = { lang_code, "ال" } })

    local temp_text = lang_module["قالب رمز لغة"]({ args = { lang_code, text } })

    local template = string.format("([[اللغة %s|ب%s]]: %s)‏",
        lang_name,
        lang_name,
        temp_text
    )

    mw.log(template)
    return template
end

local function short_temp(lang_code, text)
    local template = lang_module["قالب رمز لغة"]({ args = { lang_code, text } })
    -- local template = mw.getCurrentFrame():expandTemplate { title = "رمز لغة", args = { lang_code, text } }
    return template
end

function p._main(datavalue, datatype, options)
    local lang_code = datavalue.value.language
    local text = datavalue.value.text
    local lang_name = mw.language.fetchLanguageName(lang_code, config.i18n.lang_code)

    if lang_code == "mis" or lang_code == "mul" then -- Unsupported language
        return text
    end

    local nolang = isvalid(options.nolang)

    if nolang == lang_code then
        return ""
    end
    local same_lang = lang_name == config.i18n.lang_name or lang_code == config.i18n.lang_code

    if isvalid(options.langpref) then
        if options.langpref == "justlang" then
            return lang_name
        elseif options.langpref == "langcode" then
            return lang_code
        elseif lang_code == options.langpref then
            if isvalid(options.textformat) == "text" or isvalid(options.formatting) == "text" or same_lang then
                return text
            elseif isvalid(options.showlang) then
                return full_temp(lang_code, lang_name, text)
            else
                return short_temp(lang_code, text)
            end
        end
    else
        if same_lang then
            return text
        elseif isvalid(options.showlang) then
            return full_temp(lang_code, lang_name, text)
        else
            return short_temp(lang_code, text)
        end
    end
    return ""
end

function p.main(frame)
    local datavalue = {
        value = {
            language = frame.args["language"],
            text = frame.args["text"]
        }
    }
    local datatype = frame.args["datatype"]
    local options = frame.args

    return p._main(datavalue, datatype, options)
end

return p
