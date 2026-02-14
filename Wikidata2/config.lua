--[[
================================================================================
Wikidata2 Configuration Module
================================================================================

This module provides centralized configuration for the Wikidata2 system used on
Arabic Wikipedia. It contains internationalization settings, error messages,
category names, and system-wide defaults.

@module Wikidata2/config
@author Wikidata2-Modules-arwiki Contributors
@license CC BY-SA 4.0
@copyright 2026 Wikimedia Community

@usage
    local config = mw.loadData('Module:Wikidata2/config')
    local max_refs = config.max_number_of_ref
    local error_msg = config.i18n.errors.property_param_not_provided

@see https://www.mediawiki.org/wiki/Extension:Scribunto/Lua_reference_manual
]]

---@class Config
---@field max_claims_to_use_hidelist integer Maximum number of claims before using collapsible list
---@field max_number_of_ref integer Maximum number of references to display per statement
---@field i18n I18nConfig Internationalization configuration
---@field falsetitles string[] Page titles that should not receive tracking categories
---@field skip_items table<string, string[]> Entity IDs to skip by property ID

return {
    --[[
    Maximum number of claims to display inline before switching to a
    collapsible/hidden list format. This prevents infobox bloat when
    entities have many values for a single property.

    @type integer
    @default 5
    ]]
    max_claims_to_use_hidelist = 5,

    --[[
    Maximum number of reference citations to display per statement.
    Additional references beyond this limit are hidden to prevent
    excessive vertical space usage in infoboxes.

    @type integer
    @default 7
    ]]
    max_number_of_ref = 7,

    --[[
    Internationalization (i18n) configuration containing all localizable
    strings, error messages, and language-specific settings.

    @type table
    ]]
    i18n = {
        --[[
        Local language code for the wiki. This determines which language
        is used for label lookups and formatting when no specific language
        is requested.

        @type string
        ]]
        local_lang = "ar", -- mw.getContentLanguage():getCode()

        --[[
        Wikidata property and value QIDs that identify content in the local
        language. Used to filter multilingual values to show only those
        relevant to the wiki's language.

        Structure:
            - P407: Language of work (Q13955 = Arabic language)
            - P282: Writing system (Q8196 = Arabic alphabet)

        @type table<string, integer>
        ]]
        local_lang_qids = {
            P407 = 13955,  -- "العربية" (Arabic language)
            P282 = 8196    -- "أبجدية عربية" (Arabic alphabet)
        },

        --[[
        Category configuration for tracking and maintenance.
        All categories are Arabic Wikipedia category names.

        @type table
        ]]
        categories = {
            -- Pages with Wikidata items lacking Arabic labels
            noarabiclabel = "تصنيف:صفحات ويكي بيانات بحاجة لتسمية عربية",

            -- Pages that display Wikidata references
            cateref = "تصنيف:صفحات بها مراجع ويكي بيانات",

            -- Pages that use Wikidata values (tracking)
            tracking_category = "تصنيف:صفحات بها بيانات ويكي بيانات",

            -- Pages where Dump() debug function was called
            dump_warn_category = "Category:Called function 'Dump' from module Wikidata",

            -- Pages with occupations needing female label variants
            no_female_labels = 'تصنيف:صفحات بها مهن بحاجة للتأنيث',

            -- Pattern for property-specific tracking categories
            -- $1 is replaced with property ID
            trackingcat = "صفحات تستخدم خاصية $1",
        },

        --[[
        Error message strings for various failure conditions.
        These messages are displayed to users when errors occur.

        @type table<string, string>
        ]]
        errors = {
            -- Required property parameter not provided
            property_param_not_provided = "وسيط property غير متوفر.",

            -- Requested entity does not exist
            entity_not_found = "الكيان غير موجود.",

            -- Unknown statement type encountered
            unknown_claim_type = "نوع claim غير معروف.",

            -- Unknown snak type in data structure
            unknown_snak_type = "نوع snak غير معروف.",

            -- Unknown data type for value formatting
            unknown_datatype = "نوع data غير معروف.",

            -- Unknown entity type (not item or property)
            unknown_entity_type = "نوع entity غير معروف.",

            -- Custom property module not found
            property_module_not_found = "الوحدة المستخدمة في وسيط property-module غير موجودة.",

            -- Function not found in property module
            property_function_not_found = "الوظيفة المستخدمة في وسيط property-function غير موجودة.",

            -- Custom value module not found
            value_module_not_found = "الوحدة المستخدمة في وسيط value-module غير موجودة.",

            -- Function not found in value module
            value_function_not_found = "الوظيفة المستخدمة في وسيط value-function غير موجودة.",

            -- Custom claim module not found
            claim_module_not_found = "الوحدة المستخدمة في وسيط claim-module غير موجودة.",

            -- Function not found in claim module
            claim_function_not_found = "الوظيفة المستخدمة في وسيط claim-function غير موجودة."
        },

        --[[
        Text to display for "somevalue" snak type (value exists but is unknown).
        Empty string means nothing is displayed.

        @type string
        ]]
        somevalue = "", --'"غير محدد"'

        --[[
        Text to display for "novalue" snak type (no value applies).
        Empty string means nothing is displayed.

        @type string
        ]]
        novalue = "",   --قيمة مجهولة

        --[[
        Label for collapsible list header.
        Displayed when many values are shown in a collapsed container.

        @type string
        ]]
        list = "القائمة",

        --[[
        Suffix added to module names when in sandbox mode.
        Arabic word for "sandbox" - used for testing changes.

        @type string
        ]]
        sandbox = "ملعب",

        --[[
        Negative response value. When a parameter equals this value,
        it is treated as false/disabled.

        @type string
        ]]
        no = "لا",

        --[[
        Default label for official website links (P856).
        Used when no custom label is provided.

        @type string
        ]]
        official_site = "الموقع الرسمي",

        --[[
        Prefix added before year values in certain contexts.
        Used in date qualifier formatting.

        @type string
        ]]
        year_ = "سنة ",

        --[[
        Error message suffix for invalid Wikidata identifiers.
        Appended after the invalid ID.

        @type string
        ]]
        not_valid_qid = " لا يمثل معرف ويكي بيانات صحيح",
    },

    --[[
    Page titles that should not receive tracking categories.
    These are typically template pages and module documentation pages
    where tracking would create maintenance noise.

    @type string[]
    ]]
    falsetitles = {
        "قالب:قيمة ويكي بيانات",  -- Template:Wikidata value
        "وحدة:Wikidata2"          -- Module:Wikidata2
    },

    --[[
    Entity IDs to skip by property. Values matching these IDs
    will not be displayed, even if present in Wikidata.

    This is used to filter out sensitive or controversial values
    that may be present in Wikidata but should not appear in infoboxes.

    Structure:
        - Key: Property ID (e.g., "P106" for occupation)
        - Value: Array of Q-IDs to skip for that property

    @type table<string, string[]>
    ]]
    skip_items = {
        -- Property P106 (occupation) exclusions:
        P106 = {
            "Q42857",    -- نبي (prophet) - religious sensitivity
            "Q14886050", -- إرهابي (terrorist) - controversial label
            "Q2159907"   -- مجرم (criminal) - potentially defamatory
        }
    }
}
