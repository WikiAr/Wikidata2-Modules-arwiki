local p = {}
local getArgs = require('Module:Arguments with aliases').getArgs

local function valid_value(x)
    if x and x ~= "" then return x end
    return nil
end

local function trim(s)
    return (mw.ustring.gsub(s, "^%s*(.-)%s*$", "%1"))
end

local function xtrim(s, v)
    local a = trim(s or '');
    if a and a ~= '' then return a; else return v; end;
end

local function trim_color(s)
    local a = trim(s)
    --Removes # from value
    if a:sub(1, 1) == "#" then
        return a:sub(2)
    else
        return a
    end
end

function p.Open(options)
    local id = options['id'] or ""
    if valid_value(id) then
        id = ' id="' .. id .. '"'
    end
    local templatestyles = mw.getCurrentFrame():extensionTag('templatestyles', '', { src = "ص.م/styles.css" })
        .. mw.getCurrentFrame():extensionTag('templatestyles', '', { src = "بطاقة/icones.css" });
    return templatestyles .. '<table cellspacing="3px" class="infobox2" style="width:22em"' .. id .. '>'
end

function p.Close(options)
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
    local title = options.title or ''
    local colspan = tonumber(options.colspan) or 2;
    local class_td = trim(valid_value(options.entete) or 'entete map');
    local bg_color = trim_color(valid_value(options.bg_color) or 'E1E1E1');
    local txt_color = trim_color(valid_value(options.txt_color) or '000000');

    local res = mw.html.create('tr')
        :tag('th')
        :addClass(class_td)
        :attr('scope', 'col')
        :css('line-height', '2em')
        :css('background-color', '#' .. bg_color)
        :css('color', '#' .. txt_color)
        :attr('colspan', colspan)
        :wikitext(trim(title))
        :done()

    return tostring(res)
end

function p.IcoTitle(options)
    local colspan = tonumber(options[5]) or tonumber(options["colspan"]) or 2;
    local icon = trim(options[3] or 'Nuvola apps important.png');
    local bg_color = trim_color(options[2] or 'E1E1E1');
    local txt_color = trim_color(options[4] or '000000');
    local aright = trim(options['right'] or '');
    local ctxt1 = ''
    local ctxt2 = ''

    if aright ~= ''
    then
        ctxt1 = '[[ملف:' .. icon .. '|45x45px|center|alt=|link=]]';
        ctxt2 = '[[ملف:Pix.gif|45x45px|center|alt=|link=]]';
    else
        ctxt1 = '[[ملف:Pix.gif|45x45px|center|alt=|link=]]';
        ctxt2 = '[[ملف:' .. icon .. '|45x45px|center|alt=|link=]]';
    end

    local res = mw.html.create('tr')
        :tag('th')
        :attr('colspan', colspan)
        :tag('table')
        :attr('cellpadding', 0)
        :attr('cellspacing', 0)
        :attr('width', '100%')
        :css('text-align', 'center')
        :tag('tr')
        :addClass('entete defaut')
        :css('background-color', '#' .. bg_color)
        :tag('td')
        :attr('width', '10%')
        :wikitext(ctxt1)
        :done()
        :tag('td')
        :attr('width', '80%')
        :css('color', '#' .. txt_color)
        :wikitext(trim(options[1]))
        :done()
        :tag('td')
        :attr('width', '10%')
        :wikitext(ctxt2)
        :done()
        :done() --tr
        :done() -- tab
        :done() --th
        :done() --tr
    return tostring(res)
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
    local title = trim(options.title or '');
    local showTitle = trim(options.showTitle or '');
    local bg_color = trim_color(valid_value(options.bg_color) or 'E1E1E1');
    local txt_color = trim_color(valid_value(options.txt_color) or '000000');
    local colspan = tonumber(options.colspan) or 2;

    if not valid_value(showTitle) then
        return ''
    end
    local res = mw.html.create('tr')
        :tag('th')
        :attr('scope', 'col')
        :css('background-color', '#' .. bg_color)
        :css('color', '#' .. txt_color)
        :css('text-align', 'center')
        :attr('colspan', colspan)
        :wikitext(title)
        :done()

    return tostring(res)
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
    local showLine = trim(options.showLine or '');
    local content = trim(options.content or '');
    local textAlign = xtrim(options.textAlign, 'center');
    local bg_color = xtrim(options.bg_color, 'F9F9F9');
    local txt_color = xtrim(options.txt_color, '000000');
    local colspan = tonumber(options.colspan) or 2;
    local lineHeight = tonumber(options.lineHeight) or 0;

    bg_color = trim_color(bg_color)
    txt_color = trim_color(txt_color)

    if content == ''
    then
        content = showLine;
    end;

    if not valid_value(showLine) then
        return ''
    end
    local res = mw.html.create('tr')
        :tag('td')
        :attr('scope', 'col')
        :css('background-color', '#' .. bg_color)
        :css('color', '#' .. txt_color)
        :css('text-align', textAlign)
        :attr('colspan', colspan)
        :wikitext(content)
        :done()

    if lineHeight ~= 0 then
        res:tag('tr'):tag('td'):css('height', lineHeight .. 'px')
    end

    return tostring(res)
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
    local colspan = tonumber(options.colspan) or 0;
    local bg_color = xtrim(options.bg_color, 'F3F3F3');
    local txt_color = xtrim(options.txt_color, '000000');
    local showLine = trim(options.showLine or '');
    local title = trim(options.title or '');
    local content = trim(options.content or '');
    local width = tonumber(options.width) or 0;

    bg_color = trim_color(bg_color)
    txt_color = trim_color(txt_color)

    if content == ''
    then
        content = showLine;
    end;

    if not valid_value(showLine) then
        return ''
    end

    local res = mw.html.create('tr')
    local resth = mw.html.create('th')
        :attr('scope', 'row')
        :css('background-color', '#' .. bg_color)
        :css('color', '#' .. txt_color)
        :css('text-align', 'right')
        :wikitext(title)
        :done()
    local restd = mw.html.create('td')
        --		:css('background-color', '#'..bg_color)
        --		:css('color', '#'..txt_color)
        :wikitext(content)
        :done()

    if width ~= 0
    then
        resth:attr('width', width .. '%')
    end
    if colspan ~= 0
    then
        restd:attr('colspan', colspan)
    end
    res:node(resth)
    res:node(restd)
    return tostring(res)
end

function p.PrevNextLine(options)
    options = getArgs(options, {
        aliases = {
            dprev = { 1 },
            dnext = { 2 },
            link1 = { 3 },
            link2 = { 4 },
            colspan = { "colspan" },
        }
    })
    local dprev = trim(options.dprev or '');
    local dnext = trim(options.dnext or '');
    local colspan = tonumber(options.colspan) or '2';
    local bgc1 = 'transparent';
    local bgc2 = 'transparent';
    local link1 = trim(options.link1 or '');
    local link2 = trim(options.link2 or '');
    local arrowSize = tonumber(options[5]) or 13;

    if not valid_value(dprev) and not valid_value(dnext) then
        return ''
    end

    if dprev ~= '' then
        bgc1 = '#E6E6E6';
    end;

    if dnext ~= '' then
        bgc2 = '#E6E6E6';
    end;
    local content1 = '[[ملف:Fleche-defaut-droite.png|' .. arrowSize .. 'px|link=' .. link1 .. ']]'
    local content2 = '[[ملف:Fleche-defaut-gauche.png|' .. arrowSize .. 'px|link=' .. link2 .. ']]'
    local res = mw.html.create('tr')
        :tag('td')
        :attr('colspan', colspan)
        :attr('align', 'center')
        :tag('table')
        :css('background-color', '#eeeeee')
        :css('margin', '0 0 0 0')
        :css('border-collapse', 'collapse')
        :attr('cellspacing', 0)
        :attr('width', '100%')
        :tag('tr')
        :tag('td')
        :attr('width', '50%')
        :tag('table')
        :css('background-color', bgc1)
        :css('margin', '0 0 0 0')
        :css('border-collapse', 'collapse')
        :attr('cellspacing', 0)
        :attr('width', '100%')
        :tag('tr')
        :tag('td')
        :attr('width', '20')
        :attr('align', 'right')
        :wikitext(content1)
        :done()
        :tag('td')
        :css('text-align', 'right')
        :css('font-size', '80%')
        :wikitext(dprev)
        :done()
        :done()
        :done()
        :done()
        :tag('td')
        :attr('width', '50%')
        :tag('table')
        :css('background-color', bgc2)
        :css('margin', '0 0 0 0')
        :css('border-collapse', 'collapse')
        :attr('cellspacing', 0)
        :attr('width', '100%')
        :tag('tr')
        :tag('td')
        :css('text-align', 'left')
        :css('font-size', '80%')
        :wikitext(dnext)
        :done()
        :tag('td')
        :attr('width', '20')
        :attr('align', 'left')
        :wikitext(content2)
        :done()
        :done() -- tr
        :done() --tab
        :done() --td
        :done() -- tr
        :done() --tab
        :done() -- td
    return tostring(res)
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
    local dprev = trim(options.dprev or '');
    local dnext = trim(options.dnext or '');
    local colspan = tonumber(options.colspan) or '2';
    local link1 = trim(options.link1 or '');
    local link2 = trim(options.link2 or '');
    local arrowSize = tonumber(options.arrowSize) or 8;

    if dprev == '' and dnext == '' then return ''; end;

    local img1 = valid_value(options.right_arrow) or "Fleche-defaut-droite-gris-32.png"
    local content1 = '[[ملف:' .. img1 .. '|' .. arrowSize .. 'px|link=' .. link1 .. ']]'

    local img2 = valid_value(options.left_arrow) or "Fleche-defaut-gauche-gris-32.png"
    local content2 = '[[ملف:' .. img2 .. '|' .. arrowSize .. 'px|link=' .. link2 .. ']]'

    local row = mw.html.create('tr')
    local cell = row:tag('td')
        :attr('colspan', colspan)
        :css('align', 'center')

    local predecessor_div = mw.html.create('div')
        :css('float', 'right')
    predecessor_div:tag('span')
        :css('text-align', 'right')
        :css('width', '5%')
        :css('margin-left', '3px')
        :wikitext(content1)
    predecessor_div:tag('span')
        :css('font-size', '90%')
        :css('text-align', 'right')
        :wikitext(valid_value(dprev) or "&nbsp;")

    local successor_div = mw.html.create('div')
        :css('float', 'left')
    successor_div:tag('span')
        :css('font-size', '90%')
        :css('text-align', 'left')
        :wikitext(valid_value(dnext) or "&nbsp;")
    successor_div:tag('span')
        :css('text-align', 'left')
        :css('width', '5%')
        :css('margin-right', '3px')
        :wikitext(content2)

    cell:node(predecessor_div)
    cell:node(successor_div)

    row:done()

    return tostring(row)
end

function p.open(frame) return p.Open(frame.args) end

function p.close(frame) return p.Close(frame.args) end

function p.title(frame) return p.Title(frame.args) end

function p.icoTitle(frame) return p.IcoTitle(frame.args) end

function p.subTitle(frame) return p.SubTitle(frame.args) end

function p.line(frame) return p.Line(frame.args) end

function p.mixedLine(frame) return p.MixedLine(frame.args) end

function p.prevNextLine(frame) return p.PrevNextLine(frame.args) end

function p.prevNextLine1(frame) return p.PrevNextLine1(frame.args) end

return p
