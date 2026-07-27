#!/usr/bin/env bash
# TP2 - CRUD "facon HDFS" sur Garage (stockage objet S3), via le client mc.
# Prerequis : le conteneur "garage" de l'exercice 1 tourne (verifier avec 'docker ps').

export MSYS_NO_PATHCONV=1          # Git Bash : ne pas reecrire les chemins commencant par /

BUCKET="tp-crud"
KEY="tp-key"

# Chemin Windows du dossier courant, pour le montage Docker sous Git Bash.
HOST_PWD="$(pwd -W 2>/dev/null || pwd)"

# garage = CLI d'administration, executee DANS le conteneur de l'ex1.
garage() { docker exec garage /garage "$@"; }

# mc = client S3 jetable ; l'alias "garage" est fourni par la variable MC_HOST_garage.
mc() {
  docker run --rm --entrypoint mc \
    -v "$HOST_PWD:/work" -w /work \
    -e MC_HOST_garage="http://$KEY_ID:$SECRET@host.docker.internal:3900" \
    minio/mc "$@"
}

section() { echo; echo "==================== $* ===================="; }

# --- Setup : bucket + cle d'acces (repart propre a chaque execution) ---
section "SETUP : bucket + cle d'acces"
garage bucket create "$BUCKET" 2>/dev/null || true
garage key delete --yes "$KEY" 2>/dev/null || true
info="$(garage key create "$KEY" 2>/dev/null)"
KEY_ID="$(echo "$info" | awk '/Key ID:/{print $NF}')"
SECRET="$(echo "$info" | awk '/Secret key:/{print $NF}')"
garage bucket allow --read --write --owner "$BUCKET" --key "$KEY"

if [ -z "$KEY_ID" ] || [ -z "$SECRET" ]; then
  echo "Echec : cle d'acces introuvable. Le conteneur 'garage' tourne-t-il (docker ps) ?"
  exit 1
fi
echo "Cle d'acces prete : $KEY_ID"

# --- Donnees locales de demonstration ---
mkdir -p data/tree/sub1 data/tree/sub2
echo "contenu de demonstration" > data/sample.txt
echo "fichier a" > data/tree/a.txt
echo "fichier b" > data/tree/sub1/b.txt
echo "fichier c" > data/tree/sub2/c.txt

# 1. Creer un "repertoire" exercices + y copier un fichier
section "1. mkdir exercices + copie d'un fichier"
mc cp data/sample.txt "garage/$BUCKET/exercices/"

# 2. Lister le contenu de exercices
section "2. ls exercices"
mc ls "garage/$BUCKET/exercices/"

# 3. Supprimer le fichier copie
section "3. rm du fichier"
mc rm "garage/$BUCKET/exercices/sample.txt"

# 4. Supprimer le "repertoire" exercices (prefixe deja vide apres l'etape 3)
section "4. rm -r exercices"
mc rm --recursive --force "garage/$BUCKET/exercices/" 2>/dev/null || true

# 5. Copie recursive d'une arborescence locale
section "5. copie recursive d'une arborescence"
mc cp --recursive data/tree/ "garage/$BUCKET/tree/"
mc ls --recursive "garage/$BUCKET/tree/"

# 6. Deplacer un fichier vers backup (mv = copie + suppression cote objet)
section "6. mv vers backup"
mc cp data/sample.txt "garage/$BUCKET/exercices/"      # on remet une source, supprimee en #3
mc mv "garage/$BUCKET/exercices/sample.txt" "garage/$BUCKET/backup/sample.txt"
mc ls "garage/$BUCKET/backup/"

# 7. Lire le contenu d'un fichier
section "7. cat d'un fichier"
mc cat "garage/$BUCKET/backup/sample.txt"

# 8. Repertoires imbriques (simples prefixes)
section "8. repertoires imbriques"
mc cp data/sample.txt "garage/$BUCKET/a/b/c/sample.txt"
mc ls --recursive "garage/$BUCKET/a/"

# 9. Permissions : modele bucket + cle (pas de chmod objet)
section "9. permissions : deny puis allow --write"
garage bucket deny --write "$BUCKET" --key "$KEY"
garage bucket info "$BUCKET"
garage bucket allow --write "$BUCKET" --key "$KEY"

# 10. Espace utilise
section "10. espace utilise"
garage bucket info "$BUCKET"
mc du "garage/$BUCKET"

# 11. Suppression recursive
section "11. rm -r d'une arborescence"
mc rm --recursive --force "garage/$BUCKET/tree/"

# 12. Export vers le systeme de fichiers local
section "12. export vers le local"
mkdir -p exported
mc cp "garage/$BUCKET/backup/sample.txt" exported/sample.txt
echo "Exporte -> ./exported/sample.txt"
ls -l exported/

echo
echo "Termine."