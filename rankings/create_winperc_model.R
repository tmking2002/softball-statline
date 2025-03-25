library(tidyverse)

get_current_rpi <- function(scoreboard){
  
  team1_scoreboard <- scoreboard[c(9,1,4,5,8,12)] %>% `names<-`(c("date","team_name","runs","opponent_name","opponent_runs","season"))
  team2_scoreboard <- scoreboard[c(9,5,8,1,4,12)] %>% `names<-`(c("date","team_name","runs","opponent_name","opponent_runs","season"))
  
  scoreboard_upd <- rbind(team1_scoreboard, team2_scoreboard) %>%
    mutate(win = case_when(runs > opponent_runs ~ 1,
                           runs < opponent_runs ~ 0,
                           runs == opponent_runs ~ 0.5))
  
  
  win_perc <- scoreboard_upd %>%
    group_by(team_name) %>%
    summarise(games = n(),
              win_perc = mean(win)) %>%
    select(-games) %>% 
    drop_na()
  
  scoreboard_upd_2 <- scoreboard_upd %>%
    merge(win_perc, by.x = "opponent_name", by.y = "team_name") %>%
    rename(opponent_win_perc = win_perc) %>%
    merge(win_perc, by = "team_name")
  
  
  opponent_win_perc <- scoreboard_upd_2 %>%
    group_by(team_name) %>%
    summarise(opponent_opponent_win_perc = mean(opponent_win_perc))
  
  scoreboard_upd_3 <- scoreboard_upd_2 %>%
    merge(opponent_win_perc, by.x = "opponent_name", by.y = "team_name")
  
  
  rpi <- scoreboard_upd_3 %>%
    group_by(team_name) %>%
    summarise(rpi_coef = (.5 * mean(win_perc) + .25 * mean(opponent_win_perc) + .25 * mean(opponent_opponent_win_perc)),
              record = paste(floor(sum(win)),floor(n() - sum(win)),ceiling(sum(win) %% 1), sep = "-")) %>%
    ungroup() %>%
    mutate(rpi_rank = rank(-rpi_coef))
  
  
  return(rpi)
}

get_power_ratings <- function(scoreboard){
  
  scoreboard_longer <- rbind(scoreboard[c(9,1,4,5,8)] %>% `names<-`(c("date", "team", "runs", "opponent", "opponent_runs")),
                             scoreboard[c(9,5,8,1,4)] %>% `names<-`(c("date", "team", "runs", "opponent", "opponent_runs")))
  
  rpi <- get_current_rpi(scoreboard) %>%
    select(team_name, rpi_rank)
  
  sos <- scoreboard_longer %>%
    merge(rpi, by.x = "opponent", by.y = "team_name") %>%
    group_by(team) %>%
    summarise(avg_opponent_rpi = mean(rpi_rank)) %>%
    ungroup() %>%
    mutate(rank = rank(avg_opponent_rpi)) %>%
    select(team, rank)
  
  runs_scored <- scoreboard_longer %>% 
    group_by(team) %>% 
    summarise(avg_runs_scored = mean(runs),
              games = n()) %>% 
    select(-games) %>% 
    drop_na()
  
  runs_allowed <- scoreboard_longer %>% 
    group_by(team) %>% 
    summarise(avg_runs_allowed = mean(opponent_runs),
              games = n()) %>% 
    select(-games) %>% 
    drop_na()
  
  best_offenses <- scoreboard_longer %>% 
    merge(runs_allowed, by.x = "opponent", by.y = "team") %>% 
    mutate(diff = runs - avg_runs_allowed) %>% 
    group_by(team) %>% 
    summarise(offensive_rating = mean(diff),
              games = n()) %>% 
    ungroup() %>% 
    drop_na()
  
  best_defenses <- scoreboard_longer %>% 
    merge(runs_scored, by.x = "opponent", by.y = "team") %>% 
    mutate(diff = avg_runs_scored - opponent_runs) %>% 
    group_by(team) %>% 
    summarise(defensive_rating = mean(diff),
              games = n()) %>% 
    ungroup() %>% 
    drop_na()
  
  standings <- scoreboard_longer %>% 
    group_by(team) %>% 
    summarise(wins = sum(runs > opponent_runs, na.rm=T),
              losses = sum(runs < opponent_runs, na.rm=T),
              ties = sum(runs == opponent_runs, na.rm=T),
              win_perc = wins / (wins + losses),
              games = sum(wins, losses, ties)) %>% 
    drop_na() %>% 
    merge(best_offenses, by = "team") %>% 
    merge(best_defenses, by = "team") %>% 
    merge(sos, by = "team") %>% 
    filter(games >= 10) %>% 
    select(team, wins, losses, ties, win_perc, offensive_rating, defensive_rating, rank) 
  
  load("~/Projects/softball-projects/power_rating_winperc_model.RDA")
  
  standings$overall_rating <- predict(model, standings) - coef(model)["rank"] * standings$rank
  
  standings$power_rating <- (standings$overall_rating-min(standings$overall_rating)) / 
    (max(standings$overall_rating - min(standings$overall_rating)))
  
  return(standings)
  
}


scoreboard <- rbind(
  readRDS(url(glue::glue("https://github.com/sportsdataverse/softballR-data/raw/main/data/ncaa_scoreboard_2022.RDS"))) %>% mutate(season = 2022),
  readRDS(url(glue::glue("https://github.com/sportsdataverse/softballR-data/raw/main/data/ncaa_scoreboard_2023.RDS"))) %>% mutate(season = 2023),
  readRDS(url(glue::glue("https://github.com/sportsdataverse/softballR-data/raw/main/data/ncaa_scoreboard_2024.RDS"))) %>% mutate(season = 2024)
)

scoreboard_longer <- rbind(scoreboard[c(9,1,4,5,8,12)] %>% `names<-`(c("date", "team", "runs", "opponent", "opponent_runs", "season")),
                           scoreboard[c(9,5,8,1,4,12)] %>% `names<-`(c("date", "team", "runs", "opponent", "opponent_runs", "season")))

team1_scoreboard <- scoreboard[c(9,1,4,5,8,12)] %>% `names<-`(c("date","team_name","runs","opponent_name","opponent_runs","season"))
team2_scoreboard <- scoreboard[c(9,5,8,1,4,12)] %>% `names<-`(c("date","team_name","runs","opponent_name","opponent_runs","season"))

scoreboard_upd <- rbind(team1_scoreboard, team2_scoreboard) %>%
  mutate(win = case_when(runs > opponent_runs ~ 1,
                         runs < opponent_runs ~ 0,
                         runs == opponent_runs ~ 0.5))

win_perc <- scoreboard_upd %>%
  group_by(team_name, season) %>%  # Grouping by team and season
  summarise(games = n(),
            win_perc = mean(win)) %>%
  filter(games > 5) %>%
  select(-games) %>% 
  drop_na()

scoreboard_upd_2 <- scoreboard_upd %>%
  merge(win_perc, by.x = c("opponent_name", "season"), by.y = c("team_name", "season")) %>%
  rename(opponent_win_perc = win_perc) %>%
  merge(win_perc, by = c("team_name", "season"))

opponent_win_perc <- scoreboard_upd_2 %>%
  group_by(team_name, season) %>%  # Grouping by team and season
  summarise(opponent_opponent_win_perc = mean(opponent_win_perc))

scoreboard_upd_3 <- scoreboard_upd_2 %>%
  merge(opponent_win_perc, by.x = c("opponent_name", "season"), by.y = c("team_name", "season"))

rpi <- scoreboard_upd_3 %>%
  group_by(team_name, season) %>%  # Grouping by team and season
  summarise(rpi_coef = (.5 * mean(win_perc) + .25 * mean(opponent_win_perc) + .25 * mean(opponent_opponent_win_perc)),
            record = paste(floor(sum(win)),floor(n() - sum(win)),ceiling(sum(win) %% 1), sep = "-")) %>%
  ungroup() %>%
  mutate(rpi_rank = rank(-rpi_coef))

sos <- scoreboard_longer %>%
  merge(rpi, by.x = c("opponent", "season"), by.y = c("team_name", "season")) %>%
  group_by(team, season) %>%  # Grouping by team and season
  summarise(avg_opponent_rpi = mean(rpi_rank)) %>%
  ungroup() %>%
  group_by(season) %>% 
  mutate(rank = rank(avg_opponent_rpi)) %>%
  ungroup() %>% 
  select(team, season, rank)

runs_scored <- scoreboard_longer %>% 
  group_by(team, season) %>%  # Grouping by team and season
  summarise(avg_runs_scored = mean(runs),
            games = n()) %>% 
  filter(games >= 10) %>% 
  select(-games) %>% 
  drop_na()

runs_allowed <- scoreboard_longer %>% 
  group_by(team, season) %>%  # Grouping by team and season
  summarise(avg_runs_allowed = mean(opponent_runs),
            games = n()) %>% 
  filter(games >= 10) %>% 
  select(-games) %>% 
  drop_na()

best_offenses <- scoreboard_longer %>% 
  merge(runs_allowed, by.x = c("opponent", "season"), by.y = c("team", "season")) %>% 
  mutate(diff = runs - avg_runs_allowed) %>% 
  mutate(sign_diff = sign(diff),            
         sqrt_diff = sqrt(abs(diff)) * sign_diff) %>% 
  group_by(team, season) %>%  # Grouping by team and season
  summarise(offensive_rating = mean(sqrt_diff),
            games = n()) %>% 
  ungroup() %>% 
  filter(games >= 10) %>% 
  drop_na()

best_defenses <- scoreboard_longer %>% 
  merge(runs_scored, by.x = c("opponent", "season"), by.y = c("team", "season")) %>% 
  mutate(diff = avg_runs_scored - opponent_runs) %>% 
  mutate(sign_diff = sign(diff),         
         sqrt_diff = sqrt(abs(diff)) * sign_diff) %>% 
  group_by(team, season) %>%  # Grouping by team and season
  summarise(defensive_rating = mean(sqrt_diff),
            games = n()) %>% 
  ungroup() %>% 
  filter(games >= 10) %>% 
  drop_na()

standings <- scoreboard_longer %>% 
  group_by(team, season) %>%  # Grouping by team and season
  summarise(wins = sum(runs > opponent_runs, na.rm = T),
            losses = sum(runs < opponent_runs, na.rm = T),
            ties = sum(runs == opponent_runs, na.rm = T),
            win_perc = wins / (wins + losses),
            games = sum(wins, losses, ties, na.rm = T)) %>% 
  filter(games >= 10) %>% 
  drop_na() %>% 
  merge(best_offenses, by = c("team", "season")) %>%  # Merge by team and season
  merge(best_defenses, by = c("team", "season")) %>%  # Merge by team and season
  merge(sos, by = c("team", "season")) %>%  # Merge by team and season
  select(team, season, wins, losses, ties, win_perc, offensive_rating, defensive_rating, rank)

# Fit the model grouped by season
model <- lm(win_perc ~ offensive_rating + defensive_rating + rank, data = standings)
save(model, file = "rankings/power_rating_winperc_model.RDA")

standings$standings <- predict(model, standings) - coef(model)["rank"] * standings$rank

standings$standings <- (standings$standings - min(standings$standings)) / 
  (max(standings$standings - min(standings$standings)))

rm(list = setdiff(ls(), c("standings", "get_power_ratings", "get_current_rpi")))