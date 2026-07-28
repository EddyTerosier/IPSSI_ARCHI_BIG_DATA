# TP Hadoop MapReduce — Purchases et Access Log

Projet prêt à utiliser pour le devoir **Ex2 — Job MapReduce**.

Il contient :

- un cluster Docker Hadoop HDFS + YARN ;
- les mappers et reducers Python ;
- les scripts de chargement dans HDFS ;
- les jobs demandés sur `purchases.gz` et `access_log.gz` ;
- une version corrigée du notebook ;
- les résultats attendus ;
- un compte rendu à compléter avec des captures d'écran.

## Prérequis

- Docker Desktop démarré ;
- Docker Compose v2 ;
- au moins 4 Go de mémoire attribués à Docker ;
- Bash, disponible par défaut dans le Terminal de macOS.

## Lancement complet

Depuis la racine du projet :

```bash
chmod +x scripts/*.sh container-scripts/*.sh jobs/*/*/*.py
./scripts/06-run-all.sh
```

Cette commande :

1. démarre Hadoop et YARN ;
2. décompresse les fichiers en flux et les charge dans HDFS ;
3. vérifie leur présence et affiche leurs premières lignes ;
4. exécute tous les jobs MapReduce ;
5. exporte les résultats dans le dossier `results/`.

Les traitements portent sur environ 700 Mio de données décompressées. Leur durée dépend des ressources attribuées à Docker.

## Lancement étape par étape

```bash
./scripts/01-start-cluster.sh
./scripts/02-load-data.sh
./scripts/03-check-data.sh
./scripts/04-run-purchases.sh
./scripts/05-run-access-log.sh
```

Interfaces Web :

- NameNode : `http://localhost:9870`
- ResourceManager YARN : `http://localhost:8088`
- NodeManager : `http://localhost:8042`
- HistoryServer : `http://localhost:8188`

## Commandes courtes avec `make`

```bash
make start
make load
make check
make purchases
make access
```

Pour tout lancer :

```bash
make all
```

## Tests sans Hadoop

Les mappers et reducers peuvent être testés localement sur de petits échantillons :

```bash
make test
```

Ce test ne nécessite pas Docker. Il vérifie les scripts Python avec le pipeline :

```text
mapper.py | sort | reducer.py
```

## Résultats générés

```text
results/purchases_sales_by_store.tsv
results/purchases_sales_by_product.tsv
results/purchases_max_by_store.tsv
results/purchases_global_stats.tsv
results/purchases_daily_average.tsv
results/access_clicks_by_page.tsv
results/access_clicks_by_ip.tsv
results/access_most_visited_page.tsv
```

Les réponses de contrôle sont indiquées dans :

```text
results/RESULTATS_ATTENDUS.md
```

## Arrêter ou réinitialiser

Arrêter les conteneurs en conservant les volumes HDFS :

```bash
./scripts/07-stop-cluster.sh
```

Supprimer les conteneurs, les volumes HDFS et les résultats générés :

```bash
./scripts/08-reset-all.sh
```

## Dépôt GitHub

La version légère destinée à GitHub ne contient pas les deux gros fichiers `.gz`. Ils sont ignorés par `.gitignore`.

Après avoir décompressé la version légère :

```bash
git init
git add .
git commit -m "Ajout du TP Hadoop MapReduce"
git branch -M main
git remote add origin URL_DU_DEPOT
git push -u origin main
```

Pour exécuter le projet après clonage, replacer les deux fichiers dans `data/` :

```text
data/purchases.gz
data/access_log.gz
```

## Structure

```text
tp-mapreduce-github/
├── docker-compose.yml
├── hadoop.env
├── README.md
├── COMPTE_RENDU.md
├── Makefile
├── data/
├── docker/nodemanager/
├── jobs/
│   ├── purchases/
│   └── access_log/
├── scripts/
├── container-scripts/
├── samples/
├── notebooks/
└── results/
```

## État de vérification

Les scripts Python ont été compilés et testés localement sur les échantillons fournis. Les résultats attendus ont été recalculés sur l'intégralité des deux fichiers. Le cluster Docker doit encore être exécuté sur une machine disposant de Docker Desktop afin de produire les captures demandées.
