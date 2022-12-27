pageextension 61160 "PTE DocSearch FlexField Info" extends "CDC Template Card"
{
    layout
    {
        addafter(Codeunits)
        {
            group(DocSeachFlexFields)
            {
                Caption = 'Document Search FlexFields';
                Visible = IsMasterTemplate;

                field("FlexField1"; Rec."Field 1")
                {
                    ApplicationArea = All;
                }
                field("FlexField2"; Rec."Field 2")
                {
                    ApplicationArea = All;
                }
                field("FlexField3"; Rec."Field 3")
                {
                    ApplicationArea = All;
                }
                field("FlexField4"; Rec."Field 4")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        IsMasterTemplate := (Rec.Type = Rec.Type::Master);
    end;

    var
        [InDataSet]
        IsMasterTemplate: Boolean;
}
