box <- readRDS("~/Projects/softballR-data/data/d1_hitting_box_scores_2023.RDS") %>% 
  separate(player, c("last", "first"), sep = ", ")

proper=function(x) paste0(toupper(substr(x, 1, 1)), tolower(substring(x, 2)))

unique_names <- box %>% 
  distinct(first, last, team) %>% 
  drop_na(first, last) %>% 
  mutate(first =  proper(trimws(str_remove(first, "\\."))),
         last = proper(trimws(str_remove(last, "\\.")))) %>% 
  filter(str_length(first) > 1,
         str_length(last) > 1,
         first != "Unknown") %>% 
  arrange(last, first)

write.csv(unique_names, "~/Projects/softball-statline/players/data/sample_players.csv")
