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
  Money, CurrencyExchange, SysUtils, TestMoney;

{ TTestCurrencyExchange }

procedure TTestCurrencyExchange.TestCurrencyExchange;
var
  FromMoney : IMoney;
  ToMoney : IMoney;
begin
  FromMoney := TMoney.FromLocale(36.48, LCID_GB);
  ToMoney := TCurrencyExchange.ChangeCurrency(FromMoney, TFormatSettings.Create(LCID_US), 1.58, TMoney.CurrencyCodeOfLocale(LCID_US));
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
  FromMoney := TMoney.FromLocale(36.48, LCID_US);
  ToMoney := TCurrencyExchange.ChangeCurrency(FromMoney, TFormatSettings.Create(LCID_GB), 1.58, TMoney.CurrencyCodeOfLocale(LCID_GB));
  CheckEquals(5764, ToMoney.Amount);
  CheckEqualsString('£57.64', ToMoney.ToString);
end;

initialization
  RegisterTest(TTestCurrencyExchange.Suite);

end.
