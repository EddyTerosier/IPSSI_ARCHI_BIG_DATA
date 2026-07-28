# Résultats attendus sur les fichiers fournis

Ces valeurs ont été recalculées directement à partir des deux fichiers `.gz` fournis.
Elles permettent de vérifier que les jobs MapReduce retournent le bon résultat.

## 1. `purchases.gz`

### Contrôle du fichier

- Nombre de transactions : **4 138 476**
- Taille décompressée : **211 312 924 octets**, soit environ **201,5 Mio**
- Nombre de jours : **365**

### Ventes

| Question | Résultat |
|---|---:|
| Chiffre d'affaires du magasin Buffalo | **10 001 941,19** |
| Ventes de la catégorie Toys | **57 463 477,11** |
| Ventes de la catégorie Consumer Electronics | **57 452 374,13** |
| Achat le plus cher à Reno | **499,99** |
| Achat le plus cher à Toledo | **499,98** |
| Achat le plus cher à Chandler | **499,98** |
| Nombre total de transactions | **4 138 476** |
| Chiffre d'affaires total | **1 034 457 953,26** |
| Montant moyen par transaction | **249,96** |
| Chiffre d'affaires moyen par jour | **2 834 131,38** |

Les listes complètes par magasin et par produit sont générées dans :

```text
results/purchases_sales_by_store.tsv
results/purchases_sales_by_product.tsv
results/purchases_max_by_store.tsv
```

## 2. `access_log.gz`

### Contrôle du fichier

- Nombre total de lignes : **4 477 843**
- Lignes reconnues par le parseur Apache : **4 477 806**
- Lignes atypiques ignorées : **37**
- Taille décompressée : **504 941 532 octets**, soit environ **481,5 Mio**

### Clics et visites

| Question | Résultat |
|---|---:|
| Hits de `/assets/js/the-associates.js` | **2 456** |
| Requêtes de l'adresse `10.99.99.186` | **6** |
| Page la plus visitée | **`/assets/css/combined.css`** |
| Nombre de visites correspondant | **117 348** |

Les listes complètes sont générées dans :

```text
results/access_clicks_by_page.tsv
results/access_clicks_by_ip.tsv
results/access_most_visited_page.tsv
```
