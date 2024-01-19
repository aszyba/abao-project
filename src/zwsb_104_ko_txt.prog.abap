*&---------------------------------------------------------------------*
*& Report ZWSB_104_KO_TXT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zwsb_104_ko_txt.

TYPES:
  BEGIN OF ty_plik_ko,
    kod_odpadu      TYPE zwsb_dt_ko_104,
    rodzaje_odpadow TYPE zwsb_dt_ro_104,
  END OF ty_plik_ko,

  BEGIN OF ty_plik_rd,
    odzysk_unieszkodliwienie TYPE zwsb_dt_ou_104,
    opis                     TYPE zwsb_dt_ou_opis_104,
  END OF ty_plik_rd.

DATA:
  gt_filename    TYPE filetable,
  gv_rc          TYPE i,
  gt_ko          TYPE TABLE OF zwsb_104_ko,
  gt_filedata_ko TYPE TABLE OF ty_plik_ko,
  gt_rd          TYPE TABLE OF zwsb_104_rd,
  gt_filedata_rd TYPE TABLE OF ty_plik_rd.


SELECTION-SCREEN BEGIN OF BLOCK part1 WITH FRAME TITLE TEXT-003.
PARAMETERS: p_file TYPE string OBLIGATORY.
SELECTION-SCREEN END OF BLOCK part1.


SELECTION-SCREEN BEGIN OF BLOCK part2 WITH FRAME TITLE TEXT-004.
PARAMETERS: kod_odp  RADIOBUTTON GROUP grop,
            pr_przet RADIOBUTTON GROUP grop.
SELECTION-SCREEN END OF BLOCK part2.


" służy do wyświetlania możliwych wartości do wprowadzenia w polu wejściowym.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  " metoda statyczna do wywołania okna dialogowego z Windowsa
  cl_gui_frontend_services=>file_open_dialog(
    EXPORTING
       multiselection         = abap_false
    CHANGING
      file_table              = gt_filename  "ścieżka dostepu do pliku
      rc                      = gv_rc ).

  READ TABLE gt_filename INDEX 1 INTO p_file. "odczytuje pierwszy wiersz tabeli z tabeli filename (scieżka dostępu do pliku)
*  p_file = gt_filename[ 1 ]-filename.


START-OF-SELECTION.


  CASE abap_true.
    WHEN kod_odp.
      "pobiera dane z pliku do tabeli wewnętrznej gt_filetada_ko
      CALL FUNCTION 'GUI_UPLOAD'
        EXPORTING
          filename            = p_file
          filetype            = 'ASC'
          has_field_separator = 'X'
          codepage            = '4110'
        TABLES
          data_tab            = gt_filedata_ko.

      " gt_fieldata_ko nie zawiera mandanta ponieważ do niej ładowane są dane z pliku txt, które potem przekazywane są do tabeli z mandantem gt_ko
      MOVE-CORRESPONDING gt_filedata_ko TO gt_ko.
      MODIFY zwsb_104_ko FROM TABLE gt_ko.

    WHEN pr_przet.
      CALL FUNCTION 'GUI_UPLOAD'
        EXPORTING
          filename            = p_file
          filetype            = 'ASC'
          has_field_separator = 'X'
          codepage            = '4110'
        TABLES
          data_tab            = gt_filedata_rd.

      MOVE-CORRESPONDING gt_filedata_rd TO gt_rd.
      MODIFY zwsb_104_rd FROM TABLE gt_rd.
  ENDCASE.

  IF sy-subrc = 0.
    WRITE:/ TEXT-001.
  ELSE.
    WRITE:/ TEXT-002.
  ENDIF.
