unit lopes.TestHelper.Wizard;

interface

uses ToolsApi, Vcl.Menus;

type
  TSeting = (seProject, seBefore, seAfter, seZip);

  TTesteHelperWizard = class(TNotifierObject, IOTAWizard)
  strict private
    FTestingHelperMenu: TMenuItem;
  strict protected
    Procedure BeforeCompilationClick(Sender: TObject);
    Procedure AfterCompilationClick(Sender: TObject);
    Procedure ToggleEnabled(Sender: TObject);
    Procedure CheckForUpdatesClick(Sender: TObject);
    Procedure FontDialogueClick(Sender: TObject);
    Procedure ZIPDialogueClick(Sender: TObject);
    Procedure ZIPDialogueUpdate(Sender: TObject);
    Procedure GlobalOptionDialogueClick(Sender: TObject);
    Procedure ProjectOptionsClick(Sender: TObject);
    Procedure ProjectOptionsUpdate(Sender: TObject);
    Procedure UpdateEnabled(Sender: TObject);
    Procedure BeforeCompilationUpdate(Sender: TObject);
    Procedure AfterCompilationUpdate(Sender: TObject);
    Procedure ProjectOptions(Project: IOTAProject);
    Procedure BeforeCompilation(Project: IOTAProject);
    Procedure AfterCompilation(Project: IOTAProject);
    Procedure ZIPOptions(Project: IOTAProject);
    Procedure AboutClick(Sender: TObject);
    Procedure HelpClick(Sender: TObject);
    Procedure MenuTimerEvent(Sender: TObject);

  public
    procedure Execute;
    function GetIDString: string;
    function GetName: string;
    function GetState: TWizardState;

    constructor Create;
    destructor Destroy; override;

  end;

implementation

uses
  lopes.TestHelper.Utils;

{ TTesteHelperWizard }

procedure TTesteHelperWizard.AboutClick(Sender: TObject);
begin

end;

procedure TTesteHelperWizard.AfterCompilation(Project: IOTAProject);
begin

end;

procedure TTesteHelperWizard.AfterCompilationClick(Sender: TObject);
begin

end;

procedure TTesteHelperWizard.AfterCompilationUpdate(Sender: TObject);
begin

end;

procedure TTesteHelperWizard.BeforeCompilation(Project: IOTAProject);
begin

end;

procedure TTesteHelperWizard.BeforeCompilationClick(Sender: TObject);
begin

end;

procedure TTesteHelperWizard.BeforeCompilationUpdate(Sender: TObject);
begin

end;

procedure TTesteHelperWizard.CheckForUpdatesClick(Sender: TObject);
begin

end;

constructor TTesteHelperWizard.Create;
begin
  FTestingHelperMenu:= THelperUtils.CreateMenuItem('ITHTestingHelper', '&Testing Helper', 'Tools',
    Nil, Nil, True, False, '');
end;

destructor TTesteHelperWizard.Destroy;
begin

  inherited;
end;

procedure TTesteHelperWizard.Execute;
begin

end;

procedure TTesteHelperWizard.FontDialogueClick(Sender: TObject);
begin

end;

function TTesteHelperWizard.GetIDString: string;
begin
  Result := 'TestingHelper';
end;

function TTesteHelperWizard.GetName: string;
begin
  Result := 'Testing Helper - Support for running external tools before and ' + 'after compilations.';
end;

function TTesteHelperWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

procedure TTesteHelperWizard.GlobalOptionDialogueClick(Sender: TObject);
begin

end;

procedure TTesteHelperWizard.HelpClick(Sender: TObject);
begin

end;

procedure TTesteHelperWizard.MenuTimerEvent(Sender: TObject);
begin

end;

procedure TTesteHelperWizard.ProjectOptions(Project: IOTAProject);
begin

end;

procedure TTesteHelperWizard.ProjectOptionsClick(Sender: TObject);
begin

end;

procedure TTesteHelperWizard.ProjectOptionsUpdate(Sender: TObject);
begin

end;

procedure TTesteHelperWizard.ToggleEnabled(Sender: TObject);
begin

end;

procedure TTesteHelperWizard.UpdateEnabled(Sender: TObject);
begin

end;

procedure TTesteHelperWizard.ZIPDialogueClick(Sender: TObject);
begin

end;

procedure TTesteHelperWizard.ZIPDialogueUpdate(Sender: TObject);
begin

end;

procedure TTesteHelperWizard.ZIPOptions(Project: IOTAProject);
begin

end;

end.
