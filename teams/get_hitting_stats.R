if (!require("tidyverse", character.only = TRUE)) {
  install.packages("tidyverse")
}
library(tidyverse)

if (!require("rio", character.only = TRUE)) {
  install.packages("rio")
}
library(rio)

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

years <- 2016:2025

get_hitting_data <- function(division, year) {
  urls <- c(
    paste0("https://github.com/sportsdataverse/softballR-data/raw/main/data/d", division, "_hitting_box_scores_", year, ".RDS"),
    paste0("https://github.com/sportsdataverse/softballR-data/raw/main/data/D", division, "_hitting_box_scores_", year, ".RDS")
  )
  
  for (url in urls) {
    try({
      return(rio::import(url))
    }, silent = TRUE)
  }
  
  warning(paste("No data found for division", division, "in", year))
  return(NULL)
}

for (year in years) {
  print(year)
  
  dfs <- list(
    get_hitting_data("1", year),
    get_hitting_data("2", year)
  )
  
  if (year != 2021) {
    dfs <- append(dfs, get_hitting_data("3", year))
  }
  
  df <- bind_rows(dfs) %>%
    distinct() %>%
    get_stats(., year)
  
  write.csv(df, glue::glue("teams/data/hitting_stats/hitting_stats_{year}.csv"), row.names = FALSE)
}

