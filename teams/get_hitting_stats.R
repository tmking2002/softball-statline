install.packages("tidyverse")

library(tidyverse)

teams <- read_csv("teams/data/all_teams.csv") %>% 
  select(team_name, team_id)

players <- read_csv("players/data/all_players.csv") %>% 
  select(player, player_id)

proper=function(x) paste0(toupper(substr(x, 1, 1)), tolower(substring(x, 2)))

get_stats <- function(box, season){
  
  stats <- box %>% 
    merge(teams, by.x = "team", by.y = "team_name") %>% 
    separate(player, c("last", "first"), sep = ", ") %>% 
    drop_na(first, last) %>% 
    mutate(first =  proper(trimws(str_remove(first, "\\."))),
           last = proper(trimws(str_remove(last, "\\."))),
           player = paste(first, last),
           season = .env$season) %>% 
    filter(str_length(first) > 1,
           str_length(last) > 1,
           first != "Unknown") %>% 
    merge(players, by = "player") %>% 
    group_by(team_id, season, player, player_id) %>% 
    summarise(across(5:25, sum),
              avg = format(round(h / ab, 3), nsmall = 3),
              obp = round((h + bb + hbp) / (ab + bb + hbp + sf + sh), 3),
              slg = round(tb / ab, 3),
              ops = format(round(obp + slg, 3), nsmall = 3)) %>% 
    ungroup() %>% 
    filter(ab > 0) %>% 
    drop_na(avg, obp, ops) %>% 
    select(team_id, player_id, season, player, ab, h, x2b, x3b, hr, rbi, r, bb, hbp, k, sb, cs, avg, obp, ops) %>% 
    arrange(desc(ops))
  
}

write.csv(distinct(rbind(readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d1_hitting_box_scores_2024.RDS")), 
                         readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d2_hitting_box_scores_2024.RDS")),
                         readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d3_hitting_box_scores_2024.RDS")))) %>% get_stats(., 2024),
          "teams/data/hitting_stats/hitting_stats_2024.csv")
