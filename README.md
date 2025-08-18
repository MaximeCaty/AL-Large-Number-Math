
**Offer arithmetic of Integer larger than BigInteger as Text variable in pure AL**\
Support up to 288 digits (equiv. 957 bit Integer) positive/negative\
Decimals are not supported.\
The maximum value is : \
9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999\
\
***How it work***
\
Internally the value are stored as "limbs" Integer for faster operation, the codeunit convert text to array of Integer in a base of 10^9 (nine digits per limb).\
The Codeunit "INM Array Limbs Arithmetic" handle the limbs operations.\
\
 ***Supported Arithmetic operation***
\
For text based numbers, use the codeunit "INM Math Large Numbers" with following functions :

- Add(Number1: Text; Number2: Text): Text
- Subtract(Number1: Text; Number2: Text): Text
- Multiply(A: Text; B: Text) Result: Text
- Square(A: Text): Text
- Power(Base: Text; Exponent: Text) Result: Text
- Divide(Dividend: Text; Divisor: Text) Result: Text
- Mod(Dividend: Text; Divisor: Text) Result: Text
- ModInverse(Dividend: Text; Divisor: Text) Result: Text
- Compare(Number1: Text; Number2: Text): Integer
	-  	Return -1 when Number1 < Number2, 0 when equal or 1 when larger

Text passed to thoses functions must only contain digits from 0..9 and optional leading sign.\
\
***How to Use***


    var
	    LargeNumbMath: Codeunit "INM Math Large Numbers";
	    Result: Text;
    begin
	    Result := LargeNumbMath.MultiplyBigNumbers('12345678910111213', '98765421');
	    Message('Modulo %1 = %2', Result, LargeNumbMath.ModBigNumbers(Result, '4'));
    end;

You can combine multiple operation such as :


    if LargeNumbMath.SubtractBigNumbers(LargeNumbMath.MultiplyBigNumbers('12345678910111213', '98765421'), '-152654') = '1219326175087955108918327' then
     ...


***Limitations***
\
\
Performance :\
The limbs manipulation have been optimized for operation on large number.
Benchmark of 5'000 operations of random large number show an approximate of 130ms duration, so average of 25ns (0.025ms) per operation.\
The fastest operation is Compare (average of 2ns) then Square (average of 10ns).\
The slowest is Modular Inverse (average of 360ns).\
Other operation have consistent same average duration (about 25ns).\
If your value is in supported range of BigInteger or Decimal, you should not use this functions as its slower than native operation.\
\
Length :\
Maximum supported value is 288 digits "9" in positive or negative (sign "-" excluded of the length).\
Operation result larger than 288 digits will throw an overflow error.\
\
Text Format:\
Must stirctly contain digit in 0..9 and optioan leading negative sign "-".\
Any other format will throw an error for the conversion into limb array.\
Negative result are returned with leading "-".\
\
Decimals:\
Decimnals are not computed, division resulting in fraction are returned rounded down.\
Providing text with decimal separator such a s dot or coma to operation function will throw an error or incorrect output.\
You may cheat to support decimal adding trailing 0 to your number (as much as the number of decimal), then format the result to add a decimal separator at the position : strlen - number of zero you added.
\
Operations:\
SquareRoot, and trigonometric function are not implemented.\

