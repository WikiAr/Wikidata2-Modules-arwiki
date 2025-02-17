local p = {}

local eth = {
    ["Q49085"] = {
        ["male"] = "أمريكي أفريقي ",
        ["female"] = "أمريكية أفريقية",
        ["na"] = "أمريكيون أفارقة"
    }, --	African Americans
    ["Q201190"] = {
        ["male"] = "فلسطيني ",
        ["female"] = "فلسطينية",
        ["na"] = "فلسطينيون"
    }, --	Palestinians
    ["Q79797"] = {
        ["male"] = "أرمني ",
        ["female"] = "أرمنية",
        ["na"] = "أرمن"
    }, --	Armenians
    ["Q179248"] = {
        ["male"] = "ألباني ",
        ["female"] = "ألبانية",
        ["na"] = "ألبان"
    }, --	Albanians
    ["Q539051"] = {
        ["male"] = "يوناني ",
        ["female"] = "يونانية",
        ["na"] = "يونانيون"
    }, --	Greeks
    ["Q161652"] = {
        ["male"] = "ياباني ",
        ["female"] = "يابانية",
        ["na"] = "شعب ياباني"
    }, --	Japanese people
    ["Q127885"] = {
        ["male"] = "صربي ",
        ["female"] = "صربية",
        ["ششna"] = "صرب"
    }, --	Serbs
    ["Q7325"] = {
        ["male"] = "يهودي ",
        ["female"] = "يهودية",
        ["na"] = "يهود"
    }, --	Jews
    ["Q2325516"] = {
        ["male"] = "أرمني أمريكي ",
        ["female"] = "أرمنية أمريكية",
        ["na"] = "أرمن الولايات المتحدة"
    }, --	Armenian American
    ["Q187985"] = {
        ["male"] = "تبتي ",
        ["female"] = "تبتية",
        ["na"] = "شعب التبت"
    }, --	Tibetan people
    ["Q115026"] = {
        ["male"] = "أمريكي سويدي ",
        ["female"] = "أمريكية سويدية",
        ["na"] = "أمريكيون سويديون"
    }, --	Swedish American
    ["Q678551"] = {
        ["male"] = "يهودي أمريكي ",
        ["female"] = "يهودية أمريكية",
        ["na"] = "يهود أمريكيون"
    }, --	American Jews
    ["Q35323"] = {
        ["male"] = "عربي ",
        ["female"] = "عربية",
        ["na"] = "عرب"
    }, --	Arab
    ["Q7129609"] = {
        ["male"] = "قوقازي ",
        ["female"] = "قوقازية",
        ["na"] = "عرق قوقازي"
    }, --	Caucasian race
    ["Q133255"] = {
        ["male"] = "بلغاري ",
        ["female"] = "بلغارية",
        ["na"] = "بلغار"
    }, --	Bulgarians
    ["Q42406"] = {
        ["male"] = "إنجليزي ",
        ["female"] = "إنجليزية",
        ["na"] = "إنجليز"
    }, --	English people
    ["Q1026"] = {
        ["male"] = "بولندي ",
        ["female"] = "بولندية",
        ["na"] = "بولنديون"
    }, --	Poles
    ["Q42884"] = {
        ["male"] = "ألماني ",
        ["female"] = "ألمانية",
        ["na"] = "ألمان"
    }, --	Germans
    ["Q244504"] = {
        ["male"] = "كتلاني ",
        ["female"] = "كتلانية",
        ["na"] = "كتالان"
    }, --	Catalan people
    ["Q402913"] = {
        ["male"] = "بنغالي ",
        ["female"] = "بنغالية",
        ["na"] = "شعوب البنغال"
    }, --	Bengali people
    ["Q49078"] = {
        ["male"] = "أمريكي أبيض ",
        ["female"] = "أمريكية بيضاء",
        ["na"] = "أمريكيون بيض"
    }, --	White American
    ["Q485150"] = {
        ["male"] = "روماني ",
        ["female"] = "رومانية",
        ["na"] = "رومانيون"
    }, --	Romanians
    ["Q2436423"] = {
        ["male"] = "مقدوني ",
        ["female"] = "مقدونية",
        ["na"] = "مقدونيون"
    }, --	Macedonians
    ["Q121842"] = {
        ["male"] = "فرنسي ",
        ["female"] = "فرنسية",
        ["na"] = "فرنسيون"
    }, --	French people
    ["Q133032"] = {
        ["male"] = "مجري ",
        ["female"] = "مجرية",
        ["na"] = "مجريون"
    }, --	Hungarian people
    ["Q49542"] = {
        ["male"] = "روسي ",
        ["female"] = "روسية",
        ["na"] = "روس"
    }, --	Russians
    ["Q1075293"] = {
        ["male"] = "أمريكي أيرلندي ",
        ["female"] = "أمريكية أيرلندية",
        ["na"] = "أمريكيون أيرلنديون"
    }, --	Irish American
    ["Q974693"] = {
        ["male"] = "إيطالي أمريكي ",
        ["female"] = "أيطالية أمريكية",
        ["na"] = "أمريكيون إيطاليون"
    } --	Italian American
}

local function get_lab(entityId, gender, options)
    local vv = formatEntityId(entityId, options)
    local label

    if eth[entityId] then
        if gender == "Q6581072" then
            label = eth[entityId]["female"]
        elseif gender == "Q6581097" then
            label = eth[entityId]["male"]
        else
            label = eth[entityId]["na"]
        end
        vv = formatEntityId(entityId, { label = label })
    end

    return vv
end

function p.get_P172_lab(datavalue, datatype, options)
    local value = datavalue.value
    local entityId = datavalue.value.id

    local gender = formatStatements({
        property = "P21",
        entityId = options.entityId,
        noref = "true",
        rank = "all",
        firstvalue = "true",
        separator = "",
        conjunction = "",
        formatting = "raw"
    })


    local label = get_lab(entityId, gender, options).value
    return label
end

return p
