install.packages("tidyverse")
library(tidyverse)

print("TOTAL PITCHING STATS")

files <- list.files("teams/data/pitching_stats")
files <- files[!files == "total_pitching_stats.csv"]

pitching_stats <- rbind(read_csv(paste0("teams/data/pitching_stats/", files))) %>% 
  mutate(team = "Total",
         season = "") %>% 
  separate(ip, c("innings", "frac"), sep = "\\.") %>% 
  mutate(ip = ifelse(is.na(frac), as.numeric(innings), as.numeric(innings) + as.numeric(frac) / 3),
         weighted_era = ip * era,
         weighted_avg = ip * opp_avg,
         weighted_fip = ip * fip) %>% 
  group_by(team, player_id, season, player) %>% 
  summarise(across(c(ip, ha, bb, hb, so, hr_a), ~ sum(.x, na.rm = T)),
            era = sum(weighted_era) / ip,
            opp_avg = sum(weighted_avg) / ip,
            whip = (bb + hb + ha) / ip,
            fip = sum(weighted_fip) / ip) %>% 
  ungroup() %>% 
  mutate(ip = case_when(round(ip %% 1, 1) == 0.3 ~ (floor(ip)) + 0.1,
                        round(ip %% 1, 1) == 0.7 ~ (floor(ip)) + 0.2,
                        TRUE ~ ip),
         across(.cols = c(era, opp_avg, whip, fip), 
                .fns = \(col) as.numeric(format(round(col, 3), digits = 3))))

write.csv(pitching_stats, "teams/data/pitching_stats/total_pitching_stats.csv")
