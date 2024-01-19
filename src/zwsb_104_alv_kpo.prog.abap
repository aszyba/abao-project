*&---------------------------------------------------------------------*
*& Report ZWSB_104_ALV_KPO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zwsb_104_alv_kpo.

TABLES zwsb_104_kpo.

TYPES: BEGIN OF lty_input_data,
         nr_kpo   TYPE RANGE OF zwsb_dt_kpo_104,
         przek    TYPE RANGE OF zwsb_dt_przek_104,
         przej    TYPE RANGE OF zwsb_dt_przej_104,
         d_rozp   TYPE RANGE OF zwsb_dt_td_104,
         d_przej  TYPE RANGE OF zwsb_dt_pd_104,
         kod      TYPE RANGE OF zwsb_dt_ko_104,
         p_ch_box TYPE char1,
       END OF lty_input_data.

DATA: gs_selection_screen TYPE lty_input_data.

SELECT-OPTIONS: s_nr_kpo FOR zwsb_104_kpo-nr_kpo,
                s_przek FOR zwsb_104_kpo-przekazujacy MATCHCODE OBJECT zwsb_sh_bp_104,
                s_przej FOR zwsb_104_kpo-przejmujacy MATCHCODE OBJECT zwsb_sh_bp_104,
                s_d_rozp FOR zwsb_104_kpo-data_trans,
                s_d_prze FOR zwsb_104_kpo-data_przej,
                s_kod FOR zwsb_104_kpo-kod_odpadu.

PARAMETERS p_ch_box AS CHECKBOX.


" Przypisanie zmiennych z ekranu selekcji do jednej struktury
gs_selection_screen-nr_kpo = s_nr_kpo[].
gs_selection_screen-przek = s_przek[].
gs_selection_screen-przej = s_przej[].
gs_selection_screen-d_rozp = s_d_rozp[].
gs_selection_screen-d_przej = s_d_prze[].
gs_selection_screen-kod = s_kod[].
gs_selection_screen-p_ch_box = p_ch_box.

" tworzę swoją klasę do alv
CLASS lcl_kpo DEFINITION FINAL.
  PUBLIC SECTION.
    TYPES:
      BEGIN OF lty_input_data,
        nr_kpo   TYPE RANGE OF zwsb_dt_kpo_104,
        przek    TYPE RANGE OF zwsb_dt_przek_104,
        przej    TYPE RANGE OF zwsb_dt_przej_104,
        d_rozp   TYPE RANGE OF zwsb_dt_td_104,
        d_przej  TYPE RANGE OF zwsb_dt_pd_104,
        kod      TYPE RANGE OF zwsb_dt_ko_104,
        p_ch_box TYPE char1,
      END OF lty_input_data.

    METHODS:
      settings_alv,
      generate_alv, "wyświetlenie ALV
      constructor IMPORTING is_input_data TYPE lty_input_data."przekazanie parametrów z seletion-options

  PRIVATE SECTION.
    DATA:
      mt_kpo        TYPE STANDARD TABLE OF zwsb_104_kpo, "tabela wewnetrzna o strukturze ty_kpo
      o_alv         TYPE REF TO cl_salv_table,
      ms_input_data TYPE lty_input_data.

    METHODS:
      on_link_click FOR EVENT link_click OF cl_salv_events_table IMPORTING row column, "hotspot
      get_data_all,"selekcja danych pobranie wszytskich KPO
      get_data_nieprzetw, "selekcja danych pobranie tylko nieprzetworzonych KPO
      get_data.
ENDCLASS.


START-OF-SELECTION.
  DATA(go_kpo) = NEW lcl_kpo( is_input_data = gs_selection_screen ). "tworzenie obiektu i przekazanie parametrów z selections-screen
  go_kpo->generate_alv( ). "wywolanie alv


CLASS lcl_kpo IMPLEMENTATION.

  METHOD constructor.
    ms_input_data = is_input_data.
  ENDMETHOD.

  METHOD get_data.
    CLEAR: mt_kpo.

    " czy wszystkie dane czy nieprzetworzone
    CASE ms_input_data-p_ch_box .
      WHEN abap_true.
        get_data_nieprzetw( ).
      WHEN abap_false.
        get_data_all( ).
    ENDCASE.
    SORT mt_kpo.
  ENDMETHOD.

  " selekcja danych
  METHOD get_data_all.
    SELECT *
      FROM zwsb_104_kpo
      INTO TABLE @mt_kpo
      WHERE nr_kpo IN @ms_input_data-nr_kpo
        AND przekazujacy IN @ms_input_data-przek
        AND przejmujacy IN @ms_input_data-przej
        AND data_trans IN @ms_input_data-d_rozp
        AND data_przej IN @ms_input_data-d_przej
        AND kod_odpadu IN @ms_input_data-kod.
  ENDMETHOD.

  METHOD get_data_nieprzetw.
    SELECT *
      FROM zwsb_104_kpo
      INTO TABLE @mt_kpo
      WHERE magazyn > 0
        AND przekazujacy IN @ms_input_data-przek
        AND przejmujacy IN @ms_input_data-przej
        AND data_trans IN @ms_input_data-d_rozp
        AND data_przej IN @ms_input_data-d_przej
        AND kod_odpadu IN @ms_input_data-kod.
  ENDMETHOD.

  METHOD generate_alv.
    get_data( ).
    cl_salv_table=>factory(
      IMPORTING
        r_salv_table   = o_alv
      CHANGING
        t_table        = mt_kpo ).

    settings_alv( ).
    o_alv->display( ).
  ENDMETHOD.

  METHOD settings_alv.
    DATA: lo_column           TYPE REF TO cl_salv_column_table,
          lo_columns          TYPE REF TO cl_salv_columns_table,
          lo_functions        TYPE REF TO cl_salv_functions_list,
          lo_display_settings TYPE REF TO cl_salv_display_settings,
          layout_settings     TYPE REF TO cl_salv_layout,
          layout_key          TYPE salv_s_layout_key.

    " ukrycycie mandanta
    lo_columns          = o_alv->get_columns( ).
    lo_column ?= lo_columns->get_column( 'MANDT' ).
    lo_column->set_visible( abap_false ).

    " standardowy pf status
    lo_functions = o_alv->get_functions( ).
    lo_functions->set_default( abap_true ).
    lo_functions->set_all( ).

    " zebra
    lo_display_settings = o_alv->get_display_settings( ).
    lo_display_settings->set_striped_pattern( abap_true ).
    " tytuł ALV
    lo_display_settings->set_list_header( TEXT-001 ).

    "   o_alv->get_functions( )->set_default( abap_true ).
    " layout
    layout_settings = o_alv->get_layout( ).
    layout_key-report = sy-repid.
    layout_settings->set_key( layout_key ).
    layout_settings->set_save_restriction( if_salv_c_layout=>restrict_none ).

    " hotspot
    lo_column ?= lo_columns->get_column( 'NR_KPO' ).
    lo_column->set_cell_type( value = if_salv_c_cell_type=>hotspot ).

    DATA(lo_events) = o_alv->get_event( ).
    SET HANDLER me->on_link_click FOR lo_events.
  ENDMETHOD.

  " metoda do wybrania KPO z ALV
  METHOD on_link_click.
    CASE column.
      WHEN 'NR_KPO'.
        "ToDo: do odzielnnej metody
        READ TABLE mt_kpo INDEX row ASSIGNING FIELD-SYMBOL(<fs_kpo>).
        DATA(lv_nr_kpo) = <fs_kpo>-nr_kpo.
        " Nowszy zapis
        " DATA(lv_nr_kpo) = mt_kpo[ row ]-nr_kpo.

        DATA lv_answer TYPE char1.
        CALL FUNCTION 'POPUP_TO_CONFIRM'
          EXPORTING
            text_question         = TEXT-004
            text_button_1         = TEXT-002
            text_button_2         = TEXT-003
            default_button        = '1'
            display_cancel_button = abap_true
          IMPORTING
            answer                = lv_answer.

        " przejście do programu ZWSB_104_ZAG
        CASE lv_answer.
          WHEN '1'.
            SUBMIT zwsb_104_zag WITH nr_kpo = lv_nr_kpo
                                WITH p_przetw = abap_true
                                WITH p_wyda = abap_false
                                AND RETURN.

          WHEN '2'.
            SUBMIT zwsb_104_zag WITH nr_kpo = lv_nr_kpo
                                WITH p_przetw = abap_false
                                WITH p_wyda = abap_true
                                AND RETURN.
          WHEN 'A'.
        ENDCASE.

        get_data( ).
        o_alv->refresh( refresh_mode = if_salv_c_refresh=>full ).
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
