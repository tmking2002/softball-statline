if (!require("tidyverse", character.only = TRUE)) {
  install.packages("tidyverse")
}
library(tidyverse)

if (!require("lubridate", character.only = TRUE)) {
  install.packages("lubridate")
}
library(lubridate)

if (!require("rio", character.only = TRUE)) {
  install.packages("rio")
}
library(rio)

print("BOX")

proper=function(x) paste0(toupper(substr(x, 1, 1)), tolower(substring(x, 2)))

all_players <- read_csv("players/data/all_players.csv") %>% 
  select(player_id, player)

adjust_hitting_box <- function(raw_box, season){
  
  if(season != 2025){
    raw_box <- raw_box %>% 
      separate(player, c("last", "first"), sep = ", ") %>% 
      mutate(player = paste(first, last))
  }
  
  final_box <- raw_box %>% 
    mutate(bb = bb + hbp) %>% 
    merge(all_players, by = "player") %>% 
    arrange(desc(ab + bb)) %>% 
    select(game_id, game_date, team, opponent, player_id, player, pos, ab, r, h, rbi, hr, k, bb) %>% 
    distinct() %>% 
    arrange(mdy(game_date))
  
  return(final_box)
  
}

for(season in 2016:2025){
  
  print(season)
  
  box <- data.frame()
  
  for (division in c("D1", "D2", "D3")) {
    
    cur_box <- data.frame()
    
    # Attempt with uppercase division first
    try({
      url_upper <- paste0("https://github.com/sportsdataverse/softballR-data/raw/main/data/", division, "_hitting_box_scores_", season, ".RDS")
      cur_box <- rio::import(url_upper) %>% mutate(picked = as.numeric(picked))
    }, silent = TRUE)
    
    # If the first attempt fails, retry with lowercase division
    if (nrow(cur_box) == 0) {
      warning(paste("Retrying with lowercase division for", division))
      url_lower <- paste0("https://github.com/sportsdataverse/softballR-data/raw/main/data/", tolower(division), "_hitting_box_scores_", season, ".RDS")
      cur_box <- rio::import(url_lower) %>% mutate(picked = as.numeric(picked))
    }
    
    box <- bind_rows(box, cur_box)
    
  }
  
  write.csv(box %>% adjust_hitting_box(., season), paste0("teams/data/box_scores/hitting_box_", season, ".csv"))
  
}

adjust_pitching_box <- function(raw_box, season){
  
  if(season != 2025){
    raw_box <- raw_box %>% 
      separate(player, c("last", "first"), sep = ", ") %>% 
      mutate(player = paste(first, last))
  }
  
  final_box <- raw_box %>% 
    separate(ip, c("innings", "frac"), sep = "\\.") %>% 
    mutate(ip = as.numeric(ifelse(is.na(frac), innings, as.numeric(innings) + as.numeric(frac) * 1/3))) %>% 
    select(-c(innings, frac)) %>% 
    merge(all_players, by = "player") %>% 
    arrange(desc(game_id)) %>% 
    mutate(ip = case_when((ip * 3) %% 3 == 0 ~ round(ip),
                          round(ip * 3) %% 3 == 1 ~ round(ip) + .1,
                          round(ip * 3) %% 3 == 2 ~ round(ip) + .2),
           go = NA,
           fo = NA,
           game_order = row_number()) %>% 
    select(game_id, team, opponent, player_id, player, ip, ha, er, bb, hb, so, bf, hr_a, go, fo, game_order) %>% 
    distinct()
  
  return(final_box)
  
}

for(season in 2016:2025){
  
  print(season)
  
  box <- data.frame()
  
  for (division in c("D1", "D2", "D3")) {
    
    cur_box <- data.frame()
    
    # Attempt with uppercase division first
    try({
      url_upper <- paste0("https://github.com/sportsdataverse/softballR-data/raw/main/data/", division, "_pitching_box_scores_", season, ".RDS")
      cur_box <- rio::import(url_upper) %>% mutate(ip = as.character(ip))
    }, silent = TRUE)
    
    # If the first attempt fails, retry with lowercase division
    if (nrow(cur_box) == 0) {
      warning(paste("Retrying with lowercase division for", division))
      url_lower <- paste0("https://github.com/sportsdataverse/softballR-data/raw/main/data/", tolower(division), "_pitching_box_scores_", season, ".RDS")
      cur_box <- rio::import(url_lower) %>% mutate(ip = as.character(ip))
    }
    
    box <- bind_rows(box, cur_box)
    
  }
  
  write.csv(box %>% adjust_pitching_box(., season), paste0("teams/data/box_scores/pitching_box_", season, ".csv"))
  
}
