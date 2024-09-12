from datetime import datetime
from selenium import webdriver
from bs4 import BeautifulSoup
import pandas as pd
import shutup
import pandas as pd
from bs4 import BeautifulSoup
import warnings

shutup.please()
warnings.filterwarnings("ignore", message="Attempting to use a delegate")
warnings.filterwarnings("ignore", message="handshake failed")

def extract_schedule(html):
    soup = BeautifulSoup(html, 'html.parser')
    
    rows = soup.find_all('tr', id=lambda x: x and x.startswith('contest_'))
    
    games = pd.DataFrame()
    team_ids = []
    scores = []
    canceled = False
    current_game_id = None

    for i, row in enumerate(rows):
        columns = row.find_all('td')

        # Skip if there are no columns in this row
        if not columns:
            continue
        
        # Check if the game is canceled
        if len(columns) > 2 and columns[-2].get_text(strip=True) == 'Canceled':
            canceled = True
            continue
        
        if canceled:
            # Skip processing until we get the next game row
            if len(columns) > 1 and columns[0].get_text(strip=True) == '':
                canceled = False
            continue

        # Process valid rows
        if len(columns) > 1:
            
            team_link = columns[1].find('a', href=True)
            if not team_link:
                continue  # Skip if there is no link to extract team ID
            team_id = team_link['href'].split('/')[-1]

            try:
                if i % 2 == 0:
                    # First row: away team
                    away_team_id = team_id
                    away_score = columns[-3].get_text(strip=True) if len(columns) > 3 else 'N/A'
                    team_ids.append(away_team_id)
                    scores.append(away_score)

                    table = columns[2].find('table', id=True)
                    current_game_id = table['id'].split('_')[-2]
                else:
                    # Second row: home team
                    if not current_game_id:
                        continue

                    home_team_id = team_id
                    home_score = columns[-3].get_text(strip=True) if len(columns) > 2 else 'N/A'
                    team_ids.append(home_team_id)
                    scores.append(home_score)
                    
                    # Create DataFrame and append to games
                    cur_game = pd.DataFrame({
                        'game_id': [current_game_id],
                        'away_team_season_id': [team_ids[0]],
                        'away_score': [scores[0]],
                        'home_team_season_id': [team_ids[1]],
                        'home_score': [scores[1]]
                    })

                    games = pd.concat([games, cur_game], ignore_index=True)
                    
                    # Reset for next game
                    team_ids = []
                    scores = []
                    
            except IndexError:
                print(f"Error processing row {i}. Columns: {len(columns)}")
                continue
    
    return games



def scrape_season_data(season_id, start_date):

    driver = webdriver.Chrome()

    full_schedule = pd.DataFrame()

    date = start_date
    while True:
        print(f'Scraping {date.strftime("%Y-%m-%d")}...')
        month = int(date.strftime('%m'))
        day = int(date.strftime('%d'))
        year = date.strftime('%Y')

        url = f'https://stats.ncaa.org/season_divisions/{season_id}/livestream_scoreboards?utf8=%E2%9C%93&season_division_id=&game_date={f"{month:02d}%2F{day:02d}%2F{year}"}&conference_id=0&tournament_id=&commit=Submit'
        driver.get(url)

        html = driver.page_source
        games = extract_schedule(html)

        if len(games) > 0:

            games['date'] = date
            games = games[['game_id', 'date', 'away_team_season_id', 'away_score', 'home_team_season_id', 'home_score']]

            if date != start_date:
                if not pd.merge(full_schedule, games, on='game_id').empty:
                    break

            full_schedule = pd.concat([full_schedule, games], ignore_index=True)

        date += pd.Timedelta(days=1)

    driver.quit()   

    return full_schedule

season_information = {
    "season_ids": [18101, 17840, 17540],
    "start_dates": [datetime(2023, 2, 9), datetime(2022, 2, 10), datetime(2021, 2, 11)]
}

for i, season_id in enumerate(season_information['season_ids']):

    year = season_information['start_dates'][i].strftime('%Y')

    print(f'Scraping {year} season...')

    schedule = scrape_season_data(season_id, season_information['start_dates'][i])

    schedule.to_csv(f'schedule/schedule_{year}.csv', index=False)

# with open('scripts/test_schedule_page.html') as f:
#     html = f.read()
#     print(extract_schedule(html))