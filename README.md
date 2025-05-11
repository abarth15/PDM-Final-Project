# PDM-Final-Project

## Project Overview
This project is an analysis of PJM queue data for a potential, hypothetical client. The audience is clean energy nonprofit organizations, like the American Council on Renewable Energy. PJM, as explained in the .qmd, is the regional grid operator in the Mid-Atlantic region of the United States. As the regional grid operator, PJM is responsible for planning and operating the transmission system, and safely and reliability interconnecting new electric generating units or power plants to the grid. It takes time to study the impacts of injecting new power into the system, so generators enter the interconnection queue to allow PJM to study the impacts and asign system upgrades as needed. This project is an analysis of the characteristics of the generators waiting in PJM's interconnection queue, as well as the generators already online serving the system.

## Files in This Repository
- `Barth_Annika_ps4.qmd`: The main Quarto document with analysis and write-up.
- `PJM_Queue_Analysis.R`: R script used to load and wrangle the data.
- `PJMCycleProjects.xlsx`: Excel dataset with projects that are active in PJM's queue.
- `PJMActiveProjects.xlsx`: Excel dataset with projects that have completed the interconnection process and are online.
- `README.md`: This file.

## Data Sources
Data for this project were obtained from PJM's website at the following webpages: 
- PJMActiveProjects.xlsx file was obtained from PJM's Serial Service Request Status: https://www.pjm.com/planning/service-requests/serial-service-request-status
- PJMCycleProjects.xl.sx was obtained from PJM's Cycle Service Request Status: https://www.pjm.com/planning/m/cycle-service-request-status
