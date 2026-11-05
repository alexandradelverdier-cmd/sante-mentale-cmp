# Accès aux CMP et suivi psychiatrique à domicile en France

Infirmière en psychiatrie, en centre hospitalier, j'ai vu des lits rester occupés faute de relais à la sortie, et des patients revenir quelques semaines plus tard parce que le suivi extérieur n'avait pas pu se mettre en place. Ce projet confronte ce constat de terrain aux données nationales.

**Question** : comment la psychiatrie soigne-t-elle en dehors des murs de l'hôpital, et les départements qui suivent davantage leurs patients en ambulatoire et à domicile ont-ils des lits moins saturés ?

## Résultats (psychiatrie de l'adulte, 2025)

### 1. Les consultations existent partout

![Consultations en CMP et en unités de consultation pour 1 000 adultes](visuels/carte_consultations.png)

- 88 % de l'activité ambulatoire passe par les CMP et les unités de consultation
- De 68 à 467 actes pour 1 000 adultes selon le département, soit un écart d'environ 7 fois

### 2. Le suivi à domicile est le maillon le plus faible

![Actes des équipes de psychiatrie au domicile pour 1 000 adultes](visuels/carte_soins_domicile.png)

- Seulement 12 % de l'activité ambulatoire se fait au domicile des patients
- De 1 à 109 actes pour 1 000 adultes selon le département
- Consulter beaucoup ne veut pas dire aller chez les patients : Paris réalise 359 actes de consultation pour 1 000 adultes, mais 25 à domicile

### 3. L'hypothèse de départ n'est pas confirmée à l'échelle du département

Je m'attendais à ce que les départements qui suivent davantage leurs patients à domicile aient des lits moins saturés. Les données ne le montrent pas de façon fiable :

| Lien testé (96 départements de métropole) | Corrélation de Spearman | p-value | Fiable au seuil de 5 % |
|---|---|---|---|
| Domicile et occupation des lits | -0,16 | 0,11 | Non |
| Domicile et part de soins sans consentement | -0,04 | 0,69 | Non |
| Consultations et occupation des lits | -0,11 | 0,31 | Non |

Ça ne contredit pas l'expérience de terrain : la maille départementale est trop grossière. Pour mesurer l'effet du suivi à la sortie, il faudrait suivre les parcours des patients, et ces données ne sont pas ouvertes.

### 4. Quand les lits manquent, ce sont les soins libres qui reculent

| Départements classés par lits pour 100 000 adultes | Lits | Journées sans consentement pour 1 000 adultes | Journées en soins libres pour 1 000 adultes | Part sans consentement |
|---|---|---|---|---|
| Quart avec le moins de lits | 63 | 58 | 165 | 26 % |
| Quart avec le plus de lits | 130 | 68 | 364 | 16 % |

- Les journées en soins libres suivent très fortement le nombre de lits (corrélation 0,83, p < 0,001)
- Les journées sans consentement varient peu (corrélation 0,21, p = 0,04)
- La part de contrainte est donc plus élevée là où les lits manquent (-0,45, p < 0,001), mais ce n'est pas la contrainte qui augmente : c'est l'accès à l'hospitalisation libre qui se réduit

Les patients qui pourraient être hospitalisés librement mais ne trouvent pas de lit sont précisément ceux pour qui le suivi en consultation et à domicile compte le plus.

Les deux liens forts (soins libres et part de contrainte) tiennent quand on retire l'Île-de-France ; le lien faible sur le volume de soins sans consentement, lui, n'est plus significatif (détail dans `analysis/resultats/correlations.csv`). Ce sont des corrélations entre territoires, pas des relations de cause à effet.

## Architecture

```
sources (SAE 2025, DREES) + seeds (Insee 2023)
        │
   staging        typage, renommage, une vue par fichier source
        │
 intermediate     psychiatrie de l'adulte par établissement, population adulte par département
        │
     marts        mart_psy_ambulatoire__departements
        │
   analysis       corrélations de Spearman et cartes (Python, lecture du mart dans BigQuery)
```

| Modèle | Grain |
|---|---|
| `stg_sae__etablissements` | un établissement |
| `stg_sae__psy_activite` | un établissement x une discipline de psychiatrie |
| `stg_sae__psy_modes_legaux` | un établissement |
| `stg_insee__population` | un département x une classe d'âge |
| `int_psy_adulte__etablissements` | un établissement ayant une activité de psychiatrie de l'adulte |
| `int_population_adulte__departements` | un département |
| `mart_psy_ambulatoire__departements` | un département |

25 tests dbt (unicité des grains, clés, valeurs acceptées, proportions entre 0 et 1).

## Choix de modélisation

- **Discipline GEN plutôt que TOT** : la SAE fournit un total déjà calculé ; on part du détail adulte pour éviter les doubles comptes.
- **Localisation par `DEP_DIFF`** : quand une entité juridique répond pour plusieurs sites, l'activité est rattachée au département où elle a réellement lieu.
- **CMP et unités de consultation regroupés** : certains hôpitaux, surtout les CHU, déclarent une grande part de leur activité en unités de consultation plutôt qu'en CMP (46 % dans l'Hérault). Les séparer créerait un artefact de déclaration.
- **Données brutes chargées en texte**, typées dans le staging : les codes FINESS commencent par un zéro qui disparaîtrait avec une détection automatique des types.

- **Corrélation de Spearman** : basée sur les rangs, elle résiste aux valeurs extrêmes et ne suppose pas de relation linéaire entre des départements très hétérogènes.
- **Volumes et parts** : une part de soins sans consentement peut varier parce que les soins libres changent. Les deux sont calculés pour ne pas confondre les effets.

## Limites

- La SAE ne sépare pas le personnel du CMP de celui de l'hospitalisation : les ETP couvrent toute la psychiatrie de l'établissement.
- Il n'existe pas de données nationales ouvertes sur les délais d'attente en CMP.
- Les patients peuvent être soignés hors de leur département, ce qui influence les ratios, surtout en Île-de-France.
- Les modes légaux de soins (bordereau PSY2) ne sont pas ventilés entre adultes et enfants.
- Quelques valeurs sont à interpréter avec prudence, par exemple le Territoire de Belfort, qui déclare 0,1 % de soins sans consentement.
- La population de référence est celle de 2023, dernière estimation par classe d'âge disponible.

## Sources

- DREES, Statistique annuelle des établissements de santé (SAE) 2025, bases statistiques
- Insee, estimations de population au 1er janvier 2023 par département

## Stack

BigQuery · dbt Core · SQL · Python (pandas, SciPy, GeoPandas, Matplotlib)
