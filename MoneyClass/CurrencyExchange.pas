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
begin
  // Delegate rather than duplicate: TMoney.ChangeCurrency rescales between
  // currencies that use different numbers of minor-unit digits.
  result := TMoney.ChangeCurrency(FromMoney, ToFormatSettings, ExchangeRate);
end;

end.
