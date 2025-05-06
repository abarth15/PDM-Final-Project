install.packages("readxl")
install.packages("httr")

library(magrittr)
library(dplyr)
library(tidyverse)
library(readxl)
library(httr)
library(lubridate)
library(ggplot2)

# Read in PJMCycleProjects file

url <- "https://github.com/abarth15/PDM-Final-Project/raw/main/PJMCycleProjects.xlsx"

file <- tempfile(fileext = ".xlsx")
download.file(url, file, mode = "wb")

pjm_full_cycle <- read_excel(file)

# Read in PJMActive Projects file

url <- "https://github.com/abarth15/PDM-Final-Project/raw/main/PJMActiveProjects.xlsx"

file <- tempfile(fileext = ".xlsx")
download.file(url, file, mode = "wb")

pjm_in_service <- read_excel(file)

# Calculate fuel type as percentage of total projects in the queue

fuel_percentage <- filter(pjm_full_cycle, Status == "Active") %>%
  group_by(Fuel) %>%
  summarise(count = n()) %>%
  mutate(`Percentage of Projects` = round(100 * count / sum(count), 1)) %>%
  select(Fuel, `Percentage of Projects`) %>%
  arrange(desc(`Percentage of Projects`))

print(fuel_percentage)

# Calculate fuel type as percentage of total MW in the queue

pjm_full_cycle$`MW Energy` <- as.numeric(pjm_full_cycle$`MW Energy`)

fuel_percentage_energy <- filter(pjm_full_cycle, Status == "Active") %>%
  group_by(Fuel) %>%
  summarize(TotalMW = sum(`MW Energy`, na.rm = TRUE)) %>%
  mutate(`Percentage of MW` = round((TotalMW / sum(TotalMW)) * 100, 1)) %>%
  select(Fuel, `Percentage of MW`) %>%
  arrange(desc(`Percentage of MW`))
  
print(fuel_percentage_energy)

# Calculate MW of energy in the queue per state and county and select top
# five states and counties for solar, storage, wind, and hyrbid resources

top_five_states <- filter(pjm_full_cycle, Status == "Active" & Fuel %in% 
    c("Solar", "Wind", "Storage", "Solar,Storage,Hybrid")) %>% 
  group_by(State) %>%
  summarize(TotalMW = sum(`MW Energy`, na.rm = TRUE)) %>%
  mutate(`Clean Energy MW` = TotalMW) %>%
  select(State, `Clean Energy MW`) %>%
  arrange(desc(`Clean Energy MW`)) %>%
  head(5)

print(top_five_states)

top_five_counties <- filter(pjm_full_cycle, Status == "Active" & Fuel %in% 
    c("Solar", "Wind", "Storage", "Solar,Storage,Hybrid")) %>% 
  group_by(State, County) %>%
  summarize(TotalMW = sum(`MW Energy`, na.rm = TRUE)) %>%
  mutate(`Clean Energy MW` = TotalMW) %>%
  select(State, County, `Clean Energy MW`) %>%
  arrange(desc(`Clean Energy MW`)) %>%
  head(5)

print(top_five_counties)

# Calculate and graph average length of time that in-service projects spent
# in the interconnection queue between 2014 and 2024 by fuel type

time_in_queue <- pjm_in_service %>%
  mutate(across(c(`Submitted Date`, `Actual In Service Date`), ~ 
    as_date(mdy(.x)))) %>%
  mutate(`Time In Queue` = interval(`Submitted Date`, `Actual In Service Date`)
    / years(1))

mean_time_fuel <- time_in_queue %>%
  mutate(`In Service Year` = year(`Actual In Service Date`)) %>%
  group_by(Fuel, `In Service Year`) %>%
  summarize(AverageTime = mean(`Time In Queue`, na.rm = TRUE)) %>%
  select(Fuel, `In Service Year`, AverageTime) %>%
  filter(`In Service Year` >= 2005 & Fuel %in% c("Solar", "Wind", "Storage", 
    "Natural Gas", "Solar,Storage,Hybrid")) %>%
  rename(, `Average Time In Queue` = AverageTime)

ggplot(mean_time_fuel, aes(`In Service Year`, `Average Time In Queue`, 
  color = Fuel)) + geom_line()
    


















