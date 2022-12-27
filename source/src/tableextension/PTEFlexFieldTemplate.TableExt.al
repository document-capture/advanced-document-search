tableextension 61160 "PTE FlexField Template" extends "CDC Template"
{
    fields
    {
        field(61160; "Field 1"; Code[20])
        {
            Caption = 'Field 1';
            DataClassification = CustomerContent;
            TableRelation = "CDC Template Field".Code WHERE("Template No." = FIELD("No."),
                                                             Type = CONST(Header));
            ValidateTableRelation = true;
        }
        field(61161; "Field 2"; Code[20])
        {
            Caption = 'Field 2';
            DataClassification = CustomerContent;
            TableRelation = "CDC Template Field".Code WHERE("Template No." = FIELD("No."),
                                                             Type = CONST(Header));
            ValidateTableRelation = true;
        }
        field(61162; "Field 3"; Code[20])
        {
            Caption = 'Field 3';
            DataClassification = CustomerContent;
            TableRelation = "CDC Template Field".Code WHERE("Template No." = FIELD("No."),
                                                             Type = CONST(Header));
        }
        field(61163; "Field 4"; Code[20])
        {
            Caption = 'Field 4';
            DataClassification = CustomerContent;
            TableRelation = "CDC Template Field".Code WHERE("Template No." = FIELD("No."),
                                                             Type = CONST(Header));
            ValidateTableRelation = true;
        }
    }
}
