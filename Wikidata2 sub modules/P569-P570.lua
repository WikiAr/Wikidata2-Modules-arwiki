local p = {}

local sandbox = "ملعب"
local sandbox_added = ""
if nil ~= string.find(mw.getCurrentFrame():getTitle(), sandbox, 1, true) then
    sandbox_added = "/" .. sandbox
end

local ModuleTime = require('Module:wikidata2/time' .. sandbox_added)

local pp_config = {
    tempname = 'تاريخ الوفاة والعمر',
    time_addon = ' ق م',
    age_word = 'العمر ',
    year_word = 'سنة',
    dates_need_review = "صفحات بها تواريخ بحاجة لمراجعة",
    add_birth_and_death_categories = true,
    deaths_at_age = 'وفيات بعمر ',
    category_starts = {
        P569 = 'مواليد ',
        P570 = 'وفيات ',
    },
}

local function isvalid(x)
    if x and x ~= nil and x ~= "" then return x end
    return nil
end

local function format_cat(x)
    return ' [[' .. 'Category:' .. x .. ']]'
end

local function death_age_category(v)
    if pp_config.add_birth_and_death_categories == false then
        return ''
    end
    local v2 = tostring(v)
    return format_cat(pp_config.deaths_at_age .. v2)
end


local function category(property, y, m, d)
    if mw.title.getCurrentTitle().namespace ~= 0 then
        return ''
    end
    --
    if pp_config.add_birth_and_death_categories == false then
        return ''
    end
    --
    local prf = pp_config.category_starts[property]
    --
    local cat = ""
    local cat2 = ""
    if property == 'P569' then
        if d and m then
            cat2 = prf .. d .. ' ' .. m
        end
    end
    if isvalid(y) and isvalid(prf) then
        cat = format_cat(prf .. y)
    end
    local cate = ""
    if isvalid(cat2) then
        cate = format_cat(cat2)
    end
    return (cat or '') .. (cate or '')
end

local function getdatepart(time, option)
    if isvalid(time) then
        if option == 'y' then
            return tonumber(string.sub(time, 2, 5))
        elseif option == 'm' then
            return tonumber(string.sub(time, 7, 8))
        elseif option == 'd' then
            return tonumber(string.sub(time, 10, 11))
        end
    end
end
local function getprop(propertyID, modifytime, entity)
    local val = formatStatements({
        property = propertyID,
        entityId = entity,
        modifytime = modifytime,
        noref = 'true',
        firstvalue = 'true'
    })
    -- mw.log(val)
    return val
end

local function mathyears(year, Ryear, month, Rmonth)
    --	Ryear = Date( "%Y" )
    --	Rmonth =Date( "%m" )
    --	Rday = os.date( "%e" )
    --	if string.sub(Ryear, 1, 1) == '-' then Ryear = '+' .. string.sub(Ryear, 2) end
    --
    year = year or 0
    Ryear = Ryear or 0
    --
    local year_fixed = Ryear - year
    --
    local value = ""
    --
    if isvalid(month) then
        if Rmonth < month then
            value = year_fixed - 1
        else
            if Rmonth > month then
                value = year_fixed
            else
                value = year_fixed - 1 .. '&ndash;' .. year_fixed
            end
        end
    else
        value = year_fixed - 1 .. '&ndash;' .. year_fixed
        --mw.log( "value.." .. value )
    end
    if (year_fixed) < 0 or (year - Ryear) > 150 or (year_fixed) > 150 then
        value = value .. format_cat(pp_config.dates_need_review)
    end

    return value
end


local function count_age(v, pr, add, property)
    -- local v_old = v
    if isvalid(add) then return '' else end
    --	if string.sub(Ryear, 1, 1) == '-' then Ryear = '+' .. string.sub(Ryear, 2) end
    --	val =  mathyears(year, Ryear, month, Rmonth)
    if isvalid(pr) then
        v = pp_config.age_word .. v
    end
    local ii = (" (%s %s)"):format(v, pp_config.year_word)

    if isvalid(property) == "P570" then
        ii = ii .. death_age_category(v)
    end
    local start = mw.ustring.find(v, format_cat(pp_config.dates_need_review), 1, true)
    if start == 0 or start == nil then
        return ii
    else
        return format_cat(pp_config.dates_need_review)
    end
end

local function foo(f, s)
    if f < s
    then
        return '1'
    else
        return '0'
    end
end

local function mathfulldate(yb, mb, db, Yd, Md, Dd)
    local yd = Yd or tonumber(os.date("%Y"))
    local md = Md or tonumber(os.date("%m"))
    -- local dd = Dd or tonumber(os.date("%e"))
    local vv = ""
    local function ma(f, s)
        if f < s
        then
            return '1'
        elseif f == s then
            return '1'
        else
            return '0'
        end
    end

    if not foo(db, db) == '0' or not ma(md, mb) == '0'
    then
        vv = '1'
    else
        vv = '0'
    end
    local val = (yd) - (yb) - (vv)

    if (yd - yb) > 150 or (yb - yd) > 150 then
        val = val .. format_cat(pp_config.dates_need_review)
    end
    return val
end

local function linkdate(property, y, m, d)
    local year = ""
    if y then
        year = '[[' .. y .. ']]'
    end
    local md = ""
    if m then
        if d then
            md = '[[' .. d .. ' ' .. m .. ']] '
        else
            md = '[[' .. m .. ']] '
        end
    else
        year = pp_config.year_word .. ' ' .. year
    end
    return md .. year .. category(property, y, m, d)
end

local function getP570(P570precision, Timev, P569precision, P569time)
    local time_v = ""
    local P570addon = ""
    local P569addon = ""
    if string.sub(Timev, 1, 1) == '-' then
        time_v = '+' .. string.sub(Timev, 2)
        P570addon = isvalid(pp_config.time_addon) or ""
    else
        time_v = Timev
    end
    if isvalid(P569time) then
        if string.sub(P569time, 1, 1) == '-' then
            P569time = '+' .. string.sub(P569time, 2)
            P569addon = pp_config.time_addon
        end
    end
    local Dyear = getdatepart(time_v, 'y')
    local Dmonth = getdatepart(time_v, 'm')
    local Dmonthname = mw.getContentLanguage():formatDate('F', time_v)
    local Dday = getdatepart(time_v, 'd')
    local year = getdatepart(P569time, 'y')
    local month = getdatepart(P569time, 'm')
    -- local monthname = mw.getContentLanguage():formatDate('F', P569time)
    local day = getdatepart(P569time, 'd')

    P570precision = tonumber(P570precision)
    P569precision = tonumber(P569precision)

    local dii = ""
    --
    local year_do = mathyears(year, Dyear)
    local addon = isvalid(P570addon) or isvalid(P569addon)
    --
    if not isvalid(P569precision) then
        -- no P569 date
        if P570precision == 11 then
            dii = linkdate('P570', Dyear .. P570addon, Dmonthname, Dday)
        elseif P570precision == 10 then
            dii = linkdate('P570', Dyear .. P570addon, Dmonthname)
        elseif P570precision == 9 then
            dii = linkdate('P570', Dyear .. P570addon)
        else
            dii = ModuleTime.getdate({ time = Timev, precision = P570precision }, {})
        end
        return dii
    end
    --
    -- isvalid(P569precision) is valid
    -- Death date is full
    if P570precision == 11 then
        if P569precision == 11 then
            dii = mw.getCurrentFrame():expandTemplate {
                title = pp_config.tempname,
                args = {
                    Dyear, Dmonth, Dday, year, month, day
                } }
        elseif P569precision == 10 or P569precision == 9 then
            local age = count_age(year_do, '', addon, "P570")
            dii = linkdate('P570', Dyear .. P570addon, Dmonthname, Dday) .. age
        else
            dii = ModuleTime.getdate({ time = Timev, precision = P570precision }, {})
        end
        -- Death date is year
    elseif P570precision == 10 then
        local age = count_age(year_do, '', addon, "P570")
        dii = linkdate('P570', Dyear .. P570addon, Dmonthname) .. age
        --
    elseif P570precision == 9 then
        if P569precision == 10 or P569precision == 9 then
            local age = count_age(year_do, '', addon, "P570")
            dii = linkdate('P570', Dyear .. P570addon) .. age
        else
            dii = linkdate('P570', Dyear .. P570addon)
        end
        --
    else
        dii = ModuleTime.getdate({ time = Timev, precision = P570precision }, {})
    end
    return dii
end

local function getP569(P569precision, Timev, has_death_date)
    local P569addon = ''
    local time_v = ''
    if string.sub(Timev, 1, 1) == '-' then
        time_v = '+' .. string.sub(Timev, 2)
        P569addon = isvalid(pp_config.time_addon) or ''
    else
        time_v = Timev
    end
    local year = getdatepart(time_v, 'y')
    local month = getdatepart(time_v, 'm')
    local monthname = mw.getContentLanguage():formatDate('F', time_v)
    local day = getdatepart(time_v, 'd')

    P569precision = tonumber(P569precision)
    --
    local current_year = tonumber(os.date("%Y"))
    local current_month = tonumber(os.date("%m"))
    --
    local val = ''
    mw.log("has_death_date", has_death_date)
    if isvalid(has_death_date) then
        if P569precision == 11 then
            val = linkdate('P569', year .. P569addon, monthname, day)
        elseif P569precision == 10 then
            val = linkdate('P569', year .. P569addon, monthname)
            --
        elseif P569precision == 9 then
            val = linkdate('P569', year .. P569addon)
            --
        else
            val = ModuleTime.getdate({ time = Timev, precision = P569precision }, {})
        end
    else
        if P569precision == 11 then
            local doo = mathfulldate(year, month, day)
            local age = count_age(doo, '', P569addon, "P569")
            val = linkdate('P569', year .. P569addon, monthname, day) .. age
            --
        elseif P569precision == 10 then
            local year_t = mathyears(year, current_year, month, current_month)
            local age = count_age(year_t, '', P569addon, "P569")
            val = linkdate('P569', year .. P569addon, monthname) .. age
            --
        elseif P569precision == 9 then
            local age = count_age(mathyears(year, current_year), 't', P569addon, "P569")
            val = linkdate('P569', year .. P569addon) .. age
        else
            val = ModuleTime.getdate({ time = Timev, precision = P569precision }, {})
        end
    end
    return val -- .. P569addon
end

local function propert(precision, time_v, propertyID, entity)
    local P569precision = getprop('P569', 'precision', entity)
    local P569time = getprop('P569', 'q', entity)
    local has_death_date = formatStatements({
        property = 'P570',
        entityId = entity,
        modifytime = 'P570',
        noref = 'true',
        firstvalue = 'true',
        novalue = 'vv',
        somevalue = 'vv'
    })
    local val = ''

    if propertyID == 'P569' then
        val = getP569(precision, time_v, has_death_date)
    elseif propertyID == 'P570' then
        val = getP570(precision, time_v, P569precision, P569time)
    end
    return val -- .. (addon or '')
end

function p.getdate(datavalue, datatype, options)
    local propertyID = options.property
    local entity = mw.wikibase.getEntityObject(options.entityId)

    if datavalue.type == 'time'
    then
        local precision = tonumber(datavalue.value.precision)
        local time_v = datavalue.value.time
        if precision == 9 or precision == 10 then
            time_v = string.gsub(time_v, '-00T', '-01T')
        end

        local tt = propert(precision, time_v, propertyID, entity.id)
        return tt
    end
end

function p.test(frame)
    local propertyID = frame.args.property
    local entity = mw.wikibase.getEntityObject(frame.args.entityId)
    if isvalid(propertyID)
    then
        local val = ""
        if propertyID == 'P569'
        then
            val = getP569(frame.args.P569pre, frame.args.P569time, frame.args.P570pre)
        elseif propertyID == 'P570'
        then
            val = getP570(frame.args.P570pre, frame.args.P570time, frame.args.P569pre, frame.args.P569time)
        end

        return val
    end
end

return p
