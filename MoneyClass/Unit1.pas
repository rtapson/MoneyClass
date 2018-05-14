unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  Money, Spring.Collections;

{$R *.dfm}

procedure TForm1.Button2Click(Sender: TObject);
var
  Mon, other : IMoney;
begin
  Mon := TMoney.Create(45.34, TFormatSettings.Create);
  //other := Mon.Subtract(TMoney.Create(5.34, Curr));
  other := Mon.Multiply(5.00);

  //ShowMessage( Format('%m', [other.DecimalAmount]));
  ShowMessage(other.ToString);
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  Mon, other : IMoney;
  aList : IList<IMOney>;
begin
  Mon := TMoney.Create(0.05, TFormatSettings.Create);
  aList := Mon.Allocate([70, 30]);

  ShowMessage(aList.First.ToString);
  ShowMessage(aList.Last.ToString);
end;

end.
