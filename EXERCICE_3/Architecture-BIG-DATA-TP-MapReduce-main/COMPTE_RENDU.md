# Compte rendu — Jobs MapReduce

## Objectif

L'objectif du TP est de charger deux jeux de données dans HDFS puis d'exécuter plusieurs jobs MapReduce avec Hadoop Streaming et des scripts Python.

Le cluster utilisé contient :

- un NameNode ;
- un DataNode ;
- un ResourceManager ;
- un NodeManager ;
- un HistoryServer.

## Démarrage du cluster

```bash
./scripts/01-start-cluster.sh
```

Interfaces à capturer :

- NameNode : `http://localhost:9870`
- ResourceManager : `http://localhost:8088`

## Chargement des données dans HDFS

```bash
./scripts/02-load-data.sh
./scripts/03-check-data.sh
```

Les fichiers sont décompressés en flux puis chargés aux emplacements suivants :

```text
/hadoop/data/purchases/purchases.txt
/hadoop/data/access-log/access_log
```

## Exercice sur `purchases.gz`

```bash
./scripts/04-run-purchases.sh
```

Jobs exécutés :

1. total des ventes par magasin ;
2. total des ventes par type de produit ;
3. achat le plus cher par magasin ;
4. nombre de transactions et chiffre d'affaires global ;
5. chiffre d'affaires moyen par jour.

### Résultats principaux

| Indicateur | Résultat |
|---|---:|
| Ventes du magasin Buffalo | 10 001 941,19 |
| Ventes de Toys | 57 463 477,11 |
| Ventes de Consumer Electronics | 57 452 374,13 |
| Maximum Reno | 499,99 |
| Maximum Toledo | 499,98 |
| Maximum Chandler | 499,98 |
| Transactions | 4 138 476 |
| Chiffre d'affaires | 1 034 457 953,26 |
| Chiffre d'affaires moyen par jour | 2 834 131,38 |

## Exercice sur `access_log.gz`

```bash
./scripts/05-run-access-log.sh
```

Jobs exécutés :

1. nombre de clics par page ;
2. nombre de requêtes par adresse IP ;
3. recherche de la page la plus visitée au moyen d'un second job MapReduce.

### Résultats principaux

| Indicateur | Résultat |
|---|---:|
| Hits de `/assets/js/the-associates.js` | 2 456 |
| Requêtes de `10.99.99.186` | 6 |
| Page la plus visitée | `/assets/css/combined.css` |
| Nombre de visites | 117 348 |

## Interprétation MapReduce

Le mapper lit chaque ligne indépendamment et produit des paires clé-valeur. Par exemple, pour le chiffre d'affaires par magasin, la clé est le nom du magasin et la valeur est le montant de la transaction.

Hadoop regroupe et trie ensuite toutes les valeurs associées à une même clé. Le reducer reçoit chaque magasin avec ses montants et calcule leur somme. Le même principe est utilisé pour les produits, les pages et les adresses IP.

La page la plus visitée nécessite deux étapes :

1. un premier job calcule le nombre de visites de chaque page ;
2. un second job compare ces résultats et conserve le maximum.

## Conclusion

Les jobs MapReduce permettent de traiter les fichiers volumineux sans charger l'ensemble des données en mémoire dans un seul programme. Le traitement est séparé entre une phase de transformation distribuée, le Map, puis une phase d'agrégation, le Reduce.

Ajouter au compte rendu les captures du ResourceManager indiquant la fin des jobs avec `map 100%` et `reduce 100%`, ainsi que les fichiers de résultats du dossier `results/`.
