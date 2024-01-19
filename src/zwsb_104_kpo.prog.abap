*&---------------------------------------------------------------------*
*& Report ZWSB_104_KPO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zwsb_104_kpo.

INCLUDE zwsb_104_kpo_top.
INCLUDE zwsb_104_kpo_o01.
INCLUDE zwsb_104_kpo_i01.

START-OF-SELECTION.
  CALL SCREEN 0100.

















































































****
****
*****&---------------------------------------------------------------------*
*****&      Module  VALUE_FOR_PRZEKAZUJACY  INPUT
*****&---------------------------------------------------------------------*
*****       text
*****----------------------------------------------------------------------*
****MODULE value_for_przekazujacy INPUT.
****
****  DATA:
****    ls_kna1_ret TYPE ddshretval,
****    lt_bp_ret   TYPE TABLE OF ddshretval.
****
****  SELECT * FROM zwsb_104_v_bp INTO TABLE @DATA(lt_bp).
****
****  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
****    EXPORTING
*****     DDIC_STRUCTURE  = 'ZWSB_104_V_BP'
****      retfield        = 'PARTNER'
*****     PVALKEY         = ' '
*****     dynpprog        = sy-repid
*****     dynpnr          = sy-dynnr
*****     dynprofield     = 'GS_PRZEKAZUJACY-PARTNER'
*****     STEPL           = 0
*****     WINDOW_TITLE    =
*****     VALUE           = ' '
****      value_org       = 'S'
*****     MULTIPLE_CHOICE = ' '
*****     DISPLAY         = ' '
*****     CALLBACK_PROGRAM       = ' '
*****     CALLBACK_FORM   = ' '
*****     CALLBACK_METHOD =
*****     MARK_TAB        =
***** IMPORTING
*****     USER_RESET      =
****    TABLES
****      value_tab       = lt_bp
*****     FIELD_TAB       =
****      return_tab      = lt_bp_ret
*****     DYNPFLD_MAPPING =
****    EXCEPTIONS
****      parameter_error = 1
****      no_values_found = 2
****      OTHERS          = 3.
****  IF sy-subrc <> 0.
***** Implement suitable error handling here
****  ENDIF.
****
****"Dwie możliwośći:
****  DATA(lv_bp_partner) = lt_bp_ret[ 1 ]-fieldval.
****  DATA(lv_bp_partner_with_zeros) = CONV bu_partner( |{ lv_bp_partner ALPHA = IN }| ).
****
****  DATA: lv_bu_partner TYPE bu_partner.
****  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
****    EXPORTING
****      input  = lt_bp_ret[ 1 ]-fieldval
****    IMPORTING
****      output = lv_bu_partner.
****
****
****
****
****  DATA(ls_bp) = lt_bp[ partner = lv_bu_partner ].
****
*****  gs_przekazujacy = CORRESPONDING #( ls_bp ).
****
****  MOVE-CORRESPONDING ls_bp TO gs_przekazujacy.
****
****
****ENDMODULE.
