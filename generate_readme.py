import os
import subprocess
import requests
from datetime import datetime
import argparse
import re
import logging

DATE_FORMAT = "%d %B, %Y"

# Function to read the current README.md and map game data to create a cache
def read_existing_readme(readme_path:str) -> dict[str,list[str]]:
    game_name_to_data_mapping ={}
    if os.path.exists(readme_path):
        logging.info(f"{readme_path} exists !")
        with open(readme_path, "r") as file:
            lines = file.readlines()
            for line in lines:
                parts = line.split('|')
                if len(parts) >= 4:
                    game_name_match = re.search(r'\!\[(.*?)\]\(', parts[1].strip())
                    if not game_name_match:
                        continue
                    game_name = game_name_match.group(1)

                    game_pic_column = parts[1].strip()
                    last_played = parts[2].strip()

                    key = game_name

                    # Store the extracted data in a dictionary
                    game_name_to_data_mapping[key] = [game_name,game_pic_column,last_played]

    return game_name_to_data_mapping

# Function to get the last commit date of a folder from Git history
def get_last_commit_date(folder_path, base_path):
    try:
        result = subprocess.run(
            ['git', 'log', '-1', '--format=%ct', '--', folder_path],
            cwd=base_path,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        if result.returncode == 0:
            timestamp = int(result.stdout.strip())
            return datetime.fromtimestamp(timestamp)
        else:
            print(f"Error getting last commit date for {folder_path}: {result.stderr}")
            return None
    except Exception as e:
        print(f"Exception getting last commit date for {folder_path}: {e}")
        return None

# Function to get the Steam URL and image of a game using the Steam API
def get_steam_data(game_name):
    try:
        api_url = "https://store.steampowered.com/api/storesearch/"
        params = {
            'term': game_name,
            'l': 'english',
            'cc': 'in'
        }
        response = requests.get(api_url, params=params)
        logging.info(f"Invoked Steam API: {response.request.url}")
        response.raise_for_status()
        data = response.json()
        if data['total'] > 0 and 'items' in data:
            game = data['items'][0]
            game_id = game['id']
            game_img = game['tiny_image']
            return f"https://store.steampowered.com/app/{game_id}/", game_img
        else:
            print(f"Steam URL not found for game: {game_name}")
            return None, None
    except Exception as e:
        print(f"Exception getting Steam data for game {game_name}: {e}")
        return None, None

def generate_readme(base_path):
    # Create Cache
    games = read_existing_readme(os.path.join(base_path,"README.md"))

    for folder in os.listdir(base_path):
        folder_path = os.path.join(base_path, folder)
        if folder == ".git":
            continue
        if os.path.isdir(folder_path):
            last_played_date = get_last_commit_date(folder, base_path)
            game_name:str = folder.replace("_", ":") # ludusavi replaces : with _
            if not last_played_date:
                continue
            last_played_str = last_played_date.strftime(DATE_FORMAT)
            game_pic_data = ""
            if games.get(game_name):
                [_,game_pic_data, _] = games[game_name]
            games[game_name]=[game_name,game_pic_data,last_played_str]

    list_of_games = list(games.values())

    # Sort games by last played date in descending order
    list_of_games.sort(key=lambda x: datetime.strptime(x[2],DATE_FORMAT), reverse=True)

    # Create the README.md content
    readme_content = "# 🎮 Game Save Files Repository\n\n"
    readme_content += "## Introduction\n"
    readme_content += "Welcome to the Game Save Files repository! This repository contains save files for various games that I have played. Each save file is stored in a separate folder named after the game.\n\n"

    # Create the table header
    readme_content += "| Game Name | Last Played |\n"
    readme_content += "|-----------|-------------|\n"

    # Add the games to the table
    for [game_name,game_pic_data,last_played] in list_of_games:
        if game_pic_data == "": # Fire steam API call
            steam_url, game_img = get_steam_data(game_name)
            if steam_url and game_img:
                game_pic_data = f"[![{game_name}]({game_img})]({steam_url})"

        logging.debug(f"Writing data for {game_name,last_played}")

        if game_pic_data == "" or game_pic_data is None: # Only add if we have the image
            logging.error(f"Data for {game_name} is missing")
            continue
        readme_content += f"| {game_pic_data} | {last_played} |\n"

    # Write the README.md file
    with open(os.path.join(base_path, "README.md"), "w") as readme_file:
        readme_file.write(readme_content)

    print("README.md generated successfully!")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate a README.md file for game save files.")
    parser.add_argument('base_path', type=str, help="Path to the directory containing the game save folders")
    args = parser.parse_args()

    logging.basicConfig(level=logging.ERROR)
    generate_readme(args.base_path)
