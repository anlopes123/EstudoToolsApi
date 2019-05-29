unit UnitCustomMessageWizard;

interface

uses ToolsApi;

type
  TCustomMessagemWizard = class(TNotifierObject, IOTAWizard)
  private
    procedure Execute;
    function GetIDString: string;
    function GetName: string;
    function GetState: TWizardState;
  public

  end;

implementation

{ TCustomMessagemWizard }

procedure TCustomMessagemWizard.Execute;
begin

end;

function TCustomMessagemWizard.GetIDString: string;
begin
   Result:= 'CustomMessage';
end;

function TCustomMessagemWizard.GetName: string;
begin
  Result:= 'CustomMessage';
end;

function TCustomMessagemWizard.GetState: TWizardState;
begin
   Result:= [wsEnabled];
end;

end.
