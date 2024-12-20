# ABAP value objects
This repository provides a collection of value objects, including:

* [Date and Time](src/zcl_vo_date.clas.abap)
* [Unit of measurement](src/zcl_vo_uom.clas.abap)
* [Quantity](src/zcl_vo_quantity.clas.abap)
* [Quantity for materials](src/zcl_vo_quantity_material.clas.abap)
* [Mass quantity for materials](src/zcl_vo_quantity_material_mass.clas.abap)
* [Currency](src/zcl_vo_currency.clas.abap)
* [Money](src/zcl_vo_money.clas.abap)

The [abstract superclass](src/zcl_value_object.clas.abap) provides core functionality for all value objects. All classes use the same [exception class](src/zcx_value_object.clas.abap).

SAP Basis Component: 757 SP 4 or higher

ABAP Language Version: ABAP for Cloud Development

```ABAP
DATA(length1) = NEW zcl_vo_quantity( i_quantity = 15
                                     i_uom      = NEW #( 'm' ) ).
DATA(length2) = NEW zcl_vo_quantity( i_quantity = 150
                                     i_uom      = NEW #( 'cm' ) ).
length1->add( length2 )->get_quantity( ). "16.5
length2->add( length1 )->get_quantity( ). "1650
```
