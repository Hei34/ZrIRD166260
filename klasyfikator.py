import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.cluster import KMeans
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.feature_extraction.text import CountVectorizer


df = pd.read_pickle("roblox_gry.pkl")
descriptions = df["Opis"].dropna().tolist()


vectorizer = TfidfVectorizer(max_df=0.8, min_df=2, stop_words="english")
X = vectorizer.fit_transform(descriptions)

vectorizer_bow = CountVectorizer(max_df=0.8, min_df=2, stop_words="english")
X_bow = vectorizer_bow.fit_transform(descriptions)


n_clusters = 6
model = KMeans(n_clusters=n_clusters, random_state=42)
df["Temat"] = model.fit_predict(X)

print('=====TF-IDF=====\n')
for i in range(n_clusters):
    print(f"\n Klaster {i}:")
    sample = df[df["Temat"] == i]["Tytuł"].head(5).tolist()
    for title in sample:
        print(f"  - {title}")


sns.countplot(x="Temat", data=df)
plt.title("Rozkład gier w klastrach")
plt.show()


print('=====BAG OF WORDS=====\n')
# Klasteryzacja dla bag of words
model_bow = KMeans(n_clusters=n_clusters, random_state=42)
df["Temat_BOW"] = model_bow.fit_predict(X_bow)
for i in range(n_clusters):
    print(f"\n Klaster BOW {i}:")
    sample_bow = df[df["Temat_BOW"] == i]["Tytuł"].head(5).tolist()
    for title in sample_bow:
        print(f"  - {title}")
sns.countplot(x="Temat_BOW", data=df)
plt.title("Rozkład gier w klastrach BOW")
plt.show()
