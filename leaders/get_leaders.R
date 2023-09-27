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
    mutate(rank = rank(-rc, ties.method = "min")) %>% 
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
    mutate(rank = rank(-avg, ties.method = "min"),
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
    mutate(rank = rank(-slg, ties.method = "min"),
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
    mutate(rank = rank(-ops, ties.method = "min"),
           ops = format(round(ops, 3), digits = 3)) %>% 
    select(player_id, rank, player, ops, seasons)
  
  h_leaders <- hitting_stats %>% 
    group_by(player_id, player) %>% 
    summarise(h = sum(h),
              seasons = paste(c(min(season), max(season)), collapse = "-")) %>% 
    arrange(desc(h)) %>% 
    head(n = 100) %>% 
    ungroup() %>% 
    mutate(rank = rank(-h, ties.method = "min")) %>% 
    select(player_id, rank, player, h, seasons)
  
  xbh_leaders <- hitting_stats %>% 
    group_by(player_id, player) %>% 
    summarise(xbh = sum(xbh),
              seasons = paste(c(min(season), max(season)), collapse = "-")) %>% 
    arrange(desc(xbh)) %>% 
    head(n = 100) %>% 
    ungroup() %>% 
    mutate(rank = rank(-xbh, ties.method = "min")) %>% 
    select(player_id, rank, player, xbh, seasons)
  
  hr_leaders <- hitting_stats %>% 
    group_by(player_id, player) %>% 
    summarise(hr = sum(hr),
              seasons = paste(c(min(season), max(season)), collapse = "-")) %>% 
    arrange(desc(hr)) %>% 
    head(n = 100) %>% 
    ungroup() %>% 
    mutate(rank = rank(-hr, ties.method = "min")) %>% 
    select(player_id, rank, player, hr, seasons)
  
  sb_leaders <- hitting_stats %>% 
    group_by(player_id, player) %>% 
    summarise(sb = sum(sb),
              seasons = paste(c(min(season), max(season)), collapse = "-")) %>% 
    arrange(desc(sb)) %>% 
    head(n = 100) %>% 
    ungroup() %>% 
    mutate(rank = rank(-sb, ties.method = "min")) %>% 
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

#### Pitching ####

## Seasons ##

pitching_files <- list.files("~/Projects/softball-statline/teams/data/pitching_stats")
pitching_stats <- rbind(read_csv(paste0("~/Projects/softball-statline/teams/data/pitching_stats/", pitching_files))) %>% 
  separate(ip, c("innings", "frac"), sep = "\\.") %>% 
  mutate(ip = as.numeric(ifelse(is.na(frac), innings, as.numeric(innings) + as.numeric(frac) * 1/3))) %>% 
  mutate(k_7 = so / ip * 7,
         k_bb = so / (bb + hb),
         ip = as.numeric(ifelse(is.na(frac), innings, paste(innings, frac, sep = ".")))) %>% 
  select(-c(innings, frac))

save_leaders <- function(season) {
  
  cur_pitching_stats <- pitching_stats %>% 
    filter(season == .env$season)
  
  ip_minimum <- ifelse(season == 2020, 50, 100)
  
  ip_leaders <- cur_pitching_stats %>% 
    slice_max(n = 100, order_by = ip) %>% 
    mutate(rank = nrow(.) + 1 - rank(ip, ties.method = "max")) %>% 
    select(team_id, player_id, rank, player, ip)
  
  era_leaders <- cur_pitching_stats %>% 
    filter(ip >= ip_minimum) %>% 
    slice_min(n = 100, order_by = era) %>% 
    mutate(rank = rank(era, ties.method = "min")) %>% 
    select(team_id, player_id, rank, player, era)
  
  so_leaders <- cur_pitching_stats %>% 
    slice_max(n = 100, order_by = so) %>%
    mutate(rank = nrow(.) + 1 - rank(so, ties.method = "max")) %>% 
    select(team_id, player_id, rank, player, so)
  
  hr_a_leaders <- cur_pitching_stats %>% 
    filter(ip >= ip_minimum) %>% 
    slice_min(n = 100, order_by = hr_a) %>%
    mutate(rank = rank(hr_a, ties.method = "min")) %>% 
    select(team_id, player_id, rank, player, hr_a)
  
  k_7_leaders <- cur_pitching_stats %>% 
    filter(ip >= ip_minimum) %>% 
    slice_max(n = 100, order_by = k_7) %>%
    mutate(rank = rank(-k_7, ties.method = "max"),
           k_7 = format(round(k_7, 2), digits = 2)) %>% 
    select(team_id, player_id, rank, player, k_7)
  
  k_bb_leaders <- cur_pitching_stats %>% 
    filter(ip >= ip_minimum) %>% 
    slice_max(n = 100, order_by = k_bb) %>%
    mutate(rank = rank(-k_bb, ties.method = "max"),
           k_bb = format(round(k_bb, 2), digits = 2)) %>% 
    select(team_id, player_id, rank, player, k_bb)
  
  whip_leaders <- cur_pitching_stats %>% 
    filter(ip >= ip_minimum) %>% 
    slice_min(n = 100, order_by = whip) %>% 
    mutate(rank = rank(whip, ties.method = "min")) %>% 
    select(team_id, player_id, rank, player, whip)
  
  fip_leaders <- cur_pitching_stats %>% 
    filter(ip >= ip_minimum) %>% 
    slice_min(n = 100, order_by = fip) %>% 
    mutate(rank = rank(fip, ties.method = "min")) %>% 
    select(team_id, player_id, rank, player, fip)
  
  
  write.csv(ip_leaders, paste0("~/Projects/softball-statline/leaders/", season, "/ip_leaders.csv"))
  write.csv(era_leaders, paste0("~/Projects/softball-statline/leaders/", season, "/era_leaders.csv"))
  write.csv(so_leaders, paste0("~/Projects/softball-statline/leaders/", season, "/so_leaders.csv"))
  write.csv(hr_a_leaders, paste0("~/Projects/softball-statline/leaders/", season, "/hr_a_leaders.csv"))
  write.csv(k_7_leaders, paste0("~/Projects/softball-statline/leaders/", season, "/k_7_leaders.csv"))
  write.csv(k_bb_leaders, paste0("~/Projects/softball-statline/leaders/", season, "/k_bb_leaders.csv"))
  write.csv(whip_leaders, paste0("~/Projects/softball-statline/leaders/", season, "/whip_leaders.csv"))
  write.csv(fip_leaders, paste0("~/Projects/softball-statline/leaders/", season, "/fip_leaders.csv"))
  
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
  
  pitching_stats <- pitching_stats %>% 
    filter(season != 2020)
  
  ip_leaders <- pitching_stats %>% 
    slice_max(n = 100, order_by = ip) %>% 
    mutate(rank = nrow(.) + 1 - rank(ip, ties.method = "max")) %>% 
    select(team_id, player_id, rank, player, ip, season)
  
  era_leaders <- pitching_stats %>% 
    filter(ip >= ip_minimum) %>% 
    slice_min(n = 100, order_by = era) %>% 
    mutate(rank = rank(era, ties.method = "min")) %>% 
    select(team_id, player_id, rank, player, era, season)
  
  so_leaders <- pitching_stats %>% 
    slice_max(n = 100, order_by = so) %>%
    mutate(rank = nrow(.) + 1 - rank(so, ties.method = "max")) %>% 
    select(team_id, player_id, rank, player, so, season)
  
  hr_a_leaders <- pitching_stats %>% 
    filter(ip >= ip_minimum) %>% 
    slice_min(n = 100, order_by = hr_a) %>%
    mutate(rank = rank(hr_a, ties.method = "min")) %>% 
    select(team_id, player_id, rank, player, hr_a, season)
  
  k_7_leaders <- pitching_stats %>% 
    filter(ip >= ip_minimum) %>% 
    slice_max(n = 100, order_by = k_7) %>%
    mutate(rank = rank(-k_7, ties.method = "max"),
           k_7 = format(round(k_7, 2), digits = 2)) %>% 
    select(team_id, player_id, rank, player, k_7, season)
  
  k_bb_leaders <- pitching_stats %>% 
    filter(ip >= ip_minimum) %>% 
    slice_max(n = 100, order_by = k_bb) %>%
    mutate(rank = rank(-k_bb, ties.method = "max"),
           k_bb = format(round(k_bb, 2), digits = 2)) %>% 
    select(team_id, player_id, rank, player, k_bb, season)
  
  whip_leaders <- pitching_stats %>% 
    filter(ip >= ip_minimum) %>% 
    slice_min(n = 100, order_by = whip) %>% 
    mutate(rank = rank(whip, ties.method = "min")) %>% 
    select(team_id, player_id, rank, player, whip, season)
  
  fip_leaders <- pitching_stats %>% 
    filter(ip >= ip_minimum) %>% 
    slice_min(n = 100, order_by = fip) %>% 
    mutate(rank = rank(fip, ties.method = "min")) %>% 
    select(team_id, player_id, rank, player, fip, season)
  
  write.csv(ip_leaders, paste0("~/Projects/softball-statline/leaders/all_time/ip_leaders.csv"))
  write.csv(era_leaders, paste0("~/Projects/softball-statline/leaders/all_time/era_leaders.csv"))
  write.csv(so_leaders, paste0("~/Projects/softball-statline/leaders/all_time/so_leaders.csv"))
  write.csv(hr_a_leaders, paste0("~/Projects/softball-statline/leaders/all_time/hr_a_leaders.csv"))
  write.csv(k_7_leaders, paste0("~/Projects/softball-statline/leaders/all_time/k_7_leaders.csv"))
  write.csv(k_bb_leaders, paste0("~/Projects/softball-statline/leaders/all_time/k_bb_leaders.csv"))
  write.csv(whip_leaders, paste0("~/Projects/softball-statline/leaders/all_time/whip_leaders.csv"))
  write.csv(fip_leaders, paste0("~/Projects/softball-statline/leaders/all_time/fip_leaders.csv"))
  
}

save_all_time_leaders()


## Career ##


save_career_leaders <- function() {
  
  ip_leaders <- pitching_stats %>% 
    group_by(player_id, player) %>% 
    summarise(ip = sum(as.numeric(ip)),
              seasons = paste(c(min(season), max(season)), collapse = "-")) %>% 
    arrange(desc(ip)) %>% 
    head(n = 100) %>% 
    ungroup() %>% 
    mutate(rank = rank(-ip, ties.method = "min")) %>% 
    select(player_id, rank, player, ip, seasons)
  
  era_leaders <- pitching_stats %>% 
    mutate(weighted_era = era * ip) %>% 
    group_by(player_id, player) %>% 
    separate(ip, c("innings", "frac"), sep = "\\.") %>% 
    mutate(ip = as.numeric(ifelse(is.na(frac), innings, as.numeric(innings) + as.numeric(frac) * 1/3))) %>% 
    summarise(era = sum(weighted_era) / sum(ip),
              innings = sum(as.numeric(innings)),
              frac = sum(as.numeric(frac)),
              ip = as.numeric(ifelse(is.na(frac), innings, paste(innings, frac, sep = "."))),
              seasons = paste(c(min(season), max(season)), collapse = "-")) %>% 
    filter(ip >= 300) %>% 
    arrange(era) %>% 
    head(n = 100) %>% 
    ungroup() %>% 
    mutate(rank = rank(era, ties.method = "min"),
           era = format(round(era, 3), digits = 3)) %>% 
    select(player_id, rank, player, era, seasons)
  
  so_leaders <- pitching_stats %>% 
    group_by(player_id, player) %>% 
    summarise(so = sum(so),
              seasons = paste(c(min(season), max(season)), collapse = "-")) %>% 
    arrange(desc(so)) %>% 
    head(n = 100) %>% 
    ungroup() %>% 
    mutate(rank = rank(-so, ties.method = "min")) %>% 
    select(player_id, rank, player, so, seasons)
  
  hr_a_leaders <- pitching_stats %>% 
    group_by(player_id, player) %>% 
    summarise(hr_a = sum(hr_a),
              ip = sum(ip),
              seasons = paste(c(min(season), max(season)), collapse = "-")) %>% 
    filter(ip >= 300) %>% 
    arrange(hr_a) %>% 
    head(n = 100) %>% 
    ungroup() %>% 
    mutate(rank = rank(hr_a, ties.method = "min")) %>% 
    select(player_id, rank, player, hr_a, seasons)
  
  k_7_leaders <- pitching_stats %>% 
    group_by(player_id, player) %>% 
    summarise(k_7 = sum(so) / sum(ip) * 7,
              ip = sum(ip),
              seasons = paste(c(min(season), max(season)), collapse = "-")) %>% 
    filter(ip >= 300) %>%
    arrange(desc(k_7)) %>% 
    head(n = 100) %>% 
    ungroup() %>% 
    mutate(rank = rank(-k_7, ties.method = "min"),
           k_7 = format(round(k_7, 2), digits = 2)) %>% 
    select(player_id, rank, player, k_7, seasons)
  
  k_bb_leaders <- pitching_stats %>% 
    group_by(player_id, player) %>% 
    summarise(k_bb = sum(so) / (sum(bb) + sum(hb)),
              ip = sum(ip),
              seasons = paste(c(min(season), max(season)), collapse = "-")) %>% 
    filter(ip >= 300) %>%
    arrange(desc(k_bb)) %>% 
    head(n = 100) %>% 
    ungroup() %>% 
    mutate(rank = rank(-k_bb, ties.method = "min"),
           k_bb = format(round(k_bb, 2), digits = 2)) %>% 
    select(player_id, rank, player, k_bb, seasons)
  
  whip_leaders <- pitching_stats %>% 
    mutate(weighted_whip = whip * ip) %>% 
    group_by(player_id, player) %>% 
    separate(ip, c("innings", "frac"), sep = "\\.") %>% 
    mutate(ip = as.numeric(ifelse(is.na(frac), innings, as.numeric(innings) + as.numeric(frac) * 1/3))) %>% 
    summarise(whip = sum(weighted_whip) / sum(ip),
              innings = sum(as.numeric(innings)),
              frac = sum(as.numeric(frac)),
              ip = as.numeric(ifelse(is.na(frac), innings, paste(innings, frac, sep = "."))),
              seasons = paste(c(min(season), max(season)), collapse = "-")) %>% 
    filter(ip >= 300) %>% 
    arrange(whip) %>% 
    head(n = 100) %>% 
    ungroup() %>% 
    mutate(rank = rank(whip, ties.method = "min"),
           whip = format(round(whip, 3), digits = 3)) %>% 
    select(player_id, rank, player, whip, seasons)
  
  fip_leaders <- pitching_stats %>% 
    mutate(weighted_fip = fip * ip) %>% 
    group_by(player_id, player) %>% 
    separate(ip, c("innings", "frac"), sep = "\\.") %>% 
    mutate(ip = as.numeric(ifelse(is.na(frac), innings, as.numeric(innings) + as.numeric(frac) * 1/3))) %>% 
    summarise(fip = sum(weighted_fip, na.rm = T) / sum(ip),
              innings = sum(as.numeric(innings)),
              frac = sum(as.numeric(frac)),
              ip = as.numeric(ifelse(is.na(frac), innings, paste(innings, frac, sep = "."))),
              seasons = paste(c(min(season), max(season)), collapse = "-")) %>% 
    filter(ip >= 300) %>% 
    arrange(fip) %>% 
    head(n = 100) %>% 
    ungroup() %>% 
    mutate(rank = rank(fip, ties.method = "min"),
           fip = format(round(fip, 3), digits = 3)) %>% 
    select(player_id, rank, player, fip, seasons)
  
  write.csv(ip_leaders, paste0("~/Projects/softball-statline/leaders/career/ip_leaders.csv"))
  write.csv(era_leaders, paste0("~/Projects/softball-statline/leaders/career/era_leaders.csv"))
  write.csv(so_leaders, paste0("~/Projects/softball-statline/leaders/career/so_leaders.csv"))
  write.csv(hr_a_leaders, paste0("~/Projects/softball-statline/leaders/career/hr_a_leaders.csv"))
  write.csv(k_7_leaders, paste0("~/Projects/softball-statline/leaders/career/k_7_leaders.csv"))
  write.csv(k_bb_leaders, paste0("~/Projects/softball-statline/leaders/career/k_bb_leaders.csv"))
  write.csv(whip_leaders, paste0("~/Projects/softball-statline/leaders/career/whip_leaders.csv"))
  write.csv(fip_leaders, paste0("~/Projects/softball-statline/leaders/career/fip_leaders.csv"))
  
}

save_career_leaders()
