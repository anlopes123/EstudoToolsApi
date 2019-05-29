unit UnitIdeNotifie;

interface

uses ToolsApi;

type
  TTestHelperIntegreted = class(TNotifierObject, IOTANotifier, IOTAIDENotifier)
  private
    procedure AfterCompile(Succeeded: Boolean);
    procedure BeforeCompile(const Project: IOTAProject; var Cancel: Boolean);
    procedure FileNotification(NotifyCode: TOTAFileNotification;
      const FileName: string; var Cancel: Boolean);
  public
    constructor Create;
    destructor Destroy; override;

  end;

procedure Register;

implementation

uses Vcl.Dialogs;

{ TTestHelperIntegreted }

procedure Register;
begin
  (BorlandIDEServices as IOTAServices).AddNotifier(TTestHelperIntegreted.Create);
end;

procedure TTestHelperIntegreted.AfterCompile(Succeeded: Boolean);
begin
   if Succeeded then
     ShowMessage('Compilação feita');
end;

procedure TTestHelperIntegreted.BeforeCompile(const Project: IOTAProject;
  var Cancel: Boolean);
begin
   ShowMessage('Compilação vai começar');

end;

constructor TTestHelperIntegreted.Create;
begin

end;

destructor TTestHelperIntegreted.Destroy;
begin

  inherited;
end;

procedure TTestHelperIntegreted.FileNotification(
  NotifyCode: TOTAFileNotification; const FileName: string;
  var Cancel: Boolean);
begin

end;

end.
