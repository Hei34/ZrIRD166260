from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
import pandas as pd
import time
import random
import re
import nltk
from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer
import json


with open("stopwords-pl.json", "r", encoding="utf-8") as f:
    stop_words = set(json.load(f))

# stop_words = set(stopwords.words("polish"))
lemmatizer = WordNetLemmatizer()

def normalize_description(text):
    if not isinstance(text, str):
        return ""

    text = text.lower()
    text = re.sub(r"http\S+|www\S+|https\S+", '', text)

    text = re.sub(r"[^a-z\s]", "", text)

    tokens = nltk.word_tokenize(text)
    tokens = [lemmatizer.lemmatize(word) for word in tokens if word not in stop_words]

    return " ".join(tokens)

chrome_options = Options()
chrome_options.add_argument("--headless")
chrome_options.add_argument("--disable-blink-features=AutomationControlled")
chrome_options.add_argument("user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36")

driver_path = "C:\stuudia\chromedriver\chromedriver-win64\chromedriver.exe"
driver = webdriver.Chrome(service=Service(driver_path), options=chrome_options)

url = "https://www.roblox.com/charts#/sortName/most-popular?country=all&device=computer"
driver.get(url)
time.sleep(5)

for _ in range(3):
    driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
    time.sleep(random.uniform(2, 4))

game_links = []
cards = driver.find_elements(By.CLASS_NAME, "game-card-link")
for card in cards:
    href = card.get_attribute("href")
    if href and href not in game_links:
        game_links.append(href)

print(f"Znaleziono {len(game_links)} linków.")

data = []

for index, link in enumerate(game_links):
    try:
        driver.get(link)
        time.sleep(random.uniform(3, 8.73))

        try:
            title = driver.find_element(By.TAG_NAME, "h1").text.strip()
        except:
            title = ""

        try:
            # raw_description = driver.find_element(By.CSS_SELECTOR, ".text.game-description").text
            # description = normalize_description(raw_description)
            description = driver.find_element(By.CSS_SELECTOR, ".text.game-description").text
        except:
            description = ""

        try:
            rating = driver.find_element(By.CLASS_NAME, "vote-percentage").text.strip()
        except:
            rating = ""

        game_data = {
            "Tytuł": title,
            "Opis": description,
            "Ocena": rating,
            "Link": link,
        }

        data.append(game_data)
        print(f"[{index+1}/{len(game_links)}] Zebrano: {title}")

    except Exception as e:
        print(f"Błąd przy {link}: {e}")
        continue

driver.quit()

df = pd.DataFrame(data)
df.drop_duplicates(subset=["Tytuł", "Link"], inplace=True)
df.dropna(subset=["Tytuł"], inplace=True)


df.to_pickle("roblox_gry.pkl")
print("lista zapisana w roblox_gry.pkl")

