if (!require("tidyverse", character.only = TRUE)) {
  install.packages("tidyverse")
}
library(tidyverse)

if (!require("rio", character.only = TRUE)) {
  install.packages("rio")
}
library(rio)

print("GAME LOGS")

get_game_log <- function(season) {
  
  team_ids <- rio::import("https://github.com/sportsdataverse/softballR-data/raw/main/data/ncaa_team_info.RDS") %>% 
    filter(season == .env$season) %>% 
    select(team_name, team_id) %>% 
    distinct()
  
  raw_scoreboard <- rbind(
    rio::import(paste0("https://github.com/sportsdataverse/softballR-data/raw/main/data/ncaa_scoreboard_", season, ".RDS")),
    rio::import(paste0("https://github.com/sportsdataverse/softballR-data/raw/main/data/ncaa_scoreboard_D2_", season, ".RDS")),
    rio::import(paste0("https://github.com/sportsdataverse/softballR-data/raw/main/data/ncaa_scoreboard_D3_", season, ".RDS"))
  ) %>%
    drop_na(home_team_runs, away_team_runs, home_team, away_team) %>%
    mutate(
      home_team = gsub("&amp;", "&", home_team),
      away_team = gsub("&amp;", "&", away_team),
      home_team = gsub("&#39;", "'", home_team),
      away_team = gsub("&#39;", "'", away_team)
    )

  total_scoreboard <- data.frame()
  
  for(i in 1:nrow(team_ids)){
    
    cur_scoreboard <- raw_scoreboard %>% 
      filter(home_team == team_ids$team_name[i] | away_team == team_ids$team_name[i]) %>% 
      mutate(team = ifelse(home_team == team_ids$team_name[i], home_team, away_team),
             home = ifelse(home_team == team_ids$team_name[i], "", "@"),
             opponent = ifelse(home_team == team_ids$team_name[i], away_team, home_team),
             runs = ifelse(home_team == team_ids$team_name[i], home_team_runs, away_team_runs),
             allowed = ifelse(home_team == team_ids$team_name[i], away_team_runs, home_team_runs),
             result = ifelse(home_team == team_ids$team_name[i], 
                             case_when(home_team_runs > away_team_runs ~ "W", 
                                       away_team_runs > home_team_runs ~ "L",
                                       TRUE ~ "T"),
                             case_when(home_team_runs > away_team_runs ~ "L", 
                                       away_team_runs > home_team_runs ~ "W",
                                       TRUE ~ "T")),
             win = cumsum(result == "W"),
             loss = cumsum(result == "L"),
             tie = cumsum(result == "T"),
             record = paste(win, loss, tie, sep = "-")) %>%
      merge(team_ids, by.x = "opponent", by.y = "team_name") %>% 
      rename(opponent_id = team_id) %>% 
      mutate(team_id = team_ids$team_id[i],
             games = win+loss+tie) %>% 
      arrange(team_id, games) %>% 
      select(team_id, opponent_id, game_id, game_date, team, home, opponent, result, runs, allowed, record) 
    
    total_scoreboard <- rbind(total_scoreboard, cur_scoreboard)
    
  }
  
  return(total_scoreboard)
    
}

scoreboard_2025 <- get_game_log(2025)

write.csv(scoreboard_2025, "teams/data/game_logs/game_logs_2025.csv")

