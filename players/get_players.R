library(tidyverse)
library(softballR)

d1_hitting_box <- load_ncaa_softball_playerbox(2016:2023, "Hitting", "D1")
d2_hitting_box <- load_ncaa_softball_playerbox(2016:2023, "Hitting", "D2")
d3_hitting_box <- load_ncaa_softball_playerbox(2016:2023, "Hitting", "D3")

hitting_box <- rbind(d1_hitting_box, d2_hitting_box, d3_hitting_box) %>% 
  select(player, team, season)

d1_pitching_box <- load_ncaa_softball_playerbox(2016:2023, "Pitching", "D1")
d2_pitching_box <- load_ncaa_softball_playerbox(2016:2023, "Pitching", "D2")
d3_pitching_box <- load_ncaa_softball_playerbox(2016:2023, "Pitching", "D3")

pitching_box <- rbind(d1_pitching_box, d2_pitching_box, d3_pitching_box) %>% 
  select(player, team, season)

box <- rbind(hitting_box, pitching_box) %>% 
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
