unit OtaExampleWizarUm;

interface

uses ToolsApi, Vcl.Dialogs, Vcl.Forms, Vcl.Menus;

type
  TOtaExampleWizardUm = class(TNotifierObject, IOTAWizard)
  private
    FRoot, FMyWizard: TMenuItem;
    procedure Execute;
    function GetIDString: string;
    function GetName: string;
    function GetState: TWizardState;
    procedure AfterSave;
    procedure BeforeSave;
    procedure Destroyed;
    procedure Modified;
    procedure DoClick(Sender: TObject);
    function ExisteMenu(pCaption: String): Boolean;

  public
    constructor Create;
    destructor Destroy; override;

  end;

implementation

{ TOtaExampleWizardUm }

uses System.SysUtils;

const WizardFail = -1;

var indWizard: Integer = WizardFail;


Procedure Register;
begin
   indWizard:= (BorlandIDEServices as IOTAWizardServices).AddWizard(TOtaExampleWizardUm.Create);
end;

procedure TOtaExampleWizardUm.AfterSave;
begin

end;

procedure TOtaExampleWizardUm.BeforeSave;
begin

end;

constructor TOtaExampleWizardUm.Create;
begin
  if not Assigned(FMyWizard) then
  begin
    FMyWizard:= TMenuItem.Create(nil);
    FMyWizard.Caption:= 'MyWizard';
    FMyWizard.OnClick:= DoClick;
  end;

  if not Assigned(FRoot) then
  begin
    FRoot:= TMenuItem.Create(nil);
    FRoot.Caption:= 'Wizard';
    FRoot.Add(FMyWizard);
    FRoot.OnClick:= nil;
  end;
  if not ExisteMenu('Wizard') then
    (BorlandIDEServices as INTAServices).MainMenu.Items.Add(FRoot);
end;

destructor TOtaExampleWizardUm.Destroy;
begin
   (BorlandIDEServices as INTAServices).MainMenu.Items.Remove(FRoot);
 if Assigned(FMyWizard) then
    FreeAndNil(FMyWizard);

  if Assigned(FRoot) then
    FreeAndNil(FRoot);
  inherited;
end;

procedure TOtaExampleWizardUm.Destroyed;
begin

end;

procedure TOtaExampleWizardUm.DoClick(Sender: TObject);
begin
  Execute;
end;

procedure TOtaExampleWizardUm.Execute;
begin
   ShowMessage('Olá meu exemplo');
end;

function TOtaExampleWizardUm.ExisteMenu(pCaption: String): Boolean;
begin
  Result:= Assigned((BorlandIDEServices as INTAServices).MainMenu.Items.Find(pCaption));
end;

function TOtaExampleWizardUm.GetIDString: string;
begin
  Result:= 'Anizair OtaExamploWizard';
end;

function TOtaExampleWizardUm.GetName: string;
begin
  Result:= 'Open Tools Api Example';
end;

function TOtaExampleWizardUm.GetState: TWizardState;
begin
   Result:= [wsEnabled];
end;

procedure TOtaExampleWizardUm.Modified;
begin

end;

initialization
  Register;

finalization
  if indWizard <> WizardFail then
    (BorlandIDEServices as IOTAWizardServices).RemoveWizard(indWizard);

end.
