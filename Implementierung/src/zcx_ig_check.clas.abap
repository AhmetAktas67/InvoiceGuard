CLASS zcx_ig_check DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_t100_message .
      DATA po_id   TYPE zig_po_item-po_id   READ-ONLY.
      DATA po_item TYPE zig_po_item-po_item READ-ONLY.

      CONSTANTS:
          BEGIN OF po_item_not_found,
           msgid TYPE symsgid VALUE 'ZIG_MSG',
           msgno TYPE symsgno VALUE '005',
           attr1 TYPE scx_attrname VALUE 'PO_ID',
           attr2 TYPE scx_attrname VALUE 'PO_ITEM',
           attr3 TYPE scx_attrname VALUE '',
           attr4 TYPE scx_attrname VALUE '',
          END OF po_item_not_found.

    INTERFACES if_t100_dyn_msg .

    METHODS constructor
      IMPORTING
        !textid   LIKE if_t100_message=>t100key OPTIONAL
        !previous LIKE previous OPTIONAL
        po_id     TYPE zig_po_item-po_id OPTIONAL
        po_item   TYPE zig_po_item-po_item OPTIONAL.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcx_ig_check IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor(
    previous = previous
    ).

    me->po_id = po_id.
    me->po_item = po_item.

    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
  ENDMETHOD.



ENDCLASS.
