unit UnitCustomMessage;

interface

uses ToolsApi, Vcl.Graphics, Winapi.Windows;

type
  TCustomMessage = class(TInterfacedObject, IOTACustomMessage,
    INTACustomDrawMessage)
  private
    FMsg: String;
    FFontName: String;
    FForeColour: TColor;
    FStyle: TFontStyles;
    FBackColour: TColor;
    FMessagePntr: Pointer;
  protected
    Procedure SetForeColour(iColour: TColor);
    function CalcRect(Canvas: TCanvas; MaxWidth: Integer; Wrap: Boolean): TRect;
    procedure Draw(Canvas: TCanvas; const Rect: TRect; Wrap: Boolean);
    function GetColumnNumber: Integer;
    function GetFileName: string;
    function GetLineNumber: Integer;
    function GetLineText: string;
    procedure ShowHelp;

  public
    Constructor Create(strMsg: String; FontName: String;
      ForeColour: TColor = clBlack; Style: TFontStyles = [];
      BackColour: TColor = clWindow);
    Property ForeColour: TColor Write SetForeColour;
    Property MessagePntr: Pointer Read FMessagePntr Write FMessagePntr;
  end;

implementation

uses
  System.SysUtils;

{ TCustomMessage }

function TCustomMessage.CalcRect(Canvas: TCanvas; MaxWidth: Integer;
  Wrap: Boolean): TRect;
begin
  Canvas.Font.Name := FFontName;
  Canvas.Font.Style := FStyle;
  Result := Canvas.ClipRect;
  Result.Bottom := Result.Top + Canvas.TextHeight('Wp');
  Result.Right := Result.Left + Canvas.TextWidth(FMsg);
end;

constructor TCustomMessage.Create(strMsg, FontName: String; ForeColour: TColor;
  Style: TFontStyles; BackColour: TColor);

const
  strValidChars: set of AnsiChar = [#10, #13, #32 .. #128];

Var
  i: Integer;
  iLength: Integer;
begin

  SetLength(FMsg, Length(strMsg));
  iLength := 0;
  for i := 1 to Length(strMsg) do
  begin
    if CharInSet(strMsg[i], strValidChars) then
    begin
      FMsg[iLength + 1] := strMsg[i];
      Inc(iLength);
    end;
  end;

  SetLength(FMsg, iLength);
  FFontName := FontName;
  FForeColour := ForeColour;
  FStyle := Style;
  FBackColour := BackColour;
  FMessagePntr := Nil;
end;

procedure TCustomMessage.Draw(Canvas: TCanvas; const Rect: TRect;
  Wrap: Boolean);
begin
  If Canvas.Brush.Color = clWindow Then
  Begin
    Canvas.Font.Color := FForeColour;
    Canvas.Brush.Color := FBackColour;
    Canvas.FillRect(Rect);
  End;
  Canvas.Font.Name := FFontName;
  Canvas.Font.Style := FStyle;
  Canvas.TextOut(Rect.Left, Rect.Top, FMsg);
end;

function TCustomMessage.GetColumnNumber: Integer;
begin
  Result := 0;
end;

function TCustomMessage.GetFileName: string;
begin
  Result := '';
end;

function TCustomMessage.GetLineNumber: Integer;
begin
  Result := 0;
end;

function TCustomMessage.GetLineText: string;
begin
  Result := FMsg;
end;

procedure TCustomMessage.SetForeColour(iColour: TColor);
begin

end;

procedure TCustomMessage.ShowHelp;
begin

end;

end.
