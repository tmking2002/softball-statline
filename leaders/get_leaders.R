library(tidyverse)

#### Hitting ####

## Seasons ##

hitting_files <- list.files("~/Projects/softball-statline/teams/data/hitting_stats")
hitting_stats <- rbind(read_csv(paste0("~/Projects/softball-statline/teams/data/hitting_stats/", hitting_files))) %>% 
  mutate(pa = ab + bb + hbp,
         xbh = x2b + x3b + hr,
         tb = 2 * x2b + 3 * x3b + 4 * hr + (h - xbh),
         slg = tb / ab,
         slg = format(round(slg, 3), digits = 3),
         rc = (tb * (h + bb)) / (ab + bb),
         rc = format(round(rc, 2), digits = 2),
         avg = format(round(avg, 3), digits = 3),
         ops = format(round(ops, 3), digits = 3))

save_leaders <- function(season) {
  
  cur_hitting_stats <- hitting_stats %>% 
    filter(season == .env$season)
  
  rc_leaders <- cur_hitting_stats %>% 
    filter(pa >= 50) %>% 
    slice_max(n = 100, order_by = rc) %>% 
    mutate(rank = nrow(.) + 1 - rank(rc, ties.method = "max")) %>% 
    select(team_id, player_id, rank, player, rc)
  
  avg_leaders <- cur_hitting_stats %>% 
    filter(pa >= 50) %>% 
    slice_max(n = 100, order_by = avg) %>% 
    mutate(rank = nrow(.) + 1 - rank(avg, ties.method = "max")) %>% 
    select(team_id, player_id, rank, player, avg)
  
  slg_leaders <- cur_hitting_stats %>% 
    filter(pa >= 50) %>% 
    slice_max(n = 100, order_by = slg) %>%
    mutate(rank = nrow(.) + 1 - rank(slg, ties.method = "max")) %>% 
    select(team_id, player_id, rank, player, slg)
  
  ops_leaders <- cur_hitting_stats %>% 
    filter(pa >= 50) %>% 
    slice_max(n = 100, order_by = ops) %>%
    mutate(rank = nrow(.) + 1 - rank(ops, ties.method = "max")) %>% 
    select(team_id, player_id, rank, player, ops)
  
  h_leaders <- cur_hitting_stats %>% 
    slice_max(n = 100, order_by = h) %>%
    mutate(rank = rank(-h, ties.method = "min")) %>% 
    select(team_id, player_id, rank, player, h)
  
  xbh_leaders <- cur_hitting_stats %>% 
    slice_max(n = 100, order_by = xbh) %>%
    mutate(rank = rank(-xbh, ties.method = "min")) %>% 
    select(team_id, player_id, rank, player, xbh)
  
  hr_leaders <- cur_hitting_stats %>% 
    slice_max(n = 100, order_by = hr) %>% 
    mutate(rank = rank(-hr, ties.method = "min")) %>% 
    select(team_id, player_id, rank, player, hr)
  
  sb_leaders <- cur_hitting_stats %>% 
    filter(pa >= 50) %>% 
    slice_max(n = 100, order_by = sb) %>%
    mutate(rank = rank(-sb, ties.method = "min")) %>% 
    select(team_id, player_id, rank, player, sb)
  
  write.csv(rc_leaders, paste0("~/Projects/softball-statline/leaders/", season, "/rc_leaders.csv"))
  write.csv(avg_leaders, paste0("~/Projects/softball-statline/leaders/", season, "/avg_leaders.csv"))
  write.csv(slg_leaders, paste0("~/Projects/softball-statline/leaders/", season, "/slg_leaders.csv"))
  write.csv(ops_leaders, paste0("~/Projects/softball-statline/leaders/", season, "/ops_leaders.csv"))
  write.csv(h_leaders, paste0("~/Projects/softball-statline/leaders/", season, "/h_leaders.csv"))
  write.csv(xbh_leaders, paste0("~/Projects/softball-statline/leaders/", season, "/xbh_leaders.csv"))
  write.csv(hr_leaders, paste0("~/Projects/softball-statline/leaders/", season, "/hr_leaders.csv"))
  write.csv(sb_leaders, paste0("~/Projects/softball-statline/leaders/", season, "/sb_leaders.csv"))
  
}

save_leaders(2023)
save_leaders(2022)
save_leaders(2021)
save_leaders(2019)
save_leaders(2018)
save_leaders(2017)
save_leaders(2016)
save_leaders(2015)

## All Time ##

save_all_time_leaders <- function() {
  
  rc_leaders <- hitting_stats %>% 
    filter(pa >= 50) %>% 
    slice_max(n = 100, order_by = rc) %>% 
    mutate(rank = nrow(.) + 1 - rank(rc, ties.method = "max")) %>% 
    select(team_id, player_id, rank, player, rc, season)
  
  avg_leaders <- hitting_stats %>% 
    filter(pa >= 50) %>% 
    slice_max(n = 100, order_by = avg) %>% 
    mutate(rank = nrow(.) + 1 - rank(avg, ties.method = "max")) %>% 
    select(team_id, player_id, rank, player, avg, season)
  
  slg_leaders <- hitting_stats %>% 
    filter(pa >= 50) %>% 
    slice_max(n = 100, order_by = slg) %>%
    mutate(rank = nrow(.) + 1 - rank(slg, ties.method = "max")) %>% 
    select(team_id, player_id, rank, player, slg, season)
  
  ops_leaders <- hitting_stats %>% 
    filter(pa >= 50) %>% 
    slice_max(n = 100, order_by = ops) %>%
    mutate(rank = nrow(.) + 1 - rank(ops, ties.method = "max")) %>% 
    select(team_id, player_id, rank, player, ops, season)
  
  h_leaders <- hitting_stats %>% 
    slice_max(n = 100, order_by = h) %>%
    mutate(rank = rank(-h, ties.method = "min")) %>% 
    select(team_id, player_id, rank, player, h, season)
  
  xbh_leaders <- hitting_stats %>% 
    slice_max(n = 100, order_by = xbh) %>%
    mutate(rank = rank(-xbh, ties.method = "min")) %>% 
    select(team_id, player_id, rank, player, xbh, season)
  
  hr_leaders <- hitting_stats %>% 
    slice_max(n = 100, order_by = hr) %>% 
    mutate(rank = rank(-hr, ties.method = "min")) %>% 
    select(team_id, player_id, rank, player, hr, season)
  
  sb_leaders <- hitting_stats %>% 
    filter(pa >= 50) %>% 
    slice_max(n = 100, order_by = sb) %>%
    mutate(rank = rank(-sb, ties.method = "min")) %>% 
    select(team_id, player_id, rank, player, sb, season)
  
  write.csv(rc_leaders, paste0("~/Projects/softball-statline/leaders/all_time/rc_leaders.csv"))
  write.csv(avg_leaders, paste0("~/Projects/softball-statline/leaders/all_time/avg_leaders.csv"))
  write.csv(slg_leaders, paste0("~/Projects/softball-statline/leaders/all_time/slg_leaders.csv"))
  write.csv(ops_leaders, paste0("~/Projects/softball-statline/leaders/all_time/ops_leaders.csv"))
  write.csv(h_leaders, paste0("~/Projects/softball-statline/leaders/all_time/h_leaders.csv"))
  write.csv(xbh_leaders, paste0("~/Projects/softball-statline/leaders/all_time/xbh_leaders.csv"))
  write.csv(hr_leaders, paste0("~/Projects/softball-statline/leaders/all_time/hr_leaders.csv"))
  write.csv(sb_leaders, paste0("~/Projects/softball-statline/leaders/all_time/sb_leaders.csv"))
  
}

save_all_time_leaders()


## Career ##


save_career_leaders <- function() {
  
  rc_leaders <- hitting_stats %>% 
    group_by(player_id, player) %>% 
    summarise(rc = sum(as.numeric(rc)),
              pa = sum(pa),
              seasons = paste(c(min(season), max(season)), collapse = "-")) %>% 
    arrange(desc(rc)) %>% 
    head(n = 100) %>% 
    ungroup() %>% 
    mutate(rank = rank(-rc)) %>% 
    select(player_id, rank, player, rc, seasons)
  
  avg_leaders <- hitting_stats %>% 
    group_by(player_id, player) %>% 
    summarise(avg = sum(h) / sum(ab),
              pa = sum(pa),
              seasons = paste(c(min(season), max(season)), collapse = "-")) %>% 
    filter(pa >= 300) %>% 
    arrange(desc(avg)) %>% 
    head(n = 100) %>% 
    ungroup() %>% 
    mutate(rank = rank(-avg),
           avg = format(round(avg, 3), digits = 3)) %>% 
    select(player_id, rank, player, avg, seasons)
  
  slg_leaders <- hitting_stats %>% 
    group_by(player_id, player) %>% 
    summarise(slg = sum(tb) / sum(ab),
              pa = sum(pa),
              seasons = paste(c(min(season), max(season)), collapse = "-")) %>% 
    filter(pa >= 300) %>% 
    arrange(desc(slg)) %>% 
    head(n = 100) %>% 
    ungroup() %>% 
    mutate(rank = rank(-slg),
           slg = format(round(slg, 3), digits = 3)) %>% 
    select(player_id, rank, player, slg, seasons)
  
  ops_leaders <- hitting_stats %>% 
    group_by(player_id, player) %>% 
    summarise(pa = sum(pa),
              tb = 2 * sum(x2b) + 3 * sum(x3b) + 4 * sum(hr) + (sum(h) - sum(xbh)),
              obp = (sum(h) + sum(bb) + sum(hbp)) / pa,
              slg = tb / sum(ab),
              ops = obp + slg,
              seasons = paste(c(min(season), max(season)), collapse = "-")) %>% 
    filter(pa >= 300) %>% 
    arrange(desc(ops)) %>% 
    head(n = 100) %>% 
    ungroup() %>% 
    mutate(rank = rank(-ops),
           ops = format(round(ops, 3), digits = 3)) %>% 
    select(player_id, rank, player, ops, seasons)
  
  h_leaders <- hitting_stats %>% 
    group_by(player_id, player) %>% 
    summarise(h = sum(h),
              seasons = paste(c(min(season), max(season)), collapse = "-")) %>% 
    arrange(desc(h)) %>% 
    head(n = 100) %>% 
    ungroup() %>% 
    mutate(rank = rank(-h)) %>% 
    select(player_id, rank, player, h, seasons)
  
  xbh_leaders <- hitting_stats %>% 
    group_by(player_id, player) %>% 
    summarise(xbh = sum(xbh),
              seasons = paste(c(min(season), max(season)), collapse = "-")) %>% 
    arrange(desc(xbh)) %>% 
    head(n = 100) %>% 
    ungroup() %>% 
    mutate(rank = rank(-xbh)) %>% 
    select(player_id, rank, player, xbh, seasons)
  
  hr_leaders <- hitting_stats %>% 
    group_by(player_id, player) %>% 
    summarise(hr = sum(hr),
              seasons = paste(c(min(season), max(season)), collapse = "-")) %>% 
    arrange(desc(hr)) %>% 
    head(n = 100) %>% 
    ungroup() %>% 
    mutate(rank = rank(-hr)) %>% 
    select(player_id, rank, player, hr, seasons)
  
  sb_leaders <- hitting_stats %>% 
    group_by(player_id, player) %>% 
    summarise(sb = sum(sb),
              seasons = paste(c(min(season), max(season)), collapse = "-")) %>% 
    arrange(desc(sb)) %>% 
    head(n = 100) %>% 
    ungroup() %>% 
    mutate(rank = rank(-sb)) %>% 
    select(player_id, rank, player, sb, seasons)
  
  write.csv(rc_leaders, paste0("~/Projects/softball-statline/leaders/career/rc_leaders.csv"))
  write.csv(avg_leaders, paste0("~/Projects/softball-statline/leaders/career/avg_leaders.csv"))
  write.csv(ops_leaders, paste0("~/Projects/softball-statline/leaders/career/ops_leaders.csv"))
  write.csv(slg_leaders, paste0("~/Projects/softball-statline/leaders/career/slg_leaders.csv"))
  write.csv(h_leaders, paste0("~/Projects/softball-statline/leaders/career/h_leaders.csv"))
  write.csv(xbh_leaders, paste0("~/Projects/softball-statline/leaders/career/xbh_leaders.csv"))
  write.csv(hr_leaders, paste0("~/Projects/softball-statline/leaders/career/hr_leaders.csv"))
  write.csv(sb_leaders, paste0("~/Projects/softball-statline/leaders/career/sb_leaders.csv"))
  
}

save_career_leaders()
