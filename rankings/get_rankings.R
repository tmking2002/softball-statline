install.packages("tidyverse")
library(tidyverse)

install.packages("magrittr")
library(magrittr)

install.packages("rvest")
library(rvest)

install.package("anytime")
library(anytime)

print("TEAM RANKINGS")

cur_season <- 2024

team_ids <- read_csv("teams/data/all_teams.csv") %>% 
  select(team_name, team_id)

get_current_rpi <- function(scoreboard){
  
  team1_scoreboard <- scoreboard[c(9,1,4,5,8)] %>% `names<-`(c("date","team_name","runs","opponent_name","opponent_runs"))
  team2_scoreboard <- scoreboard[c(9,5,8,1,4)] %>% `names<-`(c("date","team_name","runs","opponent_name","opponent_runs"))
  
  scoreboard_upd <- rbind(team1_scoreboard, team2_scoreboard) %>%
    mutate(team_name = str_replace(team_name, "&amp;", "&"),
           opponent_name = str_replace(opponent_name, "&amp;", "&"),
           win = case_when(runs > opponent_runs ~ 1,
                           runs < opponent_runs ~ 0,
                           runs == opponent_runs ~ 0.5)) %>%
    drop_na(team_name, opponent_name, runs, opponent_runs)
  
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
    summarise(rpi_coef = (.5 * mean(win_perc) + .25 * mean(opponent_win_perc) + .25 * mean(opponent_opponent_win_perc)),
              record = paste(floor(sum(win)),floor(n() - sum(win)),ceiling(sum(win) %% 1), sep = "-"),
              games = n()) %>%
    ungroup() %>%
    filter(games >= 5) %>% 
    mutate(rpi_rank = rank(-rpi_coef, ties.method = 'min')) %>% 
    select(-games)
  
  
  return(rpi)
}


get_power_ratings <- function(scoreboard){
  
  scoreboard_longer <- rbind(scoreboard[c(9,1,4,5,8)] %>% `names<-`(c("date", "team", "runs", "opponent", "opponent_runs")),
                             scoreboard[c(9,5,8,1,4)] %>% `names<-`(c("date", "team", "runs", "opponent", "opponent_runs"))) %>% 
    mutate(team = str_replace(team, "&amp;", "&"),
           opponent = str_replace(opponent, "&amp;", "&")) %>% 
    group_by(team) %>% 
    filter(n() > 5) %>% 
    ungroup()
  
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
    select(team, offensive_rating, defensive_rating, rank) %>% 
    rename(team_name = team)
  
  load("rankings/power_rating_winperc_model.RDA")
  
  standings$overall_rating <- predict(model, standings) - coef(model)["rank"] * standings$rank
  
  standings$power_rating <- (standings$overall_rating-min(standings$overall_rating)) / 
    (max(standings$overall_rating - min(standings$overall_rating)))
  
  standings <- standings %>% 
    mutate(offensive_rank = rank(-offensive_rating, "min"),
           defensive_rank = rank(-defensive_rating, "min"),
           overall_rank = rank(-power_rating, "min"))
  
  return(standings)
  
}

get_net_rankings <- function(scoreboard){
  
  scoreboard_longer <- rbind(scoreboard[c(9,1,4,5,8)] %>% `names<-`(c("date", "team", "runs", "opponent", "opponent_runs")) %>% mutate(home = FALSE),
                             scoreboard[c(9,5,8,1,4)] %>% `names<-`(c("date", "team", "runs", "opponent", "opponent_runs")) %>% mutate(home = TRUE)) %>% 
    mutate(team = str_replace(team, "&amp;", "&"),
           opponent = str_replace(opponent, "&amp;", "&")) %>% 
    group_by(team) %>% 
    filter(n() > 5) %>% 
    ungroup() %>% 
    mutate(win = runs > opponent_runs) %>% 
    drop_na(team, win) %>% 
    merge(get_power_ratings(scoreboard) %>% select(team_name, overall_rank), by.x = "opponent", by.y = "team_name")
  
  final_scoreboard <- scoreboard_longer %>% 
    mutate(quad = case_when(overall_rank <= 30 | (overall_rank <= 75 & home == FALSE) ~ 1,
                            overall_rank <= 75 | (overall_rank <= 150 & home == FALSE) ~ 2,
                            overall_rank <= 150 | (overall_rank <= 225 & home == FALSE) ~ 3,
                            TRUE ~ 4))
  
  all_combinations <- expand.grid(
    team = unique(final_scoreboard$team),
    quad = unique(final_scoreboard$quad)
  )
  
  net_rankings <- final_scoreboard %>% 
    right_join(all_combinations, by = c("team", "quad")) %>% 
    group_by(team, quad) %>% 
    summarise(wins = sum(win),
              losses = n() - sum(win)) %>% 
    ungroup() %>% 
    mutate(wins = ifelse(is.na(wins), 0, wins),
           losses = ifelse(is.na(losses), 0, losses),
           record = paste(wins, losses, sep = "-")) %>% 
    group_by(team) %>% 
    summarise(quad1_record = record[which(quad == 1)],
              quad1_wins = wins[which(quad == 1)],
              quad1_win_perc = wins[which(quad == 1)] / sum(wins[which(quad == 1)], losses[which(quad == 1)]),
              quad2_record = record[which(quad == 2)],
              quad2_wins = wins[which(quad == 2)],
              quad2_win_perc = wins[which(quad == 2)] / sum(wins[which(quad == 2)], losses[which(quad == 2)]),
              quad3_record = record[which(quad == 3)],
              quad3_wins = wins[which(quad == 3)],
              quad3_win_perc = wins[which(quad == 3)] / sum(wins[which(quad == 3)], losses[which(quad == 3)]),
              quad4_record = record[which(quad == 4)],
              quad4_wins = wins[which(quad == 4)],
              quad4_win_perc = wins[which(quad == 4)] / sum(wins[which(quad == 4)], losses[which(quad == 4)]),) %>% 
    ungroup() %>% 
    mutate(across(ends_with("win_perc"), ~ifelse(is.na(.x), 0, .x))) %>% 
    rename(team_name = team)
  
  return(net_rankings)
  
}

get_nfca_rankings <- function(division){
  
  rankings <- paste0("https://nfca.org/component/com_nfca/Itemid,230/list,1/pdiv,div", division, "/top25,1/year,2024/") %>% 
    read_html() %>% 
    html_table() %>% 
    extract2(1) %>% 
    separate(Team, c("Team", "etc"), "\\(") %>% 
    mutate(Team = str_replace(Team, "State", "St."),
           Team = trimws(Team),
           Team = case_when(Team == "West Texas A&M" ~ "West Tex. A&M",
                            Team == "Indianapolis" ~ "UIndy",
                            Team == "Colorado Christian" ~ "Colo. Christian",
                            Team == "Mississippi College" ~ "Mississippi Col.",
                            Team == "Central Oklahoma" ~ "Central Okla.",
                            Team == "West Alabama" ~ "West Ala.",
                            Team == "Western Washington" ~ "Western Wash.",
                            Team == "Charleston" ~ "Charleston (WV)",
                            Team == "Wilmington" ~ "Wilmington (DE)",
                            Team == "Southern Arkansas" ~ "Southern Ark.",
                            Team == "Concordia" ~ "Concordia-St. Paul",
                            Team == "Christopher Newport" ~ "Chris. Newport",
                            Team == "Bethel" ~ "Bethel (MN)",
                            Team == "Case Western Reserve" ~  "CWRU",
                            Team == "East Texas Baptist" ~ "East Tex. Baptist",
                            Team == "Rochester" ~ "Rochester (NY)",
                            Team == "Central" ~ "Central (IA)",
                            Team == "The College of New Jersey" ~ "TCNJ",
                            Team == "Boston University" ~ "Boston U.",
                            TRUE ~ Team)) %>% 
    mutate(Team = trimws(Team)) %>% 
    left_join(team_ids, by = c("Team" = "team_name")) %>% 
    select(Team, Rank) %>% 
    `names<-`(c("team_name", "nfca_rank"))
  
  return(rankings)
  
}

d1_scoreboard <- readRDS(url(glue::glue("https://github.com/sportsdataverse/softballR-data/raw/main/data/ncaa_scoreboard_{cur_season}.RDS")))

d1_rpi <- get_current_rpi(d1_scoreboard)
d1_power_ratings <- get_power_ratings(d1_scoreboard)
d1_nfca_rankings <- get_nfca_rankings(1)
d1_net_rankings <- get_net_rankings(d1_scoreboard)

d1_power_ratings_lastweek <- get_power_ratings(d1_scoreboard %>% filter(anydate(game_date) <= Sys.Date() - 7)) %>% 
  rename(overall_prev = overall_rank) %>% 
  select(team_name, overall_prev)

d1_rankings <- merge(d1_rpi, d1_power_ratings, by = "team_name") %>% 
  merge(d1_nfca_rankings, by = "team_name", all = TRUE) %>% 
  merge(d1_net_rankings, by = "team_name") %>% 
  merge(d1_power_ratings_lastweek, by = "team_name") %>% 
  mutate(change = overall_rank - overall_prev) %>% 
  merge(team_ids, by = "team_name") %>% 
  mutate(logo = paste0("http://web2.ncaa.org/ncaa_style/img/All_Logos/sm/", team_id, ".gif")) %>% 
  select("logo", "team_name", "record", "rpi_rank", "nfca_rank", "quad1_record", "quad2_record", "quad3_record", "quad4_record", "offensive_rank", "defensive_rank", "overall_rank", "change", "team_id", 
         "quad1_win_perc", "quad1_wins", "quad2_win_perc", "quad2_wins", "quad3_win_perc", "quad3_wins", "quad4_win_perc", "quad4_wins") %>% 
  arrange(overall_rank)

write_csv(d1_rankings, "rankings/d1_rankings.csv")

d2_scoreboard <- readRDS(url(glue::glue("https://github.com/sportsdataverse/softballR-data/raw/main/data/ncaa_scoreboard_D2_{cur_season}.RDS")))

d2_rpi <- get_current_rpi(d2_scoreboard)
d2_power_ratings <- get_power_ratings(d2_scoreboard)
d2_nfca_rankings <- get_nfca_rankings(2)

d2_rankings <- merge(d2_rpi, d2_power_ratings, by = "team_name") %>% 
  merge(d2_nfca_rankings, by = "team_name", all = TRUE) %>% 
  merge(team_ids, by = "team_name") %>% 
  mutate(logo = paste0("http://web2.ncaa.org/ncaa_style/img/All_Logos/sm/", team_id, ".gif")) %>% 
  select("logo", "team_name", "record", "rpi_rank", "nfca_rank", "offensive_rank", "defensive_rank", "overall_rank", "team_id") %>% 
  arrange(overall_rank)

write_csv(d2_rankings, "rankings/d2_rankings.csv")

d3_scoreboard <- readRDS(url(glue::glue("https://github.com/sportsdataverse/softballR-data/raw/main/data/ncaa_scoreboard_D3_{cur_season}.RDS")))

d3_rpi <- get_current_rpi(d3_scoreboard)
d3_power_ratings <- get_power_ratings(d3_scoreboard)
d3_nfca_rankings <- get_nfca_rankings(3)

d3_rankings <- merge(d3_rpi, d3_power_ratings, by = "team_name") %>% 
  merge(d3_nfca_rankings, by = "team_name", all = TRUE) %>% 
  merge(team_ids, by = "team_name") %>% 
  mutate(logo = paste0("http://web2.ncaa.org/ncaa_style/img/All_Logos/sm/", team_id, ".gif")) %>% 
  select("logo", "team_name", "record", "rpi_rank", "nfca_rank", "offensive_rank", "defensive_rank", "overall_rank", "team_id") %>% 
  arrange(overall_rank)

write_csv(d3_rankings, "rankings/d3_rankings.csv")
