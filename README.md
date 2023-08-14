# Replication Package Description

The project consists of three components:

1. **`./webserver`**: This component comprises a simple web application used to evaluate the impact of different web
   font settings on performance. The application is served via NGINX and directly pulled into `/var/www/html` on a
   dedicated machine.


2. **`./webclient`**: This component is an AutoHotkey script designed to automate a Firefox Nightly profiling
   experiment. It performs the following tasks:

   - Launches Firefox Nightly
   - Loads a specific URL
   - Starts and stops the profiler
   - Saves the profile
   - Repeats the process for a defined number of rounds
   
   The script can be triggered by pressing the **middle mouse button**.


3. **`./analysis`**: This component is responsible for analyzing the results obtained from the experiments:
   - **`./analysis/data_extraction/`**: After the analysis is complete, the script can be used to extract relevant data
     from the results. Using Python, the extracted results are aggregated and written to the `output` folder, containing
     the results for each font format.
   - **`./analysis/data_evaluation/`**: The aggregated results are utilized to generate plots and tables using R.
 