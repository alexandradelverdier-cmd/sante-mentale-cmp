# Accès aux CMP et suivi psychiatrique à domicile en France

Infirmière en psychiatrie, en centre hospitalier, j'ai vu des lits rester occupés faute de relais à la sortie, et des patients revenir quelques semaines plus tard parce que le suivi extérieur n'avait pas pu se mettre en place. Ce projet confronte ce constat de terrain aux données nationales.

**Question** : les départements qui suivent davantage leurs patients en ambulatoire et à domicile ont-ils des lits de psychiatrie moins saturés et moins recours aux soins sans consentement ?

## Résultats (psychiatrie de l'adulte, 2025)

### 1. Les consultations existent partout

![Consultations en CMP et en unités de consultation pour 1 000 adultes](visuels/carte_consultations.png)

- 88 % de l'activité ambulatoire passe par les CMP et les unités de consultation
- De 68 à 467 actes pour 1 000 adultes selon le département
- Lien faible avec la saturation des lits : 86,3 % d'occupation dans le quart des départements qui consultent le moins, 82,5 % dans celui qui consulte le plus

### 2. Le suivi à domicile manque

![Actes des équipes de psychiatrie au domicile pour 1 000 adultes](visuels/carte_soins_domicile.png)

- Seulement 12 % de l'activité ambulatoire se fait au domicile des patients
- De 1 à 109 actes pour 1 000 adultes selon le département
- Paris consulte beaucoup (359 actes pour 1 000 adultes) mais va peu à domicile (25)

### 3. C'est le domicile qui va avec des lits moins saturés

| Départements classés par actes à domicile pour 1 000 adultes | Taux d'occupation des lits | Journées en soins sans consentement |
|---|---|---|
| Quart le plus faible | 87,2 % | 22,1 % |
| Quart le plus élevé | 80,8 % | 18,7 % |

### Autres constats

- Les psychologues en psychiatrie (établissements de santé) varient de 2 à 17 ETP pour 100 000 adultes
- 8 départements dépassent 95 % d'occupation de leurs lits à temps plein

Ce sont des corrélations entre territoires, pas une relation de cause à effet.

## Architecture

```
sources (SAE 2025, DREES) + seeds (Insee 2023)
        │
   staging        typage, renommage, une vue par fichier source
        │
 intermediate     psychiatrie de l'adulte par établissement, population adulte par département
        │
     marts        mart_psy_ambulatoire__departements
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

## Limites

- La SAE ne sépare pas le personnel du CMP de celui de l'hospitalisation : les ETP couvrent toute la psychiatrie de l'établissement.
- Il n'existe pas de données nationales ouvertes sur les délais d'attente en CMP.
- Les patients peuvent être soignés hors de leur département, ce qui influence les ratios, surtout en Île-de-France.
- Les modes légaux de soins (bordereau PSY2) ne sont pas ventilés entre adultes et enfants.

## Sources

- DREES, Statistique annuelle des établissements de santé (SAE) 2025, bases statistiques
- Insee, estimations de population au 1er janvier 2023 par département

## Stack

BigQuery · dbt Core · SQL
