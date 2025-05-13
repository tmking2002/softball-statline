if (!require("tidyverse", character.only = TRUE)) {
  install.packages("tidyverse")
}
library(tidyverse)

if (!require("rio", character.only = TRUE)) {
  install.packages("rio")
}
library(rio)

print("PITCHING STATS")

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
    filter(str_length(player) > 1) %>% 
    mutate(lower_player = tolower(player)) %>% 
    merge(players %>% mutate(lower_player = tolower(player)) %>% select(-player), by = "lower_player") %>% 
    group_by(team_id, team, season, player, player_id) %>% 
    summarise(across(c(er, ip, ha, bf, bb, hb, so, hr_a), 
                     .fns = \(col) sum(as.numeric(col))),
              era = format(round(er / ip * 7, 3), nsmall = 3),
              opp_avg = round((ha) / (bf - bb - hb), 3),
              whip = round((bb + hb + ha) / ip, 3),
              fip = format(round((13 * hr_a + 3 * (bb + hb) - 2 * so) / ip + 2.4, 3), nsmall = 3),
              ip = round(floor(ip) + ip %% 1 / 3, 1)) %>% 
    ungroup() %>% 
    filter(ip > 0) %>% 
    drop_na(era, opp_avg, whip, fip) %>% 
    select(team_id, player_id, season, player, ip, ha, bb, hb, so, hr_a, era, opp_avg, whip, fip, team) %>% 
    arrange(desc(ip)) 
  
  if(season == 2016){
    stats$hr_a <- 0
  }
  
  return(stats)
  
}

years <- 2017:2025

get_pitching_data <- function(division, year) {
  urls <- c(
    paste0("https://github.com/sportsdataverse/softballR-data/raw/main/data/d", division, "_pitching_box_scores_", year, ".RDS"),
    paste0("https://github.com/sportsdataverse/softballR-data/raw/main/data/D", division, "_pitching_box_scores_", year, ".RDS")
  )
  
  for (url in urls) {
    try({
      df <- rio::import(url)
      df$ip <- as.character(df$ip)
      return(df)
    }, silent = TRUE)
  }
  
  warning(paste("No data found for", division, year))
  return(NULL)
}

for (year in years) {
  print(year)
  
  dfs <- list(
    get_pitching_data("1", year),
    get_pitching_data("2", year),
    get_pitching_data("3", year)
  )
  
  df <- bind_rows(dfs) %>%
    distinct() %>%
    get_stats(., year)
  
  write.csv(df, glue::glue("teams/data/pitching_stats/pitching_stats_{year}.csv"), row.names = FALSE)
}
