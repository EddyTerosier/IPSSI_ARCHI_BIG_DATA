# TP2 — CRUD « façon HDFS » sur Garage

> **Adaptation de l'exercice Hadoop.** L'énoncé raisonne en système de fichiers HDFS (`hdfs dfs -mkdir/-put/-ls/-mv/-chmod…`). Garage est un **stockage objet S3, à plat**. On garde les 12 opérations demandées, traduites en sémantique objet, en signalant à chaque fois ce qui est un vrai équivalent et ce qui est une **simulation**.

## Analyse — HDFS est un système de fichiers, Garage un stockage objet

Trois conséquences structurent tout le TP :

- **Un « répertoire » = un préfixe de clé.** `exercices/mon_fichier` : le « dossier » `exercices/` n'existe que parce qu'une clé le mentionne. Rien à « créer » ni à « supprimer » en tant que tel.
- **`mv` n'existe pas nativement** : côté objet, un déplacement = **copie + suppression**. Les clients S3 l'emballent dans une commande `mv`, mais ce sont bien deux opérations.
- **Pas de `chmod` POSIX.** Les droits ne sont pas portés par l'objet mais par le couple **bucket + clé d'accès** (`garage bucket allow/deny`). C'est le vrai écart de l'opération 9.

## Correspondance des 12 opérations

| # | HDFS | Équivalent Garage / S3 |
|---|------|------------------------|
| 1 | `-mkdir exercices` + `-put` | `garage bucket create tp-crud`, puis `mc cp fichier garage/tp-crud/exercices/` (le préfixe naît du dépôt) |
| 2 | `-ls exercices` | `mc ls garage/tp-crud/exercices/` |
| 3 | `-rm fichier` | `mc rm garage/tp-crud/exercices/fichier` |
| 4 | `-rmdir exercices` | `mc rm --recursive --force garage/tp-crud/exercices/` (on retire le préfixe, pas un « dossier ») |
| 5 | `-put` récursif | `mc cp --recursive data/tree/ garage/tp-crud/tree/` |
| 6 | `-mv` vers `backup` | `mc mv garage/tp-crud/exercices/fichier garage/tp-crud/backup/…` (= copie + suppression) |
| 7 | `-cat` | `mc cat garage/tp-crud/backup/fichier` |
| 8 | répertoires imbriqués | `mc cp x garage/tp-crud/a/b/c/fichier` — les niveaux sont de simples préfixes, aucun `mkdir` réel |
| 9 | `-chmod` | **écart** : `garage bucket allow/deny --read/--write/--owner tp-crud --key <clé>` (droits bucket+clé) |
| 10 | `-du` | `garage bucket info tp-crud` (côté serveur) et `mc du garage/tp-crud` (côté client) |
| 11 | `-rm -r` | `mc rm --recursive --force garage/tp-crud/tree/` |
| 12 | `-get` (export) | `mc cp garage/tp-crud/backup/fichier exported/fichier` |

## Montage

On **réutilise le cluster Garage de l'exercice 1** (le conteneur `garage` doit tourner — sinon `docker compose up -d` dans le dossier de l'ex1). Deux outils :

- le **CLI `garage`** (dans le conteneur) pour l'administration : bucket, clé d'accès, permissions, espace ;
- **`mc`** (MinIO Client) pour le CRUD objet, exécuté **dans un conteneur jetable**, donc aucune install.

### Créer le bucket et la clé d'accès

```bash
export MSYS_NO_PATHCONV=1     # Git Bash : ne pas réécrire les chemins /...

docker exec garage /garage bucket create tp-crud
docker exec garage /garage key create tp-key        # relève "Key ID" et "Secret key"
docker exec garage /garage bucket allow --read --write --owner tp-crud --key tp-key
```

### Configurer `mc`

`mc` tourne dans un conteneur et joint Garage via `host.docker.internal:3900` (l'API S3 publiée par l'ex1). L'alias `garage` est fourni par la variable d'environnement `MC_HOST_garage`, ce qui évite tout fichier de config :

```bash
export KEY_ID=GK...           # le Key ID relevé ci-dessus
export SECRET=...             # le Secret key relevé ci-dessus
HOST_PWD="$(pwd -W)"          # Git Bash : chemin Windows du dossier courant

mc() {
  docker run --rm --entrypoint mc \
    -v "$HOST_PWD:/work" -w /work \
    -e MC_HOST_garage="http://$KEY_ID:$SECRET@host.docker.internal:3900" \
    minio/mc "$@"
}
```

Le dossier courant est monté dans `/work` : c'est le « système de fichiers local » vu par `mc` (les `put`/`get` s'y font).

## Détail des opérations

Les commandes sont dans `crud.sh`. Points à commenter dans le compte-rendu :

- **1–3** : équivalents directs. `mc ls garage/tp-crud/exercices/` liste par préfixe.
- **4** : après l'étape 3, `exercices/` **a déjà disparu** — un préfixe sans objet n'existe pas. La commande récursive reste valide mais sans effet : conséquence directe du modèle objet (pas de dossier vide).
- **5** : copie récursive fidèle ; l'arborescence locale devient un jeu de clés préfixées `tree/…`.
- **6** : `mc mv` = **copie puis suppression** de l'objet source. On recrée d'abord un fichier dans `exercices/` (supprimé en 3) pour avoir une source.
- **7** : `mc cat` lit l'objet vers la sortie standard.
- **8** : les répertoires « imbriqués » `a/b/c/` sont de simples préfixes ; aucun `mkdir -p` n'existe côté objet.
- **9 (écart majeur)** : pas de permission par objet. On agit sur les droits de la **clé** sur le **bucket** : `garage bucket deny --write` retire l'écriture (visible en `R` seul dans `bucket info`), `garage bucket allow --write` la rétablit.
- **10** : `garage bucket info tp-crud` donne la taille et le nombre d'objets **côté serveur** ; `mc du garage/tp-crud` recalcule côté client.
- **11** : suppression récursive du préfixe `tree/`.
- **12** : export inverse (Garage → local), le fichier réapparaît dans `./exported/`.

## Lancer le tout

Le script fait le setup (bucket + clé) puis enchaîne les 12 opérations :

```bash
bash crud.sh
```

Il est **ré-exécutable** : il recrée la clé `tp-key` à chaque lancement (`key delete --yes` puis `key create`) pour repartir propre.

## Compte-rendu — résultats observés

Setup : bucket `tp-crud` créé, clé `tp-key` en droits `RWO`.

| # | Résultat observé |
|---|------------------|
| 1 | `sample.txt` (25 B) copié dans `exercices/` |
| 2 | `ls` affiche `sample.txt` (25 B) |
| 3 | Suppression OK — un `versionId` est renvoyé (le versioning d'objets est actif) |
| 4 | Aucune sortie : le préfixe `exercices/` avait déjà disparu à l'étape 3 (pas de dossier vide en objet) — conforme |
| 5 | Copie récursive de `a.txt`, `sub1/b.txt`, `sub2/c.txt` (30 B) ; `ls --recursive` liste bien les 3 |
| 6 | `mv` = deux transferts visibles (copie vers `backup/` puis suppression de la source) |
| 7 | `cat` renvoie `contenu de demonstration` |
| 8 | `a/b/c/sample.txt` créé — les niveaux ne sont que des préfixes |
| 9 | Droits de la clé : `RWO` → `R O` (écriture retirée) → `RWO`. Démonstration nette du modèle bucket + clé |
| 10 | `bucket info` : 80 B, 5 objets ; `mc du` : `80B 5 objects` (mêmes chiffres serveur/client) |
| 11 | `rm -r tree/` : 3 fichiers supprimés |
| 12 | Export : `./exported/sample.txt` (25 B) présent sur le disque hôte |

**Bilan.** Les 12 opérations HDFS ont toutes un rendu fonctionnel sur Garage. Les seuls vrais écarts avec HDFS sont ceux annoncés : l'opération 4 est un « non-événement » (pas de dossier vide), l'opération 8 n'imbrique rien de réel (des préfixes), et l'opération 9 change les droits d'une **clé sur un bucket** faute de `chmod` par objet.

## Écarts et limites connus (Garage + mc)

- Toutes les commandes ciblent un bucket précis (`garage/tp-crud/…`). Lister les buckets seuls (`mc ls garage/`) peut ne pas être supporté selon la version de Garage.
- Garage impose l'accès **path-style** (pas de vhost) ; `mc` s'y conforme par défaut via l'endpoint fourni.
- `host.docker.internal` est fourni automatiquement par Docker Desktop. Sous Linux natif, ajouter `--add-host=host.docker.internal:host-gateway` au `docker run`.