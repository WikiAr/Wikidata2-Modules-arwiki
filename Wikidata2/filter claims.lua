--[[
================================================================================
Wikidata2 Filter Claims Module
================================================================================

This module provides comprehensive filtering capabilities for Wikidata statements
(claims). It supports multiple filtering strategies including:
  - Value-based filtering (include/exclude specific entity IDs)
  - Qualifier-based filtering (filter by qualifier presence/values)
  - Property-based filtering (filter by "instance of" relationships)
  - Pagination (limit, offset)
  - Language preference filtering

@module Wikidata2/filter_claims
@author Wikidata2-Modules-arwiki Contributors
@license CC BY-SA 4.0
@copyright 2026 Wikimedia Community

@usage
    local filterclaims = require("Module:Wikidata2/filter claims")
    local filtered = filterclaims.filter_claims(claims, options)

@see https://www.mediawiki.org/wiki/Extension:Scribunto/Lua_reference_manual
@see https://www.wikidata.org/wiki/Help:Statements
]]

---@diagnostic disable: lowercase-global

local p = {}

-- ============================================================================
-- MODULE SETUP
-- ============================================================================

--- Sandbox suffix for test module loading
local sandbox = "ملعب"
local sandbox_added = ""

-- Detect sandbox mode from frame title
if nil ~= string.find(mw.getCurrentFrame():getTitle(), sandbox, 1, true) then
    sandbox_added = "/" .. sandbox
end

--- Load configuration module
---@type Config
local config = mw.loadData('Module:Wikidata2/config' .. sandbox_added)

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

--[[
Checks if a value is valid (not nil and not empty string).

@param x any Value to validate
@return any|nil Original value if valid, nil otherwise
]]
local function isvalid(x)
    if x and x ~= nil and x ~= "" then
        return x
    end
    return nil
end

--[[
Converts a value to a table for filtering operations.

Accepts:
  - nil/empty -> returns nil
  - string with comma-separated values -> returns split table
  - table -> returns as-is

@param values string|table|nil Input to convert
@return table|nil Table of values or nil
]]
local function table_or_nil(values)
    local q_values = {}

    if not isvalid(values) then
        return nil
    end

    if type(values) == "string" then
        q_values = mw.text.split(values, ",")
    elseif type(values) == "table" then
        q_values = values
    end

    if #q_values == 0 then
        q_values = nil
    end

    return q_values
end

--[[
Parses a value to a number.

@param value any Value to parse
@return number|nil Parsed number or nil
]]
local function parse_number(value)
    if type(value) == "number" then
        return value
    end
    return tonumber(value)
end

--[[
Checks if a table contains a specific element.

Performs linear search through table values.

@param tbl table Table to search
@param element any Element to find
@return boolean True if found, false otherwise

@performance O(n) - Consider using hash tables for frequent lookups
]]
local function table_contains(tbl, element)
    for _, value in pairs(tbl) do
        if value == element then
            return true
        end
    end
    return false
end

-- ============================================================================
-- ENTITY ID EXTRACTION
-- ============================================================================

--[[
Extracts the entity ID from a statement's mainsnak.

Navigates through the statement structure safely:
  statement.mainsnak.datavalue.value.id

This function performs comprehensive null checks at each level
to handle malformed or incomplete statement structures.

@function p.get_snak_id
@param statement Statement The statement to extract from
@return string|nil Entity ID (e.g., "Q123"), or nil if not found

@usage
    local qid = p.get_snak_id(statement)
    if qid then
        -- Process the entity
    end

@note Only works for statements with wikibase-entityid datavalue type.
]]
function p.get_snak_id(statement)
    -- Comprehensive null-safe navigation
    if not statement then return nil end
    if statement.type ~= "statement" then return nil end

    local mainsnak = statement.mainsnak
    if not mainsnak then return nil end
    if mainsnak.snaktype ~= "value" then return nil end

    local datavalue = mainsnak.datavalue
    if not datavalue then return nil end
    if datavalue.type ~= "wikibase-entityid" then return nil end

    local value = datavalue.value
    if not value then return nil end

    return value.id
end

-- ============================================================================
-- VALUE-BASED FILTERING
-- ============================================================================

--[[
Filters claims by their main entity value.

This function filters statements based on whether their main entity ID
matches or doesn't match a list of specified IDs. Used for:
  - avoidvalue: Exclude statements with specific entity values
  - prefervalue: Include only statements with specific entity values

@function filter_by_value
@param claims Statement[] Array of statements to filter
@param option string|table|nil Comma-separated string or table of entity IDs
@param mode string "avoid" to exclude, "prefer" to include only matching
@return Statement[] Filtered array of statements

@usage
    -- Exclude Q123 and Q456
    claims = filter_by_value(claims, "Q123,Q456", "avoid")

    -- Include only Q789
    claims = filter_by_value(claims, {"Q789"}, "prefer")
]]
local function filter_by_value(claims, option, mode)
    option = table_or_nil(option)

    if not isvalid(option) then
        return claims
    end

    local filtered_claims = {}

    for _, claim in pairs(claims) do
        local snak_id = p.get_snak_id(claim)
        local is_included = table_contains(option, snak_id)

        -- Apply filter based on mode
        if mode == "avoid" then
            -- Include if NOT in the exclusion list
            if snak_id and not is_included then
                table.insert(filtered_claims, claim)
            elseif not snak_id then
                -- Include statements without entity IDs (edge case)
                table.insert(filtered_claims, claim)
            end
        elseif mode == "prefer" then
            -- Include only if IN the preference list
            if snak_id and is_included then
                table.insert(filtered_claims, claim)
            end
        end
    end

    return filtered_claims
end

-- ============================================================================
-- QUALIFIER-BASED FILTERING
-- ============================================================================

--[[
Checks if any qualifier in a list matches the specified values.

Used internally by filter_by_qualifier to check if a statement's
qualifiers contain any of the target values.

@param qualifiers Snak[] Array of qualifier snaks
@param values table Array of entity ID strings to match
@return boolean True if any qualifier matches, false otherwise
]]
local function any_qualifier_matches(qualifiers, values)
    if not qualifiers then
        return false
    end

    for _, qual in pairs(qualifiers) do
        if qual.snaktype == "value"
            and qual.datavalue
            and qual.datavalue.value
            and qual.datavalue.value.id
            and table_contains(values, qual.datavalue.value.id) then
            return true
        end
    end

    return false
end

--[[
Filters claims by qualifier presence and/or values.

This function filters statements based on their qualifiers:
  - avoidqualifier: Exclude statements with a specific qualifier (optionally with specific values)
  - preferqualifier: Include only statements with a specific qualifier (optionally with specific values)

@function filter_by_qualifier
@param claims Statement[] Array of statements to filter
@param option string|nil Qualifier property ID (e.g., "P585")
@param values string|table|nil Comma-separated string or table of entity IDs to match
@param mode string "avoid" to exclude, "prefer" to include only matching
@return Statement[] Filtered array of statements

@usage
    -- Exclude statements with qualifier P585 (point in time)
    claims = filter_by_qualifier(claims, "P585", nil, "avoid")

    -- Include only statements with P580 (start time) = Q123
    claims = filter_by_qualifier(claims, "P580", "Q123", "prefer")

    -- Include only statements with P580 having any of these values
    claims = filter_by_qualifier(claims, "P580", {"Q123", "Q456"}, "prefer")
]]
local function filter_by_qualifier(claims, option, values, mode)
    if not isvalid(option) then
        return claims
    end

    local qualifier_id = option:upper()
    local q_values = table_or_nil(values)
    local filtered_claims = {}

    for _, statement in pairs(claims) do
        local qualifiers = statement.qualifiers and statement.qualifiers[qualifier_id]

        if mode == "prefer" then
            -- Include only statements with the qualifier
            if qualifiers then
                if isvalid(q_values) then
                    -- Check if qualifier value matches
                    if any_qualifier_matches(qualifiers, q_values) then
                        table.insert(filtered_claims, statement)
                    end
                else
                    -- Any qualifier value is acceptable
                    table.insert(filtered_claims, statement)
                end
            end

        elseif mode == "avoid" then
            -- Exclude statements with the qualifier
            if not qualifiers then
                -- No qualifier - include
                table.insert(filtered_claims, statement)
            elseif isvalid(q_values) then
                -- Has qualifier - check if value matches
                if not any_qualifier_matches(qualifiers, q_values) then
                    table.insert(filtered_claims, statement)
                end
            end
            -- If qualifiers exist and no specific values, exclude (don't add)
        end
    end

    return filtered_claims
end

-- ============================================================================
-- PAGINATION FUNCTIONS
-- ============================================================================

--[[
Limits the number of claims returned.

Returns only the first `maxCount` claims from the array.

@param claims Statement[] Array of statements
@param maxCount integer Maximum number to return
@return Statement[] Limited array of statements
]]
local function claims_limit(claims, maxCount)
    if #claims <= maxCount then
        return claims
    end
    return { unpack(claims, 1, maxCount) }
end

--[[
Skips the first N claims (offset pagination).

Returns claims starting from position `startOffset + 1`.

@param claims Statement[] Array of statements
@param startOffset integer Number of claims to skip
@return Statement[] Offset array of statements
]]
local function claims_offset(claims, startOffset)
    if #claims <= startOffset then
        return claims
    end
    return { unpack(claims, startOffset + 1, #claims) }
end

-- ============================================================================
-- LANGUAGE FILTERING
-- ============================================================================

--[[
Filters claims to prefer those in the local language.

For multilingual properties, this function filters claims to show only
those that have qualifiers indicating content in the wiki's language.
The language QIDs are configured in config.i18n.local_lang_qids.

If no claims match the language criteria, all original claims are returned
(fallback behavior).

@function filter_langs
@param claims Statement[] Array of statements to filter
@return Statement[] Filtered array, or original if no matches

@usage
    claims = filter_langs(claims)

@note Uses local_lang_qids from configuration:
      - P407 (language of work): Q13955 (Arabic)
      - P282 (writing system): Q8196 (Arabic script)
]]
local function filter_langs(claims)
    local filtered_claims = {}
    local arabic_ids = config.i18n.local_lang_qids

    for _, statement in pairs(claims) do
        if statement.qualifiers then
            for prop, id in pairs(arabic_ids) do
                local qualifier_values = statement.qualifiers[prop]
                if qualifier_values then
                    for _, v in pairs(qualifier_values) do
                        if v.snaktype == "value"
                            and v.datavalue
                            and v.datavalue.value
                            and v.datavalue.value["numeric-id"] == id then
                            table.insert(filtered_claims, statement)
                            break
                        end
                    end
                end
            end
        end
    end

    -- Return filtered claims only if we found matches
    -- Otherwise return original claims (fallback)
    if #filtered_claims > 0 then
        return filtered_claims
    end

    return claims
end

-- ============================================================================
-- INSTANCE-OF FILTERING
-- ============================================================================

--[[
Filters claims based on the "instance of" (P31) relationship.

This advanced filter checks if the entity referenced by a claim is
an instance of specific classes. It's useful for filtering by type:
  - getonly: Include only entities that are instances of specified classes
  - dontget: Exclude entities that are instances of specified classes

@function filter_get_only_or_dont
@param claims Statement[] Array of statements to filter
@param option string|table|nil Comma-separated string or table of class Q-IDs
@param f_property string? Property to check (default: "P31" - instance of)
@param mode string "get" to include, "dont" to exclude
@return Statement[] Filtered array of statements

@usage
    -- Include only human settlements (Q486972)
    claims = filter_get_only_or_dont(claims, "Q486972", "P31", "get")

    -- Exclude rivers (Q4022)
    claims = filter_get_only_or_dont(claims, "Q4022", "P31", "dont")

@performance Warning: This function makes additional Wikidata API calls
              for each claim, which can impact performance. Use sparingly.
]]
local function filter_get_only_or_dont(claims, option, f_property, mode)
    f_property = f_property or "P31"
    local claims2 = {}
    local values = table_or_nil(option) or {}
    local is_dont_mode = (mode == "dont")

    for _, claim in pairs(claims) do
        local id = p.get_snak_id(claim)
        if id then
            local valid = is_dont_mode -- Default: exclude in "dont" mode, include in "get" mode

            -- Fetch P31 (instance of) statements for this entity
            local t2 = mw.wikibase.getBestStatements(id, f_property)

            if t2 and #t2 > 0 then
                for _, claim2 in pairs(t2) do
                    local snak2 = p.get_snak_id(claim2)
                    if snak2 and table_contains(values, snak2) then
                        valid = not is_dont_mode -- Found match: include in "get" mode
                        break
                    end
                end
            end

            if valid then
                table.insert(claims2, claim)
            end
        end
    end

    return claims2
end

-- ============================================================================
-- COUNT FILTERING
-- ============================================================================

--[[
Limits the number of claims to a maximum.

Similar to claims_limit but with different semantics - used for
the numval option which limits output display count.

@param claims Statement[] Array of statements
@param numval integer Maximum number of claims
@return Statement[] Limited array
]]
local function filter_numval(claims, numval)
    if #claims > 1 and #claims > numval then
        return { unpack(claims, 1, numval) }
    end
    return claims
end

--[[
Returns only a specific claim by position.

When firstvalue is a number, returns only that position (1-indexed).
When firstvalue is truthy but not a number, returns the first claim.

@param claims Statement[] Array of statements
@param firstvalue integer|boolean|string Position or truthy value
@return Statement[] Array with single claim, or original array
]]
local function filter_first(claims, firstvalue)
    local first = tonumber(firstvalue)

    if isvalid(first) and #claims > 1 then
        -- Ensure position is within bounds
        local position = math.max(1, math.min(first, #claims))
        return { claims[position] }
    elseif isvalid(firstvalue) and #claims > 0 then
        -- Return first claim
        return { claims[1] }
    end

    return claims
end

-- ============================================================================
-- MAIN FILTER FUNCTION
-- ============================================================================

--[[
Main entry point for claim filtering.

Applies all configured filters to the claims array in the optimal order.
Filter order is designed to minimize API calls and maximize efficiency:
  1. Instance-of filtering (getonly/dontget) - makes API calls
  2. Offset (skip first N)
  3. Limit (take first N)
  4. Qualifier filtering
  5. Value filtering
  6. Language preference
  7. First value selection
  8. Count limit

@function p.filter_claims
@param claims Statement[] Array of statements to filter
@param options Options Filter configuration options
@return Statement[] Filtered array of statements

@option options.getonly string|table Class Q-IDs to include
@option options.getonlyproperty string Property to check (default: P31)
@option options.dontget string|table Class Q-IDs to exclude
@option options.dontgetproperty string Property to check (default: P31)
@option options.offset integer Number of claims to skip
@option options.limit integer Maximum claims to return
@option options.avoidqualifier string Qualifier property ID to avoid
@option options.avoidqualifiervalue string|table Qualifier values to avoid
@option options.preferqualifier string Qualifier property ID to require
@option options.preferqualifiervalue string|table Qualifier values to require
@option options.avoidvalue string|table Entity IDs to exclude
@option options.prefervalue string|table Entity IDs to include only
@option options.langpref string Language preference (skips language filter if set)
@option options.enbarten boolean Return only first value (alias for firstvalue)
@option options.firstvalue boolean|integer Return only first or specific value
@option options.numval integer Maximum number of values

@usage
    local options = {
        property = "P19",
        avoidvalue = "Q1",
        limit = 5,
        firstvalue = true
    }
    local filtered = p.filter_claims(claims, options)

@note Claims array is not modified in place; a new array is returned.
]]
function p.filter_claims(claims, options)
    -- Work with a copy to avoid modifying the original
    local claims = claims

    -- ========================================
    -- 1. INSTANCE-OF FILTERING
    -- ========================================

    -- Filter to include only entities of specific types
    if isvalid(options.getonly) then
        claims = filter_get_only_or_dont(claims, options.getonly, options.getonlyproperty, "get")
    end

    -- Filter to exclude entities of specific types
    if isvalid(options.dontget) then
        claims = filter_get_only_or_dont(claims, options.dontget, options.dontgetproperty, "dont")
    end

    -- ========================================
    -- 2. PAGINATION (OFFSET)
    -- ========================================

    local offset = parse_number(options.offset)
    if isvalid(offset) then
        claims = claims_offset(claims, offset)
    end

    -- ========================================
    -- 3. PAGINATION (LIMIT)
    -- ========================================

    local limit = parse_number(options.limit)
    if isvalid(limit) then
        claims = claims_limit(claims, limit)
    end

    -- ========================================
    -- 4. QUALIFIER FILTERING
    -- ========================================

    -- Exclude statements with specific qualifier
    if isvalid(options.avoidqualifier) then
        claims = filter_by_qualifier(
            claims,
            options.avoidqualifier,
            options.avoidqualifiervalue,
            "avoid"
        )
    end

    -- Include only statements with specific qualifier
    if isvalid(options.preferqualifier) then
        claims = filter_by_qualifier(
            claims,
            options.preferqualifier,
            options.preferqualifiervalue,
            "prefer"
        )
    end

    -- ========================================
    -- 5. VALUE FILTERING
    -- ========================================

    -- Exclude statements with specific entity values
    if isvalid(options.avoidvalue) then
        claims = filter_by_value(claims, options.avoidvalue, "avoid")
    end

    -- Include only statements with specific entity values
    if isvalid(options.prefervalue) then
        claims = filter_by_value(claims, options.prefervalue, "prefer")
    end

    -- ========================================
    -- 6. LANGUAGE FILTERING
    -- ========================================

    -- Filter to local language (skip if langpref is set)
    if not isvalid(options.langpref) then
        claims = filter_langs(claims)
    end

    -- ========================================
    -- 7. FIRST VALUE SELECTION
    -- ========================================

    local firstvalue = isvalid(options.enbarten) or isvalid(options.firstvalue)
    if firstvalue then
        claims = filter_first(claims, firstvalue)
    end

    -- ========================================
    -- 8. COUNT LIMIT
    -- ========================================

    local numval = parse_number(options.numval)
    if isvalid(numval) then
        claims = filter_numval(claims, numval)
    end

    return claims
end

return p
