if (!require("tidyverse", character.only = TRUE)) {
  install.packages("tidyverse")
}
library(tidyverse)
if (!require("rvest", character.only = TRUE)) {
  install.packages("rvest")
}
library(rvest)
if (!require("magrittr", character.only = TRUE)) {
  install.packages("magrittr")
}
library(magrittr)

print("TEAM INFO")

# team_ids <- "https://stats.ncaa.org/game_upload/team_codes" %>%
#     rvest::read_html() %>%
#     rvest::html_table() %>%
#     magrittr::extract2(1) %>%
#     dplyr::filter(!(X1 %in% c("NCAA Codes", "ID"))) %>%
#     `names<-`(c("team_id", "team_name"))
# 
# d1_scoreboard <- readRDS(url(glue::glue("https://github.com/sportsdataverse/softballR-data/raw/main/data/ncaa_scoreboard_2025.RDS")))
# d2_scoreboard <- readRDS(url(glue::glue("https://github.com/sportsdataverse/softballR-data/raw/main/data/ncaa_scoreboard_D2_2025.RDS")))
# d3_scoreboard <- readRDS(url(glue::glue("https://github.com/sportsdataverse/softballR-data/raw/main/data/ncaa_scoreboard_D3_2025.RDS")))
# 
# scoreboard <- rbind(d1_scoreboard, d2_scoreboard, d3_scoreboard)
# 
# team1_scoreboard <- scoreboard[c(9,1,4,5,8)] %>% `names<-`(c("date","team_name","runs","opponent_name","opponent_runs"))
# team2_scoreboard <- scoreboard[c(9,5,8,1,4)] %>% `names<-`(c("date","team_name","runs","opponent_name","opponent_runs"))
# 
# scoreboard_upd <- rbind(team1_scoreboard, team2_scoreboard) %>%
#   mutate(win = case_when(runs > opponent_runs ~ 1,
#                          runs < opponent_runs ~ 0,
#                          runs == opponent_runs ~ 0.5)) %>%
#   drop_na(team_name, opponent_name, runs, opponent_runs)
# 
# records <- scoreboard_upd %>%
#   group_by(team_name) %>%
#   summarise(games = n(),
#             wins = sum(win == 1),
#             losses = sum(win == 0),
#             ties = sum(win == .5),
#             record = paste(wins, losses, ties, sep = "-"),
#             win_perc = wins / (wins + losses)) %>%
#   ungroup() %>% 
#   merge(team_ids, by = "team_name") %>% 
#   select(team_id, record, win_perc) %>%
#   drop_na()
# 
# for(i in 1:nrow(team_ids)){
#   
#   if(team_ids$team_id[i] %in% records$team_id){
#      
#     df <- try(read.csv(paste0("teams/data/team_info/team_", team_ids$team_id[i], ".csv")) %>% 
#       select(-X))
#     
#     if("try-error" %in% class(df)){
#       next
#     }
#     
#     if(df %>% filter(season == 2025) %>% nrow() == 0){next}
#     
#     record <- records[which(records$team_id == team_ids$team_id[i]),]$record
#     win_perc <- round(records[which(records$team_id == team_ids$team_id[i]),]$win_perc, 3)
#     
#     df[which(df$season == 2025),]$record <- record
#     df[which(df$season == 2025),]$win_perc <- win_perc
#     
#     df <- df %>% distinct()
#     
#     write.csv(df, paste0("teams/data/team_info/team_", team_ids$team_id[i], ".csv")) 
#   }
#   
#   print(i)
#   
# }
# 

team_info <- readRDS(url("https://github.com/sportsdataverse/softballR-data/raw/main/data/ncaa_team_info.RDS"))
team_ids <- unique(team_info$team_id)

for(i in 1:length(team_ids)){
  print(i)

  df <- team_info %>% 
    filter(team_id == team_ids[i]) %>% 
    distinct()

  write.csv(df, paste0("teams/data/team_info/team_", team_ids[i], ".csv"))

}
