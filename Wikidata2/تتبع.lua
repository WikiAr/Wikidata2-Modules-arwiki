local p = {}

-- Configuration
local config = {
    i18n = {
        category_prefix = mw.site.namespaces[14].name, --"تصنيف"
        file_prefix = mw.site.namespaces[6].name,      -- "ملف"
        pages_using_property = "صفحات تستخدم خاصية ",
        pages_with_wikidata = "صفحات بها بيانات ويكي بيانات",
        edit_property_value = "تعديل قيمة خاصية ",
        in_wikidata = " في ويكي بيانات",
        wikidata_playground = "ويكي بيانات/ملعب ويكي بيانات"
    },
}

-- Utility Functions
local function is_valid(x)
    if x and x ~= nil and x ~= "" then return x end
    return nil
end

local function trimProperty(str)
    return str:sub(1, 1) == "P" and str:sub(2) or str
end

local function getCategoryLink(propertyId)
    return config.i18n.pages_using_property .. propertyId
end

-- Core Functions
local function createCategory(propertyId, customCategory, hideCategory)
    if is_valid(hideCategory) then
        return ''
    end

    local mainCategory = '[[' ..
        config.i18n.category_prefix .. ":" .. config.i18n.pages_with_wikidata .. '|' .. trimProperty(propertyId) .. ']]'

    if is_valid(customCategory) then
        return customCategory .. mainCategory
    end

    local trimmedId = mw.text.trim(propertyId)
    local categoryLink = getCategoryLink(trimmedId)
    if categoryLink then
        return '[[' .. config.i18n.category_prefix .. ":" .. categoryLink .. ']]' .. mainCategory -- linktext(s)
    end
end

local function createIcon(propertyId, entityId, hideIcon, useAltIcon)
    if is_valid(hideIcon) then
        return ''
    end
    if not is_valid(propertyId) then
        return ''
    end

    local label = "" -- Placeholder for mw.wikibase.label(entityId)
    local temp = label .. ' (' .. propertyId .. ')'
    local iconFile = 'Twemoji_270f.svg|13px'
    if is_valid(useAltIcon) then
        iconFile = 'Wikidata-logo.svg|20px'
    end
    local editText = config.i18n.edit_property_value .. temp .. config.i18n.in_wikidata
    entityId = entityId or ''

    local imageLink = (" [[%s:%s|baseline|link=d:%s#%s|%s]]"):format(config.i18n.file_prefix, iconFile, entityId,
        propertyId,
        editText)

    local noprint = '<span class="noprint">' .. imageLink .. '</span>'
    -- local sup = '<sup>' .. noprint .. '</sup>'
    return noprint
end

-- Page Helper
function p.pageId()
    return mw.wikibase.getEntityIdForCurrentPage()
end

-- Main Category Functions
function p.makecategory1(options)
    local pageTitle = mw.title.getCurrentTitle()
    local namespace = pageTitle.namespace
    local title = pageTitle.text

    -- Extract options with defaults
    local property = is_valid(options.property)
    if not property then
        return nil -- don't do anything if no options property.
    end

    local entityId = is_valid(options.entityId) or is_valid(options.id) or p.pageId()

    local qualifier = is_valid(options.justthisqual)
    local hideIcon = is_valid(options.noicon)     -- options to hide the icon.
    local hideCategory = is_valid(options.nocate) -- options to hide the category.
    local customCategory = options.category
    local useAltIcon = is_valid(options.icon2)

    -- Normalize property ID
    local propertyId = mw.ustring.gsub(property:upper(), " ", "")

    -- Generate components
    local icon = createIcon(propertyId, entityId, hideIcon, useAltIcon)
    local category = createCategory(propertyId, customCategory, hideCategory)

    if qualifier then
        category = category .. createCategory(mw.ustring.gsub(qualifier:upper(), " ", ""), customCategory, hideCategory)
    end

    local result = category .. icon

    -- Special cases
    if title == config.i18n.wikidata_playground or namespace == 2 then -- to hide category in user pages
        result = icon
    end

    return result
end

-- Main function used in "قالب:قيمة ويكي بيانات/إيقونة وتصنيف"
function p.makecategory(frame)
    return p.makecategory1(frame.args)
end

-- Simplified Category Function
function p.make1(property, entityId)
    if not is_valid(property) then
        return nil -- don't do anything if no args property.
    end

    entityId = is_valid(entityId) or p.pageId()
    local propertyId = mw.ustring.gsub(property:upper(), " ", "")

    local icon = createIcon(propertyId, entityId)
    local category = createCategory(propertyId)

    return category .. icon
end

-- Testing Function
function p.SS(frame)
    local property = is_valid(mw.ustring.gsub(frame.args.property:upper(), " ", ""))
    if not property then return nil end

    local categoryLink = mw.text.trim(getCategoryLink(property))
    if not is_valid(categoryLink) then
        return nil
    end
    local customCategory = is_valid(frame.args.category)

    return customCategory or createCategory(categoryLink)
end

return p
