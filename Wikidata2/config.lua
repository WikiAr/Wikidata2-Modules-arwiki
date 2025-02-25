return {
    max_claims_to_use_hidelist = 5,
    max_number_of_ref = 7,
    i18n = {
        local_lang = "ar", -- mw.getContentLanguage():getCode()
        local_lang_qids = {
            P407 = 13955,  -- "العربية"
            P282 = 8196    --   = "أبجدية عربية"
        },
        categories = {
            noarabiclabel = "تصنيف:صفحات ويكي بيانات بحاجة لتسمية عربية",
            cateref = "تصنيف:صفحات بها مراجع ويكي بيانات",
            tracking_category = "تصنيف:صفحات بها بيانات ويكي بيانات",
            dump_warn_category = "Category:Called function 'Dump' from module Wikidata",
            no_female_labels = 'تصنيف:صفحات بها مهن بحاجة للتأنيث',
            trackingcat = "صفحات تستخدم خاصية $1",
        },
        errors = {
            property_param_not_provided = "وسيط property غير متوفر.",
            entity_not_found = "الكيان غير موجود.",
            unknown_claim_type = "نوع claim غير معروف.",
            unknown_snak_type = "نوع snak غير معروف.",
            unknown_datatype = "نوع data غير معروف.",
            unknown_entity_type = "نوع entity غير معروف.",
            property_module_not_found = "الوحدة المستخدمة في وسيط property-module غير موجودة.",
            property_function_not_found = "الوظيفة المستخدمة في وسيط property-function غير موجودة.",
            value_module_not_found = "الوحدة المستخدمة في وسيط value-module غير موجودة.",
            value_function_not_found = "الوظيفة المستخدمة في وسيط value-function غير موجودة.",
            claim_module_not_found = "الوحدة المستخدمة في وسيط claim-module غير موجودة.",
            claim_function_not_found = "الوظيفة المستخدمة في وسيط claim-function غير موجودة."
        },
        somevalue = "", --'"غير محدد"'
        novalue = "",   --قيمة مجهولة
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
    skip_items = {
        P106 = {
            "Q42857",    -- نبي
            "Q14886050", -- إرهابي
            "Q2159907"   -- مجرم
        }
    }
}
