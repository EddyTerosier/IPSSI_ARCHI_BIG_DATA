# Données

Le projet attend exactement ces deux fichiers :

```text
data/purchases.gz
data/access_log.gz
```

Dans l'archive complète, ils sont déjà présents.
Dans la version GitHub légère, place les fichiers fournis par le professeur dans ce dossier en conservant ces noms.

Les scripts les décompressent en flux et chargent les données non compressées dans HDFS :

```text
/hadoop/data/purchases/purchases.txt
/hadoop/data/access-log/access_log
```
