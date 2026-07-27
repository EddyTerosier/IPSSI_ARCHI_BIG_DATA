# TP — Cluster SingleNode & SPOF (avec Garage)

> **Adaptation de l'exercice Hadoop.** L'énoncé original démontre le SPOF du **NameNode** dans l'architecture maître/esclave de HDFS. Garage a une architecture **décentralisée, sans nœud maître** : il n'y a pas de NameNode/DataNode, tous les nœuds sont égaux. On garde donc le fil rouge (déployer → vérifier → provoquer une panne → conclure), mais la conclusion sur le SPOF est différente — voir la fin.

## Prérequis

- Docker Desktop (WSL2), et un shell Bash (Git Bash convient).

> **Windows / Git Bash :** Git Bash réécrit les chemins commençant par `/`, ce qui casse les `docker compose exec garage /garage ...` (`/garage` devient `C:/Program Files/Git/garage`). Lance une fois par session :
>
> ```bash
> export MSYS_NO_PATHCONV=1
> ```
>
> ou préfixe le chemin d'un double slash : `//garage`.

## Architecture déployée

Un seul nœud Garage (`replication_factor = 1`) + une interface web tierce (`garage-webui`).

| Service        | Port hôte | Rôle                                                        |
|----------------|-----------|-------------------------------------------------------------|
| `garage`       | 3900      | API S3                                                       |
| `garage`       | 3903      | API admin (health / metrics)                                |
| `garage-webui` | 3909      | **Interface web** — l'équivalent de la page NameNode `:9870`|

---

## Q1 — Lancer le cluster

```bash
# 1. Démarrer les conteneurs (garage.toml est déjà fourni, prêt à l'emploi)
docker compose up -d

# 2. Récupérer l'ID du nœud : il apparaît avec la mention "NO ROLE ASSIGNED"
docker compose exec garage /garage status

# 3. Attribuer un rôle au nœud (zone dc1, capacité 1G), puis appliquer
docker compose exec garage /garage layout assign -z dc1 -c 1G <NODE_ID>
docker compose exec garage /garage layout apply --version 1
```

> **Étape indispensable :** tant que le layout n'est pas appliqué, le nœud reste en `NO ROLE ASSIGNED` et le stockage est inutilisable. C'est le pendant Garage du « formatage » d'un cluster fraîchement lancé.

**Résultat observé.** Le nœud (`b1b75e197b4cf7f4`) démarre en `NO ROLE ASSIGNED`. Après `layout apply`, il passe en zone `dc1`, capacité `1000 MB`, réparti sur 256 partitions (réplication ×1). Un dernier `garage status` le liste en `HEALTHY NODES` avec ~975 GB d'espace disque disponible.

---

## Q2 — Vérifier la santé du cluster

Deux façons, comme dans l'énoncé (interface web **ET/OU** ligne de commande) :

**Interface web** — ouvrir <http://localhost:3909> (équivalent de la page NameNode). On y voit l'état du cluster, le nœud et son rôle, les buckets et les clés d'accès.

**Ligne de commande** — équivalent de ton `jps -ml` :

```bash
docker compose exec garage /garage status
```

Sortie attendue (nœud sain, rôle attribué) : une ligne listant l'ID du nœud, son adresse, sa **zone** (`dc1`), sa **capacité** (`1G`) et son état `HEALTHY`. S'il apparaît encore en `NO ROLE ASSIGNED`, c'est que l'étape layout de Q1 n'a pas été appliquée.

> L'API admin expose aussi un endpoint de santé sur le port 3903 (route et authentification selon la version — voir la doc de ta version de Garage). Pour ce TP, la webui et `garage status` suffisent.

**Résultat observé.** `garage status` renvoie le nœud en `HEALTHY`. La page <http://localhost:3909> affiche le cluster *healthy* : 1 nœud connecté, stockage actif, 256 partitions (nécessite une image Garage ≥ v2.0.0 pour l'API admin v2 — voir « Note de version »).

---

## Q3 — Arrêter le nœud et observer

Ici l'énoncé Hadoop demandait d'arrêter le NameNode et de regarder le shell du DataNode. En SingleNode il n'y a qu'un nœud : on l'arrête et on observe.

```bash
# Arrêter le nœud Garage (la webui reste en vie, elle, mais n'a plus rien à interroger)
docker compose stop garage

# Tenter une commande d'administration -> échoue (plus de nœud à joindre)
docker compose exec garage /garage status   # le conteneur est arrêté : erreur

# Tenter d'atteindre l'API S3 -> injoignable
curl -i http://localhost:3900   # connexion refusée
```

Et sur <http://localhost:3909>, la webui n'arrive plus à joindre l'API admin : le cluster est signalé indisponible.

```bash
# Relancer pour revenir à l'état sain
docker compose start garage
```

**Résultat observé.** Dès `docker compose stop garage`, tout tombe simultanément : `curl http://localhost:3900` renvoie une connexion refusée, `garage status` échoue (`service "garage" is not running`), et la webui (3909) repasse en `...`. Le service entier est indisponible. `docker compose start garage` restaure l'état sain.

### Conclusion

Avec un déploiement **mono-nœud**, ce nœud est un **SPOF** : sa panne rend l'ensemble du service indisponible. C'est vrai ici, exactement comme pour le NameNode HDFS.

**Mais la cause n'est pas la même**, et c'est le point important :

- Chez **HDFS**, le SPOF est **architectural** : le NameNode est un rôle unique et central. Ajouter des DataNodes n'y change rien — sans NameNode, personne ne sait où sont les blocs. (D'où l'existence, en production, du HA NameNode avec QJM/ZooKeeper.)
- Chez **Garage**, le SPOF n'existe **que parce qu'on n'a lancé qu'un seul nœud**. L'architecture est décentralisée et sans maître : en ajoutant des nœuds avec `replication_factor > 1`, la perte d'un nœud n'interrompt plus le service. Il n'y a aucun rôle central à protéger.

Autrement dit : Hadoop doit **ajouter** un mécanisme (NameNode HA) pour supprimer son SPOF ; Garage n'a **rien à supprimer**, il suffit de passer à plusieurs nœuds.

---

## Note de version

`garage-webui` utilise l'**API admin v2**, introduite à partir de Garage **v2.0.0**. Il faut donc une image Garage **v2.x** (`GARAGE_VERSION` dans `.env`), sinon l'interface reste vide (cartes `...`) car les routes v2 n'existent pas dans les versions antérieures. Le champ `admin_token` de `[admin]` reste valide en v2 : c'est le jeton « maître » que la webui utilise pour interroger l'API. Vérifie les tags disponibles sur Docker Hub (`dxflrs/garage`, `khairul169/garage-webui`) et ajuste `.env` si besoin.