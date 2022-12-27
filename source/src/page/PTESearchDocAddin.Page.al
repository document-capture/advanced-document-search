page 61160 "PTE SearchDoc Addin"
{
    // C/SIDE
    // revision:40

    Caption = 'Document Capture Client Addin', Locked = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    Permissions = TableData 6085780 = rimd;
    SourceTable = "CDC Document";

    layout
    {
        area(content)
        {

            usercontrol(CaptureUIWeb; "CDC Capture UI AddIn")
            {
                Visible = SHOWCAPTUREWEBUI;
                ApplicationArea = All;

                trigger OnControlAddIn(index: Integer; data: Text)
                begin
                    OnControlAddInEvent(Index, Data);
                end;

                trigger AddInReady()
                begin
                    AddInReady := TRUE;
                    UpdatePage;
                end;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        IF (Rec."Created Doc. Subtype" <> xRec."Created Doc. Subtype") OR (Rec."Created Doc. No." <> xRec."Created Doc. No.") THEN BEGIN
            UpdateImage;
            UpdateDropdownMenu;
            SendCommand(CaptureXmlDoc);
        END ELSE
            IF (SendAllPendingCommands AND (NOT CaptureXmlDoc.IsEmpty)) THEN BEGIN
                SendAllPendingCommands := FALSE;
                SendCommand(CaptureXmlDoc);
            END;
    end;

    trigger OnOpenPage()
    var
        Zoom: Decimal;
        PercentageWidth: Decimal;
    begin
        //Zoom := UserPersonalization.GetCaptureUIZoom(ParentPage);
        //IF Zoom > 0 THEN
        //    CurrZoom := Zoom
        //ELSE
        //    CurrZoom := 50;

        ShowCaptureUI := NOT WebClientMgt.IsWebClient;
        ShowCaptureWebUI := WebClientMgt.IsWebClient;

        IF NAVAppMgt.IsInstalledAsAnApp THEN BEGIN
            //PercentageWidth := UserPersonalization.GetCaptureUIPercentageWidth(ParentPage);
            //IF (PercentageWidth >= 1) AND (PercentageWidth <= 100) THEN
            //    AddInPercentageWidth := PercentageWidth
            //ELSE
            AddInPercentageWidth := 25;

            CaptureAddinLib.BuildSetAddInPercentageWidthCommand(AddInPercentageWidth, CaptureXmlDoc);
        END ELSE BEGIN
            //IF ContiniaUserProp.GET(USERID) AND (ContiniaUserProp."Add-In Min Width" > 0) THEN
            //    AddInPixelWidth := ContiniaUserProp."Add-In Min Width"
            //ELSE
            AddInPixelWidth := 725;

            CaptureAddinLib.BuildSetAddInWidthCommand(AddInPixelWidth, CaptureXmlDoc);
        END;
    end;

    var
        ContiniaUserProp: Record "CDC Continia User Property";
        TempDoc: Record "CDC Temp. Document" temporary;
        UserPersonalization: Codeunit "CDC User Personalisation Mgt.";
        CaptureAddinLib: Codeunit "CDC Capture RTC Library";
        NAVAppMgt: Codeunit "CDC NAV App Mgt.";
        WebClientMgt: Codeunit "CDC Web Client Management";
        TIFFMgt: Codeunit "CDC TIFF Management";
        DocAttachMgt: Codeunit "CDC Document Attachment Mgt.";
        CaptureXmlDoc: Codeunit "CSC XML Document";
        CaptureUISource: Text;
        Channel: Code[50];
        CurrentPageText: Text[250];
        CurrentZoomText: Text[30];
        HeaderFieldsFormName: Text[50];
        LineFieldsFormName: Text[50];
        CurrZoom: Decimal;
        CurrentPageNo: Integer;
        Text001: Label '(%1 pages in total)';
        Text002: Label 'Page %1';
        AddInReady: Boolean;
        SendAllPendingCommands: Boolean;
        DisableCapture: Boolean;
        [InDataSet]
        ShowCaptureUI: Boolean;
        ShowCaptureWebUI: Boolean;
        Text003: Label '(1 page in total)';
        AddInPercentageWidth: Decimal;
        AddInPixelWidth: Decimal;
        ParentPage: Integer;

    internal procedure UpdateImage()
    var
        TempDocFileInfo: Record "CDC Temp. Doc. File Info.";
        TempFile: Record "CDC Temp File" temporary;
        "Page": Record "CDC Document Page";
        HasImage: Boolean;
        FileName: Text[1024];
    begin
        IF Rec."No." = '' THEN BEGIN
            IF NOT WebClientMgt.IsWebClient THEN
                CaptureAddinLib.BuildSetImageCommand(FileName, TRUE, CaptureXmlDoc);
        END;

        IF Rec."File Type" = Rec."File Type"::XML THEN
            HasImage := Rec.GetVisualFile(TempFile)
        ELSE
            IF WebClientMgt.IsWebClient THEN BEGIN
                HasImage := Rec.GetPngFile(TempFile, 1);
                IF NOT HasImage THEN
                    HasImage := Rec.GetTiffFile(TempFile);
            END ELSE
                HasImage := Rec.GetTiffFile(TempFile);

        IF (FileName = '') AND NOT HasImage THEN BEGIN
            CaptureAddinLib.BuildClearImageCommand(CaptureXmlDoc);
            UpdateCurrPageNo(0);
            EXIT;
        END ELSE
            IF (FileName = '') AND NOT WebClientMgt.IsWebClient THEN BEGIN
                FileName := TempFile.GetClientFilePath;
                CaptureAddinLib.BuildSetImageCommand(FileName, TRUE, CaptureXmlDoc);
            END ELSE
                IF Rec."File Type" = Rec."File Type"::XML THEN
                    CaptureAddinLib.BuildSetImageDataCommand(TempFile.GetContentAsDataUrl, TRUE, CaptureXmlDoc);

        UpdateCurrPageNo(1);

        CaptureAddinLib.BuildScrollTopCommand(CaptureXmlDoc);

        // IF (UserPersonalization.GetCaptureUIZoom(ParentPage) = 0) AND (Page.GET("No.", 1)) AND (Page.Width > 0) THEN BEGIN
        //     IF NOT NAVAppMgt.IsInstalledAsAnApp THEN
        //         CurrZoom := ROUND(((AddInPixelWidth - 50) / Page.Width) * 100, 1, '<')
        //     ELSE
        //         CurrZoom := 25;
        // END ELSE
        //     CurrZoom := UserPersonalization.GetCaptureUIZoom(ParentPage);
        CurrZoom := 25;
        Zoom(CurrZoom, FALSE);

        IF Rec."No. of Pages" = 1 THEN
            CaptureAddinLib.BuildTotalNoOfPagesTextCommand(Text003, CaptureXmlDoc)
        ELSE
            CaptureAddinLib.BuildTotalNoOfPagesTextCommand(STRSUBSTNO(Text001, Rec."No. of Pages"), CaptureXmlDoc);
    end;

    internal procedure UpdateCurrPageNo(PageNo: Integer)
    var
        TempFile: Record "CDC Temp File" temporary;
        ImageManagement: Codeunit "CDC Image Management";
        ImageDataUrl: Text;
    begin
        Rec.CALCFIELDS("No. of Pages");

        CurrentPageNo := PageNo;
        CurrentPageText := STRSUBSTNO(Text002, CurrentPageNo);

        IF (WebClientMgt.IsWebClient AND (PageNo > 0)) THEN BEGIN
            IF Rec.GetPngFile(TempFile, PageNo) THEN
                ImageDataUrl := ImageManagement.GetImageDataAsJpegDataUrl(TempFile, 100)
            ELSE BEGIN
                IF Rec.GetTiffFile(TempFile) THEN
                    ImageDataUrl := TIFFMgt.GetPageAsDataUrl(TempFile, PageNo, FALSE);
            END;

            IF ImageDataUrl <> '' THEN
                CaptureAddinLib.BuildSetImageDataCommand(ImageDataUrl, TRUE, CaptureXmlDoc);
        END;

        CaptureAddinLib.BuildSetActivePageCommand(PageNo, CurrentPageText, CaptureXmlDoc);
    end;

    internal procedure ParsePageText(PageText: Text[30])
    var
        NewPageNo: Integer;
    begin
        IF STRPOS(PageText, ' ') = 0 THEN BEGIN
            IF EVALUATE(NewPageNo, PageText) THEN;
        END ELSE
            IF EVALUATE(NewPageNo, COPYSTR(PageText, STRPOS(PageText, ' '))) THEN;

        Rec.CALCFIELDS("No. of Pages");
        IF (NewPageNo <= 0) OR (NewPageNo > Rec."No. of Pages") THEN
            UpdateCurrPageNo(CurrentPageNo)
        ELSE
            UpdateCurrPageNo(NewPageNo);
    end;

    internal procedure Zoom(ZoomPct: Decimal; UpdateUserProp: Boolean)
    begin
        IF ZoomPct < 1 THEN
            ZoomPct := 1;
        CurrZoom := ZoomPct;
        CurrentZoomText := FORMAT(CurrZoom) + '%';

        // IF UpdateUserProp THEN BEGIN
        //     IF UserPersonalization.GetCaptureUIZoom(ParentPage) <> CurrZoom THEN
        //         UserPersonalization.SetCaptureUIZoom(CurrZoom, ParentPage);
        // END;

        CaptureAddinLib.BuildZoomCommand(CurrZoom, CaptureXmlDoc);
        CaptureAddinLib.BuildZoomTextCommand(CurrentZoomText, CaptureXmlDoc);
    end;

    internal procedure SendCommand(var XmlDoc: Codeunit "CSC XML Document")
    var
        NewXmlDoc: Codeunit "CSC XML Document";
    begin
        IF NOT AddInReady AND WebClientMgt.IsWebClient THEN
            EXIT;

        CaptureAddinLib.XmlToText(XmlDoc, CaptureUISource);
        CaptureAddinLib.TextToXml(NewXmlDoc, CaptureUISource);

        IF WebClientMgt.IsWebClient THEN
            CurrPage.CaptureUIWeb.SourceValueChanged(CaptureUISource);

        CLEAR(CaptureXmlDoc);
    end;

    internal procedure SetConfig(NewHeaderFieldsFormName: Text[50]; NewLineFieldsFormName: Text[50]; NewChannel: Code[50])
    begin
        HeaderFieldsFormName := NewHeaderFieldsFormName;
        LineFieldsFormName := NewLineFieldsFormName;
        Channel := NewChannel;
    end;

    internal procedure HandleSimpleCommand(Command: Text[1024])
    begin
        CASE Command OF
            'ZoomIn':
                Zoom(ROUND(CurrZoom, 5, '<') + 5, TRUE);

            'ZoomOut':
                Zoom(ROUND(CurrZoom, 5, '>') - 5, TRUE);

            'FirstPage':
                BEGIN
                    Rec.CALCFIELDS("No. of Pages");
                    IF Rec."No. of Pages" > 0 THEN
                        UpdateCurrPageNo(1);
                END;

            'NextPage':
                BEGIN
                    Rec.CALCFIELDS("No. of Pages");
                    IF CurrentPageNo < Rec."No. of Pages" THEN
                        UpdateCurrPageNo(CurrentPageNo + 1);
                END;

            'PrevPage':
                BEGIN
                    IF CurrentPageNo > 1 THEN
                        UpdateCurrPageNo(CurrentPageNo - 1);
                END;

            'LastPage':
                BEGIN
                    Rec.CALCFIELDS("No. of Pages");
                    UpdateCurrPageNo(Rec."No. of Pages");
                END;
        END;

        SendCommand(CaptureXmlDoc);
    end;

    internal procedure HandleXmlCommand(Command: Text[1024]; var InXmlDoc: Codeunit "CSC XML Document")
    var
        Document: Record "CDC Document";
        XmlLib: Codeunit "CDC Xml Library";
        DocumentElement: Codeunit "CSC XML Node";
        PercentageWidth: Decimal;
        DocumentNo: Code[20];
    begin
        InXmlDoc.GetDocumentElement(DocumentElement);
        CASE Command OF
            'UpdateWidth':
                BEGIN
                    //PercentageWidth := XmlLib.Text2Dec(XmlLib.GetNodeText(DocumentElement, 'PercentageWidth'));
                    //AddInPixelWidth := XmlLib.Text2Dec(XmlLib.GetNodeText(DocumentElement, 'PixelWidth'));

                    IF (PercentageWidth >= 1) AND (PercentageWidth <= 100) THEN
                        AddInPercentageWidth := PercentageWidth
                    ELSE
                        AddInPercentageWidth := 25;

                    //UserPersonalization.SetCaptureUIPercentageWidth(AddInPercentageWidth, ParentPage);
                END;

            'ZoomTextChanged':
                BEGIN
                    CurrentZoomText := XmlLib.GetNodeText(DocumentElement, 'Text');
                    IF EVALUATE(CurrZoom, DELCHR(CurrentZoomText, '=', '%')) THEN;
                    Zoom(CurrZoom, TRUE);
                END;

            'PageTextChanged':
                BEGIN
                    CurrentPageText := XmlLib.GetNodeText(DocumentElement, 'Text');
                    ParsePageText(CurrentPageText);
                END;

            'ChangePage':
                UpdateCurrPageNo(XmlLib.Text2Int(XmlLib.GetNodeText(DocumentElement, 'NewPageNo')));

            'InfoPaneResized':

                AddInPercentageWidth := XmlLib_Text2Dec(XmlLib.GetNodeText(DocumentElement, 'Width'));

            'DropdownOptionSelected':
                BEGIN
                    DocumentNo := XmlLib.GetNodeText(DocumentElement, 'File');
                    Document.GET(DocumentNo);
                    DisplayDocument(Document);
                END;
        END;

        IF NOT CaptureXmlDoc.IsEmpty THEN
            SendCommand(CaptureXmlDoc);
    end;

    internal procedure XmlLib_Text2Dec(Text: Text) Dec: Decimal
    begin
        IF Text = '' THEN
            EXIT(0);

        Text := CONVERTSTR(Text, '.', GetDecSep);
        EVALUATE(Dec, Text);
    end;

    internal procedure GetDecSep(): Text[1]
    begin
        EXIT(COPYSTR(FORMAT(1.1), 2, 1));
    end;

    local procedure DisplayDocument(Document: Record "CDC Document")
    var
        TempFile: Record "CDC Temp File" temporary;
        ImageMgt: Codeunit "CDC Image Management";
        PdfMgt: Codeunit "CDC PDF Management";
        ImageDataUrl: Text;
    begin
        // IF (Document."File Type" = Document."File Type"::OCR) THEN
        //     UpdateImage
        // ELSE
        //     IF (Document."File Type" = Document."File Type"::XML) THEN BEGIN
        //         Document.GetVisualFile(TempFile);
        //         ImageDataUrl := TempFile.GetContentAsDataUrl;
        //     END ELSE BEGIN
        //         Document.GetMiscFile(TempFile);
        //         CASE TRUE OF
        //             ImageMgt.FileIsTiff(TempFile):
        //                 ImageDataUrl := TIFFMgt.GetPageAsDataUrl(TempFile, 1, FALSE);
        //             ImageMgt.FileIsImage(TempFile) OR PdfMgt.FileIsPDF(TempFile):
        //                 ImageDataUrl := TempFile.GetContentAsDataUrl;
        //             ELSE BEGIN
        //                 DocAttachMgt.DownloadAttachmentFiles(TempFile, Document);

        //                 IF WebClientMgt.IsWebClient THEN BEGIN
        //                     TempFile.Name := Document.GetDocFileDescription + '.' + Document."File Extension";
        //                     TempFile.Open;
        //                 END;
        //             END;
        //         END;
        //     END;

        IF ImageDataUrl <> '' THEN
            CaptureAddinLib.BuildSetImageDataCommand(ImageDataUrl, TRUE, CaptureXmlDoc);
    end;

    internal procedure SetSendAllPendingCommands(NewSendAllPendingCommands: Boolean)
    begin
        SendAllPendingCommands := NewSendAllPendingCommands;
    end;

    internal procedure SetDisableCapture(NewDisableCapture: Boolean)
    begin
        DisableCapture := NewDisableCapture;
    end;

    internal procedure SetParentPage(ParentPageID: Text)
    begin
        EVALUATE(ParentPage, COPYSTR(ParentPageID, 6, STRLEN(ParentPageID) - 5));
    end;

    internal procedure ClearImage()
    var
        TempDocFileInfo: Record "CDC Temp. Doc. File Info.";
    begin
        CaptureAddinLib.BuildClearImageCommand(CaptureXmlDoc);
        UpdateCurrPageNo(0);
        SendCommand(CaptureXmlDoc);
        CurrPage.UPDATE(FALSE);
    end;

    internal procedure UpdatePage()
    begin
        UpdateImage;
        CaptureAddinLib.BuildCaptureEnabledCommand(FALSE, CaptureXmlDoc);
        SendCommand(CaptureXmlDoc);
        CurrPage.UPDATE(FALSE);
    end;

    local procedure UpdateDropdownMenu()
    begin
        //DocAttachMgt.GetAttachments(Rec, TempDoc);
        //CaptureAddinLib.BuildSetDropdownOptionValuesCommand(TempDoc, CaptureXmlDoc);
    end;

    internal procedure Reload()
    begin
        UpdateDropdownMenu;
        UpdateImage;
        SendCommand(CaptureXmlDoc);
    end;

    internal procedure SetDocument(var Document: Record "CDC Document"; IsNew: Boolean)
    begin
        Rec.COPYFILTERS(Document);

        if IsNew then
            if Rec.Get(Document."No.") then begin
                UpdateImage;
                UpdateDropdownMenu;
                SendCommand(CaptureXmlDoc);
            end;

        CurrPage.UPDATE(FALSE);
    end;

    local procedure OnControlAddInEvent(Index: Integer; Data: Variant)
    var
        InXmlDoc: Codeunit "CSC XML Document";
        DocumentElement: Codeunit "CSC XML Node";
        XmlLib: Codeunit "CDC Xml Library";
    begin
        IF Index = 0 THEN
            HandleSimpleCommand(Data)
        ELSE BEGIN
            CaptureAddinLib.TextToXml(InXmlDoc, Data);
            InXmlDoc.GetDocumentElement(DocumentElement);
            IF WebClientMgt.IsWebClient THEN
                HandleXmlCommand(XmlLib.GetNodeText(DocumentElement, 'Event'), InXmlDoc)
            ELSE
                HandleXmlCommand(XmlLib.GetNodeText(DocumentElement, 'Command'), InXmlDoc);
        END;
    end;
}
