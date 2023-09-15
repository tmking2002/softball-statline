library(tidyverse)
library(softballR)

adjust_hitting_box <- function(raw_box){
  
  final_box <- raw_box %>% 
    separate(player, c("last", "first"), ", ") %>% 
    mutate(player = paste(first, last)) %>% 
    arrange(desc(ab)) %>% 
    select(game_id, team, opponent, player, pos, ab, h, x2b, x3b, hr, rbi, bb, hbp, k)
  
  return(final_box)
  
}

box_2015 <- load_ncaa_softball_playerbox(season = 2015,category = "Hitting") %>% adjust_hitting_box()
box_2016 <- load_ncaa_softball_playerbox(season = 2016,category = "Hitting") %>% adjust_hitting_box()
box_2017 <- load_ncaa_softball_playerbox(season = 2017,category = "Hitting") %>% adjust_hitting_box()
box_2018 <- load_ncaa_softball_playerbox(season = 2018,category = "Hitting") %>% adjust_hitting_box()
box_2019 <- load_ncaa_softball_playerbox(season = 2019,category = "Hitting") %>% adjust_hitting_box()
box_2020 <- load_ncaa_softball_playerbox(season = 2020,category = "Hitting") %>% adjust_hitting_box()
box_2021 <- load_ncaa_softball_playerbox(season = 2021,category = "Hitting") %>% adjust_hitting_box()
box_2022 <- load_ncaa_softball_playerbox(season = 2022,category = "Hitting") %>% adjust_hitting_box()
box_2023 <- load_ncaa_softball_playerbox(season = 2023,category = "Hitting") %>% adjust_hitting_box()

write.csv(box_2015, "~/Projects/softball-statline/teams/data/box_scores/d1_hitting_box_2015.csv")
write.csv(box_2016, "~/Projects/softball-statline/teams/data/box_scores/d1_hitting_box_2016.csv")
write.csv(box_2017, "~/Projects/softball-statline/teams/data/box_scores/d1_hitting_box_2017.csv")
write.csv(box_2018, "~/Projects/softball-statline/teams/data/box_scores/d1_hitting_box_2018.csv")
write.csv(box_2019, "~/Projects/softball-statline/teams/data/box_scores/d1_hitting_box_2019.csv")
write.csv(box_2020, "~/Projects/softball-statline/teams/data/box_scores/d1_hitting_box_2020.csv")
write.csv(box_2021, "~/Projects/softball-statline/teams/data/box_scores/d1_hitting_box_2021.csv")
write.csv(box_2022, "~/Projects/softball-statline/teams/data/box_scores/d1_hitting_box_2022.csv")
write.csv(box_2023, "~/Projects/softball-statline/teams/data/box_scores/d1_hitting_box_2023.csv")

adjust_pitching_box <- function(raw_box){
  
  final_box <- raw_box %>% 
    separate(ip, c("innings", "frac"), sep = "\\.") %>% 
    mutate(ip = as.numeric(ifelse(is.na(frac), innings, as.numeric(innings) + as.numeric(frac) * 1/3))) %>% 
    select(-c(innings, frac)) %>% 
    separate(player, c("last", "first"), ", ") %>% 
    mutate(player = paste(first, last)) %>% 
    arrange(desc(ip)) %>% 
    select(game_id, team, opponent, player, ip, ha, er, bb, hb, so, bf, hr_a, go, fo)
  
  return(final_box)
  
}

box_2021 <- readRDS("~/Projects/softballR-data/data/d1_pitching_box_scores_2021.RDS") %>% adjust_pitching_box()
box_2022 <- readRDS("~/Projects/softballR-data/data/d1_pitching_box_scores_2022.RDS") %>% adjust_pitching_box()
box_2023 <- readRDS("~/Projects/softballR-data/data/d1_pitching_box_scores_2023.RDS") %>% adjust_pitching_box()


write.csv(box_2021, "~/Projects/softball-statline/teams/data/box_scores/d1_pitching_box_2021.csv")
write.csv(box_2022, "~/Projects/softball-statline/teams/data/box_scores/d1_pitching_box_2022.csv")
write.csv(box_2023, "~/Projects/softball-statline/teams/data/box_scores/d1_pitching_box_2023.csv")
