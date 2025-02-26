local p = {}
local getArgs = require('Module:Arguments with aliases').getArgs

local DEFAULTS = {
    TABLE_WIDTH = '22em',
    TITLE_BG_COLOR = 'E1E1E1',
    TITLE_TXT_COLOR = '000000',
    LINE_BG_COLOR = 'F9F9F9',
    LINE_TXT_COLOR = '000000',
    DEFAULT_ICON = 'Nuvola apps important.png',
    PLACEHOLDER_ICON = 'Pix.gif'
}

local function trim(str)
    return mw.text.trim(str)
end

local function getValidValue(value, default)
    default = default or nil
    value = trim(value or '')
    return value ~= '' and value or default
end

local function arrowTemplate(file, link, arrowSize)
    return '[[ملف:' .. file .. '|' .. arrowSize .. 'px|link=' .. link .. ']]'
end
local function trimColor(color)
    color = trim(color)
    return color:sub(1, 1) == '#' and color:sub(2) or color
end

local function getTemplateStyles()
    local frame = mw.getCurrentFrame()
    return frame:extensionTag('templatestyles', '', { src = "ص.م/styles.css" })
        .. frame:extensionTag('templatestyles', '', { src = "بطاقة/icones.css" })
end

function p.Open(options)
    local id = getValidValue(options.id, '')
    local idAttr = id ~= '' and ' id="' .. id .. '"' or ''
    return getTemplateStyles() ..
        '<table cellspacing="3px" class="infobox2" style="width:' .. DEFAULTS.TABLE_WIDTH .. '"' .. idAttr .. '>'
end

function p.Close()
    return '</table>'
end

function p.Title(options)
    options = getArgs(options, {
        aliases = {
            title = { 1 },
            bg_color = { 2, "خلفية" },
            entete = { 3 },
            txt_color = { 4 },
            colspan = { 5, "colspan" },
            lineHeight = { 7 },
        }
    })

    local title = trim(options.title or '')
    local colspan = tonumber(options.colspan) or 2
    local class = getValidValue(options.entete, 'entete map')
    local bgColor = trimColor(getValidValue(options.bg_color, DEFAULTS.TITLE_BG_COLOR))
    local textColor = trimColor(getValidValue(options.txt_color, DEFAULTS.TITLE_TXT_COLOR))

    return tostring(mw.html.create('tr')
        :tag('th')
        :addClass(class)
        :attr('scope', 'col')
        :css({ ['line-height'] = '2em', ['background-color'] = '#' .. bgColor, color = '#' .. textColor })
        :attr('colspan', colspan)
        :wikitext(title)
        :done())
end

function p.IcoTitle(options)
    options = getArgs(options, {
        aliases = {
            title = { 1 },
            bg_color = { 2 },
            icon = { 3 },
            txt_color = { 4 },
            colspan = { 5 },
            right = { "right" }
        }
    })

    local colspan = tonumber(options.colspan) or 2
    local icon = getValidValue(options.icon, DEFAULTS.DEFAULT_ICON)
    local bgColor = trimColor(options.bg_color or DEFAULTS.TITLE_BG_COLOR)
    local textColor = trimColor(options.txt_color or DEFAULTS.TITLE_TXT_COLOR)
    local hasRightIcon = trim(options.right or '') ~= ''
    local leftIcon = DEFAULTS.PLACEHOLDER_ICON
    local rightIcon = icon

    if hasRightIcon then
        leftIcon = icon
        rightIcon = DEFAULTS.PLACEHOLDER_ICON
    end

    local iconTemplate = function(file)
        return '[[ملف:' .. file .. '|45x45px|center|alt=|link=]]'
    end

    return tostring(mw.html.create('tr')
        :tag('th')
        :attr('colspan', colspan)
        :tag('table')
        :attr({ cellpadding = 0, cellspacing = 0, width = '100%' })
        :css('text-align', 'center')
        :tag('tr')
        :addClass('entete defaut')
        :css('background-color', '#' .. bgColor)
        :tag('td')
        :attr('width', '10%')
        :wikitext(iconTemplate(leftIcon))
        :done()
        :tag('td')
        :attr('width', '80%')
        :css('color', '#' .. textColor)
        :wikitext(trim(options.title or ''))
        :done()
        :tag('td')
        :attr('width', '10%')
        :wikitext(iconTemplate(rightIcon))
        :done()
        :done()
        :done()
        :done())
end

function p.SubTitle(options)
    options = getArgs(options, {
        aliases = {
            title = { 1 },
            showTitle = { 2 },
            bg_color = { 3, "خلفية", "background" },
            txt_color = { 4, "color" },
            colspan = { 5, "colspan" },
        }
    })

    if not getValidValue(options.showTitle) then return '' end

    local title = trim(options.title or '')
    local bgColor = trimColor(getValidValue(options.bg_color, DEFAULTS.TITLE_BG_COLOR))
    local textColor = trimColor(getValidValue(options.txt_color, DEFAULTS.TITLE_TXT_COLOR))
    local colspan = tonumber(options.colspan) or 2

    return tostring(mw.html.create('tr')
        :tag('th')
        :attr('scope', 'col')
        :css('background-color', '#' .. bgColor)
        :css('color', '#' .. textColor)
        :css('text-align', 'center')
        :attr('colspan', colspan)
        :wikitext(title)
        :done())
end

function p.Line(options)
    options = getArgs(options, {
        aliases = {
            showLine = { 1 },
            content = { 2 },
            textAlign = { 3 },
            bg_color = { 4, "خلفية" },
            txt_color = { 5, "خط" },
            colspan = { 6, "colspan" },
            lineHeight = { 7 },
        }
    })

    if not getValidValue(options.showLine) then return '' end

    local content = getValidValue(options.content, trim(options.showLine or ''))
    local textAlign = getValidValue(options.textAlign, 'center')
    local bgColor = trimColor(getValidValue(options.bg_color, DEFAULTS.LINE_BG_COLOR))
    local textColor = trimColor(getValidValue(options.txt_color, DEFAULTS.LINE_TXT_COLOR))
    local colspan = tonumber(options.colspan) or 2
    local lineHeight = tonumber(options.lineHeight) or 0

    local row = mw.html.create('tr')
        :tag('td')
        :attr('scope', 'col')
        :css('background-color', '#' .. bgColor)
        :css('color', '#' .. textColor)
        :css('text-align', textAlign)
        :attr('colspan', colspan)
        :wikitext(content)
        :done()

    if lineHeight > 0 then
        row:tag('tr'):tag('td'):css('height', lineHeight .. 'px')
    end

    return tostring(row)
end

function p.MixedLine(options)
    options = getArgs(options, {
        aliases = {
            title = { 1 },
            showLine = { 2 },
            content = { 3 },
            width = { 4, "width" },
            colspan = { 5, "colspan" },
            bg_color = { 6, "خلفية" },
            txt_color = { 7, "خط" },
        }
    })

    local title = trim(options.title or '')
    local content = trim(options.content or '')
    local showLine = trim(options.showLine or '')
    local bgColor = trimColor(getValidValue(options.bg_color, 'F3F3F3'))
    local textColor = trimColor(getValidValue(options.txt_color, DEFAULTS.LINE_TXT_COLOR))
    local width = tonumber(options.width) or nil
    local colspan = tonumber(options.colspan) or nil

    if content == '' then
        content = trim(options.showLine or '')
    end

    if showLine == "" then
        return ''
    end

    return tostring(mw.html.create('tr')
        :tag('th')
        :attr('scope', 'row')
        :css('background-color', '#' .. bgColor)
        :css('color', '#' .. textColor)
        :css('text-align', 'right')
        :attr('width', width and (width .. '%'))
        :wikitext(title)
        :done()
        :tag('td')
        :attr('colspan', colspan)
        :wikitext(content)
        :done())
end

function p.PrevNextLine(options)
    options = getArgs(options, {
        aliases = {
            dprev = { 1 },
            dnext = { 2 },
            link1 = { 3 },
            link2 = { 4 },
            arrowSize = { 5 },
            colspan = { "colspan" },
        }
    })

    local prevText = trim(options.dprev or '')
    local nextText = trim(options.dnext or '')
    if prevText == '' and nextText == '' then return '' end

    local colspan = tonumber(options.colspan) or 2
    local arrowSize = tonumber(options.arrowSize) or 13
    local link1 = trim(options.link1 or '')
    local link2 = trim(options.link2 or '')

    local prevBg = prevText ~= '' and '#E6E6E6' or 'transparent'
    local nextBg = nextText ~= '' and '#E6E6E6' or 'transparent'

    local content1 = arrowTemplate('Fleche-defaut-droite.png', link1, arrowSize)
    local content2 = arrowTemplate('Fleche-defaut-gauche.png', link2, arrowSize)

    return tostring(mw.html.create('tr')
        :tag('td')
        :attr('colspan', colspan)
        :attr('align', 'center')
        :tag('table')
        :css({ ['background-color'] = '#eeeeee', margin = '0', ['border-collapse'] = 'collapse' })
        :attr({ cellspacing = 0, width = '100%' })
        :tag('tr')
        :tag('td')
        :attr('width', '50%')
        :tag('table')
        :css({ ['background-color'] = prevBg, margin = '0', ['border-collapse'] = 'collapse' })
        :attr({ cellspacing = 0, width = '100%' })
        :tag('tr')
        :tag('td')
        :attr('width', '20')
        :attr('align', 'right')
        :wikitext(content1)
        :done()
        :tag('td')
        :css({ ['text-align'] = 'right', ['font-size'] = '80%' })
        :wikitext(prevText)
        :done()
        :done()
        :done()
        :done()
        :tag('td')
        :attr('width', '50%')
        :tag('table')
        :css({ ['background-color'] = nextBg, margin = '0', ['border-collapse'] = 'collapse' })
        :attr({ cellspacing = 0, width = '100%' })
        :tag('tr')
        :tag('td')
        :css({ ['text-align'] = 'left', ['font-size'] = '80%' })
        :wikitext(nextText)
        :done()
        :tag('td')
        :attr('width', '20')
        :attr('align', 'left')
        :wikitext(content2)
        :done()
        :done()
        :done()
        :done()
        :done()
        :done()
        :done())
end

function p.PrevNextLine1(options)
    options = getArgs(options, {
        aliases = {
            dprev = { 1 },
            dnext = { 2 },
            link1 = { 3 },
            link2 = { 4 },
            arrowSize = { 5 },
            colspan = { "colspan" },
            right_arrow = { "سهم يمين" },
            left_arrow = { "سهم يسار" },
        }
    })

    local prevText = getValidValue(options.dprev)
    local nextText = getValidValue(options.dnext)
    if not prevText and not nextText then return '' end

    local colspan = tonumber(options.colspan) or 2
    local arrowSize = tonumber(options.arrowSize) or 8
    local link1 = trim(options.link1 or '')
    local link2 = trim(options.link2 or '')

    local rightArrow = getValidValue(options.right_arrow, 'Fleche-defaut-droite-gris-32.png')
    local leftArrow = getValidValue(options.left_arrow, 'Fleche-defaut-gauche-gris-32.png')

    local content1 = arrowTemplate(rightArrow, link1, arrowSize)
    local content2 = arrowTemplate(leftArrow, link2, arrowSize)

    local row = mw.html.create('tr')
    local cell = row:tag('td')
        :attr('colspan', colspan)
        :css('align', 'center')

    cell:tag('div')
        :css('float', 'right')
        :tag('span')
        :css({ ['text-align'] = 'right', width = '5%', ['margin-left'] = '3px' })
        :wikitext(content1)
        :done()
        :tag('span')
        :css({ ['font-size'] = '90%', ['text-align'] = 'right' })
        :wikitext(getValidValue(prevText) or "&nbsp;")
        :done()
        :done()

    cell:tag('div')
        :css('float', 'left')
        :tag('span')
        :css({ ['font-size'] = '90%', ['text-align'] = 'left' })
        :wikitext(getValidValue(nextText) or "&nbsp;")
        :done()
        :tag('span')
        :css({ ['text-align'] = 'left', width = '5%', ['margin-right'] = '3px' })
        :wikitext(content2)
        :done()
        :done()

    return tostring(row)
end

function p.open(frame) return p.Open(frame.args) end

function p.close(frame) return p.Close() end

function p.title(frame) return p.Title(frame.args) end

function p.icoTitle(frame) return p.IcoTitle(frame.args) end

function p.subTitle(frame) return p.SubTitle(frame.args) end

function p.line(frame) return p.Line(frame.args) end

function p.mixedLine(frame) return p.MixedLine(frame.args) end

function p.prevNextLine(frame) return p.PrevNextLine(frame.args) end

function p.prevNextLine1(frame) return p.PrevNextLine1(frame.args) end

return p
