unit Money;

interface

uses
  SysUtils, Spring.Collections;

type
  ECurrencyCodeMismatch = Exception;

  IMoney = interface
    function GetAmount: Integer;
    procedure SetAmount(const Value: Integer);
    function GetFormatSettings: TFormatSettings;
    function GetDecimalAmount: Currency;

    function ToString: string;
    function Add(Amount : IMoney): IMoney;
    function Subtract(Amount : IMoney): IMoney;
    function Multiply(Amount : Currency): IMoney;
    function Allocate(Ratios : array of integer): IList<IMoney>;
    function Equals(Amount : IMoney): boolean;

    property Amount : Integer read GetAmount write SetAmount;
    property DecimalAmount : Currency read GetDecimalAmount;
    property FormatSettings : TFormatSettings read GetFormatSettings;
  end;

  TMoney = class(TInterfacedObject, IMoney)
  strict private
    FCents : array[0..3] of integer;
    FAmount : integer;
    FFormatSettings : TFormatSettings;

    procedure FillCentsArray;
    function CentFactor: integer;
    function NewMoney(Amount : integer): IMoney;
    function GetAmount: Integer;
    procedure SetAmount(const Value: Integer);
    function GetDecimalAmount: Currency;
    function GetFormatSettings: TFormatSettings;
  public
    constructor Create(Amount : Currency); overload;
    constructor Create(Amount : integer); overload;
    constructor Create(Amount : Currency; FormatSettings : TFormatSettings); overload;
    constructor Create(Amount : integer; FormatSettings : TFormatSettings); overload;
    constructor Create(Other : IMoney); overload;
    constructor ChangeCurrency(const FromMoney : IMoney; const ToFormatSettings : TFormatSettings; const ExchangeRate : Double);

    function ToString: string; override;

    function Add(Amount : IMoney): IMoney;
    function Subtract(Amount : IMoney): IMoney;
    function Multiply(Amount : Currency): IMoney;
    function Allocate(Ratios : array of integer): IList<IMoney>;
    function Equals(Amount : IMoney): boolean; reintroduce; overload;

    property Amount : Integer read GetAmount write SetAmount;
    property DecimalAmount : Currency read GetDecimalAmount;
    property FormatSettings : TFormatSettings read GetFormatSettings;
  end;

implementation

{ TMoney }

function TMoney.Add(Amount: IMoney): IMoney;
begin
  if Amount.FormatSettings.CurrencyFormat = FFormatSettings.CurrencyFormat then
    result := NewMoney(FAmount + Amount.Amount)
  else
    raise ECurrencyCodeMismatch.Create('Currency Codes don''t match.');
end;

function TMoney.Allocate(Ratios: array of integer): IList<IMoney>;
var
  Total : integer;
  Remainder : integer;
  i: Integer;
begin
  Total := 0;
  Remainder := FAmount;

  for i := Low(Ratios) to High(Ratios) do
    Total := Total + Ratios[i];

  result := TCollections.CreateList<IMoney>;

  for i := Low(Ratios) to High(Ratios) do
  begin
    result.Add(TMoney.Create(FAmount * Ratios[i] div Total, FFormatSettings));
    Remainder := Remainder - result.Last.Amount;
  end;

  for i := 0 to Remainder - 1 do
    result.Items[i].Amount := result.Items[i].Amount + 1;
end;

function TMoney.CentFactor: integer;
begin
  result := FCents[FFormatSettings.CurrencyDecimals];
end;

constructor TMoney.ChangeCurrency(const FromMoney: IMoney; const ToFormatSettings: TFormatSettings; const ExchangeRate: Double);
begin
  FillCentsArray;
  FFormatSettings := ToFormatSettings;
  FAmount := FromMoney.Multiply(ExchangeRate).Amount;
end;

constructor TMoney.Create(Amount: Currency);
begin
  FillCentsArray;
  FFormatSettings := TFormatSettings.Create;
  FAmount := Trunc(Amount * CentFactor);
end;

constructor TMoney.Create(Amount: integer);
begin
  FillCentsArray;
  FAmount := Amount;
  FFormatSettings := TFormatSettings.Create;
end;

constructor TMoney.Create(Other: IMoney);
begin
  FillCentsArray;
  FAmount := Other.Amount;
  FFormatSettings := Other.FormatSettings;
end;

function TMoney.Equals(Amount: IMoney): boolean;
begin
  if Amount.FormatSettings.CurrencyFormat = FFormatSettings.CurrencyFormat then
    result := FAmount = Amount.Amount
  else
    raise ECurrencyCodeMismatch.Create('Currency Codes don''t match.');
end;

constructor TMoney.Create(Amount: integer; FormatSettings : TFormatSettings);
begin
  FillCentsArray;
  FAmount := Amount;
  FFormatSettings := FormatSettings;
end;

procedure TMoney.FillCentsArray;
begin
  FCents[0] := 1;
  FCents[1] := 10;
  FCents[2] := 100;
  FCents[3] := 1000;
end;

function TMoney.GetAmount: Integer;
begin
  result := FAmount;
end;

function TMoney.GetDecimalAmount: Currency;
begin
  result := FAmount / CentFactor;
end;

function TMoney.GetFormatSettings: TFormatSettings;
begin
  result := FFormatSettings;
end;

function TMoney.Multiply(Amount: Currency): IMoney;
begin
  result := NewMoney(Round(FAmount * Amount));
end;

constructor TMoney.Create(Amount: Currency; FormatSettings : TFormatSettings);
begin
  FillCentsArray;
  FFormatSettings := FormatSettings;
  FAmount := Trunc(Amount * CentFactor);
end;

function TMoney.NewMoney(Amount: integer): IMoney;
begin
  result := TMoney.Create(Amount, FFormatSettings);
end;

procedure TMoney.SetAmount(const Value: Integer);
begin
  FAmount := Value;
end;

function TMoney.Subtract(Amount: IMoney): IMoney;
begin
  if Amount.FormatSettings.CurrencyFormat = FFormatSettings.CurrencyFormat then
    result := NewMoney(FAmount - Amount.Amount)
  else
    raise ECurrencyCodeMismatch.Create('Currency Codes don''t match.');
end;

function TMoney.ToString: string;
begin
  result := Format('%m', [DecimalAmount], FFormatSettings);
end;

end.
