box <- readRDS("~/Projects/softballR-data/data/d1_hitting_box_scores_2018.RDS") 
teams <- read_csv("~/Projects/softball-statline/teams/data/all_teams.csv") %>% 
  select(team_name, team_id)

proper=function(x) paste0(toupper(substr(x, 1, 1)), tolower(substring(x, 2)))

stats <- box %>% 
  merge(teams, by.x = "team", by.y = "team_name") %>% 
  separate(player, c("last", "first"), sep = ", ") %>% 
  drop_na(first, last) %>% 
  mutate(first =  proper(trimws(str_remove(first, "\\."))),
         last = proper(trimws(str_remove(last, "\\."))),
         player = paste(first, last),
         season = 2018) %>% 
  filter(str_length(first) > 1,
         str_length(last) > 1,
         first != "Unknown") %>% 
  group_by(team_id, season, player) %>% 
  summarise(across(5:25, sum),
            avg = format(round(h / ab, 3), nsmall = 3),
            obp = round((h + bb + hbp) / (ab + bb + hbp + sf + sh), 3),
            slg = round(tb / ab, 3),
            ops = format(round(obp + slg, 3), nsmall = 3)) %>% 
  ungroup() %>% 
  filter(ab > 0) %>% 
  drop_na(avg, obp, ops) %>% 
  select(team_id, season, player, ab, h, x2b, x3b, hr, rbi, r, bb, hbp, k, sb, cs, avg, obp, ops) %>% 
  arrange(desc(ops))

write.csv(stats, "~/Projects/softball-statline/teams/data/rosters/d1_hitting_stats_2018.csv")
