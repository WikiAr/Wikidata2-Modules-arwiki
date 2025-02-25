local p = {}
local lang_module = require("وحدة:لغات")

-- Configuration
local config = {
    i18n = {
        no = "لا",
        the_word = "ال",
        local_lang_code = "ar",
        local_lang_name = "العربية",
        full_temp_format = "([[اللغة %s|ب%s]]: %s)"
    },
    unsupported_langs = { "mis", "mul", "zxx" }
}

-- Utility Functions
local function is_valid(x)
    if x and x ~= nil and x ~= "" and x ~= config.i18n.no then return x end
    return nil
end

-- Template Generators
local function full_template(lang_code, text)
    local resolved_lang_name = lang_module.lang_name({ args = { lang_code, config.i18n.the_word } })

    local temp_text = lang_module.lang_code_temp({ args = { lang_code, text } })

    local template = string.format(config.i18n.full_temp_format,
        resolved_lang_name,
        resolved_lang_name,
        temp_text
    )

    mw.log(template)
    return template
end

local function short_template(lang_code, text)
    return lang_module.lang_code_temp({ args = { lang_code, text } })
end

-- Template Type Resolver
local function resolve_template_type(lang_code, text, options, is_same_lang)
    local text_format = is_valid(options.textformat) or is_valid(options.formatting)

    if (lang_code == options.langpref and text_format == "text") or is_same_lang then
        return text
    elseif is_valid(options.showlang) then
        return full_template(lang_code, text)
    end
    return short_template(lang_code, text)
end

-- Main Logic
function p._main(datavalue, datatype, options)
    local lang_code, text = datavalue.value.language, datavalue.value.text
    local lang_name = mw.language.fetchLanguageName(lang_code, config.i18n.local_lang_code)

    -- Check for unsupported languages
    if table.concat(config.unsupported_langs, " "):find(lang_code) then
        return text
    end

    if is_valid(options.nolang) == lang_code then
        return ""
    end

    local is_same_lang = lang_name == config.i18n.local_lang_name or lang_code == config.i18n.local_lang_code

    -- Handle language preferences
    if is_valid(options.langpref) then
        local result = ""
        local pref = options.langpref
        if pref == "justlang" then
            result = lang_name
        elseif pref == "langcode" then
            result = lang_code
        elseif lang_code == pref then
            result = resolve_template_type(lang_code, text, options, is_same_lang)
        end
        return result
    end

    return resolve_template_type(lang_code, text, options, is_same_lang)
end

-- Frame Interface
function p.main(frame) -- Testing function
    local datavalue = {
        value = {
            language = frame.args.language,
            text = frame.args.text
        }
    }
    return p._main(datavalue, frame.args.datatype, frame.args)
end

return p
