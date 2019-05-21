unit KeyBoardAndDebuggin;

interface

uses ToolsApi, System.Classes, Vcl.Menus, SysUtils, Windows;

type
  TDebuggingOTAExample = class(TNotifierObject, IOTAWizard)
  private
    procedure Execute;
    function GetIDString: string;
    function GetName: string;
    function GetState: TWizardState;

  public
    constructor Create;
    destructor Destroy; override;

  end;

  TKeyboardOTABinding = class(TNotifierObject, IOTAKeyboardBinding)
  private
    Procedure AddBreakpoint(const Context: IOTAKeyContext; KeyCode: TShortcut;
      var BindingResult: TKeyBindingResult);

    procedure BindKeyboard(const BindingServices: IOTAKeyBindingServices);
    function GetBindingType: TBindingType;
    function GetDisplayName: string;
    function GetName: string;
    function SourceEditor(Module: IOTAModule): IOTASourceEditor;

  public

  end;

procedure Register;

Function InitialiseWizard(BIDES: IBorlandIDEServices): TDebuggingOTAExample;

implementation

{ TKeyboardBinding }

uses Vcl.Forms;

Var
  iWizardIndex: Integer = 0;
  iKeyBindingIndex: Integer = 0;

procedure Register;
begin

  iWizardIndex := (BorlandIDEServices As IOTAWizardServices)
    .AddWizard(TDebuggingOTAExample.Create);
  //Application.Handle := (BorlandIDEServices As IOTAServices).GetParentHandle;
  iKeyBindingIndex := (BorlandIDEServices As IOTAKeyboardServices)
    .AddKeyboardBinding(TKeyboardOTABinding.Create);
end;

Function InitialiseWizard(BIDES: IBorlandIDEServices): TDebuggingOTAExample;
begin
  Result := TDebuggingOTAExample.Create;

end;

Function TKeyboardOTABinding.SourceEditor(Module: IOTAModule): IOTASourceEditor;
Var
  iFileCount: Integer;
  i: Integer;
Begin
  Result := Nil;
  If Module = Nil Then
    Exit;
  With Module Do
  Begin
    iFileCount := GetModuleFileCount;
    For i := 0 To iFileCount - 1 Do
      If GetModuleFileEditor(i).QueryInterface(IOTASourceEditor, Result)
        = S_OK Then
        Break;
  End;
End;

procedure TKeyboardOTABinding.AddBreakpoint(const Context: IOTAKeyContext;
  KeyCode: TShortcut; var BindingResult: TKeyBindingResult);

var
  i: Integer;
  DS: IOTADebuggerServices;
  MS: IOTAModuleServices;
  strFileName: String;
  Source: IOTASourceEditor;
  CP: TOTAEditPos;
  BP: IOTABreakpoint;
begin
  MS := BorlandIDEServices As IOTAModuleServices;
  Source := SourceEditor(MS.CurrentModule);
  strFileName := Source.FileName;
  CP := Source.EditViews[0].CursorPos;
  DS := BorlandIDEServices As IOTADebuggerServices;
  BP := nil;
  for i := 0 to DS.SourceBkptCount - 1 do
  begin
    if (DS.SourceBkpts[i].LineNumber = CP.Line) and
      (AnsiCompareFileName(DS.SourceBkpts[0].FileName, strFileName) = 0) then
      BP := DS.SourceBkpts[i];
  end;

  if not Assigned(BP) then
    BP := DS.NewSourceBreakpoint(strFileName, CP.Line, nil);

  If KeyCode = TextToShortCut('Ctrl+Shift+F8') Then
    BP.Edit(True)
  Else If KeyCode = TextToShortCut('Ctrl+Alt+F8') Then
    BP.Enabled := Not BP.Enabled;
  BindingResult := krHandled;
end;

procedure TKeyboardOTABinding.BindKeyboard(const BindingServices
  : IOTAKeyBindingServices);
begin
  BindingServices.AddKeyBinding([TextToShortCut('Ctrl+Shift+F8')],
    AddBreakpoint, nil);
  BindingServices.AddKeyBinding([TextToShortCut('Ctrl+Alt+F8')],
    AddBreakpoint, Nil);
end;

function TKeyboardOTABinding.GetBindingType: TBindingType;
begin
  Result := btPartial;
end;

function TKeyboardOTABinding.GetDisplayName: string;
begin
  Result := 'Debugging Tools Bindings';
end;

function TKeyboardOTABinding.GetName: string;
begin
  Result := 'Debugging Tools Bindings';
end;

{ TDebuggingWizard }

constructor TDebuggingOTAExample.Create;
begin

end;

destructor TDebuggingOTAExample.Destroy;
begin

  inherited;
end;

procedure TDebuggingOTAExample.Execute;
begin

end;

function TDebuggingOTAExample.GetIDString: string;
begin
  Result:= 'TDebuggingOTAExample';
end;

function TDebuggingOTAExample.GetName: string;
begin
  Result:= 'TDebuggingOTAExample';
end;

function TDebuggingOTAExample.GetState: TWizardState;
begin
  Result:= [wsEnabled];
end;

initialization

finalization

If iKeyBindingIndex > 0 Then
  (BorlandIDEServices As IOTAKeyboardServices).RemoveKeyboardBinding
    (iKeyBindingIndex);
If iWizardIndex > 0 Then
  (BorlandIDEServices As IOTAWizardServices).RemoveWizard(iWizardIndex);

end.
