*&---------------------------------------------------------------------*
*& Report ZOPENDATASET
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zopendataset.

TYPES: BEGIN OF ty_ekpo,
         ebeln TYPE ebeln,
         ebelp TYPE ebelp,
         bukrs TYPE bukrs,
       END OF ty_ekpo.

DATA(lv_path) = 'F:\usr\sap\CCMS\vendor.txt'.
DATA: lt_ekpo     TYPE TABLE OF ty_ekpo,
      wa_ekpo     TYPE ty_ekpo,
      wa_outbound TYPE ty_ekpo,
      lt_outbound TYPE TABLE OF ty_ekpo.

SELECT ebeln,bukrs,bstyp
  INTO TABLE @DATA(lt_ekko)
  FROM ekko
  UP TO 100 ROWS.

SELECT ebeln,ebelp,bukrs
  INTO TABLE @lt_ekpo
  FROM ekpo
  FOR ALL ENTRIES IN @lt_ekko
  WHERE ebeln = @lt_ekko-ebeln.

********************************************
**Pushing the data into Application server**
********************************************

OPEN DATASET lv_path FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
IF sy-subrc = 0.
  LOOP AT lt_ekpo INTO wa_ekpo.

**Transfering the data record by record into Dataset.
    TRANSFER wa_ekpo TO lv_path.

    CLEAR: wa_ekpo.
  ENDLOOP.
ELSE.
  MESSAGE : 'Cannot open the File' TYPE 'E'.
ENDIF.
CLOSE DATASET lv_path.

********************************************
**Pulling the data from Application server**
********************************************

OPEN DATASET lv_path FOR INPUT IN TEXT MODE ENCODING DEFAULT.

IF sy-subrc NE 0.
  MESSAGE: 'Cannot Push the data from Dataset' TYPE 'E'.
ELSE.
  WHILE ( sy-subrc = 0 ).

**Reading the data from dataset to work area.
    READ DATASET lv_path INTO wa_outbound.
    IF sy-subrc = 0.
**append the data from work area to Internal table.
      APPEND wa_outbound TO lt_outbound.

    ENDIF.

  ENDWHILE.
ENDIF.

CLOSE DATASET lv_path.

IF sy-subrc = 0.
ENDIF.
