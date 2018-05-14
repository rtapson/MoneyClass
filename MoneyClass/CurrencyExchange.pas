unit CurrencyExchange;

interface

uses
  Money, SysUtils;

type
  TCurrencyExchange = class
  public
    class function ChangeCurrency(const FromMoney : IMoney; const ToFormatSettings : TFormatSettings; const ExchangeRate : Double): IMoney;
  end;

implementation

{ TCurrencyExchange }

class function TCurrencyExchange.ChangeCurrency(const FromMoney: IMoney; const ToFormatSettings: TFormatSettings; const ExchangeRate : Double): IMoney;
var
  NewAmount : integer;
begin
  result := TMoney.Create(FromMoney.Multiply(ExchangeRate).Amount, ToFormatSettings);
end;

end.
