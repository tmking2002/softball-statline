library(tidyverse)
library(anytime)
library(rvest)
library(magrittr)

teams <- read_csv("~/Projects/softball-statline/teams/data/all_teams.csv") %>% 
  select(team_name, team_id)

rankings <- "https://nfca.org/component/com_nfca/Itemid,230/list,1/pdiv,div1/top25,1/year,2023/" %>% 
  read_html() %>% 
  html_table() %>% 
  extract2(1) %>% 
  mutate(Team = str_extract(Team, "\\w+(?: \\w+)?"),
         Team = str_replace(Team, "State", "St.")) %>% 
  left_join(teams, by = c("Team" = "team_name")) %>% 
  select(team_id, Rank) %>% 
  `names<-`(c("Team ID", "Rank"))

d1_id <- 18101
d2_id <- 18102
d3_id <- 18103

#cur_date <- Sys.Date()
start_date_d1 <- as.Date("2023-02-09")
end_date_d1 <- as.Date("2023-06-08")

start_date_d2 <- as.Date("2023-02-01")
end_date_d2 <- as.Date("2023-05-31")

start_date_d3 <- as.Date("2023-02-04")
end_date_d3 <- as.Date("2023-06-07")

get_games <- function(division_id, date){

  if(!(is(date, "Date"))){

    year <- try(strsplit(date, "-")[[1]][1])
    month <- try(strsplit(date, "-")[[1]][2])
    day <- try(strsplit(date, "-")[[1]][3])

  } else{

    month <- lubridate::month(date)
    day <- lubridate::day(date)
    year <- lubridate::year(date)

  }

  raw <- glue::glue("https://stats.ncaa.org/season_divisions/{division_id}/livestream_scoreboards?utf8=%E2%9C%93&season_division_id=&game_date={month}%2F{day}%2F{year}&conference_id=0&tournament_id=&commit=Submit") %>%
    readLines()

  locs <- grep("<tr id=\"", raw)

  if(length(locs) == 0) return(NULL)

  assemble_df <- function(loc, next_loc){

    game_vec <- raw[loc:(next_loc-1)]

    if(any(grepl("Canceled", game_vec))) return(NULL)

    game_id <- game_vec[grep("<tr id=\"", game_vec)[1]] %>%
      trimws() %>%
      stringr::str_remove_all("<tr id=\"contest_|\">")

    game_date <- game_vec[grep("<td rowspan=\"2\" valign=\"middle\">", game_vec)[1] + 1] %>%
      trimws()

    away_team <- game_vec[grep("<img height=\"20px\" width=\"30px\" alt=\"",game_vec)[1]] %>%
      strsplit("alt=\"|\" src=\"") %>%
      magrittr::extract2(1) %>%
      magrittr::extract(2)

    away_team_id <- game_vec[grep("<a target=\"TEAMS_WIN\" class=\"skipMask\" href=\"/teams/",game_vec)[1]] %>%
      strsplit("href=\"/teams/|\">") %>%
      magrittr::extract2(1) %>%
      magrittr::extract(2)

    away_team_logo <- game_vec[grep("<img height=\"20px\" width=\"30px\" alt=\"",game_vec)[1]] %>%
      strsplit("alt=\"|\" src=\"") %>%
      magrittr::extract2(1) %>%
      magrittr::extract(3) %>%
      stringr::str_remove_all("\" />")

    away_team_runs <- game_vec[grep("<div id=\"score_", game_vec)[1] + 1] %>%
      trimws()

    home_team <- game_vec[grep("<img height=\"20px\" width=\"30px\" alt=\"",game_vec)[2]] %>%
      strsplit("alt=\"|\" src=\"") %>%
      magrittr::extract2(1) %>%
      magrittr::extract(2)

    home_team_id <- game_vec[grep("<a target=\"TEAMS_WIN\" class=\"skipMask\" href=\"/teams/",game_vec)[2]] %>%
      strsplit("href=\"/teams/|\">") %>%
      magrittr::extract2(1) %>%
      magrittr::extract(2)

    home_team_logo <- game_vec[grep("<img height=\"20px\" width=\"30px\" alt=\"",game_vec)[2]] %>%
      strsplit("alt=\"|\" src=\"") %>%
      magrittr::extract2(1) %>%
      magrittr::extract(3) %>%
      stringr::str_remove_all("\" />")

    home_team_runs <- game_vec[grep("<div id=\"score_", game_vec)[2] + 1] %>%
      trimws()

    status <- game_vec[grep("<div class=\"livestream", game_vec) + 1] %>%
      trimws()

    game_df <- data.frame(away_team, away_team_id, away_team_logo, away_team_runs,
                          home_team, home_team_id, home_team_logo, home_team_runs,
                          game_date, game_id, status) %>%
      filter(status == "Final")

    return(game_df)

  }

  games_df <- data.frame()

  for(i in 1:(length(locs) - 1)){

    if(i %% 2 == 0) next

    loc <- locs[i]

    if(i == length(locs) - 3){
      next_loc <- length(raw)
    } else{
      next_loc <- locs[i + 2]
    }

    games_df <- rbind(games_df, assemble_df(loc, loc + 70))

  }

  if(length(games_df)== 0) return(NULL)

  games_df <- games_df %>%
    dplyr::filter(away_team_runs != "") %>%
    dplyr::mutate(home_team_runs = as.numeric(home_team_runs),
                  away_team_runs = as.numeric(away_team_runs),
                  game_date = substr(game_date, 1, 10)) %>%
    dplyr::distinct() %>% 
    select(-c(home_team_id, away_team_id)) %>% 
    merge(team_ids, by.x = "home_team", by.y = "team_name") %>% 
    rename(home_team_id = team_id) %>% 
    merge(team_ids, by.x = "away_team", by.y = "team_name") %>% 
    rename(away_team_id = team_id) %>% 
    mutate(season = year(anydate(game_date))) %>% 
    select(home_team_logo, home_team_id, home_team, home_team_runs, away_team_logo, away_team_id, away_team, away_team_runs, game_id, season, game_date)
  
  if(division_id == d1_id) {
    games_df <- games_df %>% 
      left_join(rankings, by = c("home_team_id" = "Team ID")) %>% 
      rename(home_rank = Rank) %>% 
      left_join(rankings, by = c("away_team_id" = "Team ID")) %>% 
      rename(away_rank = Rank) %>% 
      mutate(home_rank = ifelse(is.na(home_rank), 26, home_rank),
             away_rank = ifelse(is.na(away_rank), 26, away_rank)) %>% 
      rowwise() %>% 
      mutate(top_rank = min(c(home_rank, away_rank)),
             home_team = ifelse(home_rank <= 25, paste0("#", home_rank, " ", home_team), home_team),
             away_team = ifelse(away_rank <= 25, paste0("#", away_rank, " ", away_team), away_team)) %>% 
      arrange(top_rank) %>% 
      select(home_team_logo, home_team_id, home_team, home_team_runs, away_team_logo, away_team_id, away_team, away_team_runs, game_id, season, game_date)
  }
    
  return(games_df)

}

team_ids <- read_csv("~/Projects/softball-statline/teams/data/all_teams.csv") %>% 
  select(team_name, team_id)

for(i in start_date_d1:end_date_d1){
  cur_games <- get_games(d1_id, as.Date(i, origin = "1970-01-01"))
  
  if(!is.null(nrow(cur_games))){
    cur_games <- cur_games %>% 
      mutate(game_date = substr(game_date, 1, 10))
  }
  
  write.csv(cur_games, paste0("~/Projects/softball-statline/schedule/schedule_data/d1/", as.Date(i, origin = "1970-01-01"), ".csv"))
  
  print(as.Date(i, origin = "1970-01-01"))
}

for(i in start_date_d2:end_date_d2){
  cur_games <- get_games(d2_id, as.Date(i, origin = "1970-01-01"))
  
  if(!is.null(nrow(cur_games))){
    cur_games <- cur_games %>% 
      mutate(game_date = substr(game_date, 1, 10))
  }
  
  write.csv(cur_games, paste0("~/Projects/softball-statline/schedule/schedule_data/d2/", as.Date(i, origin = "1970-01-01"), ".csv"))
  
  print(as.Date(i, origin = "1970-01-01"))
}

for(i in start_date_d3:end_date_d3){
  cur_games <- get_games(d3_id, as.Date(i, origin = "1970-01-01"))
  
  if(!is.null(nrow(cur_games))){
    cur_games <- cur_games %>% 
      mutate(game_date = substr(game_date, 1, 10))
  }
  
  write.csv(cur_games, paste0("~/Projects/softball-statline/schedule/schedule_data/d3/", as.Date(i, origin = "1970-01-01"), ".csv"))
  
  print(as.Date(i, origin = "1970-01-01"))
}
