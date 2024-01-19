*----------------------------------------------------------------------*
***INCLUDE ZWSB_104_KPO_O01.
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'STATUS_0100'.
  SET TITLEBAR 'TITLE_0100'.

  " pętla po ekranie do zmiany wyglądu, (niekatywne pola BP)
  LOOP AT SCREEN INTO DATA(ls_screen).
    IF ls_screen-group1 = 'XYZ'.
      ls_screen-input = '0'.
      ls_screen-output = '1'.
      MODIFY SCREEN FROM ls_screen.
    ENDIF.
  ENDLOOP.
ENDMODULE.
