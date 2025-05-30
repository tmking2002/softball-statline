if (!require("tidyverse", character.only = TRUE)) {
  install.packages("tidyverse")
}
library(tidyverse)
if (!require("rvest", character.only = TRUE)) {
  install.packages("rvest")
}
library(rvest)
if (!require("anytime", character.only = TRUE)) {
  install.packages("anytime")
}
library(anytime)
if (!require("magrittr", character.only = TRUE)) {
  install.packages("magrittr")
}
library(magrittr)

if (!require("rio", character.only = TRUE)) {
  install.packages("rio")
}
library(rio)

print("SCHEDULE")

load_ncaa_softball_scoreboard <- function(season, division = "D1") {
  if (!is.numeric(season)) return("Invalid Input")
  if (!(division %in% c("D1", "D2", "D3"))) stop("Invalid Division")
  if (min(season) < 2012 | max(season) > 2025) stop("Invalid Season")
  if (min(season) < 2016 & division != "D1") stop("Invalid Season")
  
  urls <- if (division == "D1") {
    glue::glue("https://github.com/tmking2002/softballR-data/blob/main/data/ncaa_scoreboard_{season}.RDS?raw=true")
  } else {
    glue::glue("https://github.com/tmking2002/softballR-data/blob/main/data/ncaa_scoreboard_{division}_{season}.RDS?raw=true")
  }
  
  scoreboard <- lapply(urls, function(link) {
    tryCatch(rio::import(link), error = function(e) NULL)
  }) %>%
    bind_rows()
  
  return(scoreboard)
}

team_ids <- read_csv("teams/data/all_teams.csv") %>% 
  select(team_name, team_id)

rankings <- "https://nfca.org/component/com_nfca/Itemid,230/list,1/pdiv,div1/top25,1/year,2025/" %>% 
  read_html() %>% 
  html_table() %>% 
  extract2(1) %>% 
  mutate(Team = str_extract(Team, "\\w+(?: \\w+)?"),
         Team = str_replace(Team, "State", "St.")) %>% 
  left_join(team_ids, by = c("Team" = "team_name")) %>% 
  select(Team, Rank) %>% 
  `names<-`(c("Team", "Rank"))

d1_id <- 18503
d2_id <- 18504
d3_id <- 18505

days = as.Date("2025-02-04"):min(Sys.Date() - 1, "2025-06-08")

scoreboard_d1 <- load_ncaa_softball_scoreboard(2025, "D1")
scoreboard_d2 <- load_ncaa_softball_scoreboard(2025, "D2")
scoreboard_d3 <- load_ncaa_softball_scoreboard(2025, "D3")

scoreboard_d1 <- scoreboard_d1 %>% 
  select(-c(home_team_id, away_team_id)) %>% 
  mutate(
    across(
      .cols = c(home_team, away_team),
      .fns = \(col) str_replace(col, "&amp;", "&")
    ),
    across(
      .cols = c(home_team, away_team),
      .fns = \(col) str_replace(col, "&#39;", "'")
    ),
    across(
      .cols = c(home_team, away_team),
      .fns = \(col) str_remove_all(col, "Fairleigh ")
    )
  ) %>% 
  merge(team_ids %>% `names<-`(c("away_team", "away_team_id")), by = "away_team", all = TRUE) %>% 
  merge(team_ids %>% `names<-`(c("home_team", "home_team_id")), by = "home_team", all = TRUE) %>% 
  drop_na() %>% 
  select(away_team, away_team_id, away_team_logo, away_team_runs, home_team, home_team_id, home_team_logo, home_team_runs, game_date, game_id, status)

scoreboard_d2 <- scoreboard_d2 %>% 
  select(-c(home_team_id, away_team_id)) %>% 
  mutate(
    across(
      .cols = c(home_team, away_team),
      .fns = \(col) str_replace(col, "&amp;", "&")
    ),
    across(
      .cols = c(home_team, away_team),
      .fns = \(col) str_replace(col, "&#39;", "'")
    ),
    across(
      .cols = c(home_team, away_team),
      .fns = \(col) str_remove_all(col, "Fairleigh ")
    )
  ) %>% 
  merge(team_ids %>% `names<-`(c("away_team", "away_team_id")), by = "away_team", all = TRUE) %>% 
  merge(team_ids %>% `names<-`(c("home_team", "home_team_id")), by = "home_team", all = TRUE) %>% 
  drop_na() %>% 
  select(away_team, away_team_id, away_team_logo, away_team_runs, home_team, home_team_id, home_team_logo, home_team_runs, game_date, game_id, status)

scoreboard_d3 <- scoreboard_d3 %>% 
  select(-c(home_team_id, away_team_id)) %>% 
  mutate(
    across(
      .cols = c(home_team, away_team),
      .fns = \(col) str_replace(col, "&amp;", "&")
    ),
    across(
      .cols = c(home_team, away_team),
      .fns = \(col) str_replace(col, "&#39;", "'")
    ),
    across(
      .cols = c(home_team, away_team),
      .fns = \(col) str_remove_all(col, "Fairleigh ")
    )
  ) %>% 
  merge(team_ids %>% `names<-`(c("away_team", "away_team_id")), by = "away_team", all = TRUE) %>% 
  merge(team_ids %>% `names<-`(c("home_team", "home_team_id")), by = "home_team", all = TRUE) %>% 
  drop_na() %>% 
  select(away_team, away_team_id, away_team_logo, away_team_runs, home_team, home_team_id, home_team_logo, home_team_runs, game_date, game_id, status)


for(i in days){
  cur_games <- scoreboard_d1 %>% 
    filter(game_date == format(as.Date(i, origin = "1970-01-01"), "%m/%d/%Y"))
  
  if(year(as.Date(i, origin = "1970-01-01")) == 2025){
    cur_games <- cur_games %>% 
      left_join(rankings, by = c("home_team" = "Team")) %>% 
      rename(home_rank = Rank) %>% 
      left_join(rankings, by = c("away_team" = "Team")) %>% 
      rename(away_rank = Rank) %>% 
      mutate(home_rank = ifelse(is.na(home_rank), 26, home_rank),
             away_rank = ifelse(is.na(away_rank), 26, away_rank)) %>% 
      rowwise() %>% 
      mutate(top_rank = min(c(home_rank, away_rank)),
             home_team = ifelse(home_rank <= 25, paste0("#", home_rank, " ", home_team), home_team),
             away_team = ifelse(away_rank <= 25, paste0("#", away_rank, " ", away_team), away_team)) %>% 
      arrange(top_rank) %>% 
      select(away_team, away_team_id, away_team_logo, away_team_runs, home_team, home_team_id, home_team_logo, home_team_runs, game_date, game_id, status)
  }
  
  if(!is.null(nrow(cur_games))){
    cur_games <- cur_games %>% 
      mutate(game_date = substr(game_date, 1, 10))
  }
  
  write.csv(cur_games, paste0("schedule/schedule_data/d1/", as.Date(i, origin = "1970-01-01"), ".csv"))
  
  print(as.Date(i, origin = "1970-01-01"))
}

for(i in days){
  cur_games <- scoreboard_d2 %>% 
    filter(game_date == format(as.Date(i, origin = "1970-01-01"), "%m/%d/%Y"))
  
  if(!is.null(nrow(cur_games))){
    cur_games <- cur_games %>% 
      mutate(game_date = substr(game_date, 1, 10))
  }
  
  write.csv(cur_games, paste0("schedule/schedule_data/d2/", as.Date(i, origin = "1970-01-01"), ".csv"))
  
  print(as.Date(i, origin = "1970-01-01"))
}

for(i in days){
  cur_games <- scoreboard_d3 %>% 
    filter(game_date == format(as.Date(i, origin = "1970-01-01"), "%m/%d/%Y"))
  
  if(!is.null(nrow(cur_games))){
    cur_games <- cur_games %>% 
      mutate(game_date = substr(game_date, 1, 10))
  }
  
  write.csv(cur_games, paste0("schedule/schedule_data/d3/", as.Date(i, origin = "1970-01-01"), ".csv"))
  
  print(as.Date(i, origin = "1970-01-01"))
}
