
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
SubtractBigNumbers(Number1: Text; Number2: Text): Text\
MultiplyBigNumbers(A: Text; B: Text) Result: Text\
SquareBigNumber(A: Text): Text\
PowerBigNumbers(Base: Text; Exponent: Text) Result: Text\
DivideBigNumbers(Dividend: Text; Divisor: Text) Result: Text\
ModBigNumbers(Dividend: Text; Divisor: Text) Result: Text\
ModInverseBigNumbers(Dividend: Text; Divisor: Text) Result: Text\
CompareBigNumbers(Number1: Text; Number2: Text): Integer\
\
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


***Limitation***
\
Performance : The limbs manipulation have been optimized for operation on large number. division use Knuh algorihtm. \
Benchmark of 5'000 operations of random large number show an average duration of 10ns (0.01ms) per operation.\
Fastest operation is Compare (average of 0.8ns) while other operation have consistent same average duration about 10ns.\
\
Length :\
Maximum supported value is 288 digits "9" in positvie or negative (1 sign + 288 digits).\
Operation result larger than 288 digit will throw an overflow error.\
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

