from selenium.webdriver.common.by import By
from bs4 import BeautifulSoup
import pandas as pd
from selenium import webdriver

def extract_ids_from_table(table_html):
    soup = BeautifulSoup(table_html, 'html.parser')
    player_ids = pd.DataFrame()

    for a in soup.find_all('a', href=True):
        if '/players/' in a['href']:
            player_season_id = a['href'].split('/')[-1]
            player_name = a.text
            player_ids = pd.concat([player_ids, pd.DataFrame({'player_season_id': [player_season_id], 'player_name': [player_name]})])

    return player_ids

def merge_player_ids(df, player_ids):
    df = pd.merge(df, player_ids, left_on='Name', right_on='player_name', how='left').dropna(subset=['player_season_id'])
    df.drop('player_name', axis=1, inplace=True)
    df.drop_duplicates(inplace=True)
    return df

def get_game_data(game_id):
    url = f'https://stats.ncaa.org/contests/{game_id}/individual_stats'

    driver = webdriver.Chrome()
    driver.get(url)

    html = driver.page_source

    player_ids = extract_ids_from_table(html)

    table_elements = driver.find_elements(By.TAG_NAME, 'table')
    dataframes = []

    for table_element in table_elements:
        table_html = table_element.get_attribute('outerHTML')
        soup = BeautifulSoup(table_html, 'html.parser')
        df = pd.read_html(str(soup))[0]  # Read the table HTML into a DataFrame
        dataframes.append(df)

    driver.quit()

    location = dataframes[0].iloc[5,0]
    attendance = dataframes[0].iloc[6,0]

    away_team = dataframes[0].iloc[2,0]
    home_team = dataframes[0].iloc[3,0]

    game_info = {
        'game_id': game_id,
        'location': location,
        'attendance': attendance,
        'away_team': away_team,
        'home_team': home_team
    }

    ### get the away team hitting stats

    away_hitting = dataframes[3]
    away_hitting = merge_player_ids(away_hitting, player_ids)

    ### get the home team hitting stats

    home_hitting = dataframes[4]
    home_hitting = merge_player_ids(home_hitting, player_ids)

    ### get the away team pitching stats

    away_pitching = dataframes[5]
    away_pitching = merge_player_ids(away_pitching, player_ids)

    ### get the home team pitching stats

    home_pitching = dataframes[6]
    home_pitching = merge_player_ids(home_pitching, player_ids)

    ### get the away team fielding stats

    away_fielding = dataframes[7]
    away_fielding = merge_player_ids(away_fielding, player_ids)

    ### get the home team fielding stats

    home_fielding = dataframes[8]
    home_fielding = merge_player_ids(home_fielding, player_ids)

    all_data = {
        'game_info': game_info,
        'away_hitting': away_hitting,
        'home_hitting': home_hitting,
        'away_pitching': away_pitching,
        'home_pitching': home_pitching,
        'away_fielding': away_fielding,
        'home_fielding': home_fielding
    }

    return all_data
    

print(get_game_data(5336622))
# get_game_data(5336622)