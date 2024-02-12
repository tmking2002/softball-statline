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


new_info <- data.frame()

for(i in 1:nrow(team_ids)){
  
  url <- paste0("https://stats.ncaa.org/teams/history/WSB/", team_ids$team_id[i])
  
  df <- url %>% 
    read_html() %>% 
    html_table() %>% 
    extract2(1) %>% 
    filter(Year == "2023-24") %>% 
    mutate(team_name = team_ids$team_name[i],
           team_id = team_ids$team_id[i],
           Year = paste0(substr(Year, 1, 2), substr(Year, 6, 7))) %>% 
    select(team_name, team_id, Year, `Head Coaches`, Division, Conference, Wins, Losses, Ties, `WL%`) %>% 
    `names<-`(c("team_name", "team_id", "season", "head_coach", "division", "conference", "wins", "losses", "ties", "win_perc"))
  
  new_info <- rbind(new_info, df)
  
  print(i)
  
}

ncaa_team_info <- rbind(ncaa_team_info, new_info)

