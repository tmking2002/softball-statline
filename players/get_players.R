library(tidyverse)

hitting_box_2015 <- readRDS("~/Projects/softballR-data/data/d1_hitting_box_scores_2015.RDS")
hitting_box_2016 <- readRDS("~/Projects/softballR-data/data/d1_hitting_box_scores_2016.RDS")
hitting_box_2017 <- readRDS("~/Projects/softballR-data/data/d1_hitting_box_scores_2017.RDS")
hitting_box_2018 <- readRDS("~/Projects/softballR-data/data/d1_hitting_box_scores_2018.RDS")
hitting_box_2019 <- readRDS("~/Projects/softballR-data/data/d1_hitting_box_scores_2019.RDS")
hitting_box_2020 <- readRDS("~/Projects/softballR-data/data/d1_hitting_box_scores_2020.RDS")
hitting_box_2021 <- readRDS("~/Projects/softballR-data/data/d1_hitting_box_scores_2021.RDS")
hitting_box_2022 <- readRDS("~/Projects/softballR-data/data/d1_hitting_box_scores_2022.RDS")
hitting_box_2023 <- readRDS("~/Projects/softballR-data/data/d1_hitting_box_scores_2023.RDS")


box <- rbind(hitting_box_2015,
             hitting_box_2016,
             hitting_box_2017,
             hitting_box_2018,
             hitting_box_2019,
             hitting_box_2020,
             hitting_box_2021,
             hitting_box_2022,
             hitting_box_2023) %>% 
  separate(player, c("last", "first"), sep = ", ")

proper=function(x) paste0(toupper(substr(x, 1, 1)), tolower(substring(x, 2)))

unique_names <- box %>% 
  distinct(first, last, team) %>% 
  drop_na(first, last) %>% 
  mutate(first =  proper(trimws(str_remove(first, "\\."))),
         last = proper(trimws(str_remove(last, "\\.")))) %>% 
  filter(str_length(first) > 1,
         str_length(last) > 1,
         first != "Unknown") %>% 
  arrange(last, first)

write.csv(unique_names, "~/Projects/softball-statline/players/data/sample_players.csv")
