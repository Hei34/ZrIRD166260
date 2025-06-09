import pandas as pd

def load_scraped_data(path="roblox_gry.pkl"):
    try:
        df = pd.read_pickle(path)
        return df
    except FileNotFoundError:
        print(f"Plik {path} nie istnieje.")
        return pd.DataFrame()


df = load_scraped_data()
# print(df.head(20))
#pokaz opisy pierwsze 20 gier
for index, row in df.iterrows():
    print(f"{index+1}. {row['Tytuł']}: {row['Opis'][:100]}...")