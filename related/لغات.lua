local p = {}
local data = require("Module:لغات/بيانات")

local i18n = {
    scripts = {
        ['-latn'] = 'لاتينية',
        ['-cyrl'] = 'سيريلية',
        ['-arab'] = 'عربية',
    },
    the_word = "ال",
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
        lang_name_prefix_with_the = "اللغة",
    },
    ns_10_name = mw.site.namespaces[10].name
}

local function isvalid(x)
    if x and x ~= "" then return x end
    return nil
end

local function add_the_to_name(name)
    if name:match("^" .. i18n.the_word) then
        return name
    end
    return i18n.the_word .. string.gsub(name, " ", " " .. i18n.the_word)
end

local function remove_the_from_name(name)
    local name2 = name
    if name:match("^" .. i18n.the_word) then
        name2 = name2:gsub("^" .. i18n.the_word .. " ", "")
        name2 = name2:gsub(" " .. i18n.the_word, " ")
    end
    return name2
end

local function gsubname(name, add_the, code)
    if isvalid(code) then
        local name_with_all = data.lang_name_with_al[code] or data.lang_name_with_al[code:lower()]
        if name_with_all then
            return name_with_all
        end
    end
    if isvalid(add_the) then
        return add_the_to_name(name)
    end
    return name
end

local function LatnCyrl(code, al, number, returnnil)
    local ar_name = ""
    code = code:lower()
    number = (number or 0) + 1
    local e = string.sub(code, -5) -- 5 from the end until the end
    local s = string.gsub(code, e, "")
    local name = p.getname(s, "", number)
    local co = "" and isvalid(returnnil) or code

    if isvalid(name) and i18n.scripts[e] then
        ar_name = name .. " " .. i18n.scripts[e]
    end

    if ar_name == "" then
        return co
    end
    return gsubname(ar_name, al, code)
end

function p.get_name_from_code(code)
    local s = string.gsub(code, " ", "")
    return data.lang_name[s] or data.lang_name[s:lower()] or data.lang_name_with_al[s:lower()]
end

function p.getname(code, al, number, returnnil)
    number = (number or 0) + 1
    if number and number > 3 then
        return nil
    end
    if not isvalid(code) then
        return ""
    end
    if string.find(code, "[)|(]") then
        return code
    end
    code = string.gsub(code, " ", "")
    local fi
    local name = p.get_name_from_code(code)
    if isvalid(name) then
        fi = gsubname(name, al, code)
    else
        fi = LatnCyrl(code, al, number, returnnil)
    end
    return fi
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

local function matches_any(target, names)
    for _, name in ipairs(names) do
        if target == name or target == add_the_to_name(name) then
            return true
        end
    end
    return false
end

local function get_code(l_code, v, local_name, local_name_no_al)
    if matches_any(local_name, { v.name }) then
        return l_code
    end

    if matches_any(local_name, { p.getname(l_code, "") }) then
        return l_code
    end

    if v.names then
        for _, alias in ipairs(v.names) do
            -- if local_name_no_al == alias or local_name == alias or local_name == add_the_to_name(alias, true) then
            if local_name_no_al == alias or matches_any(local_name, { alias }) then
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

                if local_name_no_al == name_in_with_script then
                    return script_code
                end

                if matches_any(local_name, { name_in_with_script }) then
                    return script_code
                end
            end
        end
    end
end

local function get_code_from_name(local_name)
    -- Check direct match in lang_codes
    if data.lang_codes[local_name] then
        return data.lang_codes[local_name]
    end
    local local_name_no_al = remove_the_from_name(local_name)
    if data.lang_codes[local_name_no_al] then
        return data.lang_codes[local_name_no_al]
    end
    -- Iterate over lang_table
    for l_code, v in pairs(data.lang_table) do
        local code_b = get_code(l_code, v, local_name, local_name_no_al)
        if code_b then
            return code_b
        end
    end
    return nil
end

local function make_cat(lange)
    if lange == i18n.local_lang or lange == i18n.local_lang_2 then
        return ""
    end
    local c = p.getname(lange, "t")

    return ("[[" .. i18n.lang_usage_cat .. "]]"):format(c or lange)
end

function p.lang_name(frame)
    local na = frame.args[1]
    if not isvalid(na) then
        return ""
    end
    local code = p.getname(frame.args[1], frame.args[2], 0, frame.args["nil"])
    return mw.getCurrentFrame():preprocess(code)
end

function p.lang_code_temp(frame)
    local lange = frame.args[1]
    local text = frame.args[2]
    if not isvalid(lange) then
        return ""
    end
    lange = string.gsub(lange, " ", "")
    lange = lange:lower()
    local textout = mw.text.tag("span", { lang = lange }, text)
    local cate = make_cat(lange)

    return textout .. cate
end

function p.lang_code(frame)
    local na = frame.args[1]
    if isvalid(na) then
        return get_code_from_name(na) or get_code_from_name(add_the_to_name(na))
    end
    return ""
end

function p.list()
    local list = mw.html.create("table"):addClass("wikitable sortable collapsible mw-collapsed")

    -- إنشاء صف العناوين
    local header = list:tag("tr")
    local headers = { "ns_10_name", "template_result", "link", "name", "redirects" }
    for _, key in ipairs(headers) do
        header:tag("th"):wikitext(i18n.list[key])
    end

    -- إنشاء الصفوف
    for code, tab in pairs(data.lang_table) do
        local lang_name = tab.name
        local template_result = string.format("{{%s %s}}", i18n.list.template_ISO_639_name, code)
        local template_link = string.format("[[%s:%s %s]]", i18n.ns_10_name, i18n.list.template_ISO_639_name, code)

        local lang_link = ("[[%s %s]]"):format(i18n.list.lang_name_prefix, lang_name)
        local full_lang_name = ("[[%s %s]]"):format(i18n.list.lang_name_prefix_with_the, gsubname(lang_name, "r", code))

        local row = list:tag("tr")
        row:tag("td"):tag("span"):wikitext(template_link)
        row:tag("td"):tag("span"):wikitext(mw.getCurrentFrame():preprocess(template_result))
        row:tag("td"):tag("span"):wikitext(lang_link)
        row:tag("td"):tag("span"):wikitext(full_lang_name)

        local redirects_cell = row:tag("td")
        redirects_cell:attr("dir", "ltr")

        local codes = tab.codes and tab.codes or {}
        table.insert(codes, code)
        for _, v in pairs(codes) do
            if isvalid(v) then
                redirects_cell:tag("code"):wikitext(v)
                if _ < #codes then
                    redirects_cell:tag("span"):wikitext(" - ")
                end
            end
        end
    end

    return tostring(list)
end

p["اسم لغة"] = function(frame)
    return p.lang_name(frame)
end

p["قالب رمز لغة"] = function(frame)
    return p.lang_code_temp(frame)
end

p["رمز لغة"] = function(frame)
    return p.lang_code(frame)
end

p["قائمة"] = function(frame)
    return p.list()
end

return p
