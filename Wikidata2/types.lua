--[[
Wikidata2 Type Definitions
==========================

This file contains comprehensive type annotations for the Wikidata2 module system
using LuaCATS/EmmyLua format. These annotations provide:
- IDE autocompletion support
- Static type checking with lua-language-server
- Documentation for all data structures

Usage: Add `require("Module:Wikidata2/types")` at the top of your module
or configure your IDE to include this file for type checking.

@copyright 2026 Wikidata2-Modules-arwiki Contributors
@license CC BY-SA 4.0
]]

---@meta
---@diagnostic disable: lowercase-global, undefined-global

-- ============================================================================
-- GLOBAL MW NAMESPACE EXTENSIONS
-- ============================================================================

---@class mw
---@field wikibase mw.wikibase Wikibase interface functions
---@field title mw.title Title operations
---@field language mw.language Language utilities
---@field html mw.html HTML generation
---@field text mw.text Text manipulation
---@field uri mw.uri URI handling
---@field log fun(...: any): nil Log messages to debug console
---@field addWarning fun(msg: string): nil Add warning message to page output
---@field dumpObject fun(obj: any, opts?: table): string Serialize object to string
---@field getCurrentFrame fun(): Frame Get the current parser frame

---@class Frame
---@field args table<string, string> Frame arguments
---@field getParent fun(self: Frame): Frame Get parent frame
---@field extensionTag fun(self: Frame, name: string, content: string?, attrs: table?): string Render extension tag
---@field callParserFunction fun(self: Frame, name: string, args: table?): string Call parser function
---@field expandTemplate fun(self: Frame, options: {title: string, args: table?}): string Expand template
---@field preprocess fun(self: Frame, wikitext: string): string Preprocess wikitext

---@class mw.wikibase
---@field getEntity fun(id?: string): Entity? Get entity by ID or current page
---@field getEntityIdForCurrentPage fun(): string? Get entity ID for current page
---@field getEntityIdForTitle fun(title: string, wiki?: string): string? Get entity ID for title
---@field getLabel fun(id: string): string? Get label in content language
---@field getLabelByLang fun(id: string, lang: string): string? Get label in specific language
---@field getDescriptionByLang fun(id: string, lang: string): string? Get description in specific language
---@field getDescriptionWithLang fun(id: string): string?, string Get description with language code
---@field getSitelink fun(id: string, site?: string): string? Get site link
---@field getBestStatements fun(id: string, property: string): Statement[] Get best statements
---@field getAllStatements fun(id: string, property: string): Statement[] Get all statements
---@field isValidEntityId fun(id: string): boolean Check if ID is valid format
---@field entityExists fun(id: string): boolean Check if entity exists
---@field getReferencedEntityId fun(id: string, property: string, targets: string[]): string? Get referenced entity ID

---@class mw.language
---@field getContentLanguage fun(): mw.language.object Get content language object
---@field fetchLanguageName fun(code: string, inLanguage?: string): string Get language name
---@field new fun(code: string): mw.language.object Create language object

---@class mw.language.object
---@field code string Language code
---@field ucfirst fun(self: mw.language.object, s: string): string Uppercase first character
---@field formatNum fun(self: mw.language.object, n: number, options?: table): string Format number
---@field formatDate fun(self: mw.language.object, format: string, timestamp?: string): string Format date

---@class mw.html
---@field create fun(tag: string): mw.html.builder Create HTML builder

---@class mw.html.builder
---@field attr fun(self: mw.html.builder, attrs: table): mw.html.builder Set attributes
---@field css fun(self: mw.html.builder, styles: table): mw.html.builder Set CSS
---@field addClass fun(self: mw.html.builder, class: string): mw.html.builder Add class
---@field wikitext fun(self: mw.html.builder, text: string): mw.html.builder Add wikitext
---@field tag fun(self: mw.html.builder, tag: string): mw.html.builder Create nested tag
---@field done fun(self: mw.html.builder): mw.html.builder Return to parent
---@field allDone fun(self: mw.html.builder): string Finalize and get HTML string

-- ============================================================================
-- WIKIDATA TYPE DEFINITIONS
-- ============================================================================

--- Wikibase entity identifier (e.g., "Q123" for items, "P456" for properties)
---@alias WikibaseId string

--- Wikibase property identifier (e.g., "P31" for instance of)
---@alias PropertyId string

--- Site identifier (e.g., "arwiki", "enwiki")
---@alias SiteId string

--- Snak type indicating the value status
---@alias SnakType "value"|"somevalue"|"novalue"

--- Statement rank indicating reliability
---@alias StatementRank "preferred"|"normal"|"deprecated"

--- Date precision levels matching Wikidata precision values
---@alias DatePrecision
---| 0  # Billion years
---| 1  # Hundred million years
---| 2  # Ten million years
---| 3  # Million years
---| 4  # Hundred thousand years
---| 5  # Ten thousand years
---| 6  # Millennium
---| 7  # Century
---| 8  # Decade
---| 9  # Year
---| 10 # Month
---| 11 # Day
---| 12 # Hour
---| 13 # Minute
---| 14 # Second

--- Data types supported by Wikibase
---@alias DataType
---| "wikibase-item"
---| "wikibase-property"
---| "string"
---| "external-id"
---| "commonsMedia"
---| "time"
---| "globe-coordinate"
---| "quantity"
---| "url"
---| "monolingualtext"
---| "math"
---| "geo-shape"
---| "tabular-data"

-- ============================================================================
-- CORE WIKIDATA DATA STRUCTURES
-- ============================================================================

--- Base snak structure containing a single value assertion
---@class Snak
---@field snaktype SnakType Type of the snak
---@field property PropertyId Property ID this snak belongs to
---@field datatype DataType? Data type of the value
---@field datavalue Datavalue? The actual value (nil for somevalue/novalue)

--- Container for a data value with type information
---@class Datavalue
---@field value any The actual value (structure depends on type)
---@field type string Value type (e.g., "wikibase-entityid", "string", "time")

--- A full statement (claim) on a Wikibase entity
---@class Statement
---@field type "statement" Statement type identifier
---@field id string Unique statement ID (e.g., "Q123$456-7890")
---@field rank StatementRank Statement rank
---@field mainsnak Snak The main value snak
---@field qualifiers table<PropertyId, Snak[]>? Qualifier snaks grouped by property
---@field references Reference[]? Reference snaks
---@field qualifiers-order PropertyId[]? Order of qualifiers

--- A reference (source) for a statement
---@class Reference
---@field snaks table<PropertyId, Snak[]> Reference snaks grouped by property
---@field snaks-order PropertyId[]? Order of snaks
---@field hash string Reference hash

--- A Wikibase entity
---@class Entity
---@field id WikibaseId Entity ID
---@field type "item"|"property" Entity type
---@field labels table<string, Term>? Labels by language code
---@field descriptions table<string, Term>? Descriptions by language code
---@field aliases table<string, Term[]>? Aliases by language code
---@field claims table<PropertyId, Statement[]>? Statements by property
---@field sitelinks table<string, SiteLink>? Site links by site ID

--- A localized term (label, description, or alias)
---@class Term
---@field language string Language code
---@field value string Term text
---@field source string? Source of the term

--- A site link to a wiki page
---@class SiteLink
---@field site SiteId Site identifier (e.g., "arwiki")
---@field title string Page title
---@field badges string[] Badge identifiers

-- ============================================================================
-- DATATYPE-SPECIFIC VALUE STRUCTURES
-- ============================================================================

--- Time value structure
---@class TimeValue
---@field time string ISO 8601 timestamp (e.g., "+2024-01-15T00:00:00Z")
---@field precision DatePrecision Precision of the date
---@field before integer Digits before the date that are uncertain
---@field after integer Digits after the date that are uncertain
---@field timezone integer Timezone offset in minutes
---@field calendarmodel string Calendar model URI

--- Globe coordinate value structure
---@class GlobeCoordinateValue
---@field latitude number Latitude in degrees
---@field longitude number Longitude in degrees
---@field precision number Precision in degrees
---@field globe string Globe/celestial body URI
---@field dimension number? Dimension in meters

--- Quantity value structure
---@class QuantityValue
---@field amount string Amount as string (may include + prefix)
---@field unit string Unit URI or "1" for unitless
---@field upperBound string? Upper bound of uncertainty
---@field lowerBound string? Lower bound of uncertainty

--- Monolingual text value structure
---@class MonolingualTextValue
---@field language string Language code
---@field text string Text content

--- Wikibase entity ID value structure
---@class EntityIdValue
---@field id WikibaseId Entity ID (e.g., "Q123")
---@field numeric-id integer Numeric part of entity ID
---@field entity-type "item"|"property" Entity type

-- ============================================================================
-- MODULE OPTIONS STRUCTURES
-- ============================================================================

--- Base options for formatting operations
---@class BaseOptions
---@field noref boolean? Skip reference formatting
---@field nolink boolean? Skip linking to local wiki
---@field raw boolean? Return raw value
---@field rawtolua boolean? Return raw value as Lua dump
---@field nocate boolean? Skip tracking categories
---@field notracking boolean? Skip all tracking

--- Main options for formatStatements function
---@class FormatOptions: BaseOptions
---@field property PropertyId Property ID to fetch (required)
---@field entityId WikibaseId? Entity ID to fetch from
---@field entity Entity? Pre-loaded entity object
---@field pid PropertyId? Alias for property
---@field qid WikibaseId? Alias for entityId
---@field page string? Page title to get entity from
---@field formatting string? Output format ("raw", "sitelink", "label", etc.)
---@field pattern string? Pattern with $1 placeholder for value
---@field stringpattern string? Pattern specifically for string values
---@field rank StatementRank|"valid"|"best"|"all"? Statement rank filter
---@field separator string? Separator between multiple values
---@field conjunction string? Conjunction for last value
---@field langpref string? Preferred language code
---@field modifytime string? Time formatting modifier ("q", "precision", "longdate", etc.)
---@field modifyqualifiertime string? Qualifier time formatting modifier
---@field formatcharacters string? Character formatting ("lcfirst", "ucfirst", "lc", "uc", "formatnum")
---@field somevalue string? Text for somevalue snaktype
---@field novalue string? Text for novalue snaktype
---@field firstvalue boolean|string? Return only first value
---@field enbarten boolean|string? Alias for firstvalue
---@field numval integer? Maximum number of values
---@field limit integer? Maximum number of statements to process
---@field offset integer? Starting offset in statements
---@field numberofclaims boolean? Return count of claims
---@field numberofreferences integer? Maximum references per statement
---@field justthisqual PropertyId? Return only qualifier value
---@field justref boolean? Return only references
---@field onlyvaluewithref boolean? Return value only if referenced
---@field withdate string? Add date qualifier ("y", "before")
---@field bothdates string? Add start/end qualifiers ("line", "before")
---@field sortbytime string? Sort by time qualifier
---@field sortbynumber string? Sort by number qualifier
---@field sortbyarbitrary string? Sort by arbitrary property
---@field sort_before_filter boolean? Sort before filtering
---@field sortingproperty string|PropertyId[]? Properties for sorting
---@field addTrackingCat boolean? Add tracking categories
---@field mainprefix string? Prefix for all output
---@field mainsuffix string? Suffix for all output
---@field mainsuffixAfterIcon string? Suffix after wikidata icon
---@field hidden boolean|string? Enable collapsible list
---@field barlist boolean? Enable bar list formatting

--- Options for qualifier formatting
---@field qual1 PropertyId? First qualifier property
---@field qual1a PropertyId? First qualifier alternative
---@field qual2 PropertyId? Second qualifier property
---@field qual3 PropertyId? Third qualifier property
---@field qual4 PropertyId? Fourth qualifier property
---@field qual5 PropertyId? Fifth qualifier property
---@field qual1pref string? Prefix for first qualifier
---@field qualifierprefix string? Prefix for all qualifiers
---@field qualifiersuffix string? Suffix for all qualifiers
---@field qualifierseparator string? Separator between qualifier values
---@field qualifierconjunction string? Conjunction for last qualifier

--- Options for value filtering
---@field avoidvalue string|WikibaseId[]? Values to exclude
---@field prefervalue string|WikibaseId[]? Values to prefer
---@field avoidqualifier PropertyId? Qualifier to avoid
---@field avoidqualifiervalue string|WikibaseId[]? Qualifier values to avoid
---@field preferqualifier PropertyId? Qualifier to prefer
---@field preferqualifiervalue string|WikibaseId[]? Qualifier values to prefer
---@field getonly string|WikibaseId[]? Include only these values
---@field getonlyproperty PropertyId? Property for getonly check
---@field dontget string|WikibaseId[]? Exclude these values
---@field dontgetproperty PropertyId? Property for dontget check

--- Options for custom formatting modules
---@field value-module string? Module name for custom value formatting
---@field value-function string? Function name for custom value formatting
---@field claim-module string? Module name for custom claim formatting
---@field claim-function string? Function name for custom claim formatting
---@field property-module string? Module name for property-level formatting
---@field property-function string? Function name for property-level formatting

--- Options for related properties
---@field property1 PropertyId? First related property (for flags, images)
---@field property1pattern string? Pattern for property1
---@field property1rank StatementRank? Rank for property1
---@field property1pref string? Prefix for property1
---@field property1suff string? Suffix for property1
---@field property1after boolean? Place property1 after main value
---@field property2 PropertyId? Second related property
---@field property2pattern string? Pattern for property2
---@field propertyimage PropertyId? Property for image
---@field propertyimageformatting string? Formatting for image property

--- Options for media and display
---@field size string? Image size (e.g., "280x330px", "20")
---@field image string? Enable image output ("image")
---@field center boolean? Center the image
---@field showlang boolean? Show language label for monolingual text
---@field textformat string? Text format for monolingual text

--- Options for quantity formatting
---@field unitshort boolean? Use short unit labels
---@field nounit boolean? Omit unit from output
---@field nounitlink boolean? Don't link units
---@field label string? Custom label for units
---@field formatcoord string? Coordinate format

--- Options for URLs
---@field label string? Link label
---@field urllabel string? URL-specific label

--- Complete options structure
---@class Options: FormatOptions, BaseOptions

-- ============================================================================
-- MODULE OUTPUT STRUCTURES
-- ============================================================================

--- Result from formatting functions
---@class FormatResult
---@field value string Formatted value string
---@field label string? Extracted label
---@field item WikibaseId? Related entity ID
---@field raw Statement[]? Raw statements
---@field amount string? Amount for quantity values
---@field unit string? Formatted unit for quantity values
---@field unitraw string? Raw unit ID for quantity values
---@field ref string? Reference output
---@field reff string? Formatted references
---@field formated_quals table Formatted qualifiers

--- Result from formatOneStatement
---@class StatementResult
---@field v string? Formatted value
---@field raw FormatResult Raw statement data

--- Result from formatEntityId
---@class EntityIdResult
---@field value string Formatted entity display
---@field label string Entity label

--- Result from Labelfunction
---@class LabelResult
---@field value string Label text
---@field cat string Tracking category

-- ============================================================================
-- CONFIGURATION STRUCTURES
-- ============================================================================

--- Internationalization configuration
---@class I18nConfig
---@field local_lang string Local language code
---@field local_lang_qids table<PropertyId, integer> Local language property QIDs
---@field categories CategoriesConfig Category configuration
---@field errors ErrorsConfig Error message configuration
---@field somevalue string Text for somevalue
---@field novalue string Text for novalue
---@field list string "List" text
---@field sandbox string Sandbox suffix
---@field no string "No" text
---@field official_site string Official site text
---@field year_ string Year prefix
---@field not_valid_qid string Invalid QID message
---@field see-wikidata-value string Wikidata link title
---@field see-wikidata string Wikidata link text
---@field see-another-project string Another project link text
---@field see-another-language string Another language link text

--- Category configuration
---@class CategoriesConfig
---@field noarabiclabel string Category for missing Arabic labels
---@field cateref string Category for pages with references
---@field tracking_category string Tracking category pattern
---@field dump_warn_category string Category for dump function usage
---@field no_female_labels string Category for missing female labels
---@field trackingcat string Tracking category pattern

--- Error message configuration
---@class ErrorsConfig
---@field property_param_not_provided string
---@field entity_not_found string
---@field unknown_claim_type string
---@field unknown_snak_type string
---@field unknown_datatype string
---@field unknown_entity_type string
---@field property_module_not_found string
---@field property_function_not_found string
---@field value_module_not_found string
---@field value_function_not_found string
---@field claim_module_not_found string
---@field claim_function_not_found string

--- Main configuration
---@class Config
---@field max_claims_to_use_hidelist integer Maximum claims before collapsible
---@field max_number_of_ref integer Maximum references per statement
---@field i18n I18nConfig Internationalization config
---@field falsetitles string[] Titles to skip tracking
---@field skip_items table<PropertyId, WikibaseId[]> Items to skip by property

-- ============================================================================
-- MODULE TYPE DECLARATIONS
-- ============================================================================

--- Main Wikidata2 module
---@class Wikidata2Module
---@field formatStatements fun(frame: Frame|Options, key?: Statement[]): string|Statement[] Main entry point
---@field formatStatementsFromLua fun(options: Options, key?: Statement[]): string? Lua entry point
---@field fs fun(frame: Frame, key?: Statement[]): string Shorthand for formatStatements
---@field formatAndCat fun(args: Options): string? Format with categories
---@field formatSnak fun(snak: Snak, options: Options): FormatResult Format a snak
---@field formatEntityId fun(entityId: WikibaseId, options?: Options): EntityIdResult Format entity ID
---@field getLabel fun(entity: WikibaseId, lang?: string): string? Get entity label
---@field getSiteLink fun(frame: Frame): string? Get site link
---@field pageId fun(frame: Frame): string? Get current page entity ID
---@field descriptionIn fun(frame: Frame): string Get description
---@field labelIn fun(frame: Frame): string? Get label
---@field addLinkBack fun(str: string, id: WikibaseId?, property: PropertyId?): string Add edit link
---@field translate fun(str: string, rep1?: string, rep2?: string): string Translate i18n string
---@field getId fun(snak: Snak): WikibaseId? Get entity ID from snak
---@field countSiteLinks fun(id: WikibaseId): integer Count site links
---@field EntityIdForTitle fun(frame: Frame): string? Get entity ID for title
---@field Qidfortitleandwiki fun(frame: Frame): string? Get entity ID for title on wiki
---@field isSubclass fun(frame: Frame): boolean? Check subclass relationship
---@field ViewSomething fun(frame: Frame): string? Debug view entity data
---@field Dump fun(frame: Frame): string Debug dump entity data

--- Filter claims module
---@class FilterClaimsModule
---@field filter_claims fun(claims: Statement[], options: Options): Statement[] Filter claims
---@field get_snak_id fun(snak: Statement): WikibaseId? Get entity ID from statement

--- Sort claims module
---@class SortClaimsModule
---@field sort_claims fun(claims: Statement[], options: Options): Statement[] Sort claims
---@field sortbyqualifiernumber fun(claims: Statement[], sorting_properties: PropertyId[], sortingproperty_option: string?, sort_by: string): Statement[] Sort by qualifier
---@field sortingproperties PropertyId[] Default sorting properties
---@field sorting_methods table<string, string> Sorting method aliases

--- Time formatting module
---@class TimeModule
---@field getdate fun(time1: TimeValue, options: Options): string Format time value

--- Monolingual text module
---@class MonolingualTextModule
---@field _main fun(datavalue: Datavalue, datatype: string, options: Options): string Format monolingual text
---@field main fun(frame: Frame): string Frame entry point

--- Tracking/category module
---@class TrackModule
---@field makecategory1 fun(options: Options): string? Create tracking category
---@field makecategory fun(frame: Frame): string? Frame entry point
---@field make1 fun(property: PropertyId, entityId?: WikibaseId): string? Simplified category
---@field pageId fun(): string? Get current page entity ID

--- Dump/debug module
---@class DumpModule
---@field Dump fun(frame: Frame): string Debug dump
---@field ViewSomething fun(frame: Frame): string? View entity data
---@field isSubclass fun(frame: Frame): boolean? Check subclass
---@field Subclass fun(options: {parent: string, id?: WikibaseId, property?: PropertyId}): boolean? Check subclass

-- ============================================================================
-- PROPERTY MODULE TYPE DECLARATIONS
-- ============================================================================

--- P39 (position held) module
---@class P39Module
---@field office3 fun(statement: Statement, options: Options): string Format position held

--- P54 (member of sports team) module
---@class P54Module
---@field football fun(statement: Statement, options: Options): {value: string, Type: string}? Format team membership
---@field foot fun(claims: Statement[], options: Options): string Format all team memberships

--- P569/P570 (birth/death date) module
---@class P569P570Module
---@field getdate fun(datavalue: Datavalue, datatype: string, options: Options): string Format birth/death date
---@field test fun(frame: Frame): string Test function

--- P106 (occupation) module
---@class P106Module
---@field occupation fun(datavalue: Datavalue, datatype: string, options: Options): {value: string} Format occupation

--- P1082 (population) module
---@class P1082Module
---@field population fun(datavalue: Datavalue, datatype: string, options: Options): {value: string} Format population

--- Coordinates module
---@class CoordinatesModule
---@field coordinates fun(datavalue: Datavalue, datatype: string, options: Options): {value: string} Format coordinates

--- Awards module
---@class AwardsModule
---@field awards fun(statement: Statement, options: Options): string? Format award

--- Taxonomy module
---@class TaxModule
---@field tax fun(claims: Statement[], options: Options): string Format taxonomy

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

--- Check if a value is valid (not nil or empty)
---@param x any Value to check
---@return any|nil Returns the value if valid, nil otherwise
local function isvalid(x)
    if x and x ~= "" then
        return x
    end
    return nil
end

--- Check if a value is valid and not equal to "no"
---@param x any Value to check
---@param no_value string? Value to treat as "no"
---@return any|nil Returns the value if valid, nil otherwise
local function isvalid_with_no(x, no_value)
    no_value = no_value or "لا"
    if x and x ~= "" and x ~= no_value then
        return x
    end
    return nil
end

--- Get first valid value from a list
---@param xs any[] List of values to check
---@return any|nil First valid value or nil
local function isvalids(xs)
    for _, x in ipairs(xs) do
        if x and x ~= "" then
            return x
        end
    end
    return nil
end

--- Format error message
---@param key string Error message key
---@param i18n table Internationalization table
---@return string Error message
local function formatError(key, i18n)
    return i18n.errors[key] or ("Error: " .. key)
end

--- Format string using pattern
---@param str string String to format
---@param pattern string Pattern with $1 placeholder
---@return string Formatted string
local function formatFromPattern(str, pattern)
    if not pattern or pattern == "" then
        return str
    end
    str = str:gsub("%%", "%%%%")
    return pattern:gsub("$1", str)
end

return {
    isvalid = isvalid,
    isvalid_with_no = isvalid_with_no,
    isvalids = isvalids,
    formatError = formatError,
    formatFromPattern = formatFromPattern,
}
