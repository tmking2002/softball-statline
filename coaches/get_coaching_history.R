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

print("COACHING HISTORY")

cur_season <- 2024

teams <- rio::import("https://github.com/sportsdataverse/softballR-data/raw/main/data/ncaa_team_info.RDS") %>% 
  mutate(season = ifelse(season == 1900, 2000, season)) %>% 
  filter(wins < 80 & head_coach != "")

teams$ties[is.na(teams$ties)] <- 0

scoreboard <- bind_rows(
  rio::import(glue("https://github.com/sportsdataverse/softballR-data/raw/main/data/ncaa_scoreboard_{cur_season}.RDS")),
  rio::import(glue("https://github.com/sportsdataverse/softballR-data/raw/main/data/ncaa_scoreboard_D2_{cur_season}.RDS")),
  rio::import(glue("https://github.com/sportsdataverse/softballR-data/raw/main/data/ncaa_scoreboard_D3_{cur_season}.RDS"))
)

records <- rbind(scoreboard %>% select(away_team, away_team_runs, home_team_runs) %>% `names<-`(c("team_name", "runs", "allowed")),
                 scoreboard %>% select(home_team, home_team_runs, away_team_runs) %>% `names<-`(c("team_name", "runs", "allowed"))) %>% 
  group_by(team_name) %>% 
  summarise(wins = sum(runs > allowed),
            losses = sum(runs < allowed),
            ties = sum(runs == allowed)) %>% 
  ungroup()

for(i in 1:nrow(teams %>% filter(season == 2024))){
  
  team <- teams %>% filter(season == 2024) %>% slice(i) %>% pull(team_name)
  
  record <- records %>% filter(team_name == team)
  
  if(nrow(record) == 0) next
  
  new_row <- teams %>% filter(season == 2024) %>% slice(i) %>% 
    mutate(wins = record$wins,
           losses = record$losses,
           ties = record$ties,
           win_perc = round(record$wins / (record$wins + record$losses), 3))
  
  teams[(teams$team_name == team & teams$season == 2024),] <- new_row
  
}

extra_coaches <- data.frame()

for(i in 1:nrow(teams %>% filter(str_detect(head_coach, " \\(")))){
  teams_filtered <- teams %>% 
    filter(str_detect(head_coach, "\\(")) %>% 
    filter(row_number() == i)
  
  coaches <- teams_filtered %>% 
    pull(head_coach) %>% 
    strsplit("\\)") %>% 
    magrittr::extract2(1)
  
  wins <- str_extract(coaches, "\\d+")
  wins_losses <- str_extract(coaches, "\\d+-\\d+")
  wins_losses_ties <- str_extract(coaches, "\\d+-\\d+-\\d+")
  
  # Process wins_losses to get individual wins and losses
  wins_losses <- str_split(wins_losses, "-")
  
  # Extract the individual wins and losses from the processed wins_losses
  individual_wins <- sapply(wins_losses, function(x) x[1])
  individual_losses <- sapply(wins_losses, function(x) x[2])
  individual_ties <- ifelse(!(any(is.na(wins_losses_ties))), substr(wins_losses_ties,  nchar(wins_losses_ties), nchar(wins_losses_ties)), 0)
  
  coach_df <- data.frame(team_name = teams_filtered$team_name,
                         team_id = teams_filtered$team_id,
                         season = teams_filtered$season,
                         head_coach = word(coaches, 1, 2),
                         division = teams_filtered$division,
                         conference = teams_filtered$conference,
                         wins = individual_wins,
                         losses = individual_losses,
                         ties = individual_ties) %>% 
    mutate(across(c(wins, losses), as.numeric),
           win_perc = wins / (wins + losses)) %>% 
    drop_na(wins)
  
  if(nrow(coach_df) > 1){
    if(coach_df$wins[1] == coach_df$wins[2]){
      coach_df <- coach_df[1,]
    }
  }
  
  
  extra_coaches <- rbind(extra_coaches, coach_df)
}

total_history <- teams %>% 
  filter(!str_detect(head_coach, " \\(")) %>% 
  rbind(extra_coaches)

unique_coaches <- total_history %>% 
  arrange(season, team_name) %>% 
  group_by(head_coach) %>% 
  summarise(division = last(division)) %>% 
  ungroup() %>% 
  distinct(head_coach, division) %>% 
  mutate(coach_id = row_number()) %>% 
  arrange(head_coach)

coaching_history <- total_history %>% 
  select(-division) %>% 
  merge(unique_coaches, by = "head_coach") %>% 
  mutate(record = paste(wins, losses, ties, sep = "-"),
         win_perc = format(round(wins / (wins + losses), 3), nsmall = 3)) %>% 
  select(season, team_name, division, conference, record, win_perc, team_id, coach_id) %>% 
  arrange(desc(season))

write.csv(unique_coaches, "coaches/coach_ids.csv")
write.csv(unique_coaches %>% filter(division == "D-I"), "coaches/coach_ids_d1.csv")
write.csv(unique_coaches %>% filter(division == "D-II"), "coaches/coach_ids_d2.csv")
write.csv(unique_coaches %>% filter(division == "D-III"), "coaches/coach_ids_d3.csv")
write.csv(coaching_history, "coaches/coach_history.csv")

coach_stats <- total_history %>% 
  group_by(head_coach) %>% 
  summarise(wins = sum(wins),
            losses = sum(losses),
            ties = sum(as.numeric(ties)),
            teams = paste(unique(team_name), collapse = ", "))

