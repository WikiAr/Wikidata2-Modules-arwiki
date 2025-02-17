local p = {}
local ModuleTime = require 'Module:wikidata2/time'
local tempname = 'تاريخ الوفاة والعمر'
local o3 = '[[تصنيف:صفحات بها تواريخ بحاجة لمراجعة]]'

local agecat = { "111", "112", "116", "95", "96", "97", "98", "99", "100", "101", "102", "103", "104", "105", "106",
    "107", "108", "110", "75", "91" }

local function isvalid(x)
    if x and x ~= nil and x ~= "" then return x end
    return nil
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

local function category(property, y, m, d)
    if mw.title.getCurrentTitle().namespace ~= 0 then return '' end
    local prf = ""
    local cat = ""
    local cate = ""
    local cat2 = ""
    if property == 'P569'
    then
        prf = 'مواليد '
        if d and m then cat2 = prf .. d .. ' ' .. m end
    elseif property == 'P570'
    then
        prf = 'وفيات '
    end
    if isvalid(y) and isvalid(prf) then
        cat = ' [[تصنيف:' .. prf .. y .. ']]'
    end
    if isvalid(cat2) then
        cate = ' [[تصنيف:' .. cat2 .. ']]'
    end
    return (cat or '') .. (cate or '')
end

local function getprop(propertyID, modifytime, entity)
    local val = formatStatements({
        property = propertyID,
        entityId = entity,
        modifytime = modifytime,
        noref = 'true',
        firstvalue = 'true'
    })
    mw.log(val)
    return val
end

local function mathyears(year, Ryear, month, Rmonth)
    --	Ryear = Date( "%Y" )
    --	Rmonth =Date( "%m" )
    --	Rday = os.date( "%e" )
    --	if string.sub(Ryear, 1, 1) == '-' then Ryear = '+' .. string.sub(Ryear, 2) end
    local val = ""
    if isvalid(month)
    then
        if Rmonth < month
        then
            val = Ryear - year - 1
        else
            if Rmonth > month
            then
                val = Ryear - year
            else
                val = Ryear - year - 1 .. '&ndash;' .. Ryear - year
            end
        end
    else
        val = Ryear - year - 1 .. '&ndash;' .. Ryear - year
        --mw.log( "val.." .. val )
    end

    if (Ryear - year) < 0
    then
        val = val .. o3
    elseif (Ryear - year) > 150
    then
        val = val .. o3
    elseif (year - Ryear) > 150
    then
        val = val .. o3
    end

    return val
end

local function age(v, pr, add, property)
    -- local v_old = v
    if isvalid(add) then return '' else end
    --	if string.sub(Ryear, 1, 1) == '-' then Ryear = '+' .. string.sub(Ryear, 2) end
    --	val =  mathyears(year, Ryear, month, Rmonth)
    local v2 = tostring(v)
    if isvalid(pr) then
        v = 'العمر ' .. v
    end
    local ii = ' (' .. v .. ' سنة)'
    if property and property == "P570" then
        Age_cat = false
        for k, l in pairs(agecat) do
            if v2 == l then
                Age_cat = true
            end
        end
        if Age_cat then
            ii = ii .. '[[تصنيف:وفيات بعمر ' .. v .. ']]'
        end
    end
    local start = mw.ustring.find(v, o3, 1, true)
    if start == 0 or start == nil then
        return ii
    else
        return o3
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
    if (yd - yb) > 150 then val = val .. o3 elseif (yb - yd) > 150 then val = val .. o3 end
    return val
end

local function linkdate(property, y, m, d)
    local year = ""
    local md = ""
    if y then year = '[[' .. y .. ']]' end
    if m
    then
        if d
        then
            md = '[[' .. d .. ' ' .. m .. ']] '
        else
            md = '[[' .. m .. ']] '
        end
    else
        year = 'سنة ' .. year
    end
    return (md or '') .. year .. category(property, y, m, d)
end

local function getP570(P570precision, Timev, entity, P569precision, P569time)
    local timev = ""
    if string.sub(Timev, 1, 1) == '-' then
        timev = '+' .. string.sub(Timev, 2)
        P570addon = ' ق م'
    else
        timev = Timev
    end
    if isvalid(P569time) then
        if string.sub(P569time, 1, 1) == '-' then
            P569time = '+' .. string.sub(P569time, 2)
            P569addon = ' ق م'
        end
    end
    local Dyear = getdatepart(timev, 'y')
    local Dmonth = getdatepart(timev, 'm')
    local Dmonthname = mw.getContentLanguage():formatDate('F', timev)
    local Dday = getdatepart(timev, 'd')
    local year = getdatepart(P569time, 'y')
    local month = getdatepart(P569time, 'm')
    -- local monthname = mw.getContentLanguage():formatDate('F', P569time)
    local day = getdatepart(P569time, 'd')

    local dii = ""
    if isvalid(P569precision) then
        -- Death date is full
        if P570precision == 11 or P570precision == '11' then
            if P569precision == 11 or P569precision == '11' then
                dii = mw.getCurrentFrame():expandTemplate { title = tempname, args = { Dyear, Dmonth, Dday, year, month,
                    day } }
            elseif P569precision == 10 or P569precision == '10' or P569precision == 9 or P569precision == '9' then
                dii = linkdate('P570', Dyear .. (P570addon or ''), Dmonthname, Dday) ..
                    age(mathyears(year, Dyear), '', P570addon or P569addon, "P570")
            else
                dii = ModuleTime.getdate({ time = Timev, precision = tonumber(P570precision) }, {})
            end

            -- Death date is year
        elseif P570precision == 10 or P570precision == '10' then
            dii = linkdate('P570', Dyear .. (P570addon or ''), Dmonthname) ..
                age(mathyears(year, Dyear), '', P570addon or P569addon, "P570")
        elseif P570precision == 9 or P570precision == '9' then
            --#######################
            if P569precision == 10 or P569precision == '10' or P569precision == 9 or P569precision == '9' then
                dii = linkdate('P570', Dyear .. (P570addon or '')) ..
                    age(mathyears(year, Dyear), '', P570addon or P569addon, "P570")
            else
                dii = linkdate('P570', Dyear .. (P570addon or ''))
            end
            --#######################
        else
            dii = ModuleTime.getdate({ time = Timev, precision = tonumber(P570precision) }, {})
        end
    else
        -- no P569 date
        if P570precision == 11 or P570precision == '11' then
            dii = linkdate('P570', Dyear .. (P570addon or ''), Dmonthname, Dday)
        elseif P570precision == 10 or P570precision == '10' then
            dii = linkdate('P570', Dyear .. (P570addon or ''), Dmonthname)
        elseif P570precision == 9 or P570precision == '9' then
            dii = linkdate('P570', Dyear .. (P570addon or ''))
        else
            dii = ModuleTime.getdate({ time = Timev, precision = tonumber(P570precision) }, {})
        end
    end
    return dii
end

local function getP569(P569precision, Timev, entity, P570precision)
    local P569addon = ''
    local timev = ''
    if string.sub(Timev, 1, 1) == '-' then
        timev = '+' .. string.sub(Timev, 2)
        P569addon = ' ق م'
    else
        timev = Timev
    end
    local year = getdatepart(timev, 'y')
    local month = getdatepart(timev, 'm')
    local monthname = mw.getContentLanguage():formatDate('F', timev)
    local day = getdatepart(timev, 'd')

    local val = ''
    if isvalid(P570precision)
    then
        if P569precision == 11 or P569precision == '11'
        then
            val = linkdate('P569', year .. (P569addon or ''), monthname, day)
        elseif P569precision == 10 or P569precision == '10'
        then
            val = linkdate('P569', year .. (P569addon or ''), monthname)
        elseif P569precision == 9 or P569precision == '9' then
            val = linkdate('P569', year .. (P569addon or ''))
        else
            val = ModuleTime.getdate({ time = Timev, precision = tonumber(P569precision) }, {})
        end
    else
        if P569precision == 11 or P569precision == '11'
        then
            local doo = mathfulldate(year, month, day)
            val = linkdate('P569', year .. (P569addon or ''), monthname, day) .. age(doo, '', P569addon, "P569")
        elseif P569precision == 10 or P569precision == '10'
        then
            val = linkdate('P569', year .. (P569addon or ''), monthname)
                .. age(mathyears(year, tonumber(os.date("%Y")), month, tonumber(os.date("%m"))), '', P569addon, "P569")
        elseif P569precision == '9' or P569precision == 9 then
            val = linkdate('P569', year .. (P569addon or '')) ..
                age(mathyears(year, tonumber(os.date("%Y"))), 't', P569addon, "P569")
        else
            val = ModuleTime.getdate({ time = Timev, precision = tonumber(P569precision) }, {})
        end
    end
    return val -- .. (P569addon or '')
end

local function propert(precision, timev, propertyID, entity)
    local P569precision = getprop('P569', 'precision', entity)
    local P569time = getprop('P569', 'q', entity)
    local P570precision = formatStatements({
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
        val = getP569(precision, timev, entity, P570precision)
    elseif propertyID == 'P570' then
        val = getP570(precision, timev, entity, P569precision, P569time)
    end
    return val -- .. (addon or '')
end

function p.getdate(datavalue, datatype, options)
    local propertyID = options.property
    local entity = mw.wikibase.getEntityObject(options.entityId)

    if datavalue.type == 'time'
    then
        local precision = tonumber(datavalue.value.precision)
        local timev = datavalue.value.time
        if precision == 9 or precision == 10 then
            timev = string.gsub(timev, '-00T', '-01T')
        end

        local tt = propert(precision, timev, propertyID, entity.id)
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
            val = getP569(frame.args.P569pre, frame.args.P569time, entity, frame.args.P570pre)
        elseif propertyID == 'P570'
        then
            val = getP570(frame.args.P570pre, frame.args.P570time, entity, frame.args.P569pre, frame.args.P569time)
        end

        return val
    end
end

return p
