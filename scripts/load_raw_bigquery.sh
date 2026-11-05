#!/usr/bin/env bash
# Charge les fichiers bruts SAE dans BigQuery (toutes colonnes en STRING, typage fait dans dbt)
set -euo pipefail
PROJECT=delverdier-alexandra-wagon
DATASET=raw_sae

bq --location=EU mk --dataset --if_exists ${PROJECT}:${DATASET} 2>/dev/null || bq --location=EU mk --dataset ${PROJECT}:${DATASET} || true

bq load --replace --source_format=CSV --skip_leading_rows=1 ${PROJECT}:${DATASET}.sae_2025_id data/raw/sae_2025_id.csv an:STRING,fi:STRING,rs:STRING,fi_ej:STRING,stjr:STRING,cat:STRING,catr:STRING,reg:STRING,dep:STRING,reg_diff:STRING,dep_diff:STRING,cominsee:STRING
bq load --replace --source_format=CSV --skip_leading_rows=1 ${PROJECT}:${DATASET}.sae_2025_psy data/raw/sae_2025_psy.csv bor:STRING,an:STRING,fi:STRING,fi_ej:STRING,dis:STRING,part:STRING,nb_sect:STRING,nb_dif:STRING,int:STRING,cap_htp:STRING,cap_pft:STRING,cap_aat:STRING,cap_acp:STRING,cap_ccu:STRING,jli_htp:STRING,cap_hdj:STRING,cap_hdn:STRING,nb_at:STRING,sej_htp:STRING,jou_htp:STRING,jou_pft:STRING,jou_aat:STRING,jou_acp:STRING,jou_ccu:STRING,ven_hdj:STRING,ven_hdn:STRING,ven_at:STRING,nb_cmp_seul:STRING,nb_consult_seul:STRING,nb_cattp:STRING,act_cmp_seul:STRING,act_consult_seul:STRING,act_cattp:STRING,act_ad:STRING,act_ems:STRING,act_uhs:STRING,act_eme:STRING,fil_tot:STRING,fil_amb:STRING,efflib_pkt:STRING,etpsal_pkt:STRING,efflib_med:STRING,etpsal_med:STRING,gar_sen:STRING,ast_sen:STRING,efflib_pnm:STRING,etpsal_pnm:STRING,etp_inf:STRING,etp_aid:STRING,etp_psy:STRING,etp_ree:STRING,etp_edu:STRING
bq load --replace --source_format=CSV --skip_leading_rows=1 ${PROJECT}:${DATASET}.sae_2025_psy2 data/raw/sae_2025_psy2.csv an:STRING,fi:STRING,fi_ej:STRING,psy_c22:STRING,psy_c23:STRING,psy_c24:STRING,psy_c25:STRING,psy_c26:STRING,psy_c27:STRING,psy_c28:STRING,psy_a49:STRING,psy_b49:STRING
