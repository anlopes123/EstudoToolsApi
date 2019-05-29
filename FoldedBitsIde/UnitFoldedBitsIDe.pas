unit UnitFoldedBitsIDe;

interface

uses ToolsApi, System.Classes;

type
  TIdeFoldedBitsIDE = class(TNotifierObject, IOTAWizard)
  private
    procedure Execute;
    function GetIDString: string;
    function GetName: string;
    function GetState: TWizardState;

  public
  end;


  TKeyboardOTABinding = class(TNotifierObject, IOTAKeyboardBinding)
  private
    procedure BindKeyboard(const BindingServices: IOTAKeyBindingServices);
    function GetBindingType: TBindingType;
    function GetDisplayName: string;
    function GetName: string;
    function SourceEditor(Module: IOTAModule): IOTASourceEditor;
    Procedure CreateBindExecute(const Context: IOTAKeyContext; KeyCode: TShortcut;
      var BindingResult: TKeyBindingResult);

  public

  end;

procedure Register;

var
  iWizardIndex: Integer = 0;
  iKeyBindingIndex: Integer = 0;

implementation

uses
  System.SysUtils, Vcl.Menus;

{ TIdeFoldedBitsIDE }

procedure Register;

begin
   iWizardIndex := (BorlandIDEServices As IOTAWizardServices)
    .AddWizard(TIdeFoldedBitsIDE.Create);
  //Application.Handle := (BorlandIDEServices As IOTAServices).GetParentHandle;
  iKeyBindingIndex := (BorlandIDEServices As IOTAKeyboardServices)
    .AddKeyboardBinding(TKeyboardOTABinding.Create);
end;

procedure TIdeFoldedBitsIDE.Execute;
var TopView: IOTAEditView;
    editServices: IOTAEditorServices;
    i: IOTAElideActions;
begin
  if Supports(BorlandIDEServices, IOTAEditorServices, editServices) then
    TopView:= editServices.TopView;
  if TopView.QueryInterface(IOTAElideActions, I) = S_OK then
  begin
    i.ElideNearestBlock;
    TopView.Paint;
  end;
end;

function TIdeFoldedBitsIDE.GetIDString: string;
begin
  Result:= 'ideFoldedBitsIDE';
end;

function TIdeFoldedBitsIDE.GetName: string;
begin
  Result:= 'ideFoldedBitsIDE';
end;

function TIdeFoldedBitsIDE.GetState: TWizardState;
begin
  Result:= [wsEnabled];
end;

{ TKeyboardOTABinding }

procedure TKeyboardOTABinding.BindKeyboard(
  const BindingServices: IOTAKeyBindingServices);
begin
 BindingServices.AddKeyBinding([TextToShortCut('Ctrl+Shift+F8')],
    CreateBindExecute, nil);

end;

procedure TKeyboardOTABinding.CreateBindExecute(const Context: IOTAKeyContext;
  KeyCode: TShortcut; var BindingResult: TKeyBindingResult);
var vIotaWizer: IOTAWizard;
begin
  vIotaWizer:= TIdeFoldedBitsIDE.Create;
  vIotaWizer.Execute;
end;

function TKeyboardOTABinding.GetBindingType: TBindingType;
begin
  Result:= btPartial;
end;

function TKeyboardOTABinding.GetDisplayName: string;
begin
  Result:= 'ShortcutIde';
end;

function TKeyboardOTABinding.GetName: string;
begin
 Result:= 'ShortcutIde';
end;

function TKeyboardOTABinding.SourceEditor(Module: IOTAModule): IOTASourceEditor;
begin

end;

end.
