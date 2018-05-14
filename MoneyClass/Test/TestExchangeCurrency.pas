unit TestExchangeCurrency;

interface

uses
  TestFramework;

type
  TTestCurrencyExchange = class(TTestCase)
  published
    procedure TestCurrencyExchange;
    procedure TestCurrencyExchangeUSDtoGBP;
  end;

implementation

uses
  Money, CurrencyExchange, SysUtils;

{ TTestCurrencyExchange }

procedure TTestCurrencyExchange.TestCurrencyExchange;
var
  FromMoney : IMoney;
  ToMoney : IMoney;
begin
  FromMoney := TMoney.Create(36.48, TFormatSettings.Create(2057));
  ToMoney := TCurrencyExchange.ChangeCurrency(FromMoney, TFormatSettings.Create, 1.58);
  //57.6384
  //5764
  CheckEquals(5764, ToMoney.Amount);
  CheckEqualsString('$57.64', ToMoney.ToString);
end;

procedure TTestCurrencyExchange.TestCurrencyExchangeUSDtoGBP;
var
  FromMoney : IMoney;
  ToMoney : IMoney;
begin
  FromMoney := TMoney.Create(36.48);
  ToMoney := TCurrencyExchange.ChangeCurrency(FromMoney, TFormatSettings.Create(2057), 1.58);
  CheckEquals(5764, ToMoney.Amount);
  CheckEqualsString('£57.64', ToMoney.ToString);
end;

initialization
  RegisterTest(TTestCurrencyExchange.Suite);

end.
