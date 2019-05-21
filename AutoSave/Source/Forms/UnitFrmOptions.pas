unit UnitFrmOptions;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls,
  Vcl.ExtCtrls, Vcl.Menus;

type
  TfrmOptions = class(TForm)
    lblAutoSaveInterval: TLabel;
    edtAutosaveInterval: TEdit;
    udAutoSaveInterval: TUpDown;
    cbxPrompt: TCheckBox;
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
  private
    { Private declarations }
  public
    { Public declarations }
    Class Function Execute(var iInterval: Integer;
      var boolPrompt: Boolean): Boolean;
  end;

var
  frmOptions: TfrmOptions;

implementation

{$R *.dfm}
{ TfrmOptions }

class function TfrmOptions.Execute(var iInterval: Integer;
  var boolPrompt: Boolean): Boolean;
begin
  Result := False;

  with TfrmOptions.Create(nil) do
  begin
    try
      udAutoSaveInterval.Position := iInterval;
      cbxPrompt.Checked := boolPrompt;
      if ShowModal = mrOk then
      begin
        Result := True;
        iInterval := udAutoSaveInterval.Position;
        boolPrompt := cbxPrompt.Checked;
      end;
    finally
      free
    end;
  end;

end;

end.
