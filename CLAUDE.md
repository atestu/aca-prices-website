# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Jekyll-based static website that displays Affordable Care Act (ACA) health insurance pricing information. The site is organized hierarchically: USA → States → Counties → Coverage Types (individual/couple/family), showing health insurance plans with their costs and benefits.

### Data Source

The data powering this site comes from the sibling project `../aca-pricing-data`, which scrapes plan information from healthcare.gov's API (the federally-run marketplace only, not state exchanges). The scraper outputs JSON files that are directly consumed by this Jekyll site.

## Build & Development Commands

### Local Development
```bash
bundle install              # Install dependencies
bundle exec jekyll serve    # Start local development server at http://localhost:4000
bundle exec jekyll build    # Build static site to _site/
```

The site uses GitHub Pages for hosting, so it follows GitHub Pages conventions and constraints.

### Updating Plan Data

To refresh the insurance plan data displayed on the site:

1. Navigate to the data scraper project: `cd ../aca-pricing-data`
2. Run the scraper: `make run` (warning: takes a long time due to rate limiting)
3. Copy the scraped data to this project: `cp -r data/output/* ../aca-prices-website/_data/fips_plans/`
4. Rebuild the site: `bundle exec jekyll build`

The scraper only collects data from states using the federal marketplace (healthcare.gov). As of 2025, this includes: MT, WY, UT, AZ, AK, TX, OK, KS, NE, SD, ND, WI, MO, LA, MS, AL, GA, TN, IN, OH, FL, SC, NC, HI. Note that VA was removed from the scraper in 2025 when it moved to a state-run exchange, but may still appear in this site's hardcoded state list.

## Project Architecture

### Data Structure

The site relies on JSON data files in `_data/`:

- **`zip2fips.json`**: Maps ZIP codes to FIPS codes (county identifiers), with state and county name
- **`fips2zips.json`**: Reverse mapping from FIPS codes to location information
- **`fips_plans/[year]/[plan_type]/[fips].json`**: Plan data organized by year (2021+), coverage type (individual/couple/family), and FIPS code. Each file contains an array of insurance plans with detailed benefit information, premiums, deductibles, and coverage details.
- **`fips_stats/[plan_type]/[fips].json`**: Statistical data for each FIPS/plan type combination

### Dynamic Page Generation

The site uses Jekyll plugins to automatically generate pages from the data files:

**`_plugins/generate_state_pages.rb`**:
- Creates state index pages (e.g., `/TX`, `/VA`)
- Each state page lists counties with available plan data
- Hardcoded list of states: MT, WY, UT, AZ, AK, TX, OK, KS, NE, SD, ND, WI, MO, LA, MS, AL, GA, TN, IN, OH, FL, SC, NC, VA, HI
- **Important**: This list should match the states scraped by `aca-pricing-data`. As states transition between federal/state exchanges, both projects' state lists need updating.

**`_plugins/generate_fips_plans_pages.rb`**:
- Generates plan detail pages for each county/coverage type combination
- URL pattern: `/{state}/{county-slug}/{plan_type}/`
- Creates pages dynamically for years 2021 through 2 months into the future
- Each page shows all available insurance plans for that location and coverage type
- Only creates pages for FIPS codes that have corresponding data files in `_data/fips_plans/[year]/[plan_type]/[fips].json`

### Layouts & Templates

- **`_layouts/default.html`**: Base layout with header/CSS includes
- **`_layouts/state.html`**: State index pages with breadcrumbs and county links
- **`_layouts/fips_plans.html`**: Detailed plan comparison pages showing:
  - Plan metadata (issuer, name, metal level: Bronze 🥉, Silver 🥈, Gold/Platinum 🥇, Catastrophic 💥)
  - Benefits table with in-network/out-of-network coverage
  - Premium calculations (monthly, annual, total with deductible)
  - Links to benefits PDFs, brochures, and provider networks
  - Coverage type switcher (individual 👤, couple 👥, family 👨‍👩‍👧‍👦)

### Styling

- Uses Bootstrap 4 (via SASS in `_sass/bootstrap/`)
- Custom variables in `_sass/_bootstrap-variables.scss`
- Hamburger menu library in `_sass/libraries/hamburgers/`
- Component styles in `_sass/components/`
- Main stylesheet: `assets/css/style.scss`

### URL Structure

```
/                                    # Homepage with state list
/{STATE}/                           # State page with county list
/{STATE}/{county}/{plan_type}/      # Plan details page
```

Example: `/TX/travis/individual/` shows individual coverage plans for Travis County, Texas.

## Important Notes

- **State synchronization**: The hardcoded state list in `_plugins/generate_state_pages.rb` should match the states scraped by `aca-pricing-data`. When states move to/from state-run exchanges, both projects need updating.
- Plan data must exist in `_data/fips_plans/[year]/[plan_type]/[fips].json` for pages to generate
- The plugins automatically generate pages for all FIPS codes found in the plan data
- County names are slugified for URLs (e.g., "Travis County" → "travis")
- Coverage types match the scraper's household configurations:
  - `individual`: Single person age 27
  - `couple`: Two people age 27
  - `family`: Two adults age 27, two children age 2 and 7
