hitting_box
- game_id, team_id, opponent_id, player_id, pos, ab, r, h, rbi, hr, k, bb

pitching_box
- game_id, team_id, opponent_id, player_id, ip, ha, er, bb, hb, so, bf, go, fo

games
- game_id, game_date, season, team_id, team_score, opponent_id, opponent_score
**figure out if team is always home or away**

teams
- team_id, team, logo_link, website_link

team_seasons
- team_id, team_season_id, season

players
- player_id, player, headshot_link

rosters
- player_season_id, player_id, season, class, position, height, hometown, high_school
