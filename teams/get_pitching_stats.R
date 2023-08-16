library(tidyverse)

teams <- read_csv("~/Projects/softball-statline/teams/data/all_teams.csv") %>% 
  select(team_name, team_id)

players <- read_csv("~/Projects/softball-statline/players/data/all_players.csv") %>% 
  select(player, player_id)

proper=function(x) paste0(toupper(substr(x, 1, 1)), tolower(substring(x, 2)))

get_stats <- function(box, season){
  
  stats <- box %>% 
    separate(ip, c("innings", "frac"), sep = "\\.") %>% 
    mutate(ip = as.numeric(ifelse(is.na(frac), innings, as.numeric(innings) + as.numeric(frac) * 1/3))) %>% 
    select(-c(innings, frac)) %>% 
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
    summarise(across(c(6:37, 40), 
                     .fns = \(col) sum(as.numeric(col))),
              era = format(round(er / ip * 7, 3), nsmall = 3),
              opp_avg = round((ha) / (bf - bb - hb - sfa - sha), 3),
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

write.csv(readRDS("~/Projects/softballR-data/data/d1_pitching_box_scores_2021.RDS") %>% get_stats(., 2021), 
          "~/Projects/softball-statline/teams/data/pitching_stats/d1_pitching_stats_2021.csv")

write.csv(readRDS("~/Projects/softballR-data/data/d1_pitching_box_scores_2022.RDS") %>% get_stats(., 2022), 
          "~/Projects/softball-statline/teams/data/pitching_stats/d1_pitching_stats_2022.csv")

write.csv(readRDS("~/Projects/softballR-data/data/d1_pitching_box_scores_2023.RDS") %>% get_stats(., 2023), 
          "~/Projects/softball-statline/teams/data/pitching_stats/d1_pitching_stats_2023.csv")
