unit Money;

interface

uses
  SysUtils, Spring.Collections;

type
  ECurrencyCodeMismatch = class(Exception);

  IMoney = interface
    function GetAmount: Int64;
    procedure SetAmount(const Value: Int64);
    function GetFormatSettings: TFormatSettings;
    function GetDecimalAmount: Currency;

    function ToString: string;
    function Add(Amount : IMoney): IMoney;
    function Subtract(Amount : IMoney): IMoney;
    function Multiply(Amount : Currency): IMoney;
    function Allocate(Ratios : array of integer): IList<IMoney>;
    function Equals(Amount : IMoney): boolean;

    property Amount : Int64 read GetAmount write SetAmount;
    property DecimalAmount : Currency read GetDecimalAmount;
    property FormatSettings : TFormatSettings read GetFormatSettings;
  end;

  TMoney = class(TInterfacedObject, IMoney)
  strict private
    FCents : array[0..3] of integer;
    FAmount : Int64;
    FFormatSettings : TFormatSettings;

    procedure FillCentsArray;
    function CentFactor: integer;
    function CentFactorOf(const AFormatSettings : TFormatSettings): integer;
    function SameCurrencyAs(const Other : IMoney): boolean;
    function NewMoney(Amount : Int64): IMoney;
    function GetAmount: Int64;
    procedure SetAmount(const Value: Int64);
    function GetDecimalAmount: Currency;
    function GetFormatSettings: TFormatSettings;
  public
    constructor Create(Amount : Currency); overload;
    constructor Create(Amount : Int64); overload;
    constructor Create(Amount : Currency; FormatSettings : TFormatSettings); overload;
    constructor Create(Amount : Int64; FormatSettings : TFormatSettings); overload;
    constructor Create(Other : IMoney); overload;
    constructor ChangeCurrency(const FromMoney : IMoney; const ToFormatSettings : TFormatSettings; const ExchangeRate : Double);

    function ToString: string; override;

    function Add(Amount : IMoney): IMoney;
    function Subtract(Amount : IMoney): IMoney;
    function Multiply(Amount : Currency): IMoney;
    function Allocate(Ratios : array of integer): IList<IMoney>;
    function Equals(Amount : IMoney): boolean; reintroduce; overload;

    property Amount : Int64 read GetAmount write SetAmount;
    property DecimalAmount : Currency read GetDecimalAmount;
    property FormatSettings : TFormatSettings read GetFormatSettings;
  end;

implementation

{ TMoney }

function TMoney.Add(Amount: IMoney): IMoney;
begin
  if SameCurrencyAs(Amount) then
    result := NewMoney(FAmount + Amount.Amount)
  else
    raise ECurrencyCodeMismatch.Create('Currency Codes don''t match.');
end;

function FloorDiv(const A, B : Int64): Int64;
begin
  result := A div B;
  if (A mod B <> 0) and ((A < 0) <> (B < 0)) then
    Dec(result);
end;

function TMoney.Allocate(Ratios: array of integer): IList<IMoney>;
var
  Total : Int64;
  Remainder : Int64;
  Share : Int64;
  i: Integer;
begin
  if Length(Ratios) = 0 then
    raise EArgumentException.Create('Allocate needs at least one ratio.');

  Total := 0;
  for i := Low(Ratios) to High(Ratios) do
  begin
    if Ratios[i] < 0 then
      raise EArgumentException.Create('Allocate ratios cannot be negative.');
    Total := Total + Ratios[i];
  end;

  if Total = 0 then
    raise EArgumentException.Create('Allocate ratios cannot sum to zero.');

  result := TCollections.CreateList<IMoney>;

  // FloorDiv, not div. div truncates toward zero, so for a negative amount the
  // shares come out collectively larger than the whole and leave a negative
  // Remainder that the distribution loop below silently drops, losing a minor
  // unit. Flooring keeps Remainder in 0..High(Ratios) whatever the sign, so
  // every minor unit is handed out.
  Remainder := FAmount;
  for i := Low(Ratios) to High(Ratios) do
  begin
    Share := FloorDiv(FAmount * Ratios[i], Total);
    result.Add(TMoney.Create(Share, FFormatSettings));
    Remainder := Remainder - Share;
  end;

  for i := 0 to Integer(Remainder) - 1 do
    result.Items[i].Amount := result.Items[i].Amount + 1;
end;

function TMoney.CentFactor: integer;
begin
  result := CentFactorOf(FFormatSettings);
end;

function TMoney.CentFactorOf(const AFormatSettings : TFormatSettings): integer;
begin
  result := FCents[AFormatSettings.CurrencyDecimals];
end;

function TMoney.SameCurrencyAs(const Other : IMoney): boolean;
begin
  // CurrencyFormat only records where the symbol sits relative to the number
  // (0..3), so USD and GBP both score 0 and would compare as the same currency.
  // CurrencyString plus CurrencyDecimals is the closest thing to a currency
  // identity that TFormatSettings offers.
  result := (Other.FormatSettings.CurrencyString = FFormatSettings.CurrencyString) and
            (Other.FormatSettings.CurrencyDecimals = FFormatSettings.CurrencyDecimals);
end;

constructor TMoney.ChangeCurrency(const FromMoney: IMoney; const ToFormatSettings: TFormatSettings; const ExchangeRate: Double);
var
  FromFactor, ToFactor : integer;
begin
  FillCentsArray;
  FFormatSettings := ToFormatSettings;
  FromFactor := CentFactorOf(FromMoney.FormatSettings);
  ToFactor := CentFactorOf(ToFormatSettings);
  // Rescale between the two minor-unit scales in the same step as the rate so
  // the conversion rounds once. $10.00 (1000 cents) to JPY (no minor unit) at
  // 150 must give 1500, not 150000.
  FAmount := Round(FromMoney.Amount * ExchangeRate * ToFactor / FromFactor);
end;

constructor TMoney.Create(Amount: Currency);
begin
  FillCentsArray;
  FFormatSettings := TFormatSettings.Create;
  FAmount := Trunc(Amount * CentFactor);
end;

constructor TMoney.Create(Amount: Int64);
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
  if SameCurrencyAs(Amount) then
    result := FAmount = Amount.Amount
  else
    result := False;
end;

constructor TMoney.Create(Amount: Int64; FormatSettings : TFormatSettings);
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

function TMoney.GetAmount: Int64;
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

function TMoney.NewMoney(Amount: Int64): IMoney;
begin
  result := TMoney.Create(Amount, FFormatSettings);
end;

procedure TMoney.SetAmount(const Value: Int64);
begin
  FAmount := Value;
end;

function TMoney.Subtract(Amount: IMoney): IMoney;
begin
  if SameCurrencyAs(Amount) then
    result := NewMoney(FAmount - Amount.Amount)
  else
    raise ECurrencyCodeMismatch.Create('Currency Codes don''t match.');
end;

function TMoney.ToString: string;
begin
  result := Format('%m', [DecimalAmount], FFormatSettings);
end;

end.
