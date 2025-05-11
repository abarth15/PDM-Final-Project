install.packages("readxl")
install.packages("httr")
install.packages("gt")

library(magrittr)
library(dplyr)
library(tidyverse)
library(readxl)
library(httr)
library(lubridate)
library(ggplot2)
library(gt)

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

# Determine basic information about the datasets

ncol(pjm_full_cycle)
nrow(pjm_full_cycle)
ncol(pjm_in_service)
nrow(pjm_in_service)

# Calculate fuel type as percent of total projects in the queue

fuel_percent_projects <- filter(pjm_full_cycle, Status == "Active") %>%
  group_by(Fuel) %>%
  summarise(count = n()) %>%
  mutate(`Percent of Projects` = round(100 * count / sum(count), 1)) %>%
  select(Fuel, `Percent of Projects`) %>%
  arrange(desc(`Percent of Projects`))

gt(fuel_percent_projects) %>%
  tab_header(title = "Fuel Type as Percent of Total Projects")

# Calculate fuel type as percent of total MW in the queue

pjm_full_cycle$`MW Energy` <- as.numeric(pjm_full_cycle$`MW Energy`)

fuel_percent_energy <- filter(pjm_full_cycle, Status == "Active") %>%
  group_by(Fuel) %>%
  summarize(TotalMW = sum(`MW Energy`, na.rm = TRUE)) %>%
  mutate(`Percent of MW` = round((TotalMW / sum(TotalMW)) * 100, 1)) %>%
  select(Fuel, `Percent of MW`) %>%
  arrange(desc(`Percent of MW`))

gt(fuel_percent_energy) %>%
  tabe_header(title = "Fuel Type as Percent of Total MW")

# Calculate MW of energy in the queue per state and county and select top
# five states and counties for solar, storage, wind, and hyrbid resources

top_three_states <- filter(pjm_full_cycle, Status == "Active" & Fuel %in% 
                             c("Solar", "Wind", "Storage", "Solar,Storage,Hybrid")) %>% 
  group_by(State) %>%
  summarize(TotalMW = sum(`MW Energy`, na.rm = TRUE)) %>%
  mutate(`Clean Energy MW` = TotalMW) %>%
  select(State, `Clean Energy MW`) %>%
  arrange(desc(`Clean Energy MW`)) %>%
  head(3)

gt(top_three_states)

top_five_counties <- filter(pjm_full_cycle, Status == "Active" & Fuel %in% 
                              c("Solar", "Wind", "Storage", "Solar,Storage,Hybrid")) %>% 
  group_by(State, County) %>%
  summarize(TotalMW = sum(`MW Energy`, na.rm = TRUE)) %>%
  mutate(`Clean Energy MW` = TotalMW) %>%
  select(State, County, `Clean Energy MW`) %>%
  arrange(desc(`Clean Energy MW`)) %>%
  head(5)

gt(top_five_counties)

# Calculate and graph average length of time that in-service projects spent
# in the interconnection queue between 2005 and 2025 by fuel type

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
    "Natural Gas")) %>%
  rename(, `Average Time In Queue` = AverageTime)

all_fuels <- mean_time_fuel %>%
  group_by(`In Service Year`) %>%
  summarize(`Average Time In Queue` = mean(`Average Time In Queue`,
    na.rm = TRUE)) %>%
  mutate(Fuel = "All Fuels")

mean_time_all_fuel <- bind_rows(mean_time_fuel, all_fuels)

ggplot(mean_time_all_fuel, aes(`In Service Year`, `Average Time In Queue`, 
  color = Fuel)) + geom_line() +
  scale_color_manual(values = c(
    "Solar" = "yellow", 
    "Wind" = "skyblue",
    "Storage" = "green",
    "Natural Gas" = "grey",
    "All Fuels" = "black")) +
  labs(title = "Interconnection Wait Times by Fuel and Year")
    
# Calculate and plot z-scores for average interconnection queue wait times per
# year

sd_time_in_queue <- time_in_queue %>%
  mutate(`In Service Year` = year(`Actual In Service Date`)) %>%
  filter(`In Service Year` >= 2005 & Fuel %in% c("Solar", "Wind", "Storage", 
    "Natural Gas")) %>%
  group_by(`In Service Year`) %>%
  summarize(
    `All Fuel Mean` = mean(`Time In Queue`, na.rm = TRUE),
    `All Fuel SD` = sd(`Time In Queue`, na.rm = TRUE)
  )

z_score <- mean_time_fuel %>%
  left_join(sd_time_in_queue, by = "In Service Year") %>%
  mutate(
    `Z-Score` = (`Average Time In Queue` - `All Fuel Mean`) / `All Fuel SD`
  )

ggplot(z_score, aes(x = `In Service Year`, y = `Z-Score`, color = Fuel)) +
  geom_line() +
  geom_point() +
  scale_color_manual(values = c(
    "Solar" = "yellow", 
    "Wind" = "skyblue",
    "Storage" = "green",
    "Natural Gas" = "grey"))+
  labs(title = "Z-Score of Average Interconnection Queue Time by Fuel Type")

















