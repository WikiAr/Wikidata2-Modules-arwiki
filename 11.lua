local p = {}

local function isvalid(x)
    if x and x ~= nil and x ~= "" then return x end
    return nil
end

function p.lang(frame)
    -- https://www.cazypedia.org/extensions/Scribunto/includes/engines/LuaCommon/lualib/mw.language.lua
    local tab = {}
    local lang = mw.getContentLanguage():getCode()
    table.insert(tab, "* lang: " .. lang)

    local wiki = string.match(mw.site.server, "%a+")
    table.insert(tab, "wiki: " .. wiki)

    local language = mw.language.getContentLanguage()

    local code = language:getCode()
    table.insert(tab, "code: " .. code)

    local rtl = language:getDirMarkEntity()
    table.insert(tab, "rtl: " .. mw.text.nowiki(rtl))

    local rtl1 = language:getDirMark()
    table.insert(tab, "rtl1: " .. mw.text.nowiki(rtl1))

    local forwards = language:getArrow("forwards")
    table.insert(tab, "forwards: " .. forwards)

    local backwards = language:getArrow("backwards")
    table.insert(tab, "backwards: " .. backwards)

    local Fallback = language:getFallbackLanguages()
    table.insert(tab, "Fallback: " .. mw.dumpObject(Fallback))

    return table.concat(tab, "\n* ")
end

local function concatenateStrings(s1, s2, s3)
    if isvalid(s1) then
        if isvalid(s2) then
            return s1 .. '، ' .. s2
        elseif s1 ~= s3 then
            return s1 .. '، ' .. s3
        else
            return s1
        end
    end
end

function p.test(frame)
    local first_value = concatenateStrings("رابع", "خامس", "country1")
    local second_value = concatenateStrings("ثالث", first_value, "country2")
    local third_value = concatenateStrings("ثاني", second_value, "country3")
    local result = concatenateStrings("أول", third_value, "country4")

    return result
end

return p
