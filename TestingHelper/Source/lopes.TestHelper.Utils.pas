unit lopes.TestHelper.Utils;

interface

uses
  Winapi.Windows,
  Vcl.Menus,
  ToolsAPI,
  Vcl.Graphics,
  System.Classes,
  System.Contnrs,
  System.SysUtils,
  Vcl.ComCtrls,
  System.Generics.Collections,
  Vcl.ActnList;

type
  TProcInfoType = (pitEXE, pitParam, pitDir);

  TCustoMessage = class(TNotifierObject, IOTACustomMessage, INTACustomDrawMessage)
  strict private
    FMsg: String;
    FFonteName: String;
    FForeColour: TColor;
    FStyle: TFontStyles;
    FBackColour: TColor;
    FMessagePntr: Pointer;
  strict protected
    procedure SetForeColour(iColour: TColor);
  public
    constructor Create(strMsg: String; FontName: String; ForeColour: TColor = clBlack; Style: TFontStyles = []; BackColour: TColor = clWindow);

    property ForeColour: TColor write SetForeColour;

    Property MessagePntr: Pointer Read FMessagePntr Write FMessagePntr;
    Function GetColumnNumber: Integer;
    Function GetFileName: String;
    Function GetLineNumber: Integer;
    Function GetLineText: String;
    Procedure ShowHelp;
    Function CalcRect(Canvas: TCanvas; MaxWidth: Integer; Wrap: Boolean): TRect;
    Procedure Draw(Canvas: TCanvas; Const Rect: TRect; Wrap: Boolean);
  end;

  TClearMessage = (cmCompiler, cmSearch, cmTool);
  TClearMessages = Set of TClearMessage;

  TVersionInfo = Record
    iMajor: Integer;
    iMinor: Integer;
    iBugfix: Integer;
    iBuild: Integer;
  End;

  THelperUtils = class
    class function AddImageToIDE(strImageName: String; iMaskColour: TColor): Integer;
    class function CreateMenuItem(strName, strCaption, strParentMenu: String; ClickProc, UpdateProc: TNotifyEvent; boolBefore, boolChildMenu: Boolean; strShortCut: String; iMaskColour: TColor = clLime): TMenuItem;
    class function FindMenuItem(strParentMenu: String): TMenuItem;
    class function IterateSubMenus(strParentMenu: String; Menu: TMenuItem): TMenuItem;
    class procedure PatchActionShortcuts(Sender: TObject);
    class procedure RemoveToolbarButtonsAssociatedWithActions;
    class function IsCustomAction(Action: TBasicAction): Boolean;
    class procedure RemoveAction(Tb: TToolbar);
    class function Actions: TObjectList<TAction>;
    class function ITHHTMLHelpFile(strContext: String = ''): String;
    class procedure OutPutText(Writer: IOTAEditWriter; iIndent: Integer; strText: String);
    class function AddMsg(strText: String; boolGroup, boolAutoScroll: Boolean; strFontName: String; iForeColour: TColor; fsStyle: TFontStyles; iBackColour: TColor = clWindow; ptrParent: Pointer = Nil): Pointer;
    class function EditorAsString(SourceEditor: IOTASourceEditor): String;
    class function SourceEditor(Module: IOTAModule): IOTASourceEditor;
    class function ActiveSourceEditor: IOTASourceEditor;
    class function ProjectModule(project: IOTAProject): IOTAModule;
    class function ActiveProject: IOTAProject;
    class function ProjectGroup: IOTAProjectGroup;
    class function GetProjectName(project: IOTAProject): String;
    class procedure OutputMessage(strText: String); Overload;
    class procedure OutputMessage(strText: String; strGroupName: String); Overload;
    class procedure OutputMessage(strFileName, strText, strPrefix: String; iLine, iCol: Integer); overload;
    class function ExpandMacro(strPath: String; project: IOTAProject): String;
    class procedure ShowMessages(strGroupName: String = '');
    class procedure ClearMessages(Msg: TClearMessages);
    class procedure ShowHelperMessages;
    class procedure BuildNumber(var VersionInfo: TVersionInfo);
    class function GetProcInfo(strText: String; ProcInfoType: TProcInfoType): String;
    class function ResolvePath(Const strFName, strPath: String): String;

  end;

implementation

uses
  Vcl.Forms,
  Vcl.Controls;

resourcestring
  strITHelperGroup = 'ITHelper';

  { THelperUtils }

var
  FOTAActions: TObjectList<TAction>;

class function THelperUtils.Actions: TObjectList<TAction>;
begin
  Result := FOTAActions;
end;

class function THelperUtils.ActiveProject: IOTAProject;
var
  vProjectActive: IOTAProjectGroup;
begin
  Result := nil;
  vProjectActive := THelperUtils.ProjectGroup;
  if vProjectActive <> nil then
    Result := vProjectActive.ActiveProject;
end;

class function THelperUtils.ActiveSourceEditor: IOTASourceEditor;
var
  CM: IOTAModule;
begin
  Result := nil;
  if BorlandIDEServices = nil then
    Exit;
  CM := (BorlandIDEServices as IOTAModuleServices).CurrentModule;
  Result := THelperUtils.SourceEditor(CM);
end;

class function THelperUtils.AddImageToIDE(strImageName: String; iMaskColour: TColor): Integer;
var
  NTAS: INTAServices;
  iIImages: TImageList;
  BM: TBitmap;
begin
  Result := -1;
  if FindResource(HInstance, PChar(strImageName + 'Image'), RT_BITMAP) > 0 then
  begin
    NTAS := (BorlandIDEServices as INTAServices);
    iIImages := TImageList.Create(nil);
    try
      BM := TBitmap.Create;
      try
        BM.LoadFromResourceName(HInstance, strImageName + 'Image');
        iIImages.AddMasked(BM, iMaskColour);
        Result := NTAS.AddImages(iIImages);
      finally
        BM.Free;
      end;
    finally
      iIImages.Free;
    end;
  end;
end;

class function THelperUtils.AddMsg(strText: String; boolGroup, boolAutoScroll: Boolean; strFontName: String; iForeColour: TColor; fsStyle: TFontStyles; iBackColour: TColor; ptrParent: Pointer): Pointer;

Const
  strMessageGroupName = 'My Custom Messages';

Var
  M: TCustoMessage;
  G: IOTAMessageGroup;

Begin
  With (BorlandIDEServices As IOTAMessageServices) Do
  Begin
    M := TCustoMessage.Create(strText, strFontName, iForeColour, fsStyle, iBackColour);
    Result := M;
    If ptrParent = Nil Then
    Begin
      G := Nil;
      If boolGroup Then
        G := AddMessageGroup(strMessageGroupName)
      Else
        G := GetMessageGroup(0);
      If boolAutoScroll <> G.AutoScroll Then
        G.AutoScroll := boolAutoScroll;
      M.MessagePntr := AddCustomMessagePtr(M As IOTACustomMessage, G);
      AddCustomMessage(M As IOTACustomMessage, G);
      AddCustomMessage(M As IOTACustomMessage);
    End
    Else
      AddCustomMessage(M As IOTACustomMessage, ptrParent);
  End;
end;

class procedure THelperUtils.BuildNumber(var VersionInfo: TVersionInfo);
Var
  VerInfoSize: DWORD;
  VerInfo: Pointer;
  VerValueSize: DWORD;
  VerValue: PVSFixedFileInfo;
  Dummy: DWORD;
  strBuffer: Array [0 .. MAX_PATH] Of Char;
begin
  GetModuleFileName(HInstance, strBuffer, MAX_PATH);
  VerInfoSize := GetFileVersionInfoSize(strBuffer, Dummy);
  if VerInfoSize <> 0 then
  begin
    GetMem(VerInfo, VerInfoSize);
    try
      GetFileVersionInfo(strBuffer, 0, VerInfoSize, VerInfo);
      VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
      VersionInfo.iMajor := VerValue^.dwFileVersionMS shr 16;
      VersionInfo.iMinor := VerValue^.dwFileVersionMS and $FFFF;
      VersionInfo.iBugfix := VerValue^.dwFileVersionLS shr 16;
      VersionInfo.iBuild := VerValue^.dwFileVersionLS and $FFFF;
    finally
      FreeMem(VerInfo, VerInfoSize);
    end;
  end;
end;

class procedure THelperUtils.ClearMessages(Msg: TClearMessages);
begin
  if cmCompiler in Msg then
    (BorlandIDEServices as IOTAMessageServices).ClearCompilerMessages;
  if cmSearch in Msg then
    (BorlandIDEServices as IOTAMessageServices).ClearSearchMessages;
  if cmTool in Msg then
    (BorlandIDEServices as IOTAMessageServices).ClearToolMessages;
end;

class function THelperUtils.CreateMenuItem(strName, strCaption, strParentMenu: String; ClickProc, UpdateProc: TNotifyEvent; boolBefore, boolChildMenu: Boolean; strShortCut: String; iMaskColour: TColor): TMenuItem;
var
  NTAS: INTAServices;
  vAction: TAction;
  miMenuItem: TMenuItem;
  iImageIndex: Integer;
begin

  NTAS := (BorlandIDEServices as INTAServices);
  iImageIndex := AddImageToIDE(strName, iMaskColour);

  vAction := nil;
  Result := TMenuItem.Create(NTAS.MainMenu);
  if Assigned(ClickProc) then
  begin
    vAction := TAction.Create(NTAS.ActionList);
    vAction.ActionList := NTAS.ActionList;
    vAction.Name := strName + 'Action';
    vAction.Caption := strCaption;
    vAction.OnExecute := ClickProc;
    vAction.OnUpdate := UpdateProc;
    vAction.ShortCut := TextToShortCut(strShortCut);
    vAction.Tag := TextToShortCut(strShortCut);
    vAction.ImageIndex := iImageIndex;
    vAction.Category := 'ITHelperMenus';
    FOTAActions.Add(vAction);
  end
  else if not strCaption.IsEmpty then
  begin
    Result.Caption := strCaption;
    Result.ShortCut := TextToShortCut(strShortCut);
    Result.ImageIndex := iImageIndex;
  end
  else
    Result.Caption := '-';

  Result.Action := vAction;
  Result.Name := strName + 'Menu';
  miMenuItem := FindMenuItem(strParentMenu + 'Menu');
  If miMenuItem <> Nil Then
  Begin
    If Not boolChildMenu Then
    Begin
      If boolBefore Then
        miMenuItem.Parent.Insert(miMenuItem.MenuIndex, Result)
      Else
        miMenuItem.Parent.Insert(miMenuItem.MenuIndex + 1, Result);
    End
    Else
      miMenuItem.Add(Result);
  End;

end;

class function THelperUtils.EditorAsString(SourceEditor: IOTASourceEditor): String;
const
  iBufferSize: Integer = 1024;

var
  vReader: IOTAEditReader;
  iRead: Integer;
  iPosition: Integer;
  strBuffer: AnsiString;
begin
  Result := EmptyStr;
  vReader := SourceEditor.CreateReader;
  try
    iPosition := 0;
    repeat
      SetLength(strBuffer, iBufferSize);
      iRead := vReader.GetText(iPosition, PAnsiChar(strBuffer), iBufferSize);
      SetLength(strBuffer, iRead);
      Result := Result + String(strBuffer);
      Inc(iPosition, iRead);

    until iRead < iBufferSize;
  finally
    vReader := nil;
  end;
end;

class function THelperUtils.ExpandMacro(strPath: String; project: IOTAProject): String;
begin
  Result := strPath;
  Result := StringReplace(Result, '{$PROJPATH$}', ExtractFilePath(project.FileName), [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '{$PROJDRIVE$}', ExtractFileDrive(project.FileName), [rfReplaceAll, rfIgnoreCase]);
end;

class function THelperUtils.FindMenuItem(strParentMenu: String): TMenuItem;
var
  iMenu: Integer;
  NTAS: INTAServices;
  Items: TMenuItem;
begin
  Result := nil;
  NTAS := (BorlandIDEServices as INTAServices);
  for iMenu := 0 to NTAS.MainMenu.Items.Count - 1 do
  begin
    Items := NTAS.MainMenu.Items;
    if CompareText(strParentMenu, Items[iMenu].Name) = 0 then
      Result := Items[iMenu]
    else
      Result := IterateSubMenus(strParentMenu, Items);

    if Assigned(Result) then
      Break;
  end;
end;

class function THelperUtils.GetProcInfo(strText: String; ProcInfoType: TProcInfoType): String;
Var
  iPos: Integer;

Begin
  Result := '';
  iPos := Pos('|', strText);
  If iPos > 0 Then
  Begin
    Result := Copy(strText, 1, iPos - 1);
    If ProcInfoType = pitEXE Then
      Exit;
    Delete(strText, 1, iPos);
    iPos := Pos('|', strText);
    If iPos > 0 Then
    Begin
      Result := Copy(strText, 1, iPos - 1);
      If ProcInfoType = pitParam Then
        Exit;
      Delete(strText, 1, iPos);
      Result := strText;
    End;
  End;
end;

class function THelperUtils.GetProjectName(project: IOTAProject): String;
var
  i: Integer;
  strText: String;
begin
  Result := ExtractFileName(project.FileName);
  for i := 0 to project.ModuleFileCount - 1 do
  begin
    strText := LowerCase(ExtractFileExt(project.ModuleFileEditors[i].FileName));
    if (strText = 'dpr') or (strText = 'dpk') then
    begin
      Result := ChangeFileExt(Result, strText);
      Break;
    end;
  end;
end;

class function THelperUtils.IsCustomAction(Action: TBasicAction): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to FOTAActions.Count - 1 do
  begin
    if Action = FOTAActions[i] then
    begin
      Result := True;
      Break;
    end;
  end;
end;

class function THelperUtils.IterateSubMenus(strParentMenu: String; Menu: TMenuItem): TMenuItem;
var
  iSubMenu: Integer;
begin
  Result := nil;
  for iSubMenu := 0 to Menu.Count - 1 do
  begin
    if CompareText(strParentMenu, Menu.Items[iSubMenu].Name) = 0 then
      Result := Menu.Items[iSubMenu]
    else
      Result := Menu[iSubMenu];

    if Result <> nil then
      Break;
  end;

end;

class function THelperUtils.ITHHTMLHelpFile(strContext: String): String;
var
  iSize: Cardinal;
begin
  SetLength(Result, MAX_PATH);
  iSize := GetModuleFileName(HInstance, PChar(Result), MAX_PATH);
  SetLength(Result, iSize);
  Result := ExtractFilePath(Result) + 'IThelper.chm';
  if strContext <> '' then
    Result := Result + Format('::/%s.html', [strContext]);
end;

class procedure THelperUtils.OutputMessage(strText: String);
begin
  (BorlandIDEServices as IOTAMessageServices).AddTitleMessage(strText);
end;

class procedure THelperUtils.OutputMessage(strFileName, strText, strPrefix: String; iLine, iCol: Integer);
begin
  (BorlandIDEServices as IOTAMessageServices).AddToolMessage(strFileName, strText, strPrefix, iLine, iCol);
end;

class procedure THelperUtils.OutputMessage(strText, strGroupName: String);
var
  vGroup: IOTAMessageGroup;
begin
  vGroup := (BorlandIDEServices as IOTAMessageServices).GetGroup(strGroupName);
  if vGroup = nil then
    vGroup := (BorlandIDEServices as IOTAMessageServices).AddMessageGroup(strGroupName);
  (BorlandIDEServices as IOTAMessageServices).AddTitleMessage(strText, vGroup);
end;

class procedure THelperUtils.OutPutText(Writer: IOTAEditWriter; iIndent: Integer; strText: String);
begin
  Writer.Insert(PAnsiChar(StringOfChar(#32, iIndent) + strText));
end;

class procedure THelperUtils.PatchActionShortcuts(Sender: TObject);
var
  iAction: Integer;
  vAction: TAction;
begin
  for iAction := 0 to FOTAActions.Count - 1 do
  begin
    vAction := FOTAActions[iAction] as TAction;
    vAction.ShortCut := vAction.Tag;
  end;
end;

class function THelperUtils.ProjectGroup: IOTAProjectGroup;
var
  aModuleService: IOTAModuleServices;
  aModule: IOTAModule;
  i: Integer;
  AProjectGroup: IOTAProjectGroup;
begin
  Result := nil;
  aModuleService := (BorlandIDEServices as IOTAModuleServices);
  for i := 0 to aModuleService.ModuleCount - 1 do
  begin
    aModule := aModuleService.Modules[i];
    if aModule.QueryInterface(IOTAProjectGroup, AProjectGroup) = S_OK then
    begin
      Break;
    end;
  end;
  Result := AProjectGroup;
end;

class function THelperUtils.ProjectModule(project: IOTAProject): IOTAModule;
var
  aModuleService: IOTAModuleServices;
  aModule: IOTAModule;
  i: Integer;
  aProject: IOTAProject;
begin
  Result := nil;
  aModuleService := (BorlandIDEServices as IOTAModuleServices);
  for i := 0 to aModuleService.ModuleCount - 1 do
  begin
    aModule := aModuleService.Modules[i];
    if (aModule.QueryInterface(IOTAProject, aProject) = S_OK) and (project = aProject) then
    begin
      Break;
    end;
  end;
  Result := aProject;
end;

class procedure THelperUtils.RemoveAction(Tb: TToolbar);
var
  i: Integer;
begin
  if Assigned(Tb) then
  begin
    for i := 0 to Tb.ButtonCount - 1 do
    begin
      if IsCustomAction(Tb.Buttons[i].Action) then
        Tb.RemoveControl(Tb.Buttons[i]);
    end;
  end;
end;

class procedure THelperUtils.RemoveToolbarButtonsAssociatedWithActions;
var
  NTAS: INTAServices;
begin
  NTAS := (BorlandIDEServices as INTAServices);
  RemoveAction(NTAS.ToolBar[sCustomToolBar]);
  RemoveAction(NTAS.ToolBar[sStandardToolBar]);
  RemoveAction(NTAS.ToolBar[sDebugToolBar]);
  RemoveAction(NTAS.ToolBar[sViewToolBar]);
  RemoveAction(NTAS.ToolBar[sDesktopToolBar]);
  RemoveAction(NTAS.ToolBar[sInternetToolBar]);
  RemoveAction(NTAS.ToolBar[sCORBAToolBar]);
  RemoveAction(NTAS.ToolBar[sAlignToolbar]);
  RemoveAction(NTAS.ToolBar[sBrowserToolbar]);
  RemoveAction(NTAS.ToolBar[sHTMLDesignToolbar]);
  RemoveAction(NTAS.ToolBar[sHTMLFormatToolbar]);
  RemoveAction(NTAS.ToolBar[sHTMLTableToolbar]);
  RemoveAction(NTAS.ToolBar[sPersonalityToolBar]);
  RemoveAction(NTAS.ToolBar[sPositionToolbar]);
  RemoveAction(NTAS.ToolBar[sSpacingToolbar]);
end;

class function THelperUtils.ResolvePath(const strFName, strPath: String): String;
Var
  strFileName: String;
  strPathName: String;
begin
  strFileName := strFName;
  strPathName := strPath;
  If strFileName[1] = '.' Then
  Begin
    Repeat
      If Copy(strFileName, 1, 2) = '.\' Then
        strFileName := Copy(strFileName, 3, Length(strFileName) - 2);
      If Copy(strFileName, 1, 3) = '..\' Then
      Begin
        strFileName := Copy(strFileName, 4, Length(strFileName) - 3);
        strPathName := ExtractFilePath(Copy(strPathName, 1, Length(strPathName) - 1));
      End;
    Until strFileName[1] <> '.';
    Result := strPathName + strFileName;
  End
  Else
  Begin
    If ExtractFilePath(strFileName) = '' Then
      Result := strPathName + strFileName
    Else
      Result := strFileName;
  End;
end;

class procedure THelperUtils.ShowHelperMessages;
var
  vGroup: IOTAMessageGroup;
begin
  vGroup := (BorlandIDEServices as IOTAMessageServices).GetGroup(strITHelperGroup);
  if Application.MainForm.Visible then
    (BorlandIDEServices as IOTAMessageServices).ShowMessageView(vGroup);

end;

class procedure THelperUtils.ShowMessages(strGroupName: String);
var
  vMessageGroup: IOTAMessageGroup;
begin
  vMessageGroup := (BorlandIDEServices as IOTAMessageServices).GetGroup(strGroupName);
  (BorlandIDEServices as IOTAMessageServices).ShowMessageView(vMessageGroup);

end;

class function THelperUtils.SourceEditor(Module: IOTAModule): IOTASourceEditor;
Var
  iFileCount: Integer;
  i: Integer;
begin
  Result := nil;
  if not Assigned(Module) then
    Exit;

  iFileCount := Module.GetModuleFileCount;
  for i := 0 to iFileCount - 1 do
  begin
    if Module.GetModuleFileEditor(i).QueryInterface(IOTASourceEditor, Result) = S_OK then
      Break;
  end;
end;

{ TCustoMessage }

function TCustoMessage.CalcRect(Canvas: TCanvas; MaxWidth: Integer; Wrap: Boolean): TRect;
begin
  Canvas.Font.Name := FFonteName;
  Canvas.Font.Style := FStyle;
  Result := Canvas.ClipRect;
  Result.Bottom := Result.Top + Canvas.TextHeight('Wp');
  Result.Right := Result.Left + Canvas.TextWidth(FMsg);
end;

constructor TCustoMessage.Create(strMsg, FontName: String; ForeColour: TColor; Style: TFontStyles; BackColour: TColor);

Const
  strValidChars: Set Of AnsiChar = [#10, #13, #32 .. #128];

Var
  i: Integer;
  iLength: Integer;

begin
  SetLength(FMsg, Length(strMsg));
  iLength := 0;
  for i := 0 to Length(strMsg) do
  begin
    if CharInSet(strMsg[i], strValidChars) then
    begin
      FMsg[iLength + 1] := strMsg[i];
      Inc(iLength);
    end;
  end;
  SetLength(FMsg, iLength);
  FFonteName := FontName;
  FForeColour := ForeColour;
  FStyle := Style;
  FBackColour := BackColour;
  FMessagePntr := Nil;
end;

procedure TCustoMessage.Draw(Canvas: TCanvas; const Rect: TRect; Wrap: Boolean);
begin
  if Canvas.Brush.Color = clWindow then
  begin
    Canvas.Font.Color := FForeColour;
    Canvas.Brush.Color := FBackColour;
    Canvas.FillRect(Rect);
  end;
  Canvas.Font.Name := FFonteName;
  Canvas.Font.Style := FStyle;
  Canvas.TextOut(Rect.Left, Rect.Top, FMsg);
end;

function TCustoMessage.GetColumnNumber: Integer;
begin
  Result := 0;
end;

function TCustoMessage.GetFileName: String;
begin
  Result := '';
end;

function TCustoMessage.GetLineNumber: Integer;
begin
  Result := 0;
end;

function TCustoMessage.GetLineText: String;
begin
  Result := FMsg;
end;

procedure TCustoMessage.SetForeColour(iColour: TColor);
begin
  if FForeColour <> iColour then
    FForeColour := iColour;

end;

procedure TCustoMessage.ShowHelp;
begin

end;

initialization

FOTAActions := TObjectList<TAction>.Create(True);

finalization

{$IFNDEF CONSOLE_TESTRUNNER}
  THelperUtils.RemoveToolbarButtonsAssociatedWithActions;
{$ENDIF}
FreeAndNil(FOTAActions);

end.
