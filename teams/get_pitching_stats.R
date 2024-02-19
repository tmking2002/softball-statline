library(tidyverse)

print("PITCHING STATS")

teams <- read_csv("teams/data/all_teams.csv") %>% 
  select(team_name, team_id)

players <- read_csv("players/data/all_players.csv") %>% 
  select(player, player_id)

proper=function(x) paste0(toupper(substr(x, 1, 1)), tolower(substring(x, 2)))

get_stats <- function(box, season){
  
  stats <- box %>% 
    separate(player, c("last", "first"), sep = ", ") %>% 
    merge(teams, by.x = "team", by.y = "team_name") %>% 
    mutate(season = .env$season,
           player = paste(first, last)) %>% 
    filter(str_length(player) > 1) %>% 
    mutate(lower_player = tolower(player)) %>% 
    merge(players %>% mutate(lower_player = tolower(player)) %>% select(-player), by = "lower_player") %>% 
    group_by(team_id, season, player, player_id) %>% 
    summarise(across(c(er, ip, ha, bf, bb, hb, so, hr_a), 
                     .fns = \(col) sum(as.numeric(col))),
              era = format(round(er / ip * 7, 3), nsmall = 3),
              opp_avg = round((ha) / (bf - bb - hb), 3),
              whip = round((bb + hb + ha) / ip, 3),
              fip = format(round((13 * hr_a + 3 * (bb + hb) - 2 * so) / ip + 2.4, 3), nsmall = 3),
              ip = round(floor(ip) + ip %% 1 / 3, 1)) %>% 
    ungroup() %>% 
    filter(ip > 0) %>% 
    drop_na(era, opp_avg, whip, fip) %>% 
    select(team_id, player_id, season, player, ip, ha, bb, hb, so, hr_a, era, opp_avg, whip, fip) %>% 
    arrange(desc(ip)) 
  
  return(stats)
  
}

write.csv(distinct(rbind(readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d1_pitching_box_scores_2024.RDS")), 
                         readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d2_pitching_box_scores_2024.RDS")),
                         readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d3_pitching_box_scores_2024.RDS")))) %>% get_stats(., 2024),
          "teams/data/pitching_stats/pitching_stats_2024.csv")
