install.packages("tidyverse")
install.packages("rvest")
install.packages("magrittr")

library(tidyverse)
library(rvest)
library(magrittr)

team_ids <- "https://stats.ncaa.org/game_upload/team_codes" %>%
    rvest::read_html() %>%
    rvest::html_table() %>%
    magrittr::extract2(1) %>%
    dplyr::filter(!(X1 %in% c("NCAA Codes", "ID"))) %>%
    `names<-`(c("team_id", "team_name"))


ncaa_team_info <- url("https://github.com/sportsdataverse/softballR-data/raw/main/data/ncaa_team_info.RDS") %>% 
  readRDS() %>% 
  filter(season != 2024)

for(i in 1:nrow(team_ids)){
  
  url <- paste0("https://stats.ncaa.org/teams/history/WSB/", team_ids$team_id[i])
  
  existing_info <- ncaa_team_info %>% 
    filter(team_id == team_ids$team_id[i]) %>% 
    mutate(record = paste(wins, losses, ties, sep = "-")) %>% 
    select(season, head_coach, conference, record, win_perc)
  
  df <- url %>% 
    read_html() %>% 
    html_table() %>% 
    extract2(1) %>% 
    filter(Year == "2023-24") %>% 
    mutate(team_name = team_ids$team_name[i],
           team_id = team_ids$team_id[i],
           Year = paste0(substr(Year, 1, 2), substr(Year, 6, 7)),
           record = paste(Wins, Losses, Ties, sep = "-")) %>% 
    select(Year, `Head Coaches`, Conference, record, `WL%`) %>% 
    `names<-`(c("season", "head_coach", "conference", "record", "win_perc"))
  
  write.csv(rbind(df, existing_info), paste0("teams/data/team_info/team_", team_ids$team_id[i], ".csv"))
  
  print(i)
  
}

