codeunit 57298 "INM Math Large Numbers"
{
    SingleInstance = true;
    /*
    This codeunit offer math operation on very large number that can't be handled in BigInteger
    Value are passed and return as Text ie: 
        Result := MultiplyBigNumbers('12345678901234567890', '2');
    Performance : Very slow compared to builtint integer operation.
    Please use with caution
    Does Not support decimals and only digit chars & leading '-'


    Available operations:
    - AddBigNumbers(Number1: Text; Number2: Text): Text
    - SubtractBigNumbers(Number1: Text; Number2: Text): Text
    - MultiplyBigNumbers(A: Text; B: Text) Result: Text
    - SquareBigNumber(A: Text): Text
    - PowerBigNumbers(Base: Text; Exponent: Text) Result: Text
    - DivideBigNumbers(Dividend: Text; Divisor: Text) Result: Text
    - ModBigNumbers(Dividend: Text; Divisor: Text) Result: Text
    - ModInverseBigNumbers(Dividend: Text; Divisor: Text) Result: Text
    - CompareBigNumbers(Number1: Text; Number2: Text): Integer
*/

    procedure AddBigNumbers(Number1: Text; Number2: Text): Text
    var
        Sign1: Boolean;
        Sign2: Boolean;
        Abs1: Text;
        Abs2: Text;
        Result: Text;
    begin
        Sign1 := true;
        Sign2 := true;
        if Number1.StartsWith('-') then begin
            Sign1 := false;
            Abs1 := Number1.Substring(2);
        end else
            Abs1 := Number1;

        if Number2.StartsWith('-') then begin
            Sign2 := false;
            Abs2 := Number2.Substring(2);
        end else
            Abs2 := Number2;

        if Sign1 = Sign2 then begin
            Result := AddUnSignedBigNumbers(Abs1, Abs2);
            if Sign1 = false then
                exit('-' + Result);
            exit(Result);
        end else
            case CompareBigNumbers(Abs1, Abs2) of
                0:
                    exit('0');
                1:
                    begin
                        Result := SubtractBigNumbers(Abs1, Abs2);
                        if Sign1 = false then
                            exit('-' + Result)
                        else
                            exit(Result);
                    end;
                -1:
                    begin
                        Result := SubtractBigNumbers(Abs2, Abs1);
                        if Sign2 = false then
                            exit('-' + Result)
                        else
                            exit(Result);
                    end;
            end;
    end;

    local procedure AddUnSignedBigNumbers(Number1: Text; Number2: Text): Text
    var
        Result: Text;
        Digit1, Digit2 : Integer;
        Sum, Carry : Integer;
        i, MaxLength : Integer;
    begin
        // Ensure numbers are padded to the same length
        MaxLength := MaxStrLen(Number1, Number2);
        Number1 := PadLeft(Number1, MaxLength, '0');
        Number2 := PadLeft(Number2, MaxLength, '0');

        Carry := 0;
        Result := '';

        // Process digits from right to left
        for i := MaxLength - 1 downto 0 do begin
            Digit1 := Number1[i + 1] - 48;
            Digit2 := Number2[i + 1] - 48;
            Sum := Digit1 + Digit2 + Carry;
            Carry := Sum div 10;
            Result := Format(Sum mod 10) + Result;
        end;

        if Carry > 0 then
            Result := Format(Carry) + Result;

        // Remove leading zeros
        Result := TrimLeadingZeros(Result);
        if Result = '' then
            Result := '0';

        exit(Result);
    end;

    local procedure SubtractPositiveBigNumbers(Number1: Text; Number2: Text): Text
    var
        Result: Text;
        Digit1, Digit2 : Integer;
        Diff, Borrow : Integer;
        i, MaxLength : Integer;
        IsNegative: Boolean;
        Temp: Text;
    begin
        // Determine if result will be negative
        IsNegative := CompareBigNumbers(Number1, Number2) < 0;

        // If Number1 < Number2, swap and set negative flag
        if IsNegative then begin
            Temp := Number1;
            Number1 := Number2;
            Number2 := Temp;
        end;

        // Ensure numbers are padded to the same length
        MaxLength := MaxStrLen(Number1, Number2);
        Number1 := PadLeft(Number1, MaxLength, '0');
        Number2 := PadLeft(Number2, MaxLength, '0');

        Borrow := 0;
        Result := '';

        // Process digits from right to left
        for i := MaxLength - 1 downto 0 do begin
            Digit1 := Number1[i + 1] - 48;
            Digit2 := Number2[i + 1] - 48;
            Digit1 := Digit1 - Borrow;
            if Digit1 < Digit2 then begin
                Digit1 := Digit1 + 10;
                Borrow := 1;
            end else
                Borrow := 0;

            Diff := Digit1 - Digit2;
            Result := Format(Diff) + Result;
        end;

        // Remove leading zeros
        Result := Result.TrimStart('0');
        if Result = '' then
            Result := '0';

        // Add negative sign if necessary
        if IsNegative and (Result <> '0') then
            Result := '-' + Result;

        exit(Result);
    end;

    procedure SubtractBigNumbers(Number1: Text; Number2: Text): Text
    var
        Sign1, Sign2 : Boolean;
        AbsNum1, AbsNum2 : Text;
        ResultAbs: Text;
        ResultSign: Boolean;
    begin
        // Extraire signe Number1
        if (StrLen(Number1) > 0) and (Number1.StartsWith('-')) then begin
            Sign1 := false;
            AbsNum1 := Number1.TrimStart('-');
        end else begin
            Sign1 := true;
            AbsNum1 := Number1;
        end;

        // Extraire signe Number2
        if (StrLen(Number2) > 0) and (Number2.StartsWith('-')) then begin
            Sign2 := false;
            AbsNum2 := Number2.TrimStart('-');
        end else begin
            Sign2 := true;
            AbsNum2 := Number2;
        end;

        // Maintenant on calcule Result = Sign1 * AbsNum1 - Sign2 * AbsNum2

        if Sign1 = Sign2 then begin
            // même signe => on fait une soustraction des valeurs absolues
            if CompareBigNumbers(AbsNum1, AbsNum2) >= 0 then begin
                ResultAbs := SubtractPositiveBigNumbers(AbsNum1, AbsNum2); // nouvelle fonction à créer : soustraction sans signe, AbsNum1 >= AbsNum2
                ResultSign := Sign1;
            end else begin
                ResultAbs := SubtractPositiveBigNumbers(AbsNum2, AbsNum1);
                ResultSign := not Sign1;
            end;
        end else begin
            // signes différents => on fait une addition
            ResultAbs := AddBigNumbers(AbsNum1, AbsNum2);
            ResultSign := Sign1;
        end;

        // Ajouter signe si négatif et différent de 0
        if (ResultSign = false) and (ResultAbs <> '0') then
            exit('-' + ResultAbs)
        else
            exit(ResultAbs);
    end;

    procedure SquareBigNumber(A: Text): Text
    var
        ArrayLimbsMath: codeunit "INM Array Limbs Arithmetic";
        IntArr: array[32] of Integer;
        IntArrLen: Integer;
        ResIntArr: array[32] of Integer;
        ResIntArrLen: Integer;
    begin
        ArrayLimbsMath.TextToArray(A, IntArr, IntArrLen);
        ArrayLimbsMath.SquareArrays(IntArr, IntArrLen, ResIntArr, ResIntArrLen);
        exit(ArrayLimbsMath.ArrayToText(ResIntArr, ResIntArrLen)); // square is alway positive
    end;

    procedure MultiplyBigNumbers(A: Text; B: Text) Result: Text
    var
        ArrayLimbsMath: codeunit "INM Array Limbs Arithmetic";
        IsNegative: Boolean;
        IntArr: array[32] of Integer;
        IntArrLen: Integer;
        IntArrB: array[32] of Integer;
        IntArrBLen: Integer;
        ResIntArr: array[32] of Integer;
        ResIntArrLen: Integer;
    begin
        // Gestion des signes
        IsNegative := false;

        if A[1] = '-' then begin
            A := A.TrimStart('-');
            IsNegative := not IsNegative;
        end;

        if B[1] = '-' then begin
            B := B.TrimStart('-');
            IsNegative := not IsNegative;
        end;

        // Gestion des zéros
        A := A.TrimStart('0');
        B := B.TrimStart('0');

        if (A = '') or (B = '') then
            exit('0');

        ArrayLimbsMath.TextToArray(A, IntArr, IntArrLen);
        ArrayLimbsMath.TextToArray(B, IntArrB, IntArrBLen);
        ArrayLimbsMath.MultiplyArrays(IntArr, IntArrLen, IntArrB, IntArrBLen, ResIntArr, ResIntArrLen);
        Result := ArrayLimbsMath.ArrayToText(ResIntArr, ResIntArrLen);

        // Ajouter le signe si nécessaire
        if IsNegative and (Result <> '0') then
            Result := '-' + Result;

        exit(Result);
    end;

    procedure PowerBigNumbers(Base: Text; Exponent: Text) Result: Text
    var
        ArrayLimbsMath: codeunit "INM Array Limbs Arithmetic";
        IsNegative: Boolean;
        IntArr: array[32] of Integer;
        IntArrLen: Integer;
        IntArrB: array[32] of Integer;
        IntArrBLen: Integer;
        ResIntArr: array[32] of Integer;
        ResIntArrLen: Integer;
    begin
        // Handle edge cases
        if Base = '0' then
            exit('0');
        if Exponent = '0' then
            exit('1');
        if Exponent = '1' then
            exit(Base);

        // Gestion des signes
        IsNegative := false;
        if Base[1] = '-' then begin
            Base := Base.TrimStart('-');
            IsNegative := true;
        end;

        // Gestion des zéros
        Base := Base.TrimStart('0');
        Exponent := Exponent.TrimStart('0');

        if (Base = '') or (Exponent = '') then
            exit('0');

        ArrayLimbsMath.TextToArray(Base, IntArr, IntArrLen);
        ArrayLimbsMath.TextToArray(Exponent, IntArrB, IntArrBLen);
        ArrayLimbsMath.PowerArrays(IntArr, IntArrLen, IntArrB, IntArrBLen, ResIntArr, ResIntArrLen);
        Result := ArrayLimbsMath.ArrayToText(ResIntArr, ResIntArrLen);

        // Ajouter le signe si nécessaire
        if IsNegative then
            if not ArrayLimbsMath.IsEven(IntArrB) then // Even Exponent = +, Odd exponent = -
                Result := '-' + Result;

        exit(Result);
    end;

    procedure DivideBigNumbers(Dividend: Text; Divisor: Text) Result: Text
    var
        ArrayLimbsMath: codeunit "INM Array Limbs Arithmetic";
        IntArr: array[32] of Integer;
        IntArrLen: Integer;
        IntArrB: array[32] of Integer;
        IntArrBLen: Integer;
        ResIntArr: array[32] of Integer;
        ResIntArrLen: Integer;
        Sign1, Sign2 : Boolean;
        SignResult: Boolean;
    begin
        // Détecter signe Number1
        if (StrLen(Dividend) > 0) and Dividend.StartsWith('-') then begin
            Dividend := Dividend.TrimStart('-');
            Sign1 := false;
        end else
            Sign1 := true;

        // Détecter signe Divisor
        if (StrLen(Divisor) > 0) and (CopyStr(Divisor, 1, 1) = '-') then begin
            Divisor := Divisor.TrimStart('-');
            Sign2 := false;
        end else
            Sign2 := true;

        SignResult := (Sign1 = Sign2);

        if Divisor = '0' then
            Error('Division by zero is not allowed.');

        // Si Number1 < Divisor, quotient = 0
        if CompareBigNumbers(Dividend, Divisor) = -1 then
            exit('0');

        ArrayLimbsMath.TextToArray(Dividend, IntArr, IntArrLen);
        ArrayLimbsMath.TextToArray(Divisor, IntArrB, IntArrBLen);
        ArrayLimbsMath.DivideArray(IntArr, IntArrLen, IntArrB, IntArrBLen, ResIntArr, ResIntArrLen);
        if ResIntArrLen = 0 then
            exit('0');
        if (SignResult = false) and (Result <> '0') then // Ajouter le signe si négatif
            Result := '-' + ArrayLimbsMath.ArrayToText(ResIntArr, ResIntArrLen)
        else
            Result := ArrayLimbsMath.ArrayToText(ResIntArr, ResIntArrLen);
        exit(Result);
    end;

    procedure DivideBigNumbers(Number1: Text; Divisor: Text; MaxDecimalPlaces: Integer): Text
    // This division return also decimal using dot "." as decimal separator, if needed
    var
        Quotient: TextBuilder;
        Current: Text;
        Count: Integer;
        i: Integer;
        IntegerPart1, DecimalPart1 : Text;
        IntegerPart2, DecimalPart2 : Text;
        DecimalShift: Integer;
        AdjustedNumber1, AdjustedDivisor : Text;
        MaxLength: Integer;
        TempQuotient: Text;
        QuotLen: Integer;
        PadZeros: Integer;
    begin
        // Validate inputs
        if Number1 = '' then
            Error('Number1 cannot be empty.');
        if Divisor = '' then
            Error('Divisor cannot be empty.');
        if Divisor = '0' then
            Error('Division by zero is not allowed.');

        // Validate characters and parse decimal parts
        ParseNumber(Number1, IntegerPart1, DecimalPart1);
        ParseNumber(Divisor, IntegerPart2, DecimalPart2);

        // Count decimal places
        DecimalShift := StrLen(DecimalPart1) - StrLen(DecimalPart2);

        // Adjust numbers to remove decimals
        AdjustedNumber1 := IntegerPart1 + DecimalPart1;
        AdjustedDivisor := IntegerPart2 + DecimalPart2;

        // Remove leading zeros
        AdjustedNumber1 := TrimLeadingZeros(AdjustedNumber1);
        AdjustedDivisor := TrimLeadingZeros(AdjustedDivisor);

        // Handle edge cases
        if AdjustedNumber1 = '0' then
            exit('0');

        Current := '';
        if MaxDecimalPlaces <= 0 then
            MaxDecimalPlaces := 50; // Limit decimal precision
        MaxLength := 250; // Total length limit including dot

        // Process the division to build the quotient without decimal
        for i := 1 to StrLen(AdjustedNumber1) do begin
            Current := Current + AdjustedNumber1[i];
            Current := TrimLeadingZeros(Current);

            // Count how many times Divisor fits into Current
            Count := 0;
            while CompareBigNumbers(Current, AdjustedDivisor) >= 0 do begin
                Current := SubtractBigNumbers(Current, AdjustedDivisor);
                Count += 1;
            end;

            Quotient.Append(Format(Count));
        end;

        TempQuotient := TrimLeadingZeros(Quotient.ToText());
        Quotient.Clear();
        QuotLen := StrLen(TempQuotient);

        // Place decimal point based on DecimalShift
        if DecimalShift > 0 then begin
            if QuotLen <= DecimalShift then begin
                Quotient.Append('0.');
                PadZeros := DecimalShift - QuotLen;
                Quotient.Append(RepeatChar('0', PadZeros));
                Quotient.Append(TempQuotient);
            end else begin
                Quotient.Append(CopyStr(TempQuotient, 1, QuotLen - DecimalShift));
                Quotient.Append('.');
                Quotient.Append(CopyStr(TempQuotient, QuotLen - DecimalShift + 1, DecimalShift));
            end;
        end else if DecimalShift < 0 then begin
            Quotient.Append(TempQuotient);
            Quotient.Append(RepeatChar('0', -DecimalShift));
        end else begin
            Quotient.Append(TempQuotient);
        end;

        // Compute additional decimal part if remainder != 0
        if (Current <> '0') and (StrLen(Quotient.ToText()) < MaxLength) then begin
            if Quotient.ToText().IndexOf('.') = 0 then
                Quotient.Append('.')
            else
                MaxDecimalPlaces -= Quotient.Length - Quotient.ToText().IndexOf('.'); // reduce max decimals with existing one

            for i := 1 to MaxDecimalPlaces do begin
                if StrLen(Quotient.ToText()) >= MaxLength then
                    exit(TrimTrailingDecimalZeros(TrimLeadingZeros(Quotient.ToText())));
                if Current = '0' then
                    exit(TrimTrailingDecimalZeros(TrimLeadingZeros(Quotient.ToText())));

                Current := Current + '0';
                Current := TrimLeadingZeros(Current);

                Count := 0;
                while CompareBigNumbers(Current, AdjustedDivisor) >= 0 do begin
                    Current := SubtractBigNumbers(Current, AdjustedDivisor);
                    Count += 1;
                end;

                Quotient.Append(Format(Count));
            end;
        end;

        exit(TrimTrailingDecimalZeros(TrimLeadingZeros(Quotient.ToText())));
    end;

    procedure ModBigNumbers(Dividend: Text; Divisor: Text) Result: Text
    var
        ArrayLimbsMath: codeunit "INM Array Limbs Arithmetic";
        IntArr: array[32] of Integer;
        IntArrLen: Integer;
        IntArrB: array[32] of Integer;
        IntArrBLen: Integer;
        RemIntArr: array[32] of Integer;
        RemIntArrLen: Integer;
        Sign1, Sign2 : Boolean;
        SignResult: Boolean;
    begin
        // Détecter signe Number1
        if (StrLen(Dividend) > 0) and Dividend.StartsWith('-') then begin
            Dividend := Dividend.TrimStart('-');
            Sign1 := false;
        end else
            Sign1 := true;

        // Détecter signe Divisor
        if (StrLen(Divisor) > 0) and (CopyStr(Divisor, 1, 1) = '-') then begin
            Divisor := Divisor.TrimStart('-');
            Sign2 := false;
        end else
            Sign2 := true;

        SignResult := (Sign1 = Sign2);

        if Divisor = '0' then
            Error('Division by zero is not allowed.');

        // Si Number1 < Divisor, quotient = 0
        if CompareBigNumbers(Dividend, Divisor) = -1 then
            exit('0');

        ArrayLimbsMath.TextToArray(Dividend, IntArr, IntArrLen);
        ArrayLimbsMath.TextToArray(Divisor, IntArrB, IntArrBLen);
        ArrayLimbsMath.ModuloArray(IntArr, IntArrLen, IntArrB, IntArrBLen, RemIntArr, RemIntArrLen);
        if RemIntArrLen = 0 then
            exit('0')
        else
            if (SignResult = false) and (Result <> '0') then // Ajouter le signe si négatif
                Result := '-' + ArrayLimbsMath.ArrayToText(RemIntArr, RemIntArrLen)
            else
                Result := ArrayLimbsMath.ArrayToText(RemIntArr, RemIntArrLen);
        exit(Result);
    end;

    procedure ModInverseBigNumbers(Dividend: Text; Divisor: Text) Result: Text
    var
        ArrayLimbsMath: codeunit "INM Array Limbs Arithmetic";
        IntArr: array[32] of Integer;
        IntArrLen: Integer;
        IntArrB: array[32] of Integer;
        IntArrBLen: Integer;
        RemIntArr: array[32] of Integer;
        RemIntArrLen: Integer;
        negativeDividend: Boolean;
    begin
        negativeDividend := false;
        if Dividend.StartsWith('-') then begin
            negativeDividend := true;
            Dividend := Dividend.Substring(2);
        end;

        if Divisor.StartsWith('-') then
            Divisor := Divisor.Substring(2);

        if Divisor = '0' then
            Error('Division by zero is not allowed.');

        ArrayLimbsMath.TextToArray(Dividend, IntArr, IntArrLen);
        ArrayLimbsMath.TextToArray(Divisor, IntArrB, IntArrBLen);
        ArrayLimbsMath.ModuloInverseArray(IntArr, IntArrLen, IntArrB, IntArrBLen, RemIntArr, RemIntArrLen);

        if negativeDividend then begin
            if ArrayLimbsMath.IsZeroArray(RemIntArr, RemIntArrLen) then
                Result := '0'
            else begin
                ArrayLimbsMath.SubtractArrays(IntArrB, IntArrBLen, RemIntArr, RemIntArrLen, IntArr, IntArrLen);
                Result := ArrayLimbsMath.ArrayToText(IntArr, IntArrLen);
            end;
        end else
            Result := ArrayLimbsMath.ArrayToText(RemIntArr, RemIntArrLen);
        exit(Result);
    end;

    procedure CompareBigNumbers(Number1: Text; Number2: Text): Integer
    var
        Sign1: Boolean;
        Sign2: Boolean;
        Abs1: Text;
        Abs2: Text;
    begin
        Sign1 := true;
        Sign2 := true;
        if Number1.StartsWith('-') then begin
            Sign1 := false;
            Abs1 := Number1.Substring(2);
        end else
            Abs1 := Number1;

        if Number2.StartsWith('-') then begin
            Sign2 := false;
            Abs2 := Number2.Substring(2);
        end else
            Abs2 := Number2;

        if Sign1 <> Sign2 then
            if Sign1 then
                exit(1)
            else
                exit(-1);

        if Sign1 then
            exit(CompareBigNumbersUnSigned(Abs1, Abs2))
        else
            exit(-CompareBigNumbersUnSigned(Abs1, Abs2));
    end;

    local procedure CompareBigNumbersUnSigned(Number1: Text; Number2: Text): Integer
    var
        Len1, Len2 : Integer;
    begin
        Number1 := Number1.TrimStart('0');
        Number2 := Number2.TrimStart('0');

        // Exactly same values
        if Number1 = Number2 then
            exit(0);

        Len1 := StrLen(Number1);
        Len2 := StrLen(Number2);

        // Compare lengths first
        if Len1 > Len2 then
            exit(1);
        if Len1 < Len2 then
            exit(-1);

        // If lengths are equal, compare lexicographically
        if Number1 > Number2 then
            exit(1);
        if Number1 < Number2 then
            exit(-1);
        exit(0);
    end;


    #region internal
    local procedure TrimTrailingDecimalZeros(Number: Text): Text
    begin
        if Number.IndexOf('.') > 0 then
            exit(Number.TrimEnd('0'))
        else
            exit(Number);
    end;

    local procedure ParseNumber(Number: Text; var IntegerPart: Text; var DecimalPart: Text)
    var
        SepPlace: Integer;
    begin
        SepPlace := Number.IndexOf('.');
        case SepPlace of
            0:
                // no decimal
                IntegerPart := Number;
            1:
                begin
                    // direct decimal
                    IntegerPart := '0';
                    DecimalPart := CopyStr(Number, 2);
                end;
            else begin
                // decimal after integer
                IntegerPart := CopyStr(Number, 1, SepPlace - 1);
                DecimalPart := CopyStr(Number, SepPlace + 1);
            end;
        end;
    end;

    local procedure TrimLeadingZeros(Number: Text): Text
    begin
        Number := Number.TrimStart('0');
        if Number.StartsWith('.') then
            exit('0' + Number)
        else
            if Number = '' then
                Number := '0';
        exit(Number);
    end;

    local procedure PadLeft(Number: Text; LengthToReach: Integer; PadChar: Char) Result: Text
    begin
        Result := Number;
        while (StrLen(Result) < LengthToReach) do
            Result := PadChar + Result;
    end;

    local procedure MaxStrLen(Str1: Text; Str2: Text): Integer
    begin
        if StrLen(Str1) > StrLen(Str2) then
            exit(StrLen(Str1));
        exit(StrLen(Str2));
    end;

    procedure DecToBin(Number: Text): Text
    var
        N: Text;
        Result: Text;
    begin
        N := Number;
        while CompareBigNumbers(N, '0') > 0 do begin
            //Evaluate(Bit, ModBigNumbers(N, '2'));
            if ModBigNumbers(N, '2') = '0' then
                Result := '0' + Result
            else
                Result := '1' + Result;
            N := DivideBigNumbers(N, '2');
        end;
        exit(Result);
    end;

    local procedure RepeatChar(Char: Char; Count: Integer) Result: Text
    begin
        while strlen(Result) < Count do
            Result += Char;
    end;

    #endregion
}