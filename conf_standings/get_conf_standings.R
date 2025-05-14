if (!require("tidyverse", character.only = TRUE)) {
  install.packages("tidyverse")
}
library(tidyverse)

if (!require("glue", character.only = TRUE)) {
  install.packages("glue")
}
library(glue)

if (!require("rio", character.only = TRUE)) {
  install.packages("rio")
}
library(rio)

print("CONF STANDINGS")

cur_season <- 2025

info <- try(rio::import("https://github.com/sportsdataverse/softballR-data/raw/main/data/ncaa_team_info.RDS"), silent = TRUE)

team_ids <- read_csv("teams/data/all_teams.csv") %>% 
  select(team_name, team_id)

conferences <- info %>%
  filter(season == cur_season & division == "D-I") %>%
  distinct(team_name, conference) %>% 
  mutate(conference = ifelse(conference == "CUSA", "C-USA", conference))

conf_scoreboard <- try(
  rio::import(glue("https://github.com/sportsdataverse/softballR-data/raw/main/data/ncaa_scoreboard_{cur_season}.RDS")),
  silent = TRUE
) %>%
  filter(home_team != away_team) %>% 
  drop_na(home_team, away_team) %>%
  mutate(
    home_team = str_replace(home_team, "&amp;", "&"),
    away_team = str_replace(away_team, "&amp;", "&"),
    home_team = str_replace(home_team, "&#39;", "'"),
    away_team = str_replace(away_team, "&#39;", "'")
  ) %>%
  merge(conferences, by.x = "home_team", by.y = "team_name", all = TRUE) %>%
  rename(home_conference = conference) %>%
  merge(conferences, by.x = "away_team", by.y = "team_name", all = TRUE) %>%
  rename(away_conference = conference) %>%
  drop_na(home_conference, away_conference) %>%
  filter(home_conference == away_conference)

total_scoreboard <- try(
  rio::import(glue("https://github.com/sportsdataverse/softballR-data/raw/main/data/ncaa_scoreboard_{cur_season}.RDS")),
  silent = TRUE
) %>%
  drop_na(home_team, away_team) %>%
  mutate(
    home_team = str_replace(home_team, "&amp;", "&"),
    away_team = str_replace(away_team, "&amp;", "&"),
    home_team = str_replace(home_team, "&#39;", "'"),
    away_team = str_replace(away_team, "&#39;", "'")
  )

team1_scoreboard <- total_scoreboard[c(9,1,4,5,8)] %>% `names<-`(c("date","team_name","runs","opponent_name","opponent_runs"))
team2_scoreboard <- total_scoreboard[c(9,5,8,1,4)] %>% `names<-`(c("date","team_name","runs","opponent_name","opponent_runs"))

total_records <- rbind(team1_scoreboard, team2_scoreboard) %>%
  mutate(result = case_when(runs > opponent_runs ~ "W",
                            runs < opponent_runs ~ "L",
                            runs == opponent_runs ~ "T")) %>%
  drop_na(team_name, runs, opponent_runs) %>% 
  group_by(team_name) %>%
  summarise(W = sum(result == "W"),
            L = sum(result == "L"),
            T = sum(result == "T"),
            win_perc = (W + T / 2) / (W + L + T),
            record = paste(W, L, T, sep = "-")) %>%
  merge(team_ids, by = "team_name") %>% 
  arrange(desc(win_perc)) %>% 
  select(team_name, win_perc, record)

create_standings <- function(conference){
  
  scoreboard <- conf_scoreboard %>%
    filter(home_conference == conference)
  
  if(nrow(scoreboard) != 0){
    
    team1_scoreboard <- scoreboard[c(9,1,5,2,8)] %>% `names<-`(c("date","team_name","runs","opponent_name","opponent_runs"))
    team2_scoreboard <- scoreboard[c(9,2,8,1,5)] %>% `names<-`(c("date","team_name","runs","opponent_name","opponent_runs"))
    
    scoreboard_upd <- rbind(team1_scoreboard, team2_scoreboard) %>%
      mutate(result = case_when(runs > opponent_runs ~ "W",
                                runs < opponent_runs ~ "L",
                                runs == opponent_runs ~ "T")) %>%
      drop_na(team_name, runs, opponent_runs)
    
    standings <- scoreboard_upd %>%
      group_by(team_name) %>%
      summarise(W = sum(result == "W"),
                L = sum(result == "L"),
                T = sum(result == "T"),
                conf_win_perc = (W + T / 2) / (W + L + T),
                conf_record = paste(W, L, T, sep = "-")) %>%
      merge(team_ids, by = "team_name") %>% 
      merge(total_records, by = "team_name") %>% 
      arrange(-conf_win_perc, -win_perc) %>%
      select(team_name, conf_record, record, team_id) %>% 
      `names<-`(c("Team", "Conf", "Total", "Team ID"))
    
  } else{
    
    teams <- conferences %>% 
      filter(conference == .env$conference)
    
    standings <- total_records %>% 
      filter(team_name %in% teams$team_name) %>% 
      mutate(conference = .env$conference,
             conf_record = "0-0") %>% 
      merge(team_ids, by = "team_name") 
    
    for(i in 1:nrow(teams)){
      
      if(!(teams$team_name[i] %in% standings$team_name)){
        
        standings <- rbind(standings, data.frame(team_name = teams$team_name[i], win_perc = 0, record = "0-0", conference = conference, conf_record = "0-0") %>% merge(team_ids, by = "team_name"))
        
      }
      
    }
    
    standings <- standings %>% 
      arrange(-win_perc) %>% 
      select(team_name, conf_record, record, team_id) %>% 
      `names<-`(c("Team", "Conf", "Total", "Team ID"))
    
  }
  
  return(standings)

}

prev_standings <- list.files(path = "conf_standings", pattern = "\\.csv$", full.names = TRUE)

unlink(prev_standings)

unique_confs <- unique(conferences$conference) %>% sort() %>% paste(collapse = ", ")

write(unique_confs, file = "conf_standings/conferences.txt")

for(i in 1:length(unique(conferences$conference))){

  conf <- unique(conferences$conference)[i]

  standings <- create_standings(conf)

  write_csv(standings, file = paste0("conf_standings/",conf,".csv"))

  print(i)

}

