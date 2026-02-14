# Wikidata2 Modules Static Analysis Report

## Executive Summary

This report provides a comprehensive static analysis of the Wikidata2-Modules-arwiki codebase, a Lua-based Wikimedia module collection for Arabic Wikipedia. The analysis covers logical errors, security vulnerabilities, performance bottlenecks, architectural anti-patterns, and provides recommendations for improvement.

**Analysis Date:** 2026-02-14
**Codebase Size:** ~35 Lua files, ~1.3MB
**Primary Language:** Lua 5.1 (Scribunto extension for MediaWiki)

---

## Table of Contents

1. [Critical Issues](#1-critical-issues)
2. [Security Vulnerabilities](#2-security-vulnerabilities)
3. [Logical Errors](#3-logical-errors)
4. [Performance Bottlenecks](#4-performance-bottlenecks)
5. [Architectural Anti-Patterns](#5-architectural-anti-patterns)
6. [Code Quality Issues](#6-code-quality-issues)
7. [Recommendations](#7-recommendations)

---

## 1. Critical Issues

### 1.1 Global Variable Pollution

**Location:** Multiple files
**Severity:** HIGH

The codebase extensively uses global variables and module-level variables that persist between invocations:

```lua
-- wd2.lua:13
wd2.track_cat_done = false  -- Module-level state

-- wd2.lua:3
local Moduleill_wd2, Moduledump, ModuleTime, Moduletext, Modulecite, Moduleflags, ModuleGlobes, Moduletrack
```

**Impact:** In MediaWiki's Scribunto environment, module-level variables persist across page renders within the same request. This can cause:
- State leakage between different template invocations
- Incorrect tracking category behavior
- Race conditions in high-traffic scenarios

**Recommendation:** Use function-local variables or pass state through function parameters.

### 1.2 Deprecated API Usage

**Location:** `wd2.lua:128`, `functions.lua:70`

```lua
-- DEPRECATED: getEntityObject() is deprecated
local entity = mw.wikibase.getEntityObject(id)
```

**Impact:** Will break when MediaWiki deprecates this API.

**Recommendation:** Replace with `mw.wikibase.getEntity(id)`.

### 1.3 Inconsistent Nil Handling

**Location:** Multiple files

The codebase has multiple implementations of the same validation function with inconsistent behavior:

```lua
-- wd2.lua:35-38
local function isvalid(x)
    if x and x ~= nil and x ~= "" and x ~= i18n.no then return x end
    return nil
end

-- filter claims.lua:10-13
local function isvalid(x)
    if x and x ~= nil and x ~= "" then return x end  -- Missing i18n.no check
    return nil
end

-- functions.lua:49-52
local function isvalid(x)
    if x and x ~= nil and x ~= "" then return x end
    return nil
end
```

**Impact:** Inconsistent behavior across modules; `x and x ~= nil` is redundant.

---

## 2. Security Vulnerabilities

### 2.1 Template Injection via Pattern Substitution

**Location:** `wd2.lua:49-56`, `functions.lua:54-61`

```lua
local function formatFromPattern(str, options)
    if isvalid(options.pattern) then
        str = string.gsub(str, "%%", "%%%%")
        str = mw.ustring.gsub(options.pattern, "$1", str)
    end
    return str
end
```

**Severity:** MEDIUM

**Issue:** User-controlled pattern strings can potentially inject malicious content. While MediaWiki sanitizes output, pattern injection could cause:
- Unexpected output formatting
- Performance degradation via ReDoS-like patterns

**Recommendation:** Validate pattern strings against a whitelist of allowed patterns.

### 2.2 Dynamic Module Loading

**Location:** `wd2.lua:240-241`, `wd2.lua:612-613`

```lua
local formatter = require("Module:" .. options["value-module"])
local formatter = require("Module:" .. options["property-module"])
```

**Severity:** MEDIUM

**Issue:** Dynamic module loading based on user input allows loading arbitrary modules. In a Wikipedia context, this is mitigated by page edit restrictions, but represents a potential attack vector.

**Recommendation:** Implement a module whitelist for allowed custom formatters.

### 2.3 Unvalidated Entity IDs

**Location:** `wd2.lua:430`

```lua
property = property:upper()
```

**Severity:** LOW

**Issue:** Property IDs are used directly without validation before API calls.

**Recommendation:** Add explicit validation:
```lua
if not property:match("^P%d+$") then
    return formatError("invalid_property_id")
end
```

---

## 3. Logical Errors

### 3.1 Incorrect Comparison Logic in Date Sorting

**Location:** `sort claims.lua:26-32`, `functions.lua:200-208`

```lua
local function comparedates(a, b)
    local a = tonumber(a) or a  -- Shadows parameter 'a'
    local b = tonumber(b) or b  -- Shadows parameter 'b'
    if a and b then
        return a > b
    elseif a then
        return true
    end
end
```

**Issues:**
1. Variable shadowing: `local a` shadows the parameter `a`
2. Missing return for the case when `b` exists but `a` doesn't
3. Comparison logic is inverted for chronological sorting

**Impact:** Sorting may produce incorrect orderings in edge cases.

### 3.2 Flawed Age Calculation Logic

**Location:** `P569-P570.lua:178-183`

```lua
if not foo(db, db) == '0' or not ma(md, mb) == '0'
then
    vv = '1'
else
    vv = '0'
end
```

**Issue:** `not foo(db, db) == '0'` is parsed as `(not foo(db, db)) == '0'`, which is always false. The comparison should be `foo(db, db) ~= '0'`.

Additionally, `foo(db, db)` compares a value to itself, which always returns `'0'` (false condition).

**Impact:** Age calculations may be incorrect by one year.

### 3.3 Redundant Condition Checks

**Location:** Multiple files

```lua
-- wd2.lua:30-33
local function anyvalid(x)
    if x and x ~= nil and x ~= "" then return x end  -- x ~= nil is redundant after x
    return nil
end

-- time.lua:82-85
local function isvalid(x)
    if x and x ~= nil and x ~= "" then return x end  -- Same redundancy
    return nil
end
```

**Issue:** In Lua, `x` being truthy already implies `x ~= nil`, making `x ~= nil` redundant.

### 3.4 String Index Miscalculation

**Location:** `P569-P570.lua:76-83`

```lua
local function getdatepart(time, option)
    if isvalid(time) then
        if option == 'y' then
            return tonumber(string.sub(time, 2, 5))  -- Only 4 chars for year
        elseif option == 'm' then
            return tonumber(string.sub(time, 7, 8))
        elseif option == 'd' then
            return tonumber(string.sub(time, 10, 11))
        end
    end
end
```

**Issue:** Wikidata timestamp format is `+YYYY-MM-DDTHH:MM:SSZ`. The substring indices:
- Year: 2-5 extracts `YYYY` ✓
- Month: 7-8 extracts `MM` ✓
- Day: 10-11 extracts `DD` ✓

However, this doesn't handle negative years (BCE dates) correctly, where the format is `-YYYY-MM-DD...` with potentially more year digits.

### 3.5 Missing Nil Check Before Table Access

**Location:** `P39.lua:247-257`

```lua
local function office_is_okay(qualifiers, statement)
    if notvalid_value(statement.qualifiers.P108) and notvalid_value(statement.qualifiers.P2389) then
        return true
    end
    -- ...
end
```

**Issue:** `statement.qualifiers` may be nil, causing a runtime error.

---

## 4. Performance Bottlenecks

### 4.1 Repeated Entity Fetching

**Location:** `wd2.lua:126-135`, `filter claims.lua:172`

```lua
-- Each call fetches the entity
function wd2.countSiteLinks(id)
    local entity = mw.wikibase.getEntity(id)
    -- ...
end
```

**Issue:** Entities are fetched multiple times for the same item within a single page render.

**Recommendation:** Implement an entity cache at the module level.

### 4.2 Inefficient Table Iteration

**Location:** `filter claims.lua:46-53`

```lua
local function table_contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end
```

**Issue:** O(n) lookup for each element. Called repeatedly in filter functions.

**Recommendation:** For static lookup tables, convert to a set (hash table) for O(1) lookups:
```lua
local skip_items_set = { Q42857 = true, Q14886050 = true, Q2159907 = true }
```

### 4.3 Large Static Data in Module Memory

**Location:** `P54.lua:45-238`, `tax-cache.lua`

```lua
local flags = {
    Q16 = { "CAN", { "Flag of Canada.svg", "+1965-02-15" } },
    -- ... ~200 entries
}
```

**Issue:** Large static data tables are loaded into memory on every module invocation, even if not needed.

**Recommendation:** Move to a separate data module loaded with `mw.loadData()` which is more memory-efficient.

### 4.4 Repeated String Operations

**Location:** `wd2.lua:151-156`

```lua
local String2 = mw.ustring.gsub(label, "–", "-")
local match_y =
    mw.ustring.match(String2, "%d%d%d%d%-%d%d%d%d", 1) or
    mw.ustring.match(String2, "%d%d%-%d%d%d%d", 1) or
    mw.ustring.match(String2, "%d%d%d%d", 1) or
    mw.ustring.match(String2, "%d%d%d%d%-%d%d", 1) or
    mw.ustring.match(String2, "%d%d%d%d", 1)  -- Duplicate pattern
```

**Issues:**
1. The last pattern (`%d%d%d%d`) is duplicated
2. Each `match` call iterates through the string
3. Can be optimized with a single combined pattern

### 4.5 Multiple Regex Compilations

**Location:** `functions.lua:97-102`

Similar pattern matching inefficiency with repeated regex operations.

---

## 5. Architectural Anti-Patterns

### 5.1 God Object Pattern

**Location:** `wd2.lua`

The main module (`wd2.lua`) contains:
- 1,425 lines of code
- 50+ functions
- Multiple responsibilities: data retrieval, formatting, error handling, caching, HTML generation

**Recommendation:** Split into focused modules:
- `Wikidata2/EntityFetcher` - Entity retrieval
- `Wikidata2/Formatter` - Value formatting
- `Wikidata2/Renderer` - HTML output generation
- `Wikidata2/Validator` - Input validation

### 5.2 Duplicate Code (Copy-Paste Programming)

**Multiple Locations:**

1. **`isvalid` function** - Implemented 8+ times across files
2. **Sandbox detection** - Duplicated in every file:
```lua
local sandbox = "ملعب"
local sandbox_added = ""
if nil ~= string.find(mw.getCurrentFrame():getTitle(), sandbox, 1, true) then
    sandbox_added = "/" .. sandbox
end
```
3. **Config loading** - Duplicated pattern:
```lua
local config = mw.loadData('Module:Wikidata2/config' .. sandbox_added)
```

**Recommendation:** Create a shared utilities module with common functions.

### 5.3 Magic Numbers/Strings

**Location:** Multiple files

```lua
-- P569-P570.lua:11-23
local pp_config = {
    tempname = 'تاريخ الوفاة والعمر',
    time_addon = ' ق م',
    -- ...
}

-- wd2.lua:516
local max_num = tonumber(isvalid(options.hidden)) or config.max_claims_to_use_hidelist
```

**Issue:** Property IDs (P569, P570, P31, etc.) are hardcoded throughout the codebase without centralized constants.

**Recommendation:** Create a properties constants module:
```lua
local Properties = {
    DATE_OF_BIRTH = "P569",
    DATE_OF_DEATH = "P570",
    INSTANCE_OF = "P31",
    -- ...
}
```

### 5.4 Deep Nesting

**Location:** `wd2.lua:334-427`, `formatOneStatement` function

The function has deep nesting levels (5+), making it difficult to understand and maintain.

**Recommendation:** Extract helper functions and use early returns.

### 5.5 Implicit Dependencies

**Location:** Multiple files

Modules implicitly depend on global functions and other modules without explicit declarations:

```lua
-- wd2.lua uses formatSnak, formatEntityId, formatReferences without local declaration
-- These are defined elsewhere in the same file but called before definition
```

**Recommendation:** Organize code with explicit dependencies at the top, or use forward declarations.

---

## 6. Code Quality Issues

### 6.1 Inconsistent Naming Conventions

| File | Convention | Example |
|------|------------|---------|
| wd2.lua | snake_case | `formatStatements` |
| P54.lua | mixed | `get_countryID`, `value_valid` |
| P39.lua | mixed | `get_office_img`, `office3` |
| filter claims.lua | snake_case | `filter_claims` |

**Recommendation:** Standardize on `snake_case` for all functions and variables per Lua conventions.

### 6.2 Commented-Out Code

**Location:** Multiple files

```lua
-- functions.lua:69-76
-- local siteLinks = {}
-- return Frame:extensionTag("source", mw.dumpObject( siteLinks ),{ lang= 'lua'})

-- wd2.lua:1069-1074
--[[
if formatera == nil then
    formatera = require("Module:Wikidata2/Math")
end
local number = formatera.newFromWikidataValue(datavalue.value)
]]
```

**Recommendation:** Remove dead code or document why it's preserved.

### 6.3 Missing Error Handling

**Location:** `wd2.lua:429-460`

```lua
function get_claims(entity, qid, property, options)
    property = property:upper()  -- No nil check
    -- ...
end
```

**Recommendation:** Add defensive programming:
```lua
function get_claims(entity, qid, property, options)
    if not property then
        return {}
    end
    property = property:upper()
    -- ...
end
```

### 6.4 Unused Variables

**Location:** `P569-P570.lua:165`

```lua
-- local dd = Dd or tonumber(os.date("%e"))  -- Commented but left in
```

**Location:** `wd2.lua:4`

```lua
-- local formatera  -- Declared but never used
```

### 6.5 Hardcoded Language Values

**Location:** Multiple files

```lua
-- config.lua:5
local_lang = "ar"

-- monolingualtext.lua:9
local_lang_code = "ar"
```

**Issue:** Language codes are hardcoded in multiple places.

**Recommendation:** Centralize all configuration in `config.lua` and reference from other modules.

---

## 7. Recommendations

### 7.1 High Priority

1. **Fix deprecated API calls** - Replace `getEntityObject()` with `getEntity()`
2. **Fix logical errors** - Correct the age calculation and date comparison bugs
3. **Implement proper nil handling** - Add defensive checks before table access
4. **Fix variable shadowing** - Remove duplicate local declarations

### 7.2 Medium Priority

1. **Create shared utilities module** - Consolidate `isvalid`, sandbox detection, config loading
2. **Implement entity caching** - Reduce redundant Wikidata API calls
3. **Add input validation** - Validate property IDs, entity IDs, and user patterns
4. **Split god module** - Break wd2.lua into focused modules

### 7.3 Low Priority

1. **Standardize naming conventions**
2. **Remove dead code**
3. **Add comprehensive error messages**
4. **Create property constants module**
5. **Improve documentation**

---

## 8. Type Definitions Summary

The following Lua type annotations (using LuaCATS/EmmyLua format) should be added to improve IDE support and catch type-related errors:

### Core Types

```lua
---@alias WikibaseId string Wikibase entity ID (e.g., "Q123", "P456")
---@alias PropertyId string Wikibase property ID (e.g., "P31")
---@alias SnakType "value"|"somevalue"|"novalue"
---@alias Rank "preferred"|"normal"|"deprecated"
---@alias Precision 0|1|2|3|4|5|6|7|8|9|10|11|12|13|14

---@class Snak
---@field snaktype SnakType
---@field property string
---@field datavalue Datavalue?
---@field datatype string?

---@class Datavalue
---@field value any
---@field type string

---@class Statement: Snak
---@field type "statement"
---@field id string
---@field rank Rank
---@field qualifiers table<string, Snak[]>?
---@field references Reference[]?

---@class Options
---@field property PropertyId
---@field entityId WikibaseId?
---@field formatting string?
---@field pattern string?
---@field rank Rank?
---@field noref boolean?
---@field langpref string?
```

---

## Conclusion

The Wikidata2-Modules-arwiki codebase is functional but has several areas for improvement:

1. **Critical bugs** in age calculation and date comparison need immediate attention
2. **Security considerations** around dynamic module loading should be addressed
3. **Performance optimizations** can significantly reduce page render times
4. **Architectural refactoring** will improve maintainability and testability

The codebase would benefit from:
- Comprehensive type annotations for better IDE support
- Centralized utility functions to reduce code duplication
- Proper error handling and input validation
- Unit tests for critical functions

---

*Report generated by static analysis*
