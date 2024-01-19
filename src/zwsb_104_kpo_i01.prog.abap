*----------------------------------------------------------------------*
***INCLUDE ZWSB_104_KPO_I01.
*----------------------------------------------------------------------*

MODULE user_command_exit_0100 INPUT.
  save_ok = ok_code.
  CLEAR ok_code.

  CASE save_ok.
    WHEN 'BACK' .
      LEAVE TO SCREEN 0.
    WHEN 'EXIT' .
      LEAVE TO SCREEN 0.
    WHEN 'CANCEL'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.

" Do obsługi na ekranie selekcji (dodanie do pól nieaktywnych danych BP)
MODULE user_command_0100 INPUT.
  " dodaje zera wiodące bo inaczej nie zasysał wartości
  DATA lv_przekazujacy_bp TYPE bu_partner.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = gs_przekazujacy-partner
    IMPORTING
      output = lv_przekazujacy_bp.
  " To samo co wyżej, ale w nowej wersji
  " DATA(lv_przekazujacy_bp) = CONV bu_partner( |{ gs_przekazujacy-partner ALPHA = IN }| ).

  SELECT SINGLE * FROM zwsb_104_v_bp INTO CORRESPONDING FIELDS OF gs_przekazujacy WHERE partner = lv_przekazujacy_bp.


  DATA lv_transportujacy_bp TYPE bu_partner.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = gs_transportujacy-partner
    IMPORTING
      output = lv_transportujacy_bp.
  " To samo co wyżej, ale w nowej wersji
  " DATA(lv_transportujacy_bp) = CONV bu_partner( |{ gs_transportujacy-partner ALPHA = IN }| ).

  SELECT SINGLE * FROM zwsb_104_v_bp INTO CORRESPONDING FIELDS OF gs_transportujacy WHERE partner = lv_transportujacy_bp.

  DATA lv_przejmujacy_bp TYPE bu_partner.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = gs_przejmujacy-partner
    IMPORTING
      output = lv_przejmujacy_bp.
  " To samo co wyżej, ale w nowej wersji
  " DATA(lv_przejmujacy_bp) = CONV bu_partner( |{ gs_przejmujacy-partner ALPHA = IN }| ).

  SELECT SINGLE * FROM zwsb_104_v_bp INTO CORRESPONDING FIELDS OF gs_przejmujacy WHERE partner = lv_przejmujacy_bp.
ENDMODULE.


MODULE user_command_data INPUT.
  save_ok = ok_code.
  CLEAR ok_code.

  DATA: lv_timestamp_trans TYPE timestamp,
        lv_timestamp_przej TYPE timestamp.

  CALL FUNCTION '/SAPAPO/DATE_CONVERT_TIMESTAMP'
    EXPORTING
      iv_date      = zwsb_104_kpo-data_trans
      iv_time      = zwsb_104_kpo-godzina_trans
    IMPORTING
      ev_timestamp = lv_timestamp_trans.

  CALL FUNCTION '/SAPAPO/DATE_CONVERT_TIMESTAMP'
    EXPORTING
      iv_date      = zwsb_104_kpo-data_przej
      iv_time      = zwsb_104_kpo-godzina_przej
    IMPORTING
      ev_timestamp = lv_timestamp_przej.

  CASE save_ok.
    WHEN 'EXECUTE'.
      IF lv_timestamp_trans > lv_timestamp_przej.
        MESSAGE e000(zwsb_104_proj)." DISPLAY LIKE 'E'.
      ENDIF.

      " przypisanie parametrów z ekranu do struktury takiej jak tabela BD
      gs_kpo-przekazujacy = gs_przekazujacy-partner.
      gs_kpo-transportujacy = gs_transportujacy-partner.
      gs_kpo-przejmujacy = gs_przejmujacy-partner.
      gs_kpo-kod_odpadu = zwsb_104_kpo-kod_odpadu.
      gs_kpo-masa_odpadow = zwsb_104_kpo-masa_odpadow.
      gs_kpo-data_trans = zwsb_104_kpo-data_trans.
      gs_kpo-godzina_trans = zwsb_104_kpo-godzina_trans.
      gs_kpo-data_przej = zwsb_104_kpo-data_przej.
      gs_kpo-godzina_przej = zwsb_104_kpo-godzina_przej.
      gs_kpo-nr_rej = zwsb_104_kpo-nr_rej.
      gs_kpo-magazyn = zwsb_104_kpo-masa_odpadow.

      " Pobranie następnego numeru z ustalonego zakresu numerów obiektu ZWSB_104_KO
      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          nr_range_nr = '01'
          object      = 'ZWSB_104_K'
        IMPORTING
          number      = gs_kpo-nr_kpo.

      INSERT zwsb_104_kpo FROM gs_kpo.

      IF sy-subrc = 0.
        MESSAGE i002(zwsb_104_proj) WITH gs_kpo-nr_kpo.
      ELSE.
        MESSAGE i003(zwsb_104_proj).
      ENDIF.


    WHEN 'GENERUJ'.
      IF lv_timestamp_trans > lv_timestamp_przej.
        MESSAGE e000(zwsb_104_proj)." DISPLAY LIKE 'E'.
      ENDIF.

      " przypisanie parametrów z ekranu do struktury takiej jak tabela BD
      gs_kpo-przekazujacy = gs_przekazujacy-partner.
      gs_kpo-transportujacy = gs_transportujacy-partner.
      gs_kpo-przejmujacy = gs_przejmujacy-partner.
      gs_kpo-kod_odpadu = zwsb_104_kpo-kod_odpadu.
      gs_kpo-masa_odpadow = zwsb_104_kpo-masa_odpadow.
      gs_kpo-data_trans = zwsb_104_kpo-data_trans.
      gs_kpo-godzina_trans = zwsb_104_kpo-godzina_trans.
      gs_kpo-data_przej = zwsb_104_kpo-data_przej.
      gs_kpo-godzina_przej = zwsb_104_kpo-godzina_przej.
      gs_kpo-nr_rej = zwsb_104_kpo-nr_rej.
      gs_kpo-magazyn = zwsb_104_kpo-masa_odpadow.

      " Pobranie następnego numeru z ustalonego zakresu numerów obiektu ZWSB_104_KO
      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          nr_range_nr = '01'
          object      = 'ZWSB_104_K'
        IMPORTING
          number      = gs_kpo-nr_kpo.

      INSERT zwsb_104_kpo FROM gs_kpo.


      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          formname           = 'ZWSB_104_PROJ_FORM'
*         variant            = ' '
*         direct_call        = ' '
        IMPORTING
          fm_name            = fm_name
        EXCEPTIONS
          no_form            = 1
          no_function_module = 2
          OTHERS             = 3.

      IF sy-subrc <> 0.
*   error handling
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        EXIT.
      ENDIF.

* now call the generated function module
      CALL FUNCTION fm_name
        EXPORTING
*         archive_index    =
*         archive_parameters   =
*         control_parameters   =
*         mail_appl_obj    =
*         mail_recipient   =
*         mail_sender      =
*         output_options   =
*         user_settings    = 'X'
          nr_kpo           = gs_kpo-nr_kpo
*     importing  document_output_info =
*         job_output_info  =
*         job_output_options   =
        EXCEPTIONS
          formatting_error = 1
          internal_error   = 2
          send_error       = 3
          user_canceled    = 4
          OTHERS           = 5.

      IF sy-subrc <> 0.
*   error handling
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
  ENDCASE.
ENDMODULE.
