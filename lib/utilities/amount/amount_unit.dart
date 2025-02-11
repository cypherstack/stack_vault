import 'dart:math' as math;

import 'package:decimal/decimal.dart';
import 'package:intl/number_symbols.dart';
import 'package:intl/number_symbols_data.dart';
import 'package:stackduo/utilities/amount/amount.dart';
import 'package:stackduo/utilities/enums/coin_enum.dart';

// preserve index order as index is used to store value in preferences
enum AmountUnit {
  normal(0),
  milli(3),
  micro(6),
  nano(9),
  pico(12),
  femto(15),
  atto(18),
  zepto(21),
  yocto(24),
  ronto(27),
  quecto(30),
  ;

  const AmountUnit(this.shift);
  final int shift;

  static List<AmountUnit> valuesForCoin(Coin coin) {
    switch (coin) {
      case Coin.bitcoinTestNet:
      case Coin.bitcoin:
        return AmountUnit.values.sublist(0, 4);

      case Coin.monero:
        return AmountUnit.values.sublist(0, 5);
    }
  }
}

extension AmountUnitExt on AmountUnit {
  String unitForCoin(Coin coin) {
    switch (this) {
      case AmountUnit.normal:
        return coin.ticker;
      case AmountUnit.milli:
        return "m${coin.ticker}";
      case AmountUnit.micro:
        return "µ${coin.ticker}";
      case AmountUnit.nano:
        // if (coin == Coin.ethereum) {
        //   return "gwei";
        // } else
        if (
            // coin == Coin.wownero ||
            coin == Coin.monero
            //   ||
            // coin == Coin.nano ||
            // coin == Coin.banano
            ) {
          return "n${coin.ticker}";
        } else {
          return "sats";
        }
      case AmountUnit.pico:
        // if (coin == Coin.ethereum) {
        //   return "mwei";
        // } else
        if (
            // coin == Coin.wownero ||
            coin == Coin.monero
            //   ||
            // coin == Coin.nano ||
            // coin == Coin.banano
            ) {
          return "p${coin.ticker}";
        } else {
          return "invalid";
        }
      case AmountUnit.femto:
      // if (coin == Coin.ethereum) {
      //   return "kwei";
      // } else if (coin == Coin.nano || coin == Coin.banano) {
      //   return "f${coin.ticker}";
      // } else {
      //   return "invalid";
      // }
      case AmountUnit.atto:
      // if (coin == Coin.ethereum) {
      //   return "wei";
      // } else if (coin == Coin.nano || coin == Coin.banano) {
      //   return "a${coin.ticker}";
      // } else {
      //   return "invalid";
      // }
      case AmountUnit.zepto:
      // if (coin == Coin.nano || coin == Coin.banano) {
      //   return "z${coin.ticker}";
      // } else {
      //   return "invalid";
      // }
      case AmountUnit.yocto:
      // if (coin == Coin.nano || coin == Coin.banano) {
      //   return "y${coin.ticker}";
      // } else {
      //   return "invalid";
      // }
      case AmountUnit.ronto:
      // if (coin == Coin.nano || coin == Coin.banano) {
      //   return "r${coin.ticker}";
      // } else {
      //   return "invalid";
      // }
      case AmountUnit.quecto:
        // if (coin == Coin.nano || coin == Coin.banano) {
        //   return "q${coin.ticker}";
        // } else {
        return "invalid";
      // }
    }
  }

  String unitForContract(dynamic contract) {
    switch (this) {
      // case AmountUnit.normal:
      //   return contract.symbol;
      // case AmountUnit.milli:
      //   return "m${contract.symbol}";
      // case AmountUnit.micro:
      //   return "µ${contract.symbol}";
      // case AmountUnit.nano:
      //   return "gwei";
      // case AmountUnit.pico:
      //   return "mwei";
      // case AmountUnit.femto:
      //   return "kwei";
      // case AmountUnit.atto:
      //   return "wei";
      default:
        throw ArgumentError(
          "Duo has no eth",
        );
    }
  }

  Amount? tryParse(
    String value, {
    required String locale,
    required Coin coin,
    dynamic tokenContract,
  }) {
    final precisionLost = value.startsWith("~");

    final parts = (precisionLost ? value.substring(1) : value).split(" ");

    if (parts.first.isEmpty) {
      return null;
    }

    String str = parts.first;
    if (str.startsWith(RegExp(r'[+-]'))) {
      str = str.substring(1);
    }

    if (str.isEmpty) {
      return null;
    }

    // get number symbols for decimal place and group separator
    final numberSymbols = numberFormatSymbols[locale] as NumberSymbols? ??
        numberFormatSymbols[locale.substring(0, 2)] as NumberSymbols?;

    final groupSeparator = numberSymbols?.GROUP_SEP ?? ",";
    final decimalSeparator = numberSymbols?.DECIMAL_SEP ?? ".";

    str = str.replaceAll(groupSeparator, "");

    final decimalString = str.replaceFirst(decimalSeparator, ".");
    final Decimal? decimal = Decimal.tryParse(decimalString);

    if (decimal == null) {
      return null;
    }

    final int decimalPlaces = tokenContract?.decimals as int? ?? coin.decimals;
    final realShift = math.min(shift, decimalPlaces);

    return decimal.shift(0 - realShift).toAmount(fractionDigits: decimalPlaces);
  }

  String displayAmount({
    required Amount amount,
    required String locale,
    required Coin coin,
    required int maxDecimalPlaces,
    bool withUnitName = true,
    bool indicatePrecisionLoss = true,
    String? overrideUnit,
    dynamic? tokenContract,
  }) {
    assert(maxDecimalPlaces >= 0);

    // ensure we don't shift past minimum atomic value
    final realShift = math.min(shift, amount.fractionDigits);

    // shifted to unit
    final Decimal shifted = amount.decimal.shift(realShift);

    // get shift int value without fractional value
    final BigInt wholeNumber = shifted.toBigInt();

    // get decimal places to display
    final int places = math.max(0, amount.fractionDigits - realShift);

    // start building the return value with just the whole value
    String returnValue = wholeNumber.toString();

    // get number symbols for decimal place and group separator
    final numberSymbols = numberFormatSymbols[locale] as NumberSymbols? ??
        numberFormatSymbols[locale.substring(0, 2)] as NumberSymbols?;

    // insert group separator
    final regex = RegExp(r'\B(?=(\d{3})+(?!\d))');
    returnValue = returnValue.replaceAllMapped(
      regex,
      (m) => "${m.group(0)}${numberSymbols?.GROUP_SEP ?? ","}",
    );

    // if true and withUnitName is true, we will show "~" prepended on amount
    bool didLosePrecision = false;

    // if any decimal places should be shown continue building the return value
    if (places > 0) {
      // get the fractional value
      final Decimal fraction = shifted - shifted.truncate();

      // get final decimal based on max precision wanted while ensuring that
      // maxDecimalPlaces doesn't exceed the max per coin
      final int updatedMax;
      if (tokenContract != null) {
        updatedMax = maxDecimalPlaces > (tokenContract.decimals as int)
            ? tokenContract.decimals as int
            : maxDecimalPlaces;
      } else {
        updatedMax =
            maxDecimalPlaces > coin.decimals ? coin.decimals : maxDecimalPlaces;
      }
      final int actualDecimalPlaces = math.min(places, updatedMax);

      // get remainder string without the prepending "0."
      final fractionString = fraction.toString();
      String remainder;
      if (fractionString.length > 2) {
        remainder = fraction.toString().substring(2);
      } else {
        remainder = "0";
      }

      if (remainder.length > actualDecimalPlaces) {
        // check for loss of precision
        final remainingRemainder =
            BigInt.tryParse(remainder.substring(actualDecimalPlaces));
        if (remainingRemainder != null) {
          didLosePrecision = remainingRemainder > BigInt.zero;
        }

        // trim unwanted trailing digits
        remainder = remainder.substring(0, actualDecimalPlaces);
      } else if (remainder.length < actualDecimalPlaces) {
        // pad with zeros to achieve requested precision
        for (int i = remainder.length; i < actualDecimalPlaces; i++) {
          remainder += "0";
        }
      }

      // get decimal separator based on locale
      final String separator = numberSymbols?.DECIMAL_SEP ?? ".";

      // append separator and fractional amount
      returnValue += "$separator$remainder";
    }

    if (!withUnitName && !indicatePrecisionLoss) {
      return returnValue;
    }

    if (didLosePrecision && indicatePrecisionLoss) {
      returnValue = "~$returnValue";
    }

    if (!withUnitName && indicatePrecisionLoss) {
      return returnValue;
    }

    // return the value with the proper unit symbol
    if (tokenContract != null) {
      overrideUnit = unitForContract(tokenContract);
    }

    return "$returnValue ${overrideUnit ?? unitForCoin(coin)}";
  }
}
