import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.cluster import KMeans
import matplotlib.pyplot as plt
import seaborn as sns


df = pd.read_pickle("roblox_gry.pkl")
descriptions = df["Opis"].dropna().tolist()


vectorizer = TfidfVectorizer(max_df=0.8, min_df=2, stop_words="english")
X = vectorizer.fit_transform(descriptions)


n_clusters = 6
model = KMeans(n_clusters=n_clusters, random_state=42)
df["Temat"] = model.fit_predict(X)


for i in range(n_clusters):
    print(f"\n Klaster {i}:")
    sample = df[df["Temat"] == i]["Tytuł"].head(5).tolist()
    for title in sample:
        print(f"  - {title}")


sns.countplot(x="Temat", data=df)
plt.title("Rozkład gier w klastrach")
plt.show()
