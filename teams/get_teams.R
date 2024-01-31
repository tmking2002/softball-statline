install.packages("tidyverse")

library(tidyverse)

teams <- readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/ncaa_team_info.RDS")) %>% 
  mutate(season = ifelse(season == 1900, 2000, season)) %>% 
  filter(wins < 80)

teams$ties[which(is.na(teams$ties))] <- 0

unique_teams <- teams %>%
  filter(division != "") %>% 
  mutate(season = as.numeric(season)) %>% 
  drop_na(season) %>% 
  group_by(team_id) %>% 
  slice_max(season) %>% 
  distinct(team_name, team_id, division) %>% 
  arrange(division, team_name)

write.csv(unique_teams, "teams/data/all_teams.csv")

for(i in unique(unique_teams$team_id)){
  
  team_info <- teams %>% filter(team_id == i) %>% 
    drop_na(wins, losses) %>% 
    mutate(record = paste(wins, losses, ties, sep = "-"),
           win_perc = format(round(wins / (wins + losses), 3), nsmall = 3)) %>% 
    select(season, head_coach, conference, record, win_perc)
  
  write.csv(team_info, paste0("teams/data/team_info/team_", i, ".csv"))
  
}
