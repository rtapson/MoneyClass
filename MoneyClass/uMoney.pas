unit uMoney;

interface

uses
  System.SysUtils;

type
  TMoney = record
  strict private
    FMoney : integer;
    FCents : array[0..3] of integer;
    FFormatSettings : TFormatSettings;

    procedure FillCentsArray;
    function CentFactor: integer;

    function GetMoney: Currency;
  private
    function GetIntMoney: integer;
    //procedure SetMoney(const Value: Currency);
  public
    constructor Create(const Money : Currency); overload;
    constructor Create(const IntMoney : integer); overload;

    class operator Add(const a, b : TMoney): TMoney;
    class operator Subtract(const a, b : TMoney): TMoney;
    class operator Multiply(const a, b : TMoney): TMoney;
    class operator Divide(const a, b : TMoney): TMoney;

    property Money : Currency read GetMoney{ write SetMoney};
    property IntMoney : integer read GetIntMoney;
  end;

implementation

{ TMoney }

class operator TMoney.Add(const a, b: TMoney): TMoney;
begin
  result := TMoney.Create(a.IntMoney + b.IntMoney);
end;

function TMoney.CentFactor: integer;
begin
  result := FCents[FFormatSettings.CurrencyDecimals];
end;

constructor TMoney.Create(const IntMoney: integer);
begin
  FillCentsArray;
  FFormatSettings := TFormatSettings.Create;
  FMoney := IntMoney;
end;

class operator TMoney.Divide(const a, b: TMoney): TMoney;
begin

end;

constructor TMoney.Create(const Money : Currency);
begin
  FillCentsArray;
  FFormatSettings := TFormatSettings.Create;
  FMoney := trunc(Money * CentFactor);
end;

procedure TMoney.FillCentsArray;
begin
  FCents[0] := 1;
  FCents[1] := 10;
  FCents[2] := 100;
  FCents[3] := 1000;
end;

function TMoney.GetIntMoney: integer;
begin
  result := FMoney;
end;

function TMoney.GetMoney: Currency;
begin
  result := FMoney / CentFactor;
end;

class operator TMoney.Multiply(const a, b: TMoney): TMoney;
begin
   result := TMoney.Create(Trunc((a.IntMoney * b.IntMoney) / CentFactor));
end;

{procedure TMoney.SetMoney(const Value: Currency);
begin
  FMoney := trunc(Value * CentFactor);
end;  }

class operator TMoney.Subtract(const a, b: TMoney): TMoney;
begin
  result.Create(a.FMoney - b.FMoney);
end;

end.
