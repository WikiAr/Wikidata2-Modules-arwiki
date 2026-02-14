# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Lua module collection for Arabic Wikipedia (arwiki) that provides interfaces to Wikidata. The modules retrieve, format, and display Wikidata properties on Wikipedia pages.

## Architecture

### Main Module Entry Point
- `Wikidata2/wd2.lua` - Core module exposing functions like `formatStatements`, `formatStatementsFromLua`, `labelIn`, `descriptionIn`, `getSiteLink`, `Dump`

### Core Sub-Modules (`Wikidata2/`)
- `config.lua` - Central configuration (Arabic localization strings, category names, skip items, error messages)
- `functions.lua` - Helper functions (older copy, kept for reference)
- `filter_claims.lua` - Filter Wikidata claims by values/qualifiers
- `sort_claims.lua` - Sort claims chronologically (date/inverted)
- `time.lua` - Time/date formatting with Arabic localization
- `monolingualtext.lua` - Handle monolingual text with language codes
- `Flags.lua` - Country flag mappings by Wikidata Q-ID
- `Globes.lua` - Celestial body mappings for coordinates
- `Ill-WD2.lua` - Interlanguage link creation
- `dump.lua` - Debug entity data inspection
- `تتبع.lua` - Tracking categories and edit icons

### Property-Specific Modules (`Wikidata2 sub modules/`)
Each file handles custom formatting for specific Wikidata properties:
- `P39.lua` - Position held (renders infobox rows with terms)
- `P569-P570.lua` - Birth/death dates with age calculation
- `P54.lua` - Sports team membership
- `P106.lua` - Occupation
- `P1082.lua` - Population
- `coordinates.lua` - Geographic coordinates
- `awards.lua` - Award formatting

### Related Modules (`related/`)
- `Arguments with aliases.lua` - Argument processing with alias support
- `ص.م.lua` - Infobox/table building functions (SubTitle, Line, Title, etc.)
- `لغات.lua` / `لغات-بيانات.lua` - Language name utilities

## Key Patterns

### Validation Functions
```lua
local function isvalid(x)
    if x and x ~= nil and x ~= "" and x ~= i18n.no then return x end
    return nil
end
```
Used throughout to check for valid non-empty values. The Arabic word "لا" (i18n.no) means "no" and is treated as invalid.

### Sandbox Support
Modules support testing via sandbox subpages. The pattern detects "/ملعب" (Arabic for "sandbox") in the title:
```lua
local sandbox = "ملعب"
local sandbox_added = ""
if nil ~= string.find(mw.getCurrentFrame():getTitle(), sandbox, 1, true) then
    sandbox_added = "/" .. sandbox
end
local config = mw.loadData('Module:Wikidata2/config' .. sandbox_added)
```

### Custom Formatters via Module Options
The system supports pluggable formatters through options:
- `value-module` / `value-function` - Custom datavalue formatting
- `claim-module` / `claim-function` - Custom statement formatting
- `property-module` / `property-function` - Custom property handling

### MediaWiki Module Loading
Modules use `mw.loadData` for config (efficient, read-only) and `require` for functional modules.

## Development Notes

- All user-facing text and categories are in Arabic
- Property IDs are uppercase (e.g., "P39", "P569")
- Entity IDs follow Wikidata format (e.g., "Q12345")
- The `skip_items` table in config filters out unwanted values (e.g., prophet/terrorist/criminal from occupations)
- Testing is done via sandbox subpages on-wiki, not through automated tests

## Module Invocation

From wikitext:
```lua
{{#invoke:Wikidata2|formatStatements|entityId=Q76|property=P19}}
{{#invoke:Wikidata2|fs|qid={{{qid|}}}|pid=P19}}
```

From Lua:
```lua
local wd2 = require("Module:Wikidata2")
local value = wd2.formatStatementsFromLua({entityId="Q76", property="P19"})
```
