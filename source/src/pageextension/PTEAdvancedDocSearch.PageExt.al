pageextension 61161 "PTE Advanced Doc Search" extends "CDC Document Search"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part(DocSearchAddIn; "PTE SearchDoc Addin")
            {
                ApplicationArea = All;
                AccessByPermission = tabledata "CDC Record ID Tree" = R;
                ShowFilter = false;
                Visible = true;
                SubPageLink = "No." = field("Document No.");
            }
        }

        addafter(Repeater)
        {
            group(FlexField)
            {
                Visible = FlexFieldsFound;
                field(FlexField1; FlexFieldValue[1])
                {
                    ApplicationArea = All;
                    CaptionClass = FlexFieldCaption[1];
                    ToolTip = 'Specifies text to search.';
                    Editable = false;
                }
                field(FlexField2; FlexFieldValue[2])
                {
                    ApplicationArea = All;
                    CaptionClass = FlexFieldCaption[2];
                    ToolTip = 'Specifies text to search.';
                    Editable = false;
                }
                field(FlexField3; FlexFieldValue[3])
                {
                    ApplicationArea = All;
                    CaptionClass = FlexFieldCaption[3];
                    ToolTip = 'Specifies text to search.';
                    Editable = false;
                }
                field(FlexField4; FlexFieldValue[4])
                {
                    ApplicationArea = All;
                    CaptionClass = FlexFieldCaption[4];
                    ToolTip = 'Specifies text to search.';
                    Editable = false;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        Document: Record "CDC Document";
        DocTemplate: Record "CDC Template";
        MasterTemplate: Record "CDC Template";
        TemplateField: Record "CDC Template Field";
        FlexFieldQty: Integer;
        i: Integer;
    begin
        Clear(FlexFieldCaption);
        Clear(FlexFieldValue);
        Clear(FlexFieldsFound);

        if not Document.Get(Rec."Document No.") then
            CurrPage.DocSearchAddIn.Page.ClearImage()
        else begin
            CurrPage.DocSearchAddIn.Page.SetDocument(Document, (xRec."Document No." <> Rec."Document No."));

            if DocTemplate.Get(Document."Template No.") then
                //TODO handle PDF and XML template if DocTemplate."Data Type" = DocTemplate."Data Type"::PDF then
                if MasterTemplate.Get(DocTemplate."Master Template No.") then begin
                    if MasterTemplate."Field 1" <> '' then begin
                        FlexFieldQty += 1;
                        if TemplateField.Get(MasterTemplate."No.", TemplateField.Type, MasterTemplate."Field 1") then begin
                            FlexFieldCaption[FlexFieldQty] := TemplateField."Field Name";
                            FlexFieldValue[FlexFieldQty] := CaptureMgt.GetValueAsText(Document."No.", 0, TemplateField);
                        end;
                    end;

                    if MasterTemplate."Field 2" <> '' then begin
                        FlexFieldQty += 1;
                        if TemplateField.Get(MasterTemplate."No.", TemplateField.Type, MasterTemplate."Field 2") then begin
                            FlexFieldCaption[FlexFieldQty] := TemplateField."Field Name";
                            FlexFieldValue[FlexFieldQty] := CaptureMgt.GetValueAsText(Document."No.", 0, TemplateField);
                        end;
                    end;

                    if MasterTemplate."Field 3" <> '' then begin
                        FlexFieldQty += 1;
                        if TemplateField.Get(MasterTemplate."No.", TemplateField.Type, MasterTemplate."Field 3") then begin
                            FlexFieldCaption[FlexFieldQty] := TemplateField."Field Name";
                            FlexFieldValue[FlexFieldQty] := CaptureMgt.GetValueAsText(Document."No.", 0, TemplateField);
                        end;
                    end;

                    if MasterTemplate."Field 4" <> '' then begin
                        FlexFieldQty += 1;
                        if TemplateField.Get(MasterTemplate."No.", TemplateField.Type, MasterTemplate."Field 4") then begin
                            FlexFieldCaption[FlexFieldQty] := TemplateField."Field Name";
                            FlexFieldValue[FlexFieldQty] := CaptureMgt.GetValueAsText(Document."No.", 0, TemplateField);
                        end;
                    end;
                end;

            FlexFieldsFound := FlexFieldQty > 0;
        end;
    end;

    var
        DocInvoiceNo: Code[20];
        CaptureMgt: Codeunit "CDC Capture Management";
        CaptureEngine: Codeunit "CDC Capture Engine";
        FlexFieldCaption: array[10] of Text[250];
        FlexFieldValue: array[10] of Text[250];
        [InDataSet]
        FlexFieldsFound: Boolean;
}
