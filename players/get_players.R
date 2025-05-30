if (!require("tidyverse", character.only = TRUE)) {
  install.packages("tidyverse")
}
if (!require("rio", character.only = TRUE)) {
  install.packages("rio")
}

library(tidyverse)
library(rio)

print("PLAYERS")

load_ncaa_softball_playerbox <- function(season = 2025, category, division = "D1"){
  
  if(!is.numeric(season)) return("Invalid Season")
  
  if(!(category %in% c("Hitting", "Pitching", "Fielding"))) return("Invalid Category")
  
  if(category == "Fielding" & (length(season) > 1 | season[1] != 2023)) return("Only includes 2023 data... for now")
  
  if(min(season < 2016 | max(season > 2025)) & category == "Pitching") return("Invalid Season")
  if(min(season < 2016 | max(season > 2025)) & category == "Hitting") return("Invalid Season")
  
  if(!(division %in% c("D1", "D2", "D3"))) stop("Invalid Division")
  
  division <- stringr::str_replace(division, "D", "d")
  
  url <- c()
  
  if(category == "Hitting"){
    
    for(i in season){
      if(division == "d3" & category == "Hitting" & i == 2021) {url <- c(url, "https://github.com/sportsdataverse/softballR-data/raw/main/data/D3_hitting_box_scores_2021.RDS"); next}
      
      url <- c(url, glue::glue("https://github.com/tmking2002/softballR-data/raw/main/data/{division}_hitting_box_scores_{i}.RDS"))
    }
    
  } else if(category == "Pitching"){
    
    for(i in season){
      if(division == "d3" & category == "Pitching" & i %in% 2016:2020) {url <- c(url, glue::glue("https://github.com/sportsdataverse/softballR-data/raw/main/data/D3_pitching_box_scores_{i}.RDS")); next}
      
      url <- c(url, glue::glue("https://github.com/tmking2002/softballR-data/raw/main/data/{division}_pitching_box_scores_{i}.RDS"))
    }
    
  } else if(category == "Fielding"){
    
    url <- glue::glue("https://github.com/tmking2002/softballR-data/raw/main/data/d1_fielding_box_scores_2023.RDS")
    
  }
  
  box <- data.frame()
  
  for(i in url){
    cur <- rio::import(i)
    
    if(category == "Hitting"){
      cur <- cur %>% select(-picked)
    } else if(category == "Pitching"){
      cur <- cur %>% mutate(ip = as.character(ip))
    }
    
    box <- bind_rows(box, cur %>% mutate(game_id = as.character(game_id)))
  }
  
  return(box)
  
}

d1_hitting_box <- load_ncaa_softball_playerbox(2016:2025, "Hitting", "D1")
d2_hitting_box <- load_ncaa_softball_playerbox(2016:2025, "Hitting", "D2")
d3_hitting_box <- load_ncaa_softball_playerbox(2016:2025, "Hitting", "D3")

hitting_box <- rbind(d1_hitting_box, d2_hitting_box, d3_hitting_box) %>% 
  select(player, team, season)

d1_pitching_box <- load_ncaa_softball_playerbox(2016:2025, "Pitching", "D1")
d2_pitching_box <- load_ncaa_softball_playerbox(2016:2025, "Pitching", "D2")
d3_pitching_box <- load_ncaa_softball_playerbox(2016:2025, "Pitching", "D3")

pitching_box <- rbind(d1_pitching_box, d2_pitching_box, d3_pitching_box) %>% 
  select(player, team, season)

split_name <- function(player, season) {
  if (season == 2025) {
    parts <- unlist(strsplit(player, " "))
    c(last = parts[2], first = parts[1])
  } else {
    parts <- unlist(strsplit(player, ", "))
    c(last = parts[1], first = parts[2])
  }
}

box <- rbind(hitting_box, pitching_box) %>% 
  distinct(team, player, season) %>% 
  mutate(name = map2(player, season, split_name)) %>% 
  unnest_wider(name)

headshots <- read_csv("players/data/player_headshots.csv")

proper=function(x) paste0(toupper(substr(x, 1, 1)), tolower(substring(x, 2)))

unique_names <- box %>% 
  drop_na(first, last) %>% 
  mutate(first =  proper(trimws(str_remove(first, "\\."))),
         last = proper(trimws(str_remove(last, "\\.")))) %>% 
  group_by(last, first) %>% 
  summarise(player_id = cur_group_id(),
            teams = paste(unique(team), collapse = " + "),
            seasons = paste(unique(season), collapse = "+")) %>% 
  ungroup() %>% 
  filter(str_length(first) > 1,
         str_length(last) > 1,
         first != "Unknown",
         !str_detect(first, "[0-9]"),
         !str_detect(last, "[0-9]")) %>% 
  mutate(player = paste(first, last)) %>% 
  merge(headshots, by="player", all = TRUE) %>% 
  select(player_id, player, teams, seasons, first, last, headshot) %>% 
  arrange(player_id)

teams <- read_csv("teams/data/all_teams.csv")

final_players <- unique_names %>% 
  mutate(last_team = trimws(str_split(teams, "\\+") %>% sapply(tail, 1))) %>% 
  merge(teams, by.x = "last_team", by.y = "team_name", all = T) %>% 
  mutate(division = ifelse(is.na(division), "D-III", division)) %>% 
  arrange(player)

write.csv(unique_names, "players/data/all_players.csv")
write.csv(final_players %>% filter(division == "D-I"), "players/data/players_d1.csv")
write.csv(final_players %>% filter(division == "D-II"), "players/data/players_d2.csv")
write.csv(final_players %>% filter(division == "D-III"), "players/data/players_d3.csv")
