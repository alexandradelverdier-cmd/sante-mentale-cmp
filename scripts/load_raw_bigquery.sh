#!/usr/bin/env bash
# Charge les fichiers bruts SAE dans BigQuery (toutes colonnes en STRING, typage fait dans dbt)
set -euo pipefail
PROJECT=delverdier-alexandra-wagon
DATASET=raw_sae

bq --location=EU mk --dataset ${PROJECT}:${DATASET} 2>/dev/null || true

# anciennes tables mono-année, remplacées par les tables empilées
for t in sae_2025_id sae_2025_psy sae_2025_psy2; do bq rm -f -t ${PROJECT}:${DATASET}.$t 2>/dev/null || true; done

bq load --replace --source_format=CSV --skip_leading_rows=1 ${PROJECT}:${DATASET}.sae_id data/raw/sae_id.csv an:STRING,fi:STRING,rs:STRING,fi_ej:STRING,stjr:STRING,cat:STRING,catr:STRING,reg:STRING,dep:STRING,reg_diff:STRING,dep_diff:STRING,cominsee:STRING
bq load --replace --source_format=CSV --skip_leading_rows=1 ${PROJECT}:${DATASET}.sae_psy data/raw/sae_psy.csv bor:STRING,an:STRING,fi:STRING,fi_ej:STRING,dis:STRING,part:STRING,nb_sect:STRING,nb_dif:STRING,int:STRING,cap_htp:STRING,cap_pft:STRING,cap_aat:STRING,cap_acp:STRING,cap_ccu:STRING,cap_had:STRING,jli_htp:STRING,cap_hdj:STRING,cap_hdn:STRING,nb_at:STRING,sej_htp:STRING,jou_htp:STRING,jou_pft:STRING,jou_aat:STRING,jou_acp:STRING,jou_ccu:STRING,jou_had:STRING,ven_hdj:STRING,ven_hdn:STRING,ven_at:STRING,nb_cmp_seul:STRING,nb_consult_seul:STRING,nb_cattp:STRING,act_cmp_seul:STRING,act_consult_seul:STRING,act_cattp:STRING,act_ad:STRING,act_ems:STRING,act_uhs:STRING,act_eme:STRING,fil_tot:STRING,fil_amb:STRING,efflib_pkt:STRING,etpsal_pkt:STRING,efflib_med:STRING,etpsal_med:STRING,gar_sen:STRING,ast_sen:STRING,efflib_pnm:STRING,etpsal_pnm:STRING,etp_inf:STRING,etp_aid:STRING,etp_psy:STRING,etp_ree:STRING,etp_edu:STRING
bq load --replace --source_format=CSV --skip_leading_rows=1 ${PROJECT}:${DATASET}.sae_psy2 data/raw/sae_psy2.csv bor:STRING,an:STRING,fi:STRING,fi_ej:STRING,psy_a22:STRING,psy_a23:STRING,psy_a24:STRING,psy_a25:STRING,psy_a26:STRING,psy_a27:STRING,psy_a28:STRING,psy_b23:STRING,psy_b24:STRING,psy_b25:STRING,psy_b26:STRING,psy_b27:STRING,psy_b28:STRING,psy_c22:STRING,psy_c23:STRING,psy_c24:STRING,psy_c25:STRING,psy_c26:STRING,psy_c27:STRING,psy_c28:STRING,psy_d22:STRING,psy_d23:STRING,psy_d24:STRING,psy_d25:STRING,psy_d26:STRING,psy_d27:STRING,psy_d28:STRING,psy_e22:STRING,psy_e23:STRING,psy_e24:STRING,psy_e25:STRING,psy_e26:STRING,psy_e27:STRING,psy_e28:STRING,psy_a38:STRING,psy_b38:STRING,psy_a39:STRING,psy_b39:STRING,psy_a40:STRING,psy_b40:STRING,psy_a41:STRING,psy_b41:STRING,psy_a42:STRING,psy_b42:STRING,psy_a43:STRING,psy_a44:STRING,psy_a45:STRING,psy_a46:STRING,psy_b45:STRING,psy_b46:STRING,psy_c45:STRING,psy_c46:STRING,psy_d45:STRING,psy_d46:STRING,psy_e45:STRING,psy_e46:STRING,psy_a47:STRING,psy_b47:STRING,psy_a48:STRING,psy_b48:STRING,psy_a49:STRING,psy_b49:STRING
