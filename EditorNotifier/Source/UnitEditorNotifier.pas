unit UnitEditorNotifier;

interface

uses ToolsApi, DockForm, System.Classes;

type
  TEditorNotifier = class(TNotifierObject, INTAEditServicesNotifier)
  public
    procedure DockFormRefresh(const EditWindow: INTAEditWindow;
      DockForm: TDockableForm);
    procedure DockFormUpdated(const EditWindow: INTAEditWindow;
      DockForm: TDockableForm);
    procedure DockFormVisibleChanged(const EditWindow: INTAEditWindow;
      DockForm: TDockableForm);
    procedure EditorViewActivated(const EditWindow: INTAEditWindow;
      const EditView: IOTAEditView);
    procedure EditorViewModified(const EditWindow: INTAEditWindow;
      const EditView: IOTAEditView);
    procedure WindowActivated(const EditWindow: INTAEditWindow);
    procedure WindowCommand(const EditWindow: INTAEditWindow; Command: Integer;
      Param: Integer; var Handled: Boolean);
    procedure WindowNotification(const EditWindow: INTAEditWindow;
      Operation: TOperation);
    procedure WindowShow(const EditWindow: INTAEditWindow; Show: Boolean;
      LoadedFromDesktop: Boolean);

    constructor Create;
    destructor Destroy; override;

  end;

procedure Register;

implementation

uses Vcl.Forms, Vcl.Dialogs;

var
  iEditoIndex: Integer;

procedure Register;

begin
  Application.Handle := Application.MainForm.Handle;
  if BorlandIDEServices <> Nil then
  begin
    iEditoIndex := (BorlandIDEServices as IOTAEditorServices)
      .AddNotifier(TEditorNotifier.Create);
  end;
end;

{ TEditorNotifier }

constructor TEditorNotifier.Create;
begin

end;

destructor TEditorNotifier.Destroy;
begin

  inherited;
end;

procedure TEditorNotifier.DockFormRefresh(const EditWindow: INTAEditWindow;
  DockForm: TDockableForm);
begin
  ShowMessage('Disparou DockFormRefresh');
end;

procedure TEditorNotifier.DockFormUpdated(const EditWindow: INTAEditWindow;
  DockForm: TDockableForm);
begin
  ShowMessage('Disparou DockFormUpdated');
end;

procedure TEditorNotifier.DockFormVisibleChanged(const EditWindow
  : INTAEditWindow; DockForm: TDockableForm);
begin
  ShowMessage('Disparou DockFormVisibleChanged');
end;

procedure TEditorNotifier.EditorViewActivated(const EditWindow: INTAEditWindow;
  const EditView: IOTAEditView);
begin
  ShowMessage('Disparou EditorViewActivated');
end;

procedure TEditorNotifier.EditorViewModified(const EditWindow: INTAEditWindow;
  const EditView: IOTAEditView);
begin
  ShowMessage('Disparou EditorViewModified');
end;

procedure TEditorNotifier.WindowActivated(const EditWindow: INTAEditWindow);
begin
  ShowMessage('Disparou WindowActivated');
end;

procedure TEditorNotifier.WindowCommand(const EditWindow: INTAEditWindow;
  Command, Param: Integer; var Handled: Boolean);
begin
  ShowMessage('Disparou WindowCommand');
end;

procedure TEditorNotifier.WindowNotification(const EditWindow: INTAEditWindow;
  Operation: TOperation);
begin
  ShowMessage('Disparou WindowNotification');
end;

procedure TEditorNotifier.WindowShow(const EditWindow: INTAEditWindow;
  Show, LoadedFromDesktop: Boolean);
begin
  ShowMessage('Disparou WindowNotification');
end;

initialization

finalization

(BorlandIDEServices as IOTAEditorServices).RemoveNotifier(iEditoIndex);

end.
