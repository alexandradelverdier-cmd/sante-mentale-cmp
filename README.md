# Accès aux CMP et suivi psychiatrique à domicile en France

J'ai été infirmière en psychiatrie pendant plusieurs années. J'y ai vu des lits rester occupés faute de relais à la sortie, et des patients revenir quelques mois plus tard parce que le suivi à l'extérieur n'avait pas pu se mettre en place.

Ces situations m'ont laissé des questions. Aujourd'hui data engineer, j'ai voulu les creuser avec les données nationales : ce projet construit un pipeline sur trois années de la Statistique annuelle des établissements de santé (DREES, 2023 à 2025) pour voir ce que les chiffres disent de la psychiatrie en dehors de l'hôpital.

**Question** : comment la psychiatrie soigne-t-elle les patients en dehors de l'hôpital, et les départements qui suivent davantage leurs patients à domicile ont-ils des lits d'hôpital moins saturés ?

## Quelques repères

- **CMP** (centre médico-psychologique) : lieu de consultation public et gratuit, rattaché à un hôpital. C'est la porte d'entrée du suivi psychiatrique en dehors de l'hôpital.
- **Unité de consultation** : consultations de psychiatrie organisées directement à l'hôpital, plutôt qu'en CMP.
- **Acte** : un rendez-vous ou une intervention d'un soignant auprès d'un patient (consultation avec un psychiatre, entretien infirmier, visite à domicile). Un patient suivi régulièrement compte plusieurs actes dans l'année.
- **Lieux de vie intermédiaires** : des étapes entre l'hôpital et la vie autonome. En placement familial thérapeutique, le patient vit dans une famille d'accueil accompagnée par l'équipe soignante ; en appartement thérapeutique, il vit dans un logement avec des visites régulières des soignants.
- **ETP** (équivalent temps plein) : deux infirmiers à mi-temps font un ETP.

## Résultats (psychiatrie de l'adulte)

### 1. Les consultations existent partout (2025)

![Consultations en CMP et en unités de consultation pour 1 000 adultes](visuels/carte_consultations.png)

- 88 % des soins hors hospitalisation se font en consultation, en CMP ou à l'hôpital
- Selon le département, on compte de 68 à 467 consultations et entretiens pour 1 000 adultes dans l'année, soit un écart d'environ 1 à 7

### 2. Le suivi à domicile est le maillon le plus faible (2025)

![Soins des équipes de psychiatrie au domicile des patients pour 1 000 adultes](visuels/carte_soins_domicile.png)

- Seulement 12 % des soins hors hospitalisation ont lieu au domicile des patients
- Selon le département, on compte de 1 à 109 visites et soins à domicile pour 1 000 adultes : l'écart est bien plus fort que pour les consultations
- Consulter beaucoup ne veut pas dire aller chez les patients : Paris compte 359 consultations pour 1 000 adultes, mais seulement 25 soins à domicile

### 3. L'hypothèse de départ n'est pas confirmée à l'échelle du département

Je m'attendais à ce que les départements qui vont davantage chez leurs patients aient des lits d'hôpital moins saturés. Les données ne le montrent pas de façon fiable, ni en comparant les départements entre eux, ni en suivant l'évolution de chaque département entre 2023 et 2025 :

| Lien testé (96 départements de métropole) | En comparant les départements (2025) | En suivant chaque département dans le temps (2023-2025) |
|---|---|---|
| Soins à domicile et occupation des lits | -0,16 (p = 0,11) | +0,17 (p = 0,11) |
| Soins à domicile et part de soins sans consentement | -0,04 (p = 0,68) | |
| Soins à domicile et durée des hospitalisations | | 0,00 (p = 0,97) |
| Consultations et occupation des lits | -0,11 (p = 0,31) | +0,14 (p = 0,18) |

Corrélations de Spearman. Aucun de ces liens n'est significatif au seuil de 5 %.

Ça ne contredit pas l'expérience de terrain. L'échelle du département est trop large : pour mesurer l'effet du suivi après une sortie d'hôpital, il faudrait suivre le parcours de chaque patient, et ces données ne sont pas ouvertes.

### 4. Quand les lits manquent, ce sont les hospitalisations librement acceptées qui reculent (2025)

| Départements classés selon leur nombre de lits | Lits pour 100 000 adultes | Jours d'hospitalisation sans consentement pour 1 000 adultes | Jours d'hospitalisation en soins libres pour 1 000 adultes | Part des jours sans consentement |
|---|---|---|---|---|
| Le quart avec le moins de lits | 63 | 58 | 165 | 26 % |
| Le quart avec le plus de lits | 130 | 67 | 362 | 16 % |

- Les hospitalisations en soins libres suivent de très près le nombre de lits (corrélation 0,83, p < 0,001)
- Les hospitalisations sans consentement, elles, varient peu d'un département à l'autre (corrélation 0,20, p = 0,047)
- Là où les lits manquent, la part des soins sans consentement est donc plus élevée (-0,44, p < 0,001). Mais ce n'est pas la contrainte qui augmente : ces patients doivent de toute façon être hospitalisés. C'est l'accès à l'hospitalisation librement acceptée qui se réduit

Le résultat se confirme dans le temps : entre 2023 et 2025, **les départements qui ont perdu des lits ont aussi perdu des journées d'hospitalisation en soins libres** (corrélation 0,33, p = 0,001). Comme chaque département est comparé à lui-même, ce lien ne peut pas s'expliquer par ce qui ne change pas d'une année à l'autre, comme sa géographie ou le profil de sa population.

Les patients qui auraient accepté d'être hospitalisés mais ne trouvent pas de lit sont précisément ceux pour qui le suivi en consultation et à domicile compte le plus.

Les deux liens forts tiennent quand on retire l'Île-de-France de l'analyse. Le lien faible sur les hospitalisations sans consentement, lui, n'est plus fiable (détail dans `analysis/resultats/`).

### 5. Entre 2023 et 2025 : plus de patients, moins de lits et de lieux de vie

![Évolution 2023-2025 de la psychiatrie de l'adulte](visuels/evolution_2023_2025.png)

- Le nombre de patients suivis augmente de 5,8 %, les soins à domicile de 4,1 % et les consultations de 3,6 %
- Les lits d'hospitalisation complète reculent de 2,7 % et les infirmiers de 2,3 % : chaque soignant suit en moyenne 8 % de patients en plus
- Les places en lieux de vie intermédiaires (placement familial et appartements thérapeutiques) reculent de 9,6 %, alors que ce sont elles qui permettent de quitter l'hôpital sans revenir directement seul chez soi
- Les écarts entre départements pour les soins à domicile ne se réduisent pas : chaque année, les départements les mieux dotés font environ 8 fois plus de soins à domicile que les moins dotés (comparaison entre le 10e et le 90e centile)

Pour les soins à domicile, la hausse est calculée à périmètre constant, c'est-à-dire en comparant les mêmes établissements d'une année à l'autre. Ceux dont la façon de compter a changé en 2024 sont retirés (voir les choix de modélisation).

## Ce que racontent ces résultats

### Le constat de terrain

En psychiatrie, l'hospitalisation complète a une fin, et c'est normal dans le parcours du patient. Mais quand elle s'arrête, une fragilité reste souvent présente. Le patient n'a plus sa place dans un lit, qui est rare, et il a encore besoin d'être accompagné. Si personne ne prend le relais à la sortie, la sortie ne tient pas : on revoit les mêmes patients tous les 3 à 6 mois. C'est ce qu'on appelle la « porte tournante ».

### Ce que les données confirment

**La porte d'entrée s'élargit, la porte de sortie se rétrécit.** Entre 2023 et 2025, la psychiatrie prend en charge 5,8 % de patients en plus, surtout en consultation. Mais ce qui permet de réussir une sortie recule :

| 2023 à 2025, France métropolitaine | Hôpitaux publics | Privé non lucratif | Cliniques privées commerciales |
|---|---|---|---|
| Lits d'hospitalisation complète | -3,8 % | -4,6 % | stable |
| Patients suivis | +5,5 % | -0,9 % | +21 % |
| Infirmiers (ETP) | -2,3 % | -3,5 % | stable |
| Places en lieux de vie intermédiaires | -9,8 % | -8,0 % | aucune |

- Toute la baisse des lits vient de la psychiatrie de secteur, publique et privée non lucrative, qui accueille pourtant l'essentiel des nouveaux patients
- Les lieux de vie intermédiaires, qui servent de transition entre l'hôpital et le domicile, n'existent que dans ce secteur, et ils reculent
- Chaque soignant suit 8 % de patients en plus

Ces évolutions prolongent une tendance longue. Selon la DREES, la psychiatrie de l'adulte a perdu 7 400 lits depuis 2013 : 8 400 en moins dans le public, 2 100 en plus dans les cliniques commerciales. Sur la même période, les places alternatives à l'hospitalisation pour adultes ont reculé de 10,4 %. Selon une enquête de la Fédération hospitalière de France, fin 2022, un quart des hôpitaux publics de psychiatrie avaient fermé entre 10 % et 30 % de leurs lits, faute de médecins et de soignants.

### Ce que les données ne permettent pas de trancher

- **Le recul des lieux de vie intermédiaires** peut traduire une vraie disparition de ces places, ou leur transfert vers le secteur médico-social et le logement accompagné (comme le dispositif « Un chez-soi d'abord »), qui n'est pas compté dans la SAE
- **Les réhospitalisations ne sont pas mesurées.** La SAE compte des lits, des soins et des patients, mais pas les allers-retours d'un même patient entre l'hôpital et chez lui. Mesurer la porte tournante demanderait les données de parcours de soins (RIM-P, SNDS), dont l'accès est très encadré
- **Les délais d'attente pour un premier rendez-vous en CMP ne sont publiés nulle part** au niveau national

Autrement dit, les données publiques décrivent l'offre de soins, mais pas ce qui arrive aux patients entre deux hospitalisations. C'est pourtant là que se joue la sortie.

## Architecture

Cette partie et les suivantes s'adressent aux lecteurs techniques. Elles décrivent comment les données sont transformées, de leur téléchargement jusqu'aux résultats.

```
archives DREES (SAE 2023, 2024, 2025) + fichier Insee
        │
 scripts/preparer_donnees_brutes.py   extraction, harmonisation des colonnes et de l'encodage, empilement des années
        │
   sources + seeds    chargés dans BigQuery, toutes colonnes en texte
        │
   staging            typage, renommage, une vue par fichier source
        │
 intermediate         psychiatrie de l'adulte par établissement, contrôle de cohérence, population par département
        │
     marts            mart_psy_ambulatoire__departements
        │
   analysis           corrélations, évolutions et visuels (Python, lecture du mart dans BigQuery)
```

| Modèle | Grain (ce que représente une ligne) |
|---|---|
| `stg_sae__etablissements` | un établissement x une année |
| `stg_sae__psy_activite` | un établissement x une discipline de psychiatrie x une année |
| `stg_sae__psy_modes_legaux` | un établissement x une année |
| `stg_insee__population` | un département x une classe d'âge x une année |
| `int_psy_adulte__etablissements` | un établissement ayant une activité de psychiatrie de l'adulte x une année |
| `int_population_adulte__departements` | un département x une année de la SAE |
| `mart_psy_ambulatoire__departements` | un département x une année |

25 tests dbt : grain de chaque modèle, clés non nulles, valeurs acceptées, proportions entre 0 et 1, population disponible pour chaque année, et une surveillance de la qualité des déclarations.

## Choix de modélisation

- **Discipline GEN plutôt que TOT** : la SAE fournit un total déjà calculé ; on part du détail adulte pour éviter les doubles comptes.
- **Localisation par `DEP_DIFF`** : quand une entité juridique répond pour plusieurs sites, l'activité est rattachée au département où elle a réellement lieu.
- **CMP et unités de consultation regroupés** : certains hôpitaux, surtout les CHU, déclarent une grande part de leurs consultations en unités de consultation plutôt qu'en CMP (46 % dans l'Hérault). Les séparer ferait apparaître de faux déserts, qui viendraient seulement de la façon de déclarer.
- **Contrôle de cohérence entre bordereaux** : les journées ventilées par mode légal (PSY2) doivent correspondre aux journées d'hospitalisation déclarées dans PSY. Quand l'écart dépasse un facteur 2, les modes légaux de l'établissement sont écartés. Sans ce contrôle, le CHU de Grenoble, qui déclare 586 847 journées dans PSY2 en 2024 contre environ 9 500 dans PSY, fausserait à lui seul la tendance nationale. Entre 20 et 29 établissements sont écartés chaque année, soit 1,5 à 1,6 % des journées d'hospitalisation adulte : certains n'ont pas rempli PSY2, d'autres y déclarent des chiffres incohérents.
- **Rupture de série sur le domicile en 2024** : avec la réforme des autorisations d'activité de soins, l'hospitalisation à domicile (HAD) psychiatrique n'est plus comptée comme une hospitalisation mais comme des soins à domicile. Les 15 établissements qui avaient une HAD en 2023 voient leurs soins à domicile augmenter de 25 % entre 2023 et 2025, contre 4 % pour les autres. Le modèle repère ces établissements (`concerne_reforme_had`) et le mart fournit une série à périmètre constant (`actes_domicile_perimetre_constant`), utilisée pour toutes les comparaisons entre années. Sans cette correction, la hausse des soins à domicile serait de 5,5 % au lieu de 4,1 %.
- **Années empilées dès les données brutes** : les noms de colonnes (minuscules en 2023 et 2024, majuscules en 2025) et l'encodage (Latin-1 puis UTF-8) changent selon les millésimes. Le script de préparation les harmonise ; toutes les transformations métier restent dans dbt.
- **Données brutes chargées en texte**, typées dans le staging : les codes FINESS, qui identifient les établissements, commencent par un zéro qui disparaîtrait avec une détection automatique des types.
- **Population par année** : chaque année de la SAE prend la dernière estimation Insee disponible ; ajouter une nouvelle estimation ne demande aucun changement de code.
- **Corrélation de Spearman** : basée sur les classements, elle résiste aux valeurs extrêmes et ne suppose pas de relation linéaire entre des départements très différents.
- **Une année à la fois pour les comparaisons entre départements** : empiler les trois années compterait chaque département trois fois et rendrait les liens artificiellement fiables. Les évolutions sont testées sur les variations 2023-2025, une observation par département.
- **Volumes et parts** : une part de soins sans consentement peut varier simplement parce que les soins libres changent. Les deux sont calculés pour ne pas confondre les effets.

## Limites

- La SAE ne sépare pas le personnel des CMP de celui de l'hospitalisation : les ETP couvrent toute la psychiatrie de l'établissement.
- Il n'existe pas de données nationales ouvertes sur les délais d'attente en CMP.
- Les patients peuvent être soignés hors de leur département, ce qui influence les ratios, surtout en Île-de-France.
- Les données sur les soins sans consentement (bordereau PSY2) ne distinguent pas les adultes et les enfants.
- La population de référence est celle de 2023 pour les trois années, dernière estimation par classe d'âge disponible dans le fichier utilisé. La population évolue peu sur la période, mais les taux pour 1 000 adultes de 2024 et 2025 sont légèrement surestimés.
- En 2023, la SAE ne renseigne pas l'isolement ni les équipes mobiles pour personnes âgées.
- Les soins à domicile de 2025 (carte et chiffres de l'année) incluent l'ancienne HAD psychiatrique de 14 établissements. Les comparaisons entre années utilisent la série à périmètre constant.
- Quelques valeurs sont à interpréter avec prudence, par exemple le Territoire de Belfort, qui déclare 0,1 % de soins sans consentement en 2025.

## Sources

- DREES, Statistique annuelle des établissements de santé (SAE) 2023, 2024 et 2025, bases statistiques
- Insee, estimations de population au 1er janvier par département, sexe et grande classe d'âge
- DREES, [Les établissements de santé, édition 2026, fiche 11 : l'offre de soins de psychiatrie](https://drees.solidarites-sante.gouv.fr/sites/default/files/2026-07/ES%202026%20-%20Fiche%2011%20-%20L%27offre%20de%20soins%20de%20psychiatrie%20dans%20les%20%C3%A9tablissements%20de%20sant%C3%A9.pdf)
- Fédération hospitalière de France, [enquête psychiatrie 2023](https://fhf.fr/sites/default/files/2023-09/Enqu%C3%AAte%20psychiatrie_2023.pdf)

## Stack

BigQuery · dbt Core · SQL · Python (pandas, SciPy, GeoPandas, Matplotlib)
