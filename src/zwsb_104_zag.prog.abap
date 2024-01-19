*&---------------------------------------------------------------------*
*& Report ZWSB_104_ZAG
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zwsb_104_zag.

TABLES: sscrfields.
DATA: gs_przetwarzanie TYPE zwsb_104_przetw,
      gs_wydanie       TYPE zwsb_104_wydanie,
      gs_kpo           TYPE zwsb_104_kpo.

PARAMETERS nr_kpo TYPE zwsb_dt_kpo_104 OBLIGATORY.
PARAMETERS: p_przetw RADIOBUTTON GROUP gr1,
            p_wyda   RADIOBUTTON GROUP gr1.

SELECTION-SCREEN BEGIN OF SCREEN 9100.
SELECTION-SCREEN COMMENT /1(30) comm1.
SELECTION-SCREEN ULINE /1(50).

PARAMETERS: p_odzysk TYPE zwsb_104_rd-odzysk_unieszkodliwienie,
            p_inst   TYPE zwsb_104_kpo-przejmujacy MATCHCODE OBJECT zwsb_sh_bp_104,
            p_p_masa TYPE zwsb_104_kpo-magazyn.
SELECTION-SCREEN SKIP 2.
SELECTION-SCREEN PUSHBUTTON 35(10) but1 USER-COMMAND but1.
SELECTION-SCREEN END OF SCREEN 9100.


SELECTION-SCREEN BEGIN OF SCREEN 9200.
SELECTION-SCREEN COMMENT /1(30) comm2.
SELECTION-SCREEN ULINE /1(50).

PARAMETERS: p_wyd    TYPE bu_partner MATCHCODE OBJECT zwsb_sh_bp_104,
            p_w_masa TYPE zwsb_104_kpo-magazyn.
SELECTION-SCREEN SKIP 2.
SELECTION-SCREEN PUSHBUTTON 35(10) but2 USER-COMMAND but2.
SELECTION-SCREEN END OF SCREEN 9200.


AT SELECTION-SCREEN.

  CASE sscrfields.
    WHEN 'BUT1'.
      IF p_p_masa > gs_kpo-magazyn.
        MESSAGE w001(zwsb_104_proj).
      ENDIF.
      " wykonuje zapis do bazy danych "jednocześnie" dla dwóch MODIFY
      PERFORM modify_db_on_przetw ON COMMIT.
    WHEN 'BUT2'.

      IF p_w_masa > gs_kpo-magazyn.
        MESSAGE w001(zwsb_104_proj).
      ENDIF.
      " wykonuje zapis do bazy danych "jednocześnie" dla dwóch MODIFY
      PERFORM modify_db_on_wydanie ON COMMIT.
  ENDCASE.

  COMMIT WORK.

AT SELECTION-SCREEN OUTPUT.
  but1 = TEXT-001.
  but2 = TEXT-002.
  comm1 = |{ TEXT-003 } { nr_kpo }|.
  comm2 = |{ TEXT-003 } { nr_kpo }|.

*INITIALIZATION.
  SELECT SINGLE * FROM zwsb_104_kpo INTO @gs_kpo WHERE nr_kpo = @nr_kpo.
  p_p_masa = gs_kpo-magazyn.
  p_inst = gs_kpo-przejmujacy.
  p_w_masa = gs_kpo-magazyn.

START-OF-SELECTION.

  " Blokada danego wiersza tabeli do edycji przez innego użytkownika
  CALL FUNCTION 'ENQUEUE_EZWSB_104_KPO'
    EXPORTING
      mode_zwsb_104_kpo = 'E'
      mandt             = sy-mandt
      nr_kpo            = nr_kpo
    EXCEPTIONS
      foreign_lock      = 1
      system_failure    = 2
      OTHERS            = 3.
  IF sy-subrc <> 0.
    " ToDo: Obsłuzyć w przypadku błędu
  ENDIF.


  CASE abap_true.
    WHEN p_przetw.
      CALL SELECTION-SCREEN 9100.
    WHEN p_wyda.
      CALL SELECTION-SCREEN 9200.
  ENDCASE.


FORM modify_db_on_przetw.
  gs_przetwarzanie-nr_kpo = nr_kpo.
  gs_przetwarzanie-odzysk_unieszkodliwienie = p_odzysk.
  gs_przetwarzanie-bp_wydanie = p_inst.
  gs_przetwarzanie-kod_odpadu = gs_kpo-kod_odpadu.
  gs_przetwarzanie-masa_odpadow = p_p_masa.
  gs_przetwarzanie-data = sy-datum.
  gs_przetwarzanie-godzina = sy-uzeit.
  gs_przetwarzanie-username = sy-uname.

  " Sprawdzenie czy rekord z kluczem już istnieje, żeby dodawał, a nie nadpisywał
  SELECT SINGLE FROM zwsb_104_przetw
    FIELDS *
    WHERE nr_kpo = @nr_kpo
      AND odzysk_unieszkodliwienie = @p_odzysk
      AND bp_wydanie = @p_inst
     INTO @DATA(ls_przetw).
  " jeśli tak, to dodaj masę odpadów
  IF sy-subrc = 0.
    gs_przetwarzanie-masa_odpadow = gs_przetwarzanie-masa_odpadow + ls_przetw-masa_odpadow.
  ENDIF.

  MODIFY zwsb_104_przetw FROM gs_przetwarzanie.

  " Odblokowanie wiersza tabeli
  CALL FUNCTION 'DEQUEUE_EZWSB_104_KPO'
    EXPORTING
      mode_zwsb_104_kpo = 'E'
      mandt             = sy-mandt
      nr_kpo            = nr_kpo.

  " zaktualizuje również wiersz dla KPO o pomniejszoną masę odpadów z magazynu
  gs_kpo-magazyn = gs_kpo-magazyn - p_p_masa.
  MODIFY zwsb_104_kpo FROM gs_kpo.
ENDFORM.

FORM modify_db_on_wydanie.
  gs_wydanie-nr_kpo = nr_kpo.
  gs_wydanie-bp_wydanie = p_wyd.
  gs_wydanie-kod_odpadu = gs_kpo-kod_odpadu.
  gs_wydanie-masa_odpadow = p_w_masa.
  gs_wydanie-data = sy-datum.
  gs_wydanie-godzina = sy-uzeit.
  gs_wydanie-username = sy-uname.

  " Sprawdzenie czy rekord z kluczem już istnieje
  SELECT SINGLE FROM zwsb_104_wydanie
    FIELDS *
    WHERE nr_kpo = @nr_kpo
      AND bp_wydanie = @p_wyd
     INTO @DATA(ls_wydanie).
  " jeśli tak, to dodaj masę odpadów
  IF sy-subrc = 0.
    gs_wydanie-masa_odpadow = gs_wydanie-masa_odpadow + ls_wydanie-masa_odpadow.
  ENDIF.

  MODIFY zwsb_104_wydanie FROM gs_wydanie.

  CALL FUNCTION 'DEQUEUE_EZWSB_104_KPO'
    EXPORTING
      mode_zwsb_104_kpo = 'E'
      mandt             = sy-mandt
      nr_kpo            = nr_kpo.

  " zaktualizuj również wiersz dla KPO o pomniejszoną masę odpadów z magazynu
  gs_kpo-magazyn = gs_kpo-magazyn - p_w_masa.
  MODIFY zwsb_104_kpo FROM gs_kpo.
ENDFORM.
