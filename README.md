**Offer arithmetic of Integer larger than BigInteger as Text variable in pure AL**\
Support up to 288 digits (equiv. 957 bit Integer) positive/negative\
Decimals are not supported.\
The maximum value is : \
9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999\
\
***How it work***
\
Internally the value are stored as array of Integer (aka "limbs") for faster operation, the coduenit convert text to array of Integer in a base of 10^{9}.\
The Codeunit "INM Array Limbs Arithmetic" handle the limbs operations.\
\
 ***Supported Arithmetic operation***
\
For text based numbers, use the codeunit "INM Math Large Numbers" with following functions :\
\
AddBigNumbers(Number1: Text; Number2: Text): Text\
MultiplyBigNumbers(A: Text; B: Text) Result: Text\
SquareBigNumber(A: Text): Text\
PowerBigNumbers(Base: Text; Exponent: Text) Result: Text\
DivideBigNumbers(Dividend: Text; Divisor: Text) Result: Text\
ModBigNumbers(Dividend: Text; Divisor: Text) Result: Text\
ModInverseBigNumbers(Dividend: Text; Divisor: Text) Result: Text\
CompareBigNumbers(Number1: Text; Number2: Text): Integer\
\
Text variable passed to thoses function must only contain digits from 0..9 and optional leading sign.\
\
***How to Use***
\
\
var\
* LargeNumbMath: Codeunit "INM Math Large Numbers";\
* Result: Text;\
begin\
* Result := LargeNumbMath.MultiplyBigNumbers('12345678910111213', '98765421');\
* Message('Modulo %1 = %2', Result, LargeNumbMath.ModBigNumbers(Result, '4'));\
end;\
\
You can combine multiple operation such as :\
\
if LargeNumbMath.SubtractBigNumbers(LargeNumbMath.MultiplyBigNumbers('12345678910111213', '98765421'), '-152654') = '1219326175087955108918327' then\
 ...

