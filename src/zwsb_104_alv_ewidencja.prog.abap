*&---------------------------------------------------------------------*
*& Report ZWSB_104_ALV_EWIDENCJA
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zwsb_104_alv_ewidencja.

TABLES: zwsb_104_kpo, zwsb_104_przetw.

TYPES: BEGIN OF lty_input_data,
         kod_odpadu TYPE RANGE OF zwsb_dt_ko_104,
         d_przej    TYPE RANGE OF zwsb_dt_pd_104,
       END OF lty_input_data.

DATA: gs_selection_screen TYPE lty_input_data.

SELECT-OPTIONS: s_kod FOR zwsb_104_kpo-kod_odpadu,
                s_d_prze FOR zwsb_104_kpo-data_przej.

" Przypisanie zmiennych z ekranu selekcji do jednej struktury
gs_selection_screen-kod_odpadu = s_kod[].
gs_selection_screen-d_przej = s_d_prze[].

" tworzę swoją klasę do alv
CLASS lcl_ewidencja DEFINITION FINAL.
  PUBLIC SECTION.
    TYPES:
      BEGIN OF lty_input_data,
        kod_odpadu TYPE RANGE OF zwsb_dt_ko_104,
        d_przej    TYPE RANGE OF zwsb_dt_pd_104,
      END OF lty_input_data,

      BEGIN OF lty_output_alv,
        kod_odpadu       TYPE zwsb_dt_ko_104,
*        data_przej               TYPE zwsb_dt_pd_104,
*        suma_odpadow             TYPE zwsb_dt_mo_104,
        masa_odpadow     TYPE zwsb_dt_mo_104,
        magazyn          TYPE zwsb_dt_mo_104,
*        przekazujacy             TYPE zwsb_dt_przek_104,
*        transportujacy           TYPE  zwsb_dt_trans_104,
*        przejmujacy               TYPE zwsb_dt_przej_104,
*        odzysk_unieszkodliwienie TYPE zwsb_dt_ou_104,
*        bp_wydanie_ou            TYPE zwsb_dt_wyd_104,
        masa_odpadow_ou  TYPE zwsb_dt_mo_104,
*        bp_wydanie_wyd           TYPE zwsb_dt_wyd_104,
        masa_odpadow_wyd TYPE zwsb_dt_mo_104,
      END OF lty_output_alv.

    METHODS:
      settings_alv,
      generate_alv, "wyświetlenie ALV
      constructor IMPORTING is_input_data TYPE lty_input_data."przekazanie parametrów z seletion-options

  PRIVATE SECTION.
    DATA:
      mt_ewidencja  TYPE STANDARD TABLE OF lty_output_alv, "tabela wewnetrzna o strukturze ty_kpo
      o_alv         TYPE REF TO cl_salv_table,
      ms_input_data TYPE lty_input_data.

    METHODS:
      get_data,
      set_subtotals,
      set_columns_name.

ENDCLASS.



START-OF-SELECTION.
  DATA(go_kpo) = NEW lcl_ewidencja( is_input_data = gs_selection_screen ). "tworzenie obiektu i przekazanie parametrów z selections-screen
  go_kpo->generate_alv( ). "wywolanie alv


CLASS lcl_ewidencja IMPLEMENTATION.

  METHOD constructor.
    ms_input_data = is_input_data.
  ENDMETHOD.

  METHOD get_data.
    CLEAR: mt_ewidencja.
*
*    SELECT
*      a~kod_odpadu,
*           SUM( a~masa_odpadow ) AS masa_odpadow,
*           SUM( a~magazyn ) AS magazyn
*
*      FROM zwsb_104_kpo AS a
**      LEFT OUTER JOIN zwsb_104_przetw AS b ON a~nr_kpo = b~nr_kpo
*      INTO CORRESPONDING FIELDS OF TABLE @mt_ewidencja
*      WHERE kod_odpadu IN @ms_input_data-kod_odpadu
*        AND a~data_przej IN @ms_input_data-d_przej
*      GROUP BY a~kod_odpadu.


*    SELECT
*      nr_kpo,
*      kod_odpadu,
*      masa_odpadow,
*      magazyn
*      FROM zwsb_104_kpo
**      LEFT OUTER JOIN zwsb_104_przetw AS b ON a~nr_kpo = b~nr_kpo
*      INTO TABLE @DATA(lt_kpo)
*      WHERE kod_odpadu IN @ms_input_data-kod_odpadu
*        AND data_przej IN @ms_input_data-d_przej.


    SELECT
      a~nr_kpo,
      a~kod_odpadu,
      a~masa_odpadow as masa1,
      a~magazyn,
      b~masa_odpadow as masa2
      FROM zwsb_104_kpo as a
      LEFT OUTER JOIN zwsb_104_przetw AS b ON a~kod_odpadu = b~kod_odpadu
      INTO TABLE @DATA(lt_kpo)
      WHERE a~kod_odpadu IN @ms_input_data-kod_odpadu
        AND a~data_przej IN @ms_input_data-d_przej.

*    SELECT a~kod_odpadu,
*           a~przekazujacy,
*           a~transportujacy,
*           a~przejmujacy,
*           a~data_przej,
*           SUM( a~masa_odpadow ) AS masa_odpadow,
*           SUM( a~magazyn ) AS magazyn,
**           b~odzysk_unieszkodliwienie,
**           b~bp_wydanie AS bp_wydanie_ou,
**           b~masa_odpadow AS masa_odpadow_ou,
*           SUM( b~masa_odpadow ) AS masa_odpadow_ou,
*
**           c~bp_wydanie AS bp_wydanie_wyd,
**           c~masa_odpadow AS masa_odpadow_wyd
*           SUM( c~masa_odpadow ) AS masa_odpadow_wyd
*      FROM zwsb_104_kpo AS a
*      LEFT OUTER JOIN zwsb_104_przetw AS b ON a~nr_kpo = b~nr_kpo
*      LEFT OUTER JOIN zwsb_104_wydanie AS c ON a~nr_kpo = c~nr_kpo
*      INTO CORRESPONDING FIELDS OF TABLE @mt_ewidencja
*      WHERE kod_odpadu IN @ms_input_data-kod_odpadu
*        AND a~przekazujacy IN @ms_input_data-przek
*        AND a~transportujacy IN @ms_input_data-trans
*        AND a~przejmujacy IN @ms_input_data-przej
*        AND a~data_trans IN @ms_input_data-d_rozp
*        AND a~data_przej IN @ms_input_data-d_przej
*        AND b~odzysk_unieszkodliwienie IN @ms_input_data-odzysk_unieszkodliw
*        GROUP BY kod_odpadu, przekazujacy, transportujacy, przejmujacy, data_przej.

    SORT mt_ewidencja.
  ENDMETHOD.

  METHOD generate_alv.
    get_data( ).
    cl_salv_table=>factory(
      IMPORTING
        r_salv_table   = o_alv
      CHANGING
        t_table        = mt_ewidencja ).

*    set_subtotals( ).
    set_columns_name( ).
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
  ENDMETHOD.

  METHOD set_subtotals.
    DATA(lo_aggrs) = o_alv->get_aggregations( ).
    DATA(lo_sorts) = o_alv->get_sorts( ).

    TRY.
        lo_sorts->add_sort(
          EXPORTING
            columnname         = 'KOD_ODPADU'
          RECEIVING
            value              = DATA(lo_sort_column) ).
      CATCH cx_salv_not_found.
      CATCH cx_salv_existing.
      CATCH cx_salv_data_error.
    ENDTRY.

    TRY.
        lo_sort_column->set_subtotal( value = if_salv_c_bool_sap=>true ).
      CATCH cx_salv_data_error.
    ENDTRY.

    TRY.
        lo_aggrs->add_aggregation(
          EXPORTING
            columnname         = 'MASA_ODPADOW'
            aggregation        = if_salv_c_aggregation=>total ).

        lo_aggrs->add_aggregation(
          EXPORTING
            columnname         = 'MAGAZYN'
            aggregation        = if_salv_c_aggregation=>total ).

        lo_aggrs->add_aggregation(
          EXPORTING
            columnname         = 'MASA_ODPADOW_OU'
            aggregation        = if_salv_c_aggregation=>total ).

        lo_aggrs->add_aggregation(
          EXPORTING
            columnname         = 'MASA_ODPADOW_WYD'
            aggregation        = if_salv_c_aggregation=>total ).
      CATCH cx_salv_data_error.
      CATCH cx_salv_not_found.
      CATCH cx_salv_existing.
    ENDTRY.



  ENDMETHOD.

  METHOD set_columns_name.
    DATA: lo_column TYPE REF TO cl_salv_column.
    DATA(lo_columns) = o_alv->get_columns( ).

    TRY.
        lo_column = lo_columns->get_column( 'KOD_ODPADU' ).
        lo_column->set_output_length( 12 ).

        lo_column = lo_columns->get_column( 'MASA_ODPADOW' ).
        lo_column->set_short_text( |{ TEXT-01s }| ).
        lo_column->set_medium_text( |{ TEXT-01m }| ).
        lo_column->set_long_text( |{ TEXT-01m }| ).
        lo_column->set_output_length( 15 ).

        lo_column = lo_columns->get_column( 'MAGAZYN' ).
        lo_column->set_short_text( |{ TEXT-02s }| ).
        lo_column->set_medium_text( |{ TEXT-02s }| ).
        lo_column->set_long_text( |{ TEXT-02s }| ).
        lo_column->set_output_length( 15 ).

*        lo_column = lo_columns->get_column( 'BP_WYDANIE_OU' ).
*        lo_column->set_short_text( |{ TEXT-02s }| ).
*        lo_column->set_medium_text( |{ TEXT-02m }| ).
*        lo_column->set_long_text( |{ TEXT-02l }| ).

        lo_column = lo_columns->get_column( 'MASA_ODPADOW_OU' ).
        lo_column->set_short_text( |{ TEXT-03s }| ).
        lo_column->set_medium_text( |{ TEXT-03m }| ).
        lo_column->set_long_text( |{ TEXT-03m }| ).
*
*        lo_column = lo_columns->get_column( 'BP_WYDANIE_WYD' ).
*        lo_column->set_short_text( |{ TEXT-04s }| ).
*        lo_column->set_medium_text( |{ TEXT-04s }| ).
*        lo_column->set_long_text( |{ TEXT-04s }| ).

        lo_column = lo_columns->get_column( 'MASA_ODPADOW_WYD' ).
        lo_column->set_short_text( |{ TEXT-04s }| ).
        lo_column->set_medium_text( |{ TEXT-04s }| ).
        lo_column->set_long_text( |{ TEXT-04s }| ).

      CATCH cx_salv_not_found INTO DATA(lo_error).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
