

# AL Large Number Math

Offer arithmetic operation on arbitrary large integer in pure AL language.

Support signed 288 digits (120 byte Integer equivalent).
**Decimals are not supported.** 
Maximum supported value is :  
(-)9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999  
  
 
## Supported operation


Use the codeunit "INM Math Large Numbers" with following functions :

-   Add
-   Subtract
-   Multiply
-   Square
-   Power
-   Divide
-   Mod
-   ModInverse (modular inverse, popular in cryptography)
-   Compare
		- Return -1 when Number1 < Number2, 0 when equal or 1 when larger

Values passed and returned by thoses function are text based integer, and must only contain digits from 0..9 with optional leading sign.  

## How it work

Internally value are stored as "limbs" of AL Integers for faster operation.
The codeunit "INM Array Limbs Arithmetic" convert text based large number to array of Integer in a base of 10^9 (nine digits per limb). This codeunit have been carefully optimised for intensive call.

Values passed and returned, are represented with Text variable type.
  
##  Usage

```
var
    Math: Codeunit "INM Math Large Numbers";
    Result: Text;
begin
    Result := Math.Multiply('12345678910111213', '98765421');
    Message('Multiplication result = %1', Result);
end;
```

You can combine multiple operations ine one line such as :

```
Result := Math.Subtract(Math.Multiply('12345678910111213', '98765421'), '-152654');
```

## Limitations
  
**Performance :** 

The limbs manipulation have been optimized for operation on large number. 
Benchmark of 5'000 operations of random large number show an approximate of 25ns (0.025ms) per operation.  
The fastest operation is Compare (average of 2ns) then Square (average of 10ns).  
The slowest is Modular Inverse (average of 360ns).  
Other operation have consistent same **average duration (about 25ns)**.  
If the nmumeric value you use is in supported range of BigInteger, please use native operation for better performance.
  
**Length :**  
Maximum supported value is 288 digits "9" in positive or negative (sign "-" excluded of the length).  
Operation result larger than 288 digits will throw an overflow error.  
  
**Format**
Text passed must stirctly contain digit in 0..9 and optional leading negative sign "-".  
Any other format may throw a runtime error during the limb conversion.  
Negative result are returned with leading "-".  
  
**Decimals**
Decimals are not computed.
Division resulting in fractionnal number are returned truncated (i.e. 10/3 = 3).
Providing text with decimal separator such as dot or coma may throw runtime error or give incorrect result.
