# Documentation for Front Matter of Marble Markdown Files

### **YAML Front Matter Pieces for Date Tracking**

1. **`date_created`**

    - **Default Value:** `YYYY-MM-DD` (from the CSV).
    - **Behavior:**
        - If the value is `YYYY-MM-DD`, display in HTML as `Created on: YYYY-MM-DD`.
        - If the value is `YYYY-MM-DD, Custom Text`, display in HTML with the custom text (e.g., `Posted on: YYYY-MM-DD`).
2. **`date_lastchanged`**

    - **Default Value:** `YYYY-MM-DD` (from the CSV).
    - **Behavior:**
        - If the value is `YYYY-MM-DD`, display in HTML as `Last updated: YYYY-MM-DD`.
        - If the value is `YYYY-MM-DD, Custom Text`, display in HTML with the custom text (e.g., `Reviewed on: YYYY-MM-DD`).
3. **`show_date_lastchanged_updatedauto`**

    - **Default Value:** `YES, NO, NO`.
    - **Behavior:**
        - **First Value (`NO` or `YES`):**
            - Determines if `date_created` is displayed in the HTML.
            - `NO`: Do not show `date_created` in the HTML.
            - `YES`: Show `date_created` in the HTML using the specified custom text or default formatting.
        - **Second Value (`NO` or `YES`):**
            - Determines if `date_lastchanged` is displayed in the HTML.
            - `NO`: Do not show `date_lastchanged` in the HTML.
            - `YES`: Show `date_lastchanged` in the HTML using the specified custom text or default formatting.
        - **Third Value (`NO` or `YES`):**
            - Determines if the script should automatically update the `date_lastchanged` field based on changes to the markdown file.
            - `NO`: Do not update the `date_lastchanged` value automatically.
            - `YES`: Automatically update the `date_lastchanged` value when changes are detected in the markdown file.



## Marble Reference Syntax Grammar

### Basic Structure
```
[<template_name>[:<parameter>=<value>[:<parameter>=<value>...]][ - <description>]](<file>.md)
```

### Components

**1. Template Name (Required)**
- First element after opening bracket
- Defines which HTML include file to use
- Maps to `_includes/marble-preview-{template_name}.html`
- Examples: `preview`, `slip`, `card`, `compact`, `full`, `illustration`

**2. Parameters (Optional)**
- Format: `parameter=value`
- Separated by colons `:`
- Order doesn't matter
- Common parameters:
  - `length=<number>` - excerpt length in characters
  - `style=<string>` - additional styling modifier
  - `image=<boolean>` - show/hide image (true/false)

**3. Description Separator (Optional)**
- Single dash with optional spaces: ` - `, `-`, `- `, or ` -`
- Spaces before and after the dash don't matter
- Everything after separator becomes custom description
- If present, overrides default title

**4. File Reference (Required)**
- Standard markdown link format
- Must end with `.md`
- Extracts marble ID from filename

### Valid Examples

```markdown
<!-- Basic template only -->
[preview](MARBLE-ID.md)
[slip](MARBLE-ID.md)

<!-- Template with parameters -->
[preview:length=150](MARBLE-ID.md)
[slip:length=100:image=false](MARBLE-ID.md)
[card:style=minimal:length=200](MARBLE-ID.md)

<!-- With descriptions (flexible spacing around dash) -->
[preview - Custom title](MARBLE-ID.md)
[slip:length=100- Illustration: Roots of Renewables](MARBLE-ID.md)
[card:length=150 -Quick note about toxic CO2](MARBLE-ID.md)
[full:image=true  -  Quotes: being silent during times of injustice](MARBLE-ID.md)

<!-- Complex example -->
[illustration:length=250:style=bordered - A detailed look at renewable energy systems](RENEWABLE-SYSTEMS.md)
```

### Parsing Logic
1. Extract template name (everything before first `:` or ` -` or `](`)
2. Parse parameters between template and description separator
3. Extract description after ` - ` (if present)
4. Extract marble ID from file path

### Template File Mapping
- `preview` → `_includes/marble-preview.html` (default template)
- `slip` → `_includes/marble-preview-slip.html`
- `card` → `_includes/marble-preview-card.html`
- `{custom}` → `_includes/marble-preview-{custom}.html`
