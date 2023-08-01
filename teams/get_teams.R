teams <- readRDS("~/Projects/softballR-data/data/ncaa_team_info.RDS")

unique_teams <- teams %>%
  filter(division != "") %>% 
  mutate(season = as.numeric(season)) %>% 
  drop_na(season) %>% 
  group_by(team_id) %>% 
  slice_max(season) %>% 
  distinct(team_name, team_id, division) %>% 
  arrange(division, team_name)

write.csv(unique_teams, "~/Projects/softball-statline/teams/data/all_teams.csv")
