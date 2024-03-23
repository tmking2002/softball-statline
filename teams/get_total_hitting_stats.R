if (!require("tidyverse", character.only = TRUE)) {
  install.packages("tidyverse")
}
library(tidyverse)

files <- list.files("teams/data/hitting_stats")
files <- files[!files == "total_hitting_stats.csv"]

hitting_stats <- rbind(read_csv(paste0("teams/data/hitting_stats/", files))) %>% 
  mutate(team = "Total",
         season = "") %>% 
  group_by(team, player_id, season, player) %>% 
  summarise(across(c(ab, h , x2b, x3b, hr, rbi, r, bb, hbp, k, sb, cs), sum),
            avg = h / ab,
            obp = (h + bb + hbp) / (ab + bb + hbp),
            slg = (h - x2b - x3b - hr + (2 * x2b) + (3 * x3b) + (4 * hr)) / ab,
            ops = obp + slg) %>% 
  ungroup() %>% 
  mutate(across(.cols = c(avg, obp, ops), 
                .fns = \(col) format(round(col, digits = 3)))) %>% 
  select(-slg)

write.csv(hitting_stats, "teams/data/hitting_stats/total_hitting_stats.csv")
