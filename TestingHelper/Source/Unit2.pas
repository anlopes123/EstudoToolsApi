unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm2 = class(TForm)
    Button1: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
    function Rec(X: integer): integer;
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

function TForm2.Rec(X: integer): integer;
var vrec: integer;
begin
  if x = 0 then
    vrec := 1;
  else
    vrec:= x + Rec(x-1);

  result:= vrec;
end;

end.
