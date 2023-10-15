library(tidyverse)

hitting_box_2015 <- distinct(rbind(readRDS("~/Projects/softballR-data/data/d1_hitting_box_scores_2015.RDS"))) %>% select(player, team, season)

hitting_box_2016 <- distinct(rbind(readRDS("~/Projects/softballR-data/data/d1_hitting_box_scores_2016.RDS"), 
                                   readRDS("~/Projects/softballR-data/data/d2_hitting_box_scores_2016.RDS"))) %>% select(player, team, season)

hitting_box_2017 <- distinct(rbind(readRDS("~/Projects/softballR-data/data/d1_hitting_box_scores_2017.RDS"), 
                                   readRDS("~/Projects/softballR-data/data/d2_hitting_box_scores_2017.RDS"))) %>% select(player, team, season)

hitting_box_2018 <- distinct(rbind(readRDS("~/Projects/softballR-data/data/d1_hitting_box_scores_2018.RDS"), 
                                   readRDS("~/Projects/softballR-data/data/d2_hitting_box_scores_2018.RDS"))) %>% select(player, team, season)

hitting_box_2019 <- distinct(rbind(readRDS("~/Projects/softballR-data/data/d1_hitting_box_scores_2019.RDS"), 
                                   readRDS("~/Projects/softballR-data/data/d2_hitting_box_scores_2019.RDS"))) %>% select(player, team, season)

hitting_box_2020 <- distinct(rbind(readRDS("~/Projects/softballR-data/data/d1_hitting_box_scores_2020.RDS"), 
                                   readRDS("~/Projects/softballR-data/data/d2_hitting_box_scores_2020.RDS"))) %>% select(player, team, season)

hitting_box_2021 <- distinct(rbind(readRDS("~/Projects/softballR-data/data/d1_hitting_box_scores_2021.RDS"), 
                                   readRDS("~/Projects/softballR-data/data/d2_hitting_box_scores_2021.RDS"))) %>% select(player, team, season)

hitting_box_2022 <- distinct(rbind(readRDS("~/Projects/softballR-data/data/d1_hitting_box_scores_2022.RDS"), 
                                   readRDS("~/Projects/softballR-data/data/d2_hitting_box_scores_2022.RDS"))) %>% select(player, team, season)

hitting_box_2023 <- distinct(rbind(readRDS("~/Projects/softballR-data/data/d1_hitting_box_scores_2023.RDS"), 
                                   readRDS("~/Projects/softballR-data/data/d2_hitting_box_scores_2023.RDS"))) %>% select(player, team, season)

pitching_box_2015 <- readRDS("~/Projects/softballR-data/data/d1_pitching_box_scores_2015.RDS") %>% mutate(season = 2015) %>% select(player, team, season)
pitching_box_2016 <- readRDS("~/Projects/softballR-data/data/d1_pitching_box_scores_2016.RDS") %>% mutate(season = 2016) %>% select(player, team, season)
pitching_box_2017 <- readRDS("~/Projects/softballR-data/data/d1_pitching_box_scores_2017.RDS") %>% mutate(season = 2017) %>% select(player, team, season)
pitching_box_2018 <- readRDS("~/Projects/softballR-data/data/d1_pitching_box_scores_2018.RDS") %>% mutate(season = 2018) %>% select(player, team, season)
pitching_box_2019 <- readRDS("~/Projects/softballR-data/data/d1_pitching_box_scores_2019.RDS") %>% mutate(season = 2019) %>% select(player, team, season)
pitching_box_2020 <- readRDS("~/Projects/softballR-data/data/d1_pitching_box_scores_2020.RDS") %>% mutate(season = 2020) %>% select(player, team, season)
pitching_box_2021 <- readRDS("~/Projects/softballR-data/data/d1_pitching_box_scores_2021.RDS") %>% mutate(season = 2021) %>% select(player, team, season)
pitching_box_2022 <- readRDS("~/Projects/softballR-data/data/d1_pitching_box_scores_2022.RDS") %>% mutate(season = 2022) %>% select(player, team, season)
pitching_box_2023 <- readRDS("~/Projects/softballR-data/data/d1_pitching_box_scores_2023.RDS") %>% mutate(season = 2023) %>% select(player, team, season)


box <- rbind(hitting_box_2023,
             pitching_box_2023,
             hitting_box_2022,
             pitching_box_2022,
             hitting_box_2021,
             pitching_box_2021,
             hitting_box_2020,
             pitching_box_2020,
             hitting_box_2019,
             pitching_box_2019,
             hitting_box_2018,
             pitching_box_2018,
             hitting_box_2017,
             pitching_box_2017,
             hitting_box_2016,
             pitching_box_2016,
             hitting_box_2015,
             pitching_box_2015) %>% 
  distinct(team, player, season) %>% 
  separate(player, c("last", "first"), sep = ", ")

proper=function(x) paste0(toupper(substr(x, 1, 1)), tolower(substring(x, 2)))

unique_names <- box %>% 
  drop_na(first, last) %>% 
  mutate(first =  proper(trimws(str_remove(first, "\\."))),
         last = proper(trimws(str_remove(last, "\\.")))) %>% 
  group_by(last, first) %>% 
  summarise(player_id = cur_group_id(),
            teams = paste(unique(team), collapse = " + "),
            seasons = paste(unique(season), collapse = "+")) %>% 
  ungroup() %>% 
  filter(str_length(first) > 1,
         str_length(last) > 1,
         first != "Unknown",
         !str_detect(first, "[0-9]"),
         !str_detect(last, "[0-9]")) %>% 
  mutate(player = paste(first, last)) %>% 
  select(player_id, player, teams, seasons, first, last) %>% 
  arrange(player_id)

write.csv(unique_names, "~/Projects/softball-statline/players/data/all_players.csv")
