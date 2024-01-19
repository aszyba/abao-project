*&---------------------------------------------------------------------*
*& Include          ZWSB_104_KPO_TOP
*&---------------------------------------------------------------------*
TABLES:
  zwsb_104_kpo, zwsb_104_v_bp.

DATA:
  ok_code           TYPE syst_ucomm,
  save_ok           TYPE syst_ucomm,
  gs_przekazujacy   TYPE zwsb_104_v_bp,
  gs_transportujacy TYPE zwsb_104_v_bp,
  gs_przejmujacy    TYPE zwsb_104_v_bp,
  gs_kpo            TYPE zwsb_104_kpo,
  nr_kpo            TYPE zwsb_dt_kpo_104,
  fm_name           TYPE rs38l_fnam.
