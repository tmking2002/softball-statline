cur_season <- 2023

info <- try(readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/ncaa_team_info.RDS")), silent = TRUE)

conferences <- info %>%
  filter(season == cur_season & division == "D-I") %>%
  distinct(team_name, conference)

conf_scoreboard <- try(readRDS(url(glue::glue("https://github.com/sportsdataverse/softballR-data/raw/main/data/ncaa_scoreboard_{cur_season}.RDS"))), silent = TRUE) %>%
  drop_na(home_team, away_team) %>%
  mutate(home_team = str_replace(home_team, "&amp;", "&"),
         away_team = str_replace(away_team, "&amp;", "&"),
         home_team = str_replace(home_team, "&#39;", "'"),
         away_team = str_replace(away_team, "&#39;", "'")) %>%
  merge(conferences, by.x = "home_team", by.y = "team_name", all = T) %>%
  rename(home_conference = conference) %>%
  merge(conferences, by.x = "away_team", by.y = "team_name", all = T) %>%
  rename(away_conference = conference) %>%
  drop_na(home_conference, away_conference) %>%
  filter(home_conference == away_conference &
           anytime::anydate(game_date) < "2023-05-10")

create_standings <- function(conference){

  scoreboard <- conf_scoreboard %>%
    filter(home_conference == conference)

  team1_scoreboard <- scoreboard[c(9,1,5,2,8)] %>% `names<-`(c("date","team_name","runs","opponent_name","opponent_runs"))
  team2_scoreboard <- scoreboard[c(9,2,8,1,5)] %>% `names<-`(c("date","team_name","runs","opponent_name","opponent_runs"))

  scoreboard_upd <- rbind(team1_scoreboard, team2_scoreboard) %>%
    mutate(result = case_when(runs > opponent_runs ~ "W",
                              runs < opponent_runs ~ "L",
                              runs == opponent_runs ~ "T")) %>%
    drop_na(team_name, runs, opponent_runs)

  standings <- scoreboard_upd %>%
    group_by(team_name) %>%
    summarise(W = sum(result == "W"),
              L = sum(result == "L"),
              T = sum(result == "T"),
              win_perc = (W + T / 2) / (W + L + T)) %>%
    arrange(desc(win_perc)) %>%
    select(-win_perc) %>%
    `names<-`(c("Team", "W", "L", "T"))

  return(standings)

}

for(i in 1:length(unique(conf_scoreboard$home_conference))){

  conf <- unique(conf_scoreboard$home_conference)[i]

  standings <- create_standings(conf)

  write_csv(standings, file = paste0("~/Projects/softball-statline/conf_standings/",conf,".csv"))

  print(i)

}
