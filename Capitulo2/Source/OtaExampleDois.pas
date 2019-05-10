unit OtaExampleDois;

interface

uses ToolsApi,
  Vcl.Forms,
  Winapi.Windows,
  System.SysUtils,
  UnitFrmOptions,
  Vcl.ExtCtrls,
  Vcl.Menus,
  System.IniFiles;

type
  TOtaExampleWizarAutoSave = class(TInterfacedObject, IOTAWizard)
  private
    FTimer: TTimer; // New
    FCounter: Integer; // New
    FAutoSaveInt: Integer; // New
    FPrompt: Boolean; // New
    FMenuItem: TMenuItem; // New
    FINIFileName: String; // New
    Procedure SaveModifiedFiles;

    procedure Execute;
    function GetIDString: string;
    function GetName: string;
    function GetState: TWizardState;
    procedure AfterSave;
    procedure BeforeSave;
    procedure Destroyed;
    procedure Modified;
  protected
    Procedure TimerEvent(Sender: TObject); // New
    Procedure MenuClick(Sender: TObject); // New
    Procedure LoadSettings; // New
    Procedure SaveSettings; // New
  public
    constructor Create;
    destructor Destroy; override;
  end;

var
  iWizardIndex: Integer = 0;

procedure Register;

implementation

{ TOtaExampleWizarAutoSave }

procedure Register;
begin
  iWizardIndex := (BorlandIDEServices as IOTAWizardServices)
    .AddWizard(TOtaExampleWizarAutoSave.Create);
end;

procedure TOtaExampleWizarAutoSave.AfterSave;
begin

end;

procedure TOtaExampleWizarAutoSave.BeforeSave;
begin

end;

constructor TOtaExampleWizarAutoSave.Create;
var
  NTAS: INTAServices;
  mmiViewMenu: TMenuItem;
  mmiFirstDivider: TMenuItem;

begin
  FMenuItem := nil;
  FCounter := 0;
  FAutoSaveInt := 300;
  FPrompt := True;
  SetLength(FINIFileName, MAX_PATH);
  FINIFileName := ChangeFileExt(FINIFileName, '.INI');
  LoadSettings;
  FTimer := TTimer.Create(nil);
  FTimer.Interval := 1000;
  FTimer.OnTimer := TimerEvent;
  FTimer.Enabled := True;
  NTAS := (BorlandIDEServices As INTAServices);
  if Assigned(NTAS) and Assigned(NTAS.MainMenu) then
  begin
    mmiViewMenu := NTAS.MainMenu.Items.Find('View');
    if Assigned(mmiViewMenu) then
    begin
      mmiFirstDivider := mmiViewMenu.Find('-');
      if Assigned(mmiFirstDivider) then
      begin
        FMenuItem := TMenuItem.Create(mmiViewMenu);
        FMenuItem.Caption := '&Auto Save Options...';
        FMenuItem.OnClick := MenuClick;
        mmiViewMenu.Insert(mmiFirstDivider.MenuIndex, FMenuItem);
      end;
    end;

  end;

end;

destructor TOtaExampleWizarAutoSave.Destroy;
begin
  SaveSettings;
  FreeAndNil(FMenuItem);
  FreeAndNil(FTimer);
  inherited;
end;

procedure TOtaExampleWizarAutoSave.Destroyed;
begin

end;

procedure TOtaExampleWizarAutoSave.Execute;
begin

end;

function TOtaExampleWizarAutoSave.GetIDString: string;
begin
  Result := 'OtaExampleAutoSave';
end;

function TOtaExampleWizarAutoSave.GetName: string;
begin
  Result := 'OtaExampleAutoSave';
end;

function TOtaExampleWizarAutoSave.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

procedure TOtaExampleWizarAutoSave.LoadSettings;
begin
  With TIniFile.Create(FINIFileName) do
  begin
    try
      FAutoSaveInt := ReadInteger('Setup', 'AutoSaveInt', FAutoSaveInt);
      FPrompt := ReadBool('Setup', 'Prompt', FPrompt);
    finally
      Free;
    end;
  end;
end;

procedure TOtaExampleWizarAutoSave.MenuClick(Sender: TObject);
begin
  if TfrmOptions.Execute(FAutoSaveInt, FPrompt) then
    SaveSettings;

end;

procedure TOtaExampleWizarAutoSave.Modified;
begin

end;

procedure TOtaExampleWizarAutoSave.SaveModifiedFiles;
var
  vIterator: IOTAEditBufferIterator;
  i: Integer;
begin
  if (BorlandIDEServices As IOTAEditorServices).GetEditBufferIterator
    (vIterator) Then
  begin
    For i := 0 To vIterator.Count - 1 Do
      If vIterator.EditBuffers[i].IsModified Then
        vIterator.EditBuffers[i].Module.Save(False, not FPrompt);
  end;
end;

procedure TOtaExampleWizarAutoSave.SaveSettings;
begin
  with TIniFile.Create(FINIFileName) do
  begin
    try
      WriteInteger('Setup', 'AutoSaveInt', FAutoSaveInt);
      WriteBool('Setup', 'Prompt', FPrompt);
    finally
      Free;
    end;
  end;
end;

procedure TOtaExampleWizarAutoSave.TimerEvent(Sender: TObject);
begin
  Inc(FCounter);
  If FCounter >= FAutoSaveInt then
  begin
    FCounter := 0;
    SaveModifiedFiles;
  end;

end;

end.
