unit Money;

interface

uses
  SysUtils, Spring.Collections;

type
  ECurrencyCodeMismatch = class(Exception);

  IMoney = interface
    function GetAmount: Int64;
    function GetFormatSettings: TFormatSettings;
    function GetDecimalAmount: Currency;

    function ToString: string;
    function Add(Amount : IMoney): IMoney;
    function Subtract(Amount : IMoney): IMoney;
    function Multiply(Amount : Currency): IMoney;
    function Allocate(Ratios : array of integer): IList<IMoney>;
    function Equals(Amount : IMoney): boolean;

    property Amount : Int64 read GetAmount;
    property DecimalAmount : Currency read GetDecimalAmount;
    property FormatSettings : TFormatSettings read GetFormatSettings;
  end;

  TMoney = class(TInterfacedObject, IMoney)
  strict private
    FAmount : Int64;
    FFormatSettings : TFormatSettings;

    function CentFactor: Int64;
    function CentFactorOf(const AFormatSettings : TFormatSettings): Int64;
    function SameCurrencyAs(const Other : IMoney): boolean;
    function NewMoney(Amount : Int64): IMoney;
    function GetAmount: Int64;
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

    property Amount : Int64 read GetAmount;
    property DecimalAmount : Currency read GetDecimalAmount;
    property FormatSettings : TFormatSettings read GetFormatSettings;
  end;

implementation

const
  // Currency itself carries four decimal places, so a scale beyond that cannot
  // round-trip through the Currency conversions anyway.
  MaxCurrencyDecimals = 4;
  CentFactors : array[0..MaxCurrencyDecimals] of Int64 = (1, 10, 100, 1000, 10000);

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
  Shares : TArray<Int64>;
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

  // FloorDiv, not div. div truncates toward zero, so for a negative amount the
  // shares come out collectively larger than the whole and leave a negative
  // Remainder that the distribution below would silently drop, losing a minor
  // unit. Flooring keeps Remainder in 0..High(Ratios) whatever the sign, so
  // every minor unit is handed out.
  SetLength(Shares, Length(Ratios));
  Remainder := FAmount;
  for i := Low(Ratios) to High(Ratios) do
  begin
    Shares[i] := FloorDiv(FAmount * Ratios[i], Total);
    Remainder := Remainder - Shares[i];
  end;

  for i := 0 to Integer(Remainder) - 1 do
    Shares[i] := Shares[i] + 1;

  // Settle the amounts before constructing, so no TMoney is ever handed out
  // and then altered. That is what lets IMoney.Amount stay read-only.
  result := TCollections.CreateList<IMoney>;
  for i := Low(Shares) to High(Shares) do
    result.Add(TMoney.Create(Shares[i], FFormatSettings));
end;

function TMoney.CentFactor: Int64;
begin
  result := CentFactorOf(FFormatSettings);
end;

function TMoney.CentFactorOf(const AFormatSettings : TFormatSettings): Int64;
begin
  // CurrencyDecimals is a Byte, and Windows regional settings let it run well
  // past the table. Reading off the end silently scaled amounts by whatever
  // happened to follow in memory, so refuse the setting instead.
  if AFormatSettings.CurrencyDecimals > MaxCurrencyDecimals then
    raise EArgumentException.CreateFmt(
      'CurrencyDecimals is %d; TMoney supports at most %d.',
      [AFormatSettings.CurrencyDecimals, MaxCurrencyDecimals]);

  result := CentFactors[AFormatSettings.CurrencyDecimals];
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
  FromFactor, ToFactor : Int64;
begin
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
  FFormatSettings := TFormatSettings.Create;
  FAmount := Round(Amount * CentFactor);
end;

constructor TMoney.Create(Amount: Int64);
begin
  FAmount := Amount;
  FFormatSettings := TFormatSettings.Create;
end;

constructor TMoney.Create(Other: IMoney);
begin
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
  FAmount := Amount;
  FFormatSettings := FormatSettings;
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
  FFormatSettings := FormatSettings;
  FAmount := Round(Amount * CentFactor);
end;

function TMoney.NewMoney(Amount: Int64): IMoney;
begin
  result := TMoney.Create(Amount, FFormatSettings);
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
