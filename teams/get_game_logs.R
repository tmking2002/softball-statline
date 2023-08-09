get_game_log <- function(season) {
  
  team_ids <- readRDS("~/Projects/softballR-data/data/ncaa_team_info.RDS") %>% 
    filter(season == .env$season) %>% 
    select(team_name, team_id) %>% 
    distinct()
  
  raw_scoreboard <- rbind(readRDS(paste0("~/Projects/softballR-data/data/ncaa_scoreboard_", season, ".RDS")),
                          readRDS(paste0("~/Projects/softballR-data/data/ncaa_scoreboard_D2_", season, ".RDS")),
                          readRDS(paste0("~/Projects/softballR-data/data/ncaa_scoreboard_D3_", season, ".RDS"))) %>% 
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
      mutate(team_id = team_ids$team_id[i]) %>% 
      select(team_id, opponent_id, game_id, game_date, team, home, opponent, result, runs, allowed, record) %>% 
      arrange(team_id, game_date)
    
    total_scoreboard <- rbind(total_scoreboard, cur_scoreboard)
    
  }
  
  return(total_scoreboard)
    
}

scoreboard_2023 <- get_game_log(2023)
scoreboard_2022 <- get_game_log(2022)
scoreboard_2021 <- get_game_log(2021)
scoreboard_2020 <- get_game_log(2020)
scoreboard_2019 <- get_game_log(2019)
scoreboard_2018 <- get_game_log(2018)
scoreboard_2017 <- get_game_log(2017)
scoreboard_2016 <- get_game_log(2016)
scoreboard_2015 <- get_game_log(2015)
scoreboard_2014 <- get_game_log(2014)
scoreboard_2013 <- get_game_log(2013)
scoreboard_2012 <- get_game_log(2012)

write.csv(scoreboard_2023, "~/Projects/softball-statline/teams/data/game_logs/game_logs_2023.csv")
write.csv(scoreboard_2022, "~/Projects/softball-statline/teams/data/game_logs/game_logs_2022.csv")
write.csv(scoreboard_2021, "~/Projects/softball-statline/teams/data/game_logs/game_logs_2021.csv")
write.csv(scoreboard_2020, "~/Projects/softball-statline/teams/data/game_logs/game_logs_2020.csv")
write.csv(scoreboard_2019, "~/Projects/softball-statline/teams/data/game_logs/game_logs_2019.csv")
write.csv(scoreboard_2018, "~/Projects/softball-statline/teams/data/game_logs/game_logs_2018.csv")
write.csv(scoreboard_2017, "~/Projects/softball-statline/teams/data/game_logs/game_logs_2017.csv")
write.csv(scoreboard_2016, "~/Projects/softball-statline/teams/data/game_logs/game_logs_2016.csv")
write.csv(scoreboard_2015, "~/Projects/softball-statline/teams/data/game_logs/game_logs_2015.csv")
write.csv(scoreboard_2014, "~/Projects/softball-statline/teams/data/game_logs/game_logs_2014.csv")
write.csv(scoreboard_2013, "~/Projects/softball-statline/teams/data/game_logs/game_logs_2013.csv")
write.csv(scoreboard_2012, "~/Projects/softball-statline/teams/data/game_logs/game_logs_2012.csv")