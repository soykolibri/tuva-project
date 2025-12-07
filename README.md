## ✅ Take Home Submission

### Methodology
1. I defined "Cancer" as a diagnosis code that matched one of the [Neoplasms C00-D49](https://www.icd10data.com/ICD10CM/Codes/C00-D49) ICD-10-CM codes.
   a. I excluded Benign & Uncertain Neoplasms, D10-D49, because ChatGPT suggested they were not cancer, but tumor-related.
2. I treated the `medical_claim` table as my primary source of truth. 
   a. I created a staging model as if this were a source table I'd ingested.
   b. I created an intermediate model to scrape all the unique ICD-10-CM diagnosis codes, and leveraged a macro to enrich them with cancer metadata.
   c. I created a mart (finance) table to summarize medical claim spend, broken out by cancer anatomical site, severity, and care setting.

### Key Findings
1. Cancer codes were rare in the synthetic claim data. 
   a. This is a finding I noticed as soon as I had my intermediate model working, and something I would have flagged immediately to my stakeholder(s) before spending further time on the analysis. 
   b. However, in the interest of demonstrating a more complete architecture, I built out a sample mart model despite the small sample size.
2. I am unable to comment on cost drivers, as the `total_cost_amount` column in the `medical_claim` table is null all the way down.
   a. I hope that the agg model I drafted in `marts/finance` gives some indication as to how I would have approached the analysis, if cost data had been available to analyze.

### AI Usage Log
1. All changes were drafted within Cursor.
2. I prompted Cursor to write jinja to loop over all diagnosis codes and assemble a deduped list for my staging model.
3. I asked ChatGPT how best to isolate cancer codes from everything else. It suggested the Neoplasms section of ICD-10-CM codes.
   a. It gave me a list of ranges for a variety of anatomical sites.
   b. Cursor helped me change the ChatGPT ranges into a config block and macro.
   c. Cursor repeatedly flagged my macro file for incorrect syntax. But it's because it wanted more `{{ }}` than were actually needed. dbt doesn't parse properly with nested curly braces, and Cursor's "corrections" were suggesting too many in this case.
4. I prompted Cursor to write the join condition on diagnosis code in my final mart model.
5. I prompted Cursor to help me loop through two config objects to get breakdowns in my mart model by different time periods and whether the claim was in-network or not.
   a. It hallucinated `loop.parent.loop.last` to handle the final comma in my select statement.
   b. I prompted it to think of other approaches and it gave me two (loop counter, pre-assemble configs into a list so I don't have to nest for-loops). I took the second suggestion.
6. I prompted Cursor to write column descriptions for my agg model.

### Notes on Prompt
1. I didn't have the necessary tools pre-installed on my personal laptop, so there was some setup required before I could even attempt the data modeling. Installations and validation of the installs (duckdb, dbt, Cursor) took about 45 minutes. 
   a. I assumed this setup time was not intended to be part of the recommended 2-3 hours to complete the exercise.
2. Once the project was set up, `dbt deps && dbt build` took 1h 10m but I forgot to thread it. The build might be faster for others if they think of threading sooner than I did. 
   a. I also did not count this time towards the 2-3 hr exercise.
3. Building the entire Tuva demo resulted in nearly 1000 tables. This was a little confusing for me. I ended up restricting my search to only those tables that appeared in the `input_layer` schema, and I pretended like that was a data source with respect to setting up my staging layer.
   a. If there had been an ERD to reference to understand how to connect entities, I would have found this a very helpful resource.
