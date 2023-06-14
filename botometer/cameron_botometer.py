import botometer
import tweepy
import datetime
import os
import pandas as pd

df = pd.read_csv(r"C:\Users\amber\Desktop\account_status\dominion\output_2023-06-10.csv")

list_of_handles = df.loc[df['status'].str.contains("Active")]
list_of_handles = list_of_handles['id'].values.tolist()

to_merge = df.loc[df['status'] != "Active"]
to_merge['userID'] = to_merge['id']
to_merge['username'] = 'none'
to_merge['cap_universal'] = -1
to_merge = to_merge[['userID', 'username', 'cap_universal', 'status']]


twitter_app_auth = {

    'consumer_key': 'CyPNY4e0EtuGFuXx4stjcfksO',

    'consumer_secret': 'hxoQKb6FdE9drm0TtjArlKjvJ5uy2hzNTrk2Yrg4xs6zDoozu8',

    'access_token': '3807667157-t6f2iiDWLO6g6hlQT5VvnABJeMDC2fUbEaSLM8s',

    'access_token_secret': 'hK156TyzWzTf8lDUO4C4A5I2hlN4THedKiz29rk87Hj4A',

  }


botometer_api_url = 'https://botometer-pro.p.mashape.com'

bom = botometer.Botometer(botometer_api_url=botometer_api_url,
    wait_on_ratelimit=True,
    rapidapi_key='85d8c98d8emsh73f6d22851cf11ap108f3djsn447254edb8d4',
  **twitter_app_auth)


list_of_df = []
_index = 0
for screen_name, result in bom.check_accounts_in(list_of_handles):
    print(_index)
    if('user' not in list(result.keys())):
        print(result)
        if ('error' in list(result.keys())):
          if '34' in result['error'] :
            data = {
              'userID': 'none', 
              'username': list_of_handles[_index], 
              'cap_universal':  -1,
              'cap_english':  -1,
              'english_astroturf':  -1,
              'english_fake_follower':  -1,
              'english_financial':  -1,
              'english_other':  -1,
              'english_overall':  -1,
              'english_self_declared':  -1,
              'english_spammer':  -1,
              'universal_astroturf':  -1,
              'universal_fake_follower': -1,
              'universal_financial':  -1,
              'universal_other':  -1,
              'universal_overall':  -1,
              'universal_self_declared':  -1,
              'universal_spammer': -1,
              'status': "deleted"
            }
            df = pd.DataFrame(data, index=[_index])
            list_of_df.append(df)
            _index = _index + 1
          else: 
            data = {
              'userID': 'none', 
              'username': list_of_handles[_index], 
              'cap_universal':  -1,
              'cap_english':  -1,
              'english_astroturf':  -1,
              'english_fake_follower':  -1,
              'english_financial':  -1,
              'english_other':  -1,
              'english_overall':  -1,
              'english_self_declared':  -1,
              'english_spammer':  -1,
              'universal_astroturf':  -1,
              'universal_fake_follower': -1,
              'universal_financial':  -1,
              'universal_other':  -1,
              'universal_overall':  -1,
              'universal_self_declared':  -1,
              'universal_spammer': -1,
              'status': "suspended"
            }
            df = pd.DataFrame(data, index=[_index])
            list_of_df.append(df)
            _index = _index + 1
    else: 
        data = {
          'userID': result['user']['user_data']['id_str'], 
          'username': list_of_handles[_index], 
          'cap_universal': result['cap']['universal'],
          'cap_english': result['cap']['english'],
          'english_astroturf': result['display_scores']['english']['astroturf'],
          'english_fake_follower': result['display_scores']['english']['fake_follower'],
          'english_financial': result['display_scores']['english']['financial'],
          'english_other': result['display_scores']['english']['other'],
          'english_overall': result['display_scores']['english']['overall'],
          'english_self_declared': result['display_scores']['english']['self_declared'],
          'english_spammer': result['display_scores']['english']['spammer'],
          'universal_astroturf': result['display_scores']['universal']['astroturf'],
          'universal_fake_follower': result['display_scores']['universal']['fake_follower'],
          'universal_financial': result['display_scores']['universal']['financial'],
          'universal_other': result['display_scores']['universal']['other'],
          'universal_overall': result['display_scores']['universal']['overall'],
          'universal_self_declared': result['display_scores']['universal']['self_declared'],
          'universal_spammer': result['display_scores']['universal']['spammer'],
          'status': "active"
        }
        df = pd.DataFrame(data, index=[_index])
        list_of_df.append(df)
        _index = _index + 1


current_date = str(datetime.datetime.today()).split()[0]
bot = pd.concat(list_of_df)
final = pd.concat([bot, to_merge], ignore_index=True)
final.to_csv('/botometer_output/dominion_bots_{}.csv'.format(current_date))
