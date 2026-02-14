--[[
================================================================================
Wikidata2 Utility Module
================================================================================

This module provides shared utility functions used across all Wikidata2 modules.
It centralizes common validation, sandbox detection, and formatting functions
to ensure consistency and reduce code duplication.

@module Wikidata2/utils
@author Wikidata2-Modules-arwiki Contributors
@license CC BY-SA 4.0
@copyright 2026 Wikimedia Community

@usage
    local utils = require("Module:Wikidata2/utils")
    local is_valid = utils.isvalid("test")
    local sandbox_suffix = utils.get_sandbox_suffix()

@see https://www.mediawiki.org/wiki/Extension:Scribunto/Lua_reference_manual
]]

---@meta
---@diagnostic disable: lowercase-global

local p = {}

-- ============================================================================
-- CONSTANTS
-- ============================================================================

--- Arabic word for sandbox, used as suffix for test modules
p.SANDBOX = "ملعب"

--- Value that represents "no" or disabled state
p.NO_VALUE = "لا"

-- ============================================================================
-- SANDBOX DETECTION
-- ============================================================================

--[[
Detects if the current module is running in sandbox mode.

In MediaWiki, sandbox modules are named with a suffix (e.g., "/ملعب" in Arabic).
This function checks the current frame's title to determine if we're in a sandbox.

@function get_sandbox_suffix
@treturn string Returns "/ملعب" if in sandbox mode, empty string otherwise

@usage
    local suffix = utils.get_sandbox_suffix()
    local config = mw.loadData('Module:Wikidata2/config' .. suffix)

@note This function must be called from within a module context where
      mw.getCurrentFrame() is available.
]]
function p.get_sandbox_suffix()
    local frame = mw.getCurrentFrame()
    if not frame then
        return ""
    end

    local title = frame:getTitle()
    if title and string.find(title, p.SANDBOX, 1, true) then
        return "/" .. p.SANDBOX
    end

    return ""
end

--[[
Gets the sandbox suffix with caching for performance.

This is a memoized version of get_sandbox_suffix that caches the result
after the first call, avoiding repeated frame title lookups.

@function get_cached_sandbox_suffix
@treturn string Returns "/ملعب" if in sandbox mode, empty string otherwise

@usage
    local suffix = utils.get_cached_sandbox_suffix()
]]
local cached_sandbox_suffix = nil

function p.get_cached_sandbox_suffix()
    if cached_sandbox_suffix == nil then
        cached_sandbox_suffix = p.get_sandbox_suffix()
    end
    return cached_sandbox_suffix
end

-- ============================================================================
-- VALIDATION FUNCTIONS
-- ============================================================================

--[[
Checks if a value is valid (not nil and not empty string).

This is the standard validation function used throughout Wikidata2.
A value is considered invalid if it is:
  - nil
  - An empty string ("")

@function isvalid
@param x any The value to validate
@return any|nil Returns the original value if valid, nil otherwise

@usage
    if utils.isvalid(options.property) then
        -- property exists and is not empty
    end

@note This function does NOT check for the "no" value. Use isvalid_with_no
      if you need to exclude the "لا" (no) value.
]]
function p.isvalid(x)
    if x ~= nil and x ~= "" then
        return x
    end
    return nil
end

--[[
Checks if a value is valid and not equal to the "no" value.

In addition to checking for nil and empty strings, this also checks
if the value equals the configured "no" value (default: "لا").

@function isvalid_with_no
@param x any The value to validate
@param no_value string? Optional custom "no" value (default: "لا")
@return any|nil Returns the original value if valid, nil otherwise

@usage
    -- Returns nil if options.nolink == "لا"
    if utils.isvalid_with_no(options.nolink) then
        -- nolink is set to something other than "no"
    end
]]
function p.isvalid_with_no(x, no_value)
    no_value = no_value or p.NO_VALUE
    if x ~= nil and x ~= "" and x ~= no_value then
        return x
    end
    return nil
end

--[[
Returns the first valid value from a list.

Iterates through a list of values and returns the first one that
passes the isvalid() check. Useful for handling multiple aliases
for the same parameter.

@function first_valid
@param xs any[] List of values to check
@return any|nil Returns the first valid value, or nil if none are valid

@usage
    -- Check multiple aliases for entity ID
    local id = utils.first_valid({
        options.entityId,
        options.id,
        options.qid
    })
]]
function p.first_valid(xs)
    if type(xs) ~= "table" then
        return p.isvalid(xs)
    end

    for _, x in pairs(xs) do
        local valid = p.isvalid(x)
        if valid then
            return valid
        end
    end

    return nil
end

--[[
Checks if a value is invalid (nil, empty, or "no").

This is the inverse of isvalid_with_no, useful for conditional checks.

@function not_valid
@param x any The value to check
@param no_value string? Optional custom "no" value (default: "لا")
@return boolean Returns true if the value is invalid, false otherwise

@usage
    if utils.not_valid(options.nolink) then
        -- nolink is not set or is "no"
    end
]]
function p.not_valid(x, no_value)
    return p.isvalid_with_no(x, no_value) == nil
end

-- ============================================================================
-- STRING UTILITIES
-- ============================================================================

--[[
Formats a string using a pattern with $1 placeholder.

Replaces $1 in the pattern with the provided string, after escaping
any percent signs in the original string to prevent pattern injection.

@function format_from_pattern
@param str string The string to insert into the pattern
@param pattern string The pattern containing $1 placeholder
@return string The formatted string, or original string if no pattern

@usage
    local result = utils.format_from_pattern("123", "ID: $1")
    -- Returns: "ID: 123"

@security This function escapes percent signs in the input string to
          prevent Lua pattern injection attacks.
]]
function p.format_from_pattern(str, pattern)
    if not p.isvalid(pattern) then
        return str
    end

    -- Escape percent signs in the string to prevent pattern injection
    local escaped = string.gsub(str, "%%", "%%%%")

    -- Replace $1 with the escaped string
    return mw.ustring.gsub(pattern, "$1", escaped)
end

--[[
Trims whitespace from both ends of a string.

@function trim
@param str string The string to trim
@return string The trimmed string, or original if not a string

@usage
    local clean = utils.trim("  hello world  ")
    -- Returns: "hello world"
]]
function p.trim(str)
    if type(str) ~= "string" then
        return str
    end
    return mw.text.trim(str)
end

-- ============================================================================
-- TABLE UTILITIES
-- ============================================================================

--[[
Checks if a table contains a specific value.

Performs a linear search through the table's values.

@function table_contains
@param tbl table The table to search
@param element any The value to find
@return boolean True if the element is found, false otherwise

@usage
    local skip_list = {"Q123", "Q456"}
    if utils.table_contains(skip_list, "Q123") then
        -- Skip this item
    end

@performance O(n) where n is the number of elements in the table.
             For frequent lookups, consider using a set (hash table).
]]
function p.table_contains(tbl, element)
    if type(tbl) ~= "table" then
        return false
    end

    for _, value in pairs(tbl) do
        if value == element then
            return true
        end
    end

    return false
end

--[[
Converts a comma-separated string or table to a table of values.

Accepts either:
  - A string with comma-separated values (e.g., "Q1,Q2,Q3")
  - A table that is returned as-is
  - nil/empty which returns nil

@function to_table
@param values string|table|nil The input to convert
@return table|nil A table of values, or nil if input was empty/nil

@usage
    local ids = utils.to_table("Q1,Q2,Q3")
    -- Returns: {"Q1", "Q2", "Q3"}

    local ids2 = utils.to_table({"Q1", "Q2"})
    -- Returns: {"Q1", "Q2"}
]]
function p.to_table(values)
    if not p.isvalid(values) then
        return nil
    end

    if type(values) == "string" then
        local result = mw.text.split(values, ",")
        if #result == 0 then
            return nil
        end
        return result
    elseif type(values) == "table" then
        if #values == 0 then
            -- Check if it's an empty table
            local has_content = false
            for _ in pairs(values) do
                has_content = true
                break
            end
            if not has_content then
                return nil
            end
        end
        return values
    end

    return nil
end

--[[
Safely gets a value from a nested table.

Navigates through nested tables safely, returning nil if any
intermediate key doesn't exist.

@function nested_get
@param tbl table The root table
@param ... any Keys to navigate (variable arguments)
@return any|nil The value at the path, or nil if not found

@usage
    local value = utils.nested_get(statement, "mainsnak", "datavalue", "value", "id")
    -- Equivalent to statement.mainsnak.datavalue.value.id but safely
]]
function p.nested_get(tbl, ...)
    local current = tbl
    for _, key in ipairs({...}) do
        if type(current) ~= "table" then
            return nil
        end
        current = current[key]
        if current == nil then
            return nil
        end
    end
    return current
end

-- ============================================================================
-- ERROR HANDLING
-- ============================================================================

--[[
Creates a formatted error message from the i18n configuration.

@function format_error
@param key string The error message key
@param i18n table The internationalization table containing errors
@return string The error message, or a generic message if key not found

@usage
    local msg = utils.format_error("property_param_not_provided", config.i18n)
]]
function p.format_error(key, i18n)
    if i18n and i18n.errors and i18n.errors[key] then
        return i18n.errors[key]
    end
    return "Error: " .. (key or "unknown")
end

-- ============================================================================
-- WIKIDATA UTILITIES
-- ============================================================================

--[[
Extracts the entity ID from a statement's mainsnak.

Navigates through the statement structure to find the entity ID
if the statement is about a wikibase-item.

@function get_snak_entity_id
@param statement Statement The statement to extract from
@return string|nil The entity ID (e.g., "Q123"), or nil if not found

@usage
    local qid = utils.get_snak_entity_id(statement)
]]
function p.get_snak_entity_id(statement)
    return p.nested_get(statement, "mainsnak", "datavalue", "value", "id")
end

--[[
Gets the numeric ID from a wikibase-entityid datavalue.

@function get_numeric_id
@param datavalue Datavalue The datavalue to extract from
@return integer|nil The numeric ID, or nil if not a valid entity ID

@usage
    local num_id = utils.get_numeric_id(snak.datavalue)
]]
function p.get_numeric_id(datavalue)
    if type(datavalue) ~= "table" then
        return nil
    end

    local value = datavalue.value
    if type(value) ~= "table" then
        return nil
    end

    if datavalue.type == "wikibase-entityid" then
        return value["numeric-id"]
    end

    return nil
end

--[[
Validates a Wikidata entity ID format.

Checks if the ID matches the expected format for items (Q###)
or properties (P###).

@function is_valid_entity_id
@param id string The ID to validate
@return boolean True if the ID format is valid, false otherwise

@usage
    if utils.is_valid_entity_id("Q123") then
        -- Valid item ID
    end
]]
function p.is_valid_entity_id(id)
    if type(id) ~= "string" then
        return false
    end
    return id:match("^[QP]%d+$") ~= nil
end

--[[
Validates a property ID format.

@function is_valid_property_id
@param id string The ID to validate
@return boolean True if the ID is a valid property ID (P###)

@usage
    if utils.is_valid_property_id("P31") then
        -- Valid property ID
    end
]]
function p.is_valid_property_id(id)
    if type(id) ~= "string" then
        return false
    end
    return id:match("^P%d+$") ~= nil
end

-- ============================================================================
-- HTML UTILITIES
-- ============================================================================

--[[
Creates an HTML element with specified attributes and content.

@function create_element
@param tag string The HTML tag name
@param attrs table? Optional attributes table
@param content string? Optional content
@return string The HTML string

@usage
    local html = utils.create_element("span", {class = "wikidata"}, "value")
]]
function p.create_element(tag, attrs, content)
    local builder = mw.html.create(tag)

    if type(attrs) == "table" then
        builder:attr(attrs)
    end

    if content then
        builder:wikitext(content)
    end

    return tostring(builder)
end

return p
