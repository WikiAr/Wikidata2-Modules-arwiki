local p = {}
local data = require("Module:لغات/بيانات")

local i18n = {
    scripts = {
        ["-latn"] = "لاتينية",
        ["-cyrl"] = "سيريلية",
        ["-arab"] = "عربية"
    },
    al_word = "ال",
    local_lang = "ar",
    local_lang_2 = "ara",
    lang_usage_cat = "تصنيف:مقالات تحوي نصا ب%s",
    list = {
        name = "اسم",
        link = "وصلة",
        template_result = "نتيجة القالب",
        redirects = "التحويلات",
        template_ISO_639_name = "اسم آيزو 639",
        lang_name_prefix = "لغة",
        lang_name_prefix_with_the = "اللغة"
    },
    ns_10_name = mw.site.namespaces[10].name
}

local function isValid(x)
    if x and x ~= "" then return x end
    return nil
end

local function addDefiniteArticle(name)
    if not name or name:match("^" .. i18n.al_word) then
        return name
    end
    return i18n.al_word .. name:gsub(" ", " " .. i18n.al_word)
end

local function remove_al_from_name(name)
    local name2 = name
    if name:match("^" .. i18n.al_word) then
        name2 = name2:gsub("^" .. i18n.al_word .. " ", "")
        name2 = name2:gsub(" " .. i18n.al_word, " ")
    end
    return name2
end

local function formatLanguageName(name, add_the, lang_code)
    if isValid(lang_code) then
        local name_with_all = data.lang_name_with_al[lang_code] or data.lang_name_with_al[lang_code:lower()]
        if name_with_all then
            return name_with_all
        end
    end
    if isValid(add_the) then
        return addDefiniteArticle(name)
    end
    return name
end

local function get_name_from_code(lang_code)
    if not isValid(lang_code) then return nil end
    local clean_code = lang_code:gsub("%s", ""):lower()
    return data.lang_name[clean_code] or data.lang_name_with_al[clean_code]
end

local function handleScriptVariant(lang_code, add_the, recursion_count)
    recursion_count = (recursion_count or 0) + 1
    if recursion_count > 3 then return nil end

    local code = lang_code:lower()
    local script_suffix = code:match(".-(%-%a+)$")
    if not script_suffix or not i18n.scripts[script_suffix] then
        return code
    end

    local base_code = code:gsub(script_suffix, "")
    local base_name = get_name_from_code(base_code)
    if not base_name then return code end

    local full_name = base_name .. " " .. i18n.scripts[script_suffix]
    return formatLanguageName(full_name, add_the, code)
end

local function getLanguageName(lang_code, add_the, recursion_count, return_nil_if_invalid)
    if not isValid(lang_code) then return "" end
    if lang_code:find("[|(]") then return lang_code end

    local clean_code = lang_code:gsub("%s", "")
    local name = get_name_from_code(clean_code)
    if name then
        return formatLanguageName(name, add_the, clean_code)
    end

    return handleScriptVariant(clean_code, add_the, recursion_count) or
        (return_nil_if_invalid and nil or clean_code)
end

local function has_name(name, names)
    for _, v in pairs(names) do
        if mw.ustring.find(name, v) ~= nil then
            -- mw.log(("!!has_name:(%s) name:(%s)"):format(v, name))
            return v
        end
    end
    return false
end

local function matchesName(target, names)
    for _, name in ipairs(names) do
        if target == name or target == addDefiniteArticle(name) then
            return true
        end
    end
    return false
end

local function get_code(l_code, v, local_name, name_without_al)
    if matchesName(local_name, { v.name }) then
        return l_code
    end

    if matchesName(local_name, { getLanguageName(l_code, "") }) then
        return l_code
    end

    if v.names then
        for _, alias in ipairs(v.names) do
            -- if name_without_al == alias or local_name == alias or local_name == addDefiniteArticle(alias, true) then
            if name_without_al == alias or matchesName(local_name, { alias }) then
                return l_code
            end
        end
    end

    local names = v.names and v.names or {}
    table.insert(names, v.name)

    local name_in = has_name(local_name, names)
    if name_in then
        -- Check for script variants
        for script, script_name in pairs(i18n.scripts) do
            -- if local_name has script_name
            if mw.ustring.find(local_name, script_name) ~= nil then
                local name_in_with_script = name_in .. " " .. script_name
                -- mw.log(("local_name:(%s) name_in_with_script:(%s)"):format(local_name, name_in_with_script))
                local script_code = l_code .. script

                if name_without_al == name_in_with_script then
                    return script_code
                end

                if matchesName(local_name, { name_in_with_script }) then
                    return script_code
                end
            end
        end
    end
end

local function get_code_from_name(local_name)
    if not isValid(local_name) then return nil end

    if data.lang_codes[local_name] then
        return data.lang_codes[local_name]
    end

    local name_without_al = remove_al_from_name(local_name)
    if data.lang_codes[name_without_al] then
        return data.lang_codes[name_without_al]
    end

    for l_code, lang_data in pairs(data.lang_table) do
        local code_b = get_code(l_code, lang_data, local_name, name_without_al)
        if code_b then
            return code_b
        end
    end
    return nil
end

local function generateCategory(lang_code)
    if lang_code == i18n.local_lang or lang_code == i18n.local_lang_2 then
        return ""
    end
    local lang_name = getLanguageName(lang_code, true) or lang_code
    return ("[[" .. i18n.lang_usage_cat .. "]]"):format(lang_name)
end

function p.getLanguageName(frame)
    local code = frame.args[1]
    if not isValid(code) then return "" end
    local add_the = frame.args[2]
    local result = getLanguageName(code, add_the, 0, frame.args["nil"])
    return mw.getCurrentFrame():preprocess(result)
end

function p.tagLanguageCode(frame)
    local lang_code = frame.args[1]
    local text = frame.args[2]
    if not isValid(lang_code) then return "" end

    local clean_code = lang_code:gsub("%s", ""):lower()
    local tagged_text = mw.text.tag("span", { lang = clean_code }, text)
    return tagged_text .. generateCategory(clean_code)
end

function p.getLanguageCode(frame)
    local name = frame.args[1]
    if not isValid(name) then return "" end
    return get_code_from_name(name) or get_code_from_name(addDefiniteArticle(name)) or ""
end

function p.generateLanguageList()
    local headers = { "ns_10_name", "template_result", "link", "name", "redirects" }
    local table_builder = mw.html.create("table"):addClass("wikitable sortable collapsible mw-collapsed")
    local frame = mw.getCurrentFrame()

    -- إنشاء رأس الجدول
    local header_row = table_builder:tag("tr")
    for _, key in ipairs(headers) do
        header_row:tag("th"):wikitext(i18n.list[key])
    end

    -- ملء الجدول بالبيانات
    for code, lang_data in pairs(data.lang_table) do
        local row = table_builder:tag("tr")
        local template_link = string.format("[[%s:%s %s]]", i18n.ns_10_name,
            i18n.list.template_ISO_639_name, code)
        local template_result = frame:preprocess(string.format("{{%s %s}}",
            i18n.list.template_ISO_639_name, code))
        local simple_link = string.format("[[%s %s]]", i18n.list.lang_name_prefix, lang_data.name)
        local full_link = string.format("[[%s %s]]", i18n.list.lang_name_prefix_with_the,
            formatLanguageName(lang_data.name, true, code))

        row:tag("td"):wikitext(template_link)
        row:tag("td"):wikitext(template_result)
        row:tag("td"):wikitext(simple_link)
        row:tag("td"):wikitext(full_link)
        local redirect_cell = row:tag("td"):attr("dir", "ltr")
        local codes = lang_data.codes or {}
        table.insert(codes, code)
        redirect_cell:wikitext(table.concat(codes, " - "))
    end

    return tostring(table_builder)
end

p.lang_name = p.getLanguageName
p["اسم لغة"] = p.getLanguageName
p.lang_code_temp = p.tagLanguageCode
p["قالب رمز لغة"] = p.tagLanguageCode
p["رمز لغة"] = p.getLanguageCode
p.lang_code = p.getLanguageCode
p["قائمة"] = p.generateLanguageList

return p
