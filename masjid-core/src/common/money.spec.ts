import {
  money,
  nonNegative,
  sumMoney,
  toAmount,
  toAmountOrNull,
  ZERO,
} from './money';

describe('money helpers', () => {
  it('adds exactly where JS numbers drift', () => {
    expect(0.1 + 0.2).not.toBe(0.3);
    expect(toAmount(sumMoney([0.1, 0.2]))).toBe(0.3);
    expect(toAmount(sumMoney([1300.25, 300.1, 777.77]))).toBe(2378.12);
  });

  it('subtracts exactly', () => {
    expect(toAmount(money(600).minus(200.25))).toBe(399.75);
    expect(toAmount(money('1532.82').minus(845.3))).toBe(687.52);
  });

  it('treats null and undefined as zero', () => {
    expect(money(null).equals(ZERO)).toBe(true);
    expect(toAmount(sumMoney([null, undefined, 5]))).toBe(5);
  });

  it('rounds responses to paise', () => {
    expect(toAmount(money(1).dividedBy(3))).toBe(0.33);
    expect(toAmountOrNull(null)).toBeNull();
    expect(toAmountOrNull('12.5')).toBe(12.5);
  });

  it('clamps negative dues to zero', () => {
    expect(toAmount(nonNegative(money(100).minus(150)))).toBe(0);
    expect(toAmount(nonNegative(money(100).minus(40)))).toBe(60);
  });
});
