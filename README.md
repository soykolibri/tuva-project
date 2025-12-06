## ✅ Take Home Submission

### Methodology
1. How I defined "cancer" and handled data ambiguities

c. I excluded Benign & Uncertain Neoplasms because ChatGPT suggested they were not cancer, but tumor-related.

### Key Findings
1. A brief executive summary of the prevalence and top cost drivers found in the data.

### AI Usage Log
1. All changes were drafted within Cursor.
2. I prompted Cursor to write jinja to loop over all diagnosis codes and assemble a deduped list for my staging model.
3. I asked ChatGPT how best to isolate cancer codes from everything else. It suggested the Neoplasms section of ICD-10-CM codes.
   a. It gave me a list of ranges for a variety of anatomical sites.
   b. Cursor agent helped me change the ChatGPT ranges into a config block and macro.
4. 
A short section detailing how you used AI tools to accelerate the build
(e.g., generating code lists, regex), and any instance where you had to correct the AI

### Notes on Prompt
1. I didn't have the necessary tools pre-installed on my personal laptop, so there was some setup required before I could even attempt the data modeling. Installations and getting the repo set up took about 45 minutes. I assumed this setup time was not intended to be part of the recommended 2-3 hours to complete the exercise. It might be nice to clarify the time expectation for other folks who attempt the exercise.
   a. Once the project was set up, `dbt deps && dbt build` took 1h 10m but I forgot to thread it. Might be faster for others if they think of this sooner than I did.