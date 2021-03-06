unit TestMoney;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit 
  being tested.

}

interface

uses
  TestFramework, SysUtils, Money;

type
  // Test methods for class TMoney
  TestTMoney = class(TTestCase)
  strict private
    FMoney: TMoney;
  public
    procedure SetUp; override;
  published
    procedure TestToString;
    procedure TestAdd;
    procedure TestSubtract;
    procedure TestMultiply;
    procedure TestAllocate;
    procedure TestEquals;
    procedure TestChangeCurrencyConstructorGBPtoUSD;
    procedure TestChangeCurrencyConstructorUSDtoGBP;
    procedure TestJBConversion;
  end;

  //Test Allocating money
  TestAllocatingMoney = class(TTestCase)
  strict private
    FMoney: TMoney;
  public
    procedure SetUp; override;
  published
    procedure TestAllocate5050;
    procedure TestAllocate3070;
  end;

  //check the formatting for different currencies
  TestBritishMoney = class(TTestCase)
  strict private
    FMoney: TMoney;
  public
    procedure SetUp; override;
  published
    procedure TestToString;
  end;

  TestFrenchMoney = class(TTestCase)
  strict private
    FMoney: TMoney;
  public
    procedure SetUp; override;
  published
    procedure TestToString;
  end;

  TestGermanMoney = class(TTestCase)
  strict private
    FMoney: TMoney;
  public
    procedure SetUp; override;
  published
    procedure TestToString;
  end;

  TestSwedishMoney = class(TTestCase)
  strict private
    FMoney: TMoney;
  public
    procedure SetUp; override;
  published
    procedure TestToString;
  end;

implementation

uses
  Spring.Collections;

procedure TestTMoney.SetUp;
begin
  FMoney := TMoney.Create(45.34, TFormatSettings.Create);
end;

procedure TestTMoney.TestToString;
var
  ReturnValue: string;
begin
  ReturnValue := FMoney.ToString;
  Check(ReturnValue = '$45.34');
  // TODO: Validate method results
end;

procedure TestTMoney.TestAdd;
var
  ReturnValue: IMoney;
begin
  ReturnValue := FMoney.Add(TMoney.Create(50.29, TFormatSettings.Create));
  Check(ReturnValue.Amount = 9563);
end;

procedure TestTMoney.TestSubtract;
var
  ReturnValue: IMoney;
  Amount: IMoney;
begin
  Amount := TMoney.Create(30.03);
  ReturnValue := FMoney.Subtract(Amount);
  Check(ReturnValue.Amount = 1531);
end;

procedure TestTMoney.TestMultiply;
var
  ReturnValue: IMoney;
  Amount: Currency;
begin
  // TODO: Setup method call parameters
  Amount := 1.00;
  ReturnValue := FMoney.Multiply(Amount);
  // TODO: Validate method results
  Check(ReturnValue.DecimalAmount = FMoney.DecimalAmount, 'Multiply failed');
end;

procedure TestTMoney.TestAllocate;
var
  ReturnValue: IList<IMoney>;
  Ratios: array[0..1] of integer;
begin
  Ratios[0] := 7;
  Ratios[1] := 3;

  ReturnValue := FMoney.Allocate(Ratios);

  Check(ReturnValue.Items[0].Amount = 3174);
  Check(ReturnValue.Items[1].Amount = 1360);
end;

procedure TestTMoney.TestChangeCurrencyConstructorGBPtoUSD;
var
  FromMoney : IMoney;
  ToMoney : IMoney;
begin
  FromMoney := TMoney.Create(36.48, TFormatSettings.Create(2057));
  ToMoney := TMoney.ChangeCurrency(FromMoney, TFormatSettings.Create, 1.58);
  //57.6384
  //5764
  CheckEquals(5764, ToMoney.Amount);
  CheckEqualsString('$57.64', ToMoney.ToString);
end;

procedure TestTMoney.TestChangeCurrencyConstructorUSDtoGBP;
var
  FromMoney : IMoney;
  ToMoney : IMoney;
begin
  FromMoney := TMoney.Create(36.48);
  ToMoney := TMoney.ChangeCurrency(FromMoney, TFormatSettings.Create(2057), 1.58);
  CheckEquals(5764, ToMoney.Amount);
  CheckEqualsString('�57.64', ToMoney.ToString);
end;

procedure TestTMoney.TestEquals;
var
  ReturnValue : boolean;
  aMoney : IMoney;
begin
  aMoney := TMoney.Create(45.34);
  ReturnValue := FMoney.Equals(aMoney);
  Check(ReturnValue);

  aMoney := nil;
  aMoney := TMoney.Create(5.27);
  ReturnValue := FMoney.Equals(aMoney);
  CheckFalse(ReturnValue);

  aMoney := nil;
  aMoney := TMoney.Create(5.27, TFormatSettings.Create(2057));
  ReturnValue := FMoney.Equals(aMoney);
//  CheckException(ReturnValue);

end;

procedure TestTMoney.TestJBConversion;
var
  CRC : IMoney;
  USD : IMoney;
begin
{  CRC := TMoney.Create(135102.13);

  USD := Crc.(492.57);

  CheckEquals(274.28, USD.DecimalAmount);}

  USD := TMoney.Create(FromMoney.Multiply(ExchangeRate).Amount, ToFormatSettings);
end;

{ TestBritishMoney }

procedure TestBritishMoney.SetUp;
begin
  FMoney := TMoney.Create(45.34, TFormatSettings.Create(2057));
end;

procedure TestBritishMoney.TestToString;
var
  ReturnValue: string;
begin
  ReturnValue := FMoney.ToString;
  Check(ReturnValue = '�45.34');
end;

{ TestFrenchMoney }

procedure TestFrenchMoney.SetUp;
begin
  FMoney := TMoney.Create(45.34, TFormatSettings.Create(1036));
end;

procedure TestFrenchMoney.TestToString;
var
  ReturnValue: string;
begin
  ReturnValue := FMoney.ToString;
  Check(ReturnValue = '45,34 �');
end;

{ TestGermanMoney }

procedure TestGermanMoney.SetUp;
begin
  FMoney := TMoney.Create(45.34, TFormatSettings.Create(1031));
end;

procedure TestGermanMoney.TestToString;
var
  ReturnValue: string;
begin
  ReturnValue := FMoney.ToString;
  Check(ReturnValue = '45,34 �');
end;

{ TestSwedishMoney }

procedure TestSwedishMoney.SetUp;
begin
  FMoney := TMoney.Create(45.34, TFormatSettings.Create(1053));
end;

procedure TestSwedishMoney.TestToString;
var
  ReturnValue: string;
begin
  ReturnValue := FMoney.ToString;
  Check(ReturnValue = '45,34 kr');
end;

{ TestAllocatingMoney }

procedure TestAllocatingMoney.SetUp;
begin
  FMoney := TMoney.Create(0.05);
end;

procedure TestAllocatingMoney.TestAllocate3070;
var
  ReturnValue: IList<IMoney>;
  Ratios: array[0..1] of integer;
begin
  Ratios[0] := 3;
  Ratios[1] := 7;

  ReturnValue := FMoney.Allocate(Ratios);

  Check(ReturnValue.Items[0].Amount = 2);
  Check(ReturnValue.Items[1].Amount = 3);
end;

procedure TestAllocatingMoney.TestAllocate5050;
var
  ReturnValue: IList<IMoney>;
  Ratios: array[0..1] of integer;
begin
  Ratios[0] := 5;
  Ratios[1] := 5;

  ReturnValue := FMoney.Allocate(Ratios);

  Check(ReturnValue.Items[0].Amount = 3);
  Check(ReturnValue.Items[1].Amount = 2);
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTMoney.Suite);
  RegisterTest(TestBritishMoney.Suite);
  RegisterTest(TestFrenchMoney.Suite);
  RegisterTest(TestGermanMoney.Suite);
  RegisterTest(TestSwedishMoney.Suite);
  RegisterTest(TestAllocatingMoney.Suite);

end.

