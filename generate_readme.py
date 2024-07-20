import os
import subprocess
import requests
from datetime import datetime
import argparse

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

# Function to read the current README.md and map game names to their last played date
def read_existing_readme(readme_path):
    game_data = {}
    if os.path.exists(readme_path):
        with open(readme_path, "r") as file:
            lines = file.readlines()
            for line in lines[2:]:  # Skip the header lines
                parts = line.split('|')
                if len(parts) >= 3:
                    game_name = parts[1].strip().split('](')[0][2:]  # Extract game name from Markdown
                    last_played = parts[2].strip()
                    game_data[(game_name, last_played)] = line
    return game_data

# Function to generate or update README.md file
def generate_readme(base_path):
    existing_game_data = read_existing_readme(os.path.join(base_path, "README.md"))
    games = []
    new_lines = []
    added_lines = set()

    for folder in os.listdir(base_path):
        folder_path = os.path.join(base_path, folder)
        if os.path.isdir(folder_path):
            last_played_dt = get_last_commit_date(folder, base_path)
            if last_played_dt:
                game_name = folder.replace("_", ":")
                last_played_str = last_played_dt.strftime('%d %B, %Y')
                game_info = (game_name, last_played_str)
                if game_info in existing_game_data:
                    # Use existing line if available
                    new_lines.append(existing_game_data[game_info])
                    added_lines.add(game_info)
                else:
                    # Create a new line for the game
                    steam_url, game_img = get_steam_data(game_name)
                    new_line = f"| ![{game_name}]({game_img}) [{game_name}]({steam_url}) | {last_played_str} |\n"
                    new_lines.append(new_line)
                    added_lines.add(game_info)

    # Create the new README.md content
    readme_content = "# Game Save Files\n\n"
    readme_content += "This repository contains save files for the following games:\n\n"
    readme_content += "| Game Name | Last Played |\n"
    readme_content += "|-----------|-------------|\n"
    for line in new_lines:
        readme_content += line

    # Write the README.md file
    with open(os.path.join(base_path, "README.md"), "w") as readme_file:
        readme_file.write(readme_content)

    print("README.md updated successfully!")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate a README.md file for game save files.")
    parser.add_argument('base_path', type=str, help="Path to the directory containing the game save folders")
    args = parser.parse_args()

    generate_readme(args.base_path)
