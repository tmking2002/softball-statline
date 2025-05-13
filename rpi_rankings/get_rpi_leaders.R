install.packages("tidyverse")
library(tidyverse)

if (!require("rio", character.only = TRUE)) {
  install.packages("rio")
}
library(rio)

print("RPI LEADERS")

cur_season <- 2025

get_current_rpi <- function(scoreboard){

  team1_scoreboard <- scoreboard[c(9,1,4,5,8)] %>% `names<-`(c("date","team_name","runs","opponent_name","opponent_runs"))
  team2_scoreboard <- scoreboard[c(9,5,8,1,4)] %>% `names<-`(c("date","team_name","runs","opponent_name","opponent_runs"))

  scoreboard_upd <- rbind(team1_scoreboard, team2_scoreboard) %>%
    mutate(win = case_when(runs > opponent_runs ~ 1,
                           runs < opponent_runs ~ 0,
                           runs == opponent_runs ~ 0.5)) %>%
    drop_na(team_name, opponent_name, runs, opponent_runs) %>% 
    mutate(team_name = str_replace(team_name, "&amp;", "&"),
           team_name = str_replace(team_name, "&#39;", "'"),
           opponent_name = str_replace(opponent_name, "&amp;", "&"),
           opponent_name = str_replace(opponent_name, "&#39;", "'"))
  
  win_perc <- scoreboard_upd %>%
    group_by(team_name) %>%
    summarise(games = n(),
              win_perc = mean(win, na.rm = T)) %>%
    ungroup() %>% 
    select(-games) %>%
    drop_na()

  scoreboard_upd_2 <- scoreboard_upd %>%
    merge(win_perc, by.x = "opponent_name", by.y = "team_name", all = T) %>%
    rename(opponent_win_perc = win_perc) %>%
    merge(win_perc, by = "team_name", all = T)


  opponent_win_perc <- scoreboard_upd_2 %>%
    group_by(team_name) %>%
    summarise(opponent_opponent_win_perc = mean(opponent_win_perc, na.rm = T))

  scoreboard_upd_3 <- scoreboard_upd_2 %>%
    merge(opponent_win_perc, by.x = "opponent_name", by.y = "team_name", all = T)


  rpi <- scoreboard_upd_3 %>%
    drop_na() %>% 
    group_by(team_name) %>%
    summarise(rpi_coef = (.25 * mean(win_perc) + .5 * mean(opponent_win_perc) + .25 * mean(opponent_opponent_win_perc)),
              record = paste(floor(sum(win)),floor(n() - sum(win)),ceiling(sum(win) %% 1), sep = "-"),
              games = n()) %>%
    ungroup() %>%
    # filter(games >= 5) %>% 
    mutate(rpi_rank = rank(-rpi_coef, ties.method = 'min')) %>% 
    select(-games)


  return(rpi)
}

team_ids <- read_csv("teams/data/all_teams.csv") %>% 
  select(team_name, team_id)

# D1
d1_scoreboard <- rio::import(glue("https://github.com/sportsdataverse/softballR-data/raw/main/data/ncaa_scoreboard_{cur_season}.RDS"))

d1_rpi <- get_current_rpi(d1_scoreboard) %>%
  merge(team_ids, by = "team_name") %>% 
  select(rpi_rank, team_name, record, team_id) %>%
  `names<-`(c("Rank", "Team", "Record", "Team ID")) %>% 
  arrange(Rank)

write_csv(d1_rpi, "rpi_rankings/d1_rpi.csv")

# D2
d2_scoreboard <- rio::import(glue("https://github.com/sportsdataverse/softballR-data/raw/main/data/ncaa_scoreboard_D2_{cur_season}.RDS"))

d2_rpi <- get_current_rpi(d2_scoreboard) %>%
  merge(team_ids, by = "team_name") %>% 
  select(rpi_rank, team_name, record, team_id) %>%
  `names<-`(c("Rank", "Team", "Record", "Team ID")) %>% 
  arrange(Rank)

write_csv(d2_rpi, "rpi_rankings/d2_rpi.csv")

# D3
d3_scoreboard <- rio::import(glue("https://github.com/sportsdataverse/softballR-data/raw/main/data/ncaa_scoreboard_D3_{cur_season}.RDS"))

d3_rpi <- get_current_rpi(d3_scoreboard) %>%
  merge(team_ids, by = "team_name") %>% 
  select(rpi_rank, team_name, record, team_id) %>%
  `names<-`(c("Rank", "Team", "Record", "Team ID")) %>% 
  arrange(Rank)

write_csv(d3_rpi, "rpi_rankings/d3_rpi.csv")