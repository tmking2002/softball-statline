library(tidyverse)

print("BOX")

load_ncaa_softball_playerbox <- function(season = 2024, category, division = "D1"){
  
  if(!is.numeric(season)) return("Invalid Season")
  
  if(!(category %in% c("Hitting", "Pitching", "Fielding"))) return("Invalid Category")
  
  if(category == "Fielding" & (length(season) > 1 | season[1] != 2023)) return("Only includes 2023 data... for now")
  
  if(min(season < 2015 | max(season > 2024)) & category == "Pitching") return("Invalid Season")
  if(min(season < 2015 | max(season > 2024)) & category == "Hitting") return("Invalid Season")
  
  if(!(division %in% c("D1", "D2", "D3"))) stop("Invalid Division")
  
  division <- stringr::str_replace(division, "D", "d")
  
  url <- c()
  
  if(category == "Hitting"){
    
    for(i in season){
      if(division == "d3" & category == "Hitting" & i == 2021) {url <- c(url, "https://github.com/sportsdataverse/softballR-data/blob/main/data/D3_hitting_box_scores_2021.RDS?raw=true"); next}
      
      url <- c(url, glue::glue("https://github.com/tmking2002/softballR-data/blob/main/data/{division}_hitting_box_scores_{i}.RDS?raw=true"))
    }
    
  } else if(category == "Pitching"){
    
    for(i in season){
      if(division == "d3" & category == "Pitching" & i %in% 2016:2020) {url <- c(url, glue::glue("https://github.com/sportsdataverse/softballR-data/blob/main/data/D3_pitching_box_scores_{i}.RDS?raw=true")); next}
      
      url <- c(url, glue::glue("https://github.com/tmking2002/softballR-data/blob/main/data/{division}_pitching_box_scores_{i}.RDS?raw=true"))
    }
    
  } else if(category == "Fielding"){
    
    url <- glue::glue("https://github.com/tmking2002/softballR-data/blob/main/data/d1_fielding_box_scores_2023.RDS?raw=true")
    
  }
  
  box <- data.frame()
  
  for(i in url){
    
    con <- url(i)
    
    on.exit(close(con))
    
    box <- bind_rows(box, readRDS(con))
    
  }
  
  return(box)
  
}


all_players <- read_csv("players/data/all_players.csv") %>% 
  select(player_id, player)

adjust_hitting_box <- function(raw_box){
  
  final_box <- raw_box %>% 
    separate(player, c("last", "first"), ", ") %>% 
    mutate(player = paste(first, last),
           bb = bb + hbp) %>% 
    merge(all_players, by = "player") %>% 
    arrange(desc(ab + bb)) %>% 
    select(game_id, team, opponent, player_id, player, pos, ab, r, h, rbi, hr, k, bb)
  
  return(final_box)
  
}

for(season in 2024){
  
  box <- data.frame()
  
  for(division in c("D1", "D2", "D3")){
    
    box <- rbind(box, load_ncaa_softball_playerbox(season, category = "Hitting", division))
    
  }
  
  write.csv(box %>% adjust_hitting_box(.), paste0("teams/data/box_scores/hitting_box_", season, ".csv"))
  
}


adjust_pitching_box <- function(raw_box){
  
  final_box <- raw_box %>% 
    separate(ip, c("innings", "frac"), sep = "\\.") %>% 
    mutate(ip = as.numeric(ifelse(is.na(frac), innings, as.numeric(innings) + as.numeric(frac) * 1/3))) %>% 
    select(-c(innings, frac)) %>% 
    separate(player, c("last", "first"), ", ") %>% 
    mutate(player = paste(first, last)) %>% 
    merge(all_players, by = "player") %>% 
    arrange(desc(ip)) %>% 
    mutate(ip = case_when((ip * 3) %% 3 == 0 ~ round(ip),
                          round(ip * 3) %% 3 == 1 ~ round(ip) + .1,
                          round(ip * 3) %% 3 == 2 ~ round(ip) + .2)) %>% 
    select(game_id, team, opponent, player_id, player, ip, ha, er, bb, hb, so, bf, hr_a, go, fo)
  
  return(final_box)
  
}

for(season in 2024){
  
  box <- data.frame()
  
  for(division in c("D1", "D2", "D3")){
    
    box <- rbind(box, load_ncaa_softball_playerbox(season, category = "Pitching", division))
    
  }
  
  write.csv(box %>% adjust_pitching_box(.), paste0("teams/data/box_scores/pitching_box_", season, ".csv"))
  
}

