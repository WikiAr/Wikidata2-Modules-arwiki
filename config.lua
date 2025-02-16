return {
    max_claims_to_use_hidelist = 5,
    max_number_of_ref = 7,
    i18n = {
        local_lang = "ar",
        local_lang_qids = { ["P407"] = 13955, ["P282"] = 8196 }, -- Q13955 = "العربية", Q8196 = "أبجدية عربية"
        errors = {
            ["property-param-not-provided"] = "وسيط property غير متوفر.",
            ["entity-not-found"] = "الكيان غير موجود.",
            ["unknown-claim-type"] = "نوع claim غير معروف.",
            ["unknown-snak-type"] = "نوع snak غير معروف.",
            ["unknown-datatype"] = "نوع data غير معروف.",
            ["unknown-entity-type"] = "نوع entity غير معروف.",
            ["property-module-not-found"] = "الوحدة المستخدمة في وسيط property-module غير موجودة.",
            ["property-function-not-found"] = "الوظيفة المستخدمة في وسيط property-function غير موجودة.",
            ["value-module-not-found"] = "الوحدة المستخدمة في وسيط value-module غير موجودة.",
            ["value-function-not-found"] = "الوظيفة المستخدمة في وسيط value-function غير موجودة.",
            ["claim-module-not-found"] = "الوحدة المستخدمة في وسيط claim-module غير موجودة.",
            ["claim-function-not-found"] = "الوظيفة المستخدمة في وسيط claim-function غير موجودة."
        },
        noarabiclabel = "تصنيف:صفحات ويكي بيانات بحاجة لتسمية عربية",
        warnDump = "[[تصنيف:Called function 'Dump' from module Wikidata]]",
        somevalue = "", --'"غير محدد"'
        novalue = "",   --قيمة مجهولة
        cateref = "[[تصنيف:صفحات بها مراجع ويكي بيانات]]",
        tracking_category = "تصنيف:صفحات بها بيانات ويكي بيانات",
        trackingcat = "صفحات تستخدم خاصية $1",
        list = "القائمة",
        sandbox = "ملعب",
        no = "لا",
        official_site = "الموقع الرسمي",
        year_ = "سنة ",
        not_valid_qid = " لا يمثل معرف ويكي بيانات صحيح",
    },
    falsetitles = {
        "قالب:قيمة ويكي بيانات",
        "وحدة:Wikidata2"
    },
    skiip_items = {
        P106 = {
            "Q42857",    -- prophet
            "Q14886050", -- terrorist
            "Q2159907"   -- criminal
        }
    }
}
