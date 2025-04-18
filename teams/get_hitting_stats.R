if (!require("tidyverse", character.only = TRUE)) {
  install.packages("tidyverse")
}
library(tidyverse)

print("HITTING STATS")

teams <- read_csv("teams/data/all_teams.csv") %>% 
  select(team_name, team_id)

players <- read_csv("players/data/all_players.csv") %>% 
  select(player, player_id)

proper=function(x) paste0(toupper(substr(x, 1, 1)), tolower(substring(x, 2)))

get_stats <- function(box, season){
  
  stats <- box %>% 
    merge(teams, by.x = "team", by.y = "team_name")
  
  if(season != 2025){
    stats <- stats %>% 
      separate(player, c("last", "first"), sep = ", ") %>% 
      drop_na(first, last) %>% 
      mutate(first =  proper(trimws(str_remove(first, "\\."))),
             last = proper(trimws(str_remove(last, "\\."))),
             player = paste(first, last))
  }

  stats <- stats %>% 
    mutate(season = .env$season,
           across(4:26, \(col) ifelse(is.na(col), 0, col))) %>% 
    merge(players, by = "player") %>% 
    group_by(team_id, team, season, player, player_id) %>% 
    summarise(across(c(ab, h, x2b, x3b, tb, hr, rbi, r, bb, hbp, k, sb, cs, sf, sh), sum),
              avg = format(round(h / ab, 3), nsmall = 3),
              obp = round((h + bb + hbp) / (ab + bb + hbp + sf + sh), 3),
              slg = round(tb / ab, 3),
              ops = format(round(obp + slg, 3), nsmall = 3)) %>% 
    ungroup() %>% 
    filter(ab > 0) %>% 
    drop_na(avg, obp, ops) %>% 
    select(team_id, player_id, season, player, ab, h, x2b, x3b, hr, rbi, r, bb, hbp, k, sb, cs, avg, obp, ops, team) %>% 
    arrange(desc(ops))
  
}

write.csv(distinct(rbind(readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d1_hitting_box_scores_2016.RDS")), 
                         readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d2_hitting_box_scores_2016.RDS")),
                         readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d3_hitting_box_scores_2016.RDS")))) %>% get_stats(., 2016),
          "teams/data/hitting_stats/hitting_stats_2016.csv")

write.csv(distinct(rbind(readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d1_hitting_box_scores_2017.RDS")), 
                         readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d2_hitting_box_scores_2017.RDS")),
                         readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d3_hitting_box_scores_2017.RDS")))) %>% get_stats(., 2017),
          "teams/data/hitting_stats/hitting_stats_2017.csv")

write.csv(distinct(rbind(readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d1_hitting_box_scores_2018.RDS")), 
                         readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d2_hitting_box_scores_2018.RDS")),
                         readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d3_hitting_box_scores_2018.RDS")))) %>% get_stats(., 2018),
          "teams/data/hitting_stats/hitting_stats_2018.csv")

write.csv(distinct(rbind(readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d1_hitting_box_scores_2019.RDS")), 
                         readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d2_hitting_box_scores_2019.RDS")),
                         readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d3_hitting_box_scores_2019.RDS")))) %>% get_stats(., 2019),
          "teams/data/hitting_stats/hitting_stats_2019.csv")

write.csv(distinct(rbind(readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d1_hitting_box_scores_2020.RDS")), 
                         readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d2_hitting_box_scores_2020.RDS")),
                         readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d3_hitting_box_scores_2020.RDS")))) %>% get_stats(., 2020),
          "teams/data/hitting_stats/hitting_stats_2020.csv")

write.csv(distinct(rbind(readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d1_hitting_box_scores_2021.RDS")), 
                         readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d2_hitting_box_scores_2021.RDS")))) %>% get_stats(., 2021),
          "teams/data/hitting_stats/hitting_stats_2021.csv")

write.csv(distinct(rbind(readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d1_hitting_box_scores_2022.RDS")), 
                         readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d2_hitting_box_scores_2022.RDS")),
                         readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d3_hitting_box_scores_2022.RDS")))) %>% get_stats(., 2022),
          "teams/data/hitting_stats/hitting_stats_2022.csv")

write.csv(distinct(rbind(readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d1_hitting_box_scores_2023.RDS")), 
                         readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d2_hitting_box_scores_2023.RDS")),
                         readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d3_hitting_box_scores_2023.RDS")))) %>% get_stats(., 2023),
          "teams/data/hitting_stats/hitting_stats_2023.csv")

write.csv(distinct(rbind(readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d1_hitting_box_scores_2024.RDS")), 
                         readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d2_hitting_box_scores_2024.RDS")),
                         readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d3_hitting_box_scores_2024.RDS")))) %>% get_stats(., 2024),
          "teams/data/hitting_stats/hitting_stats_2024.csv")

write.csv(distinct(rbind(readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d1_hitting_box_scores_2025.RDS")), 
                         readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d2_hitting_box_scores_2025.RDS")),
                         readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/d3_hitting_box_scores_2025.RDS")))) %>% get_stats(., 2025),
          "teams/data/hitting_stats/hitting_stats_2025.csv")

