library(tidyverse)

teams <- read_csv("~/Projects/softball-statline/teams/data/all_teams.csv") %>% 
  select(team_name, team_id)

players <- read_csv("~/Projects/softball-statline/players/data/all_players.csv") %>% 
  select(player, player_id)

proper=function(x) paste0(toupper(substr(x, 1, 1)), tolower(substring(x, 2)))

get_stats <- function(box, season){
  
  stats <- box %>% 
    merge(teams, by.x = "team", by.y = "team_name") %>% 
    mutate(season = .env$season) %>% 
    filter(str_length(player) > 1) %>% 
    merge(players, by = "player") %>% 
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

write.csv(read_csv("~/Projects/softball-statline/teams/data/box_scores/d1_pitching_box_2015.csv") %>% get_stats(., 2015), 
          "~/Projects/softball-statline/teams/data/pitching_stats/pitching_stats_2015.csv")

write.csv(read_csv("~/Projects/softball-statline/teams/data/box_scores/d1_pitching_box_2016.csv") %>% get_stats(., 2016), 
          "~/Projects/softball-statline/teams/data/pitching_stats/pitching_stats_2016.csv")

write.csv(read_csv("~/Projects/softball-statline/teams/data/box_scores/d1_pitching_box_2017.csv") %>% get_stats(., 2017), 
          "~/Projects/softball-statline/teams/data/pitching_stats/pitching_stats_2017.csv")

write.csv(read_csv("~/Projects/softball-statline/teams/data/box_scores/d1_pitching_box_2018.csv") %>% get_stats(., 2018), 
          "~/Projects/softball-statline/teams/data/pitching_stats/pitching_stats_2018.csv")

write.csv(read_csv("~/Projects/softball-statline/teams/data/box_scores/d1_pitching_box_2019.csv") %>% get_stats(., 2019), 
          "~/Projects/softball-statline/teams/data/pitching_stats/pitching_stats_2019.csv")

write.csv(read_csv("~/Projects/softball-statline/teams/data/box_scores/d1_pitching_box_2020.csv") %>% get_stats(., 2020), 
          "~/Projects/softball-statline/teams/data/pitching_stats/pitching_stats_2020.csv")

write.csv(read_csv("~/Projects/softball-statline/teams/data/box_scores/d1_pitching_box_2021.csv") %>% get_stats(., 2021), 
          "~/Projects/softball-statline/teams/data/pitching_stats/pitching_stats_2021.csv")

write.csv(read_csv("~/Projects/softball-statline/teams/data/box_scores/d1_pitching_box_2022.csv") %>% get_stats(., 2022), 
          "~/Projects/softball-statline/teams/data/pitching_stats/pitching_stats_2022.csv")

write.csv(read_csv("~/Projects/softball-statline/teams/data/box_scores/d1_pitching_box_2023.csv") %>% get_stats(., 2023), 
          "~/Projects/softball-statline/teams/data/pitching_stats/pitching_stats_2023.csv")
