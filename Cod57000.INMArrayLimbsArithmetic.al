codeunit 57000 "INM Array Limbs Arithmetic"
{
    // Provide convertion and math operation on Arrays 32 of limbs integer base 1000000000
    /*
        Conversion :
            TextToArray(BigBigInteger: Text; var ArrInt: array[32] of Integer; var Len: Integer)
            ArrayToText(var ArrInt: array[32] of Integer; var ArrLen: Integer): Text

        Arithmetic operation :
            AddArrays(A: array[32] of Integer; ALen: Integer; B: array[32] of Integer; BLen: Integer; var ResultLen: Integer) Res: array[32] of Integer
            SubtractArrays(A: array[32] of Integer; ALen: Integer; B: array[32] of Integer; BLen: Integer; var ResultLen: Integer) Res: array[32] of Integer
            DivideArray(Dividend: array[32] of Integer; DividendLen: Integer;Divisor: array[32] of Integer; DivisorLen: Integer;var Quotien: array[32] of Integer;var qLen: Integer)
            DivideArrayWithRemainder(Dividend: array[32] of Integer; DividendLen: Integer;Divisor: array[32] of Integer; DivisorLen: Integer;var Remainder: array[32] of Integer; var rLen: Integer;var Quotien: array[32] of Integer;var qLen: Integer)
            ModuloArray(Dividend: array[32] of Integer; DividendLen: Integer;Divisor: array[32] of Integer; DivisorLen: Integer;var Remainder: array[32] of Integer; var rLen: Integer)
            ModuloInverseArray(Dividend: array[32] of Integer; DividendLen: Integer;Divisor: array[32] of Integer; DivisorLen: Integer;var Remainder: array[32] of Integer; var rLen: Integer)
            MultiplyArrays(AArr: array[32] of Integer; ALen: Integer; BArr: array[32] of Integer; BLen: Integer; var ResultArr: array[32] of Integer; var ResultLen: Integer)
            SquareArrays(AArr: array[32] of Integer; ALen: Integer; var ResultArr: array[32] of Integer; var ResultLen: Integer)
            PowerArrays(BaseArr: array[32] of Integer; BaseLen: Integer; ExpArr: array[32] of Integer; ExpLen: Integer; var ResultArr: array[32] of Integer; var ResultLen: Integer)
    */

    SingleInstance = true;


    #region Conversion
    procedure TextToArray(BigBigInteger: Text; var ArrInt: array[32] of Integer; var Len: Integer)
    var
        Pos: Integer;
        i, ChunkSize : Byte;
    begin
        clear(ArrInt);
        clear(Len);
        BigBigInteger := BigBigInteger.TrimStart('-');
        Pos := StrLen(BigBigInteger);
        if Pos = 0 then exit;
        while Pos > 0 do begin
            i += 1;
            if Pos < 9 then
                ChunkSize := Pos
            else
                ChunkSize := 9;
            Evaluate(ArrInt[i], BigBigInteger.Substring(Pos - ChunkSize + 1, ChunkSize));
            Len += 1;
            Pos -= ChunkSize;
        end;
        if ArrInt[i] = 0 then
            Len -= 1;
    end;

    procedure ArrayToText(var ArrInt: array[32] of Integer; ArrLen: Integer): Text
    var
        i: Byte;
        TextBuild: TextBuilder;
    begin
        TextBuild.Append(Format(ArrInt[ArrLen]));
        if ArrLen > 1 then
            for i := ArrLen - 1 downto 1 do
                TextBuild.Append(Format(ArrInt[i]).PadLeft(9, '0'));
        exit(TextBuild.ToText());
    end;
    #endregion

    #region Array Func

    procedure IsZeroArray(Arr: array[32] of Integer; Len: Integer): Boolean
    var
        k: Integer;
    begin
        // Len peut être > 0 ; on vérifie la valeur réelle (tous les limbs nuls)
        for k := Len downto 1 do
            if Arr[k] <> 0 then
                exit(false);
        exit(true);
    end;

    procedure CopyPrefix(var Src: array[32] of Integer; var Dst: array[32] of Integer; count: Integer)
    var
        i: Byte;
    begin
        for i := 1 to count do
            Dst[i] := Src[i];
        // ne touche pas au reste de Dst (laisse 0)
    end;

    procedure Normalize(var Vals: array[32] of Integer; Len: Integer): Integer
    begin
        if Len = 0 then exit(0);
        while (Vals[Len] = 0) do begin
            Len -= 1;
            if Len = 0 then
                exit(Len);
        end;
        exit(Len);
    end;

    procedure NormalizeLen(var Vals: array[32] of Integer; var Len: Integer)
    begin
        if Len = 0 then exit;
        while (Vals[Len] = 0) do begin
            Len -= 1;
            if Len = 0 then
                exit;
        end;
        exit;
    end;

    procedure IsOdd(AArr: array[32] of Integer): Boolean
    begin
        exit((AArr[1] mod 2) = 1);
    end;

    procedure IsEven(AArr: array[32] of Integer): Boolean
    begin
        exit((AArr[1] mod 2) = 0);
    end;

    #endregion


    #region Arith. Add

    procedure AddArrays(A: array[32] of Integer; ALen: Integer; B: array[32] of Integer; BLen: Integer; var Res: array[32] of Integer; var ResultLen: Integer)
    var
        Carry: Integer;
        Temp: Integer;
        i: Byte;
        MaxLen: Integer;
    begin
        Carry := 0;
        if ALen > BLen then MaxLen := ALen else MaxLen := BLen;
        for i := 1 to MaxLen do begin
            Temp := Carry;
            if i <= ALen then Temp += A[i];
            if i <= BLen then Temp += B[i];
            Res[i] := Temp mod 1000000000;
            Carry := Temp div 1000000000;
        end;
        if Carry > 0 then begin
            if MaxLen + 1 > ArrayLen(Res) then
                Error('Overflow in big integer addition');
            Res[MaxLen + 1] := Carry;
            MaxLen += 1;
        end;
        ResultLen := Normalize(Res, MaxLen);
    end;
    #endregion

    #region Arith. Sub
    procedure SubtractArrays(A: array[32] of Integer; ALen: Integer; B: array[32] of Integer; BLen: Integer; var Res: array[32] of Integer; var ResultLen: Integer)
    var
        Borrow: Integer;
        Temp: Integer;
        i: Byte;
    begin
        // Absolute substraction
        // Important : A must be >= than B !!
        for i := 1 to ALen do begin
            if i <= BLen then
                Temp := A[i] - B[i] - Borrow
            else
                Temp := A[i] - Borrow;
            if Temp < 0 then begin
                Temp += 1000000000;
                Borrow := 1;
            end else
                Borrow := 0;
            Res[i] := Temp;
        end;
        if Borrow > 0 then
            Error('Bug: Negative result in magnitude subtraction');
        ResultLen := Normalize(Res, ALen);
    end;
    #endregion

    #region Arith. Div
    procedure DivideArray(
        Dividend: array[32] of Integer; DividendLen: Integer;
        Divisor: array[32] of Integer; DivisorLen: Integer;
        var Quotien: array[32] of Integer;
        var qLen: Integer)
    var
        j: Byte;
        m: Integer;
        QHat: Integer;
    begin
        Clear(Quotien);
        qLen := DividendLen;
        if DivisorLen = 0 then
            Error('Divide by zero (n = 0).');

        // Dividend < Divisor → quotient = 0, remainder = dividend
        if CompareArrays(Dividend, DividendLen, Divisor, DivisorLen) < 0 then
            exit;

        // Diviseur sur 1 limb → chemin rapide O(m)
        if DivisorLen = 1 then begin
            SingleLimbDiv(Dividend, DividendLen, Divisor[1], Quotien, qLen);
            exit;
        end;

        // Use Knuth "D Algorithm" to divide large number through limbs
        // Note : difference is AL is 1 index based, and we use little endian. Knuth algorithm is 0 based and use big endian.
        // https://skanthak.hier-im-netz.de/division.html

        // D.0 Define
        // U = Dividend, V = Divisor
        m := DividendLen - DivisorLen;
        //n := DivisorLen;

        // D.1 Normalize
        KnuthD1Normalize(Dividend, Divisor, m, DivisorLen); // Multiplie U et V par D

        // D.2 to D.6 division
        for j := m downto 0 do begin
            QHat := KnuthD3TrialQuotient(Dividend, Divisor, j, DivisorLen);
            if KnuthD4MultiplyAndSubtract(Dividend, Divisor, j, DivisorLen, QHat) then begin
                QHat := QHat - 1;
                KnuthD6AddBack(Dividend, Divisor, j, DivisorLen);
            end;
            Quotien[j + 1] := QHat;
        end;
        qLen := Normalize(Quotien, m + 1);
    end;
    #endregion

    #region Arith.Div+Rem
    procedure DivideArrayWithRemainder(
        Dividend: array[32] of Integer; DividendLen: Integer;
        Divisor: array[32] of Integer; DivisorLen: Integer;
        var Remainder: array[32] of Integer; var rLen: Integer;
        var Quotien: array[32] of Integer; var qLen: Integer)
    var
        j: Byte;
        m: Integer;
        QHat: Integer;
        D: Integer;
    begin
        Clear(Remainder);
        Clear(Quotien);
        qLen := DividendLen;
        Clear(rLen);

        if DivisorLen = 0 then
            Error('Divide by zero (n = 0).');

        // Dividend < Divisor → quotient = 0, remainder = dividend
        if CompareArrays(Dividend, DividendLen, Divisor, DivisorLen) < 0 then begin
            CopyPrefix(Dividend, Remainder, DividendLen);
            clear(qLen);
            rLen := DividendLen;
            exit;
        end;

        // Diviseur sur 1 limb → chemin rapide O(m)
        if DivisorLen = 1 then begin
            SingleLimbDivWithRemainder(Dividend, DividendLen, Divisor[1], Remainder, rLen, Quotien, qLen);
            exit;
        end;

        // Use Knuth "D Algorithm" to divide large number through limbs
        // Note : difference is AL is 1 index based, and we use little endian. Knuth algorithm is 0 based and use big endian.
        // https://skanthak.hier-im-netz.de/division.html

        // D.0 Define
        // U = Dividend
        // V = Divisor
        m := DividendLen - DivisorLen;
        //n := DivisorLen;

        // D.1 Normalize
        D := KnuthD1Normalize(Dividend, Divisor, m, DivisorLen); // Multiplie U et V par D

        // D.2 to D.6 division
        for j := m downto 0 do begin
            QHat := KnuthD3TrialQuotient(Dividend, Divisor, j, DivisorLen);
            if KnuthD4MultiplyAndSubtract(Dividend, Divisor, j, DivisorLen, QHat) then begin
                QHat := QHat - 1;
                KnuthD6AddBack(Dividend, Divisor, j, DivisorLen);
            end;
            Quotien[j + 1] := QHat;
        end;

        // D.7 : unnormalize
        KnuthD7UnnormalizeRemainder(Dividend, DivisorLen, D);

        // D.8 : output Lengths
        rLen := 0;
        CopyArray(Remainder, Dividend, 1);
        rLen := Normalize(Remainder, DivisorLen + 1);
        qLen := Normalize(Quotien, m + 1);
    end;

    procedure SingleLimbDiv(
        var U: array[32] of Integer; m: Integer; d: Integer;
        var Q: array[32] of Integer; var qLen: Integer)
    var
        i: Byte;
        carry, tmp : Decimal;
        Qid: Decimal;
    begin
        if d <= 0 then
            Error('Invalid divisor (<= 0).');
        Clear(Q);
        for i := m downto 1 do begin
            tmp := carry * 1000000000 + U[i];
            Q[i] := tmp div d;
            Qid := Q[i];
            Qid *= d;
            carry := tmp - Qid;
        end;
        qLen := m;
        NormalizeLen(Q, qLen);
    end;

    procedure SingleLimbDivWithRemainder(
        var U: array[32] of Integer; m: Integer; d: Integer;
        var R: array[32] of Integer; var rLen: Integer;
        var Q: array[32] of Integer; var qLen: Integer)
    var
        i: Byte;
        carry, tmp : Decimal;
        Qid: Decimal;
    begin
        if d <= 0 then
            Error('Invalid divisor (<= 0).');
        Clear(Q);
        Clear(R);
        for i := m downto 1 do begin
            tmp := carry * 1000000000 + U[i];
            Q[i] := tmp div d;
            Qid := Q[i];
            Qid *= d;
            carry := tmp - Qid;
        end;
        if carry <> 0 then begin
            R[1] := carry;
            rLen := 1;
        end else
            rLen := 0;
        qLen := m;
        NormalizeLen(Q, qLen);
    end;
    #endregion

    #region Arith. Mod
    procedure ModuloArray(
    Dividend: array[32] of Integer; DividendLen: Integer;
        Divisor: array[32] of Integer; DivisorLen: Integer;
        var Remainder: array[32] of Integer; var rLen: Integer)
    var
        j: Byte;
        m: Integer;
        QHat: Integer;
        D: Integer;
    begin
        // Same as division, remouved quotient storing
        Clear(Remainder);
        Clear(rLen);

        if DivisorLen = 0 then
            Error('Divide by zero (n = 0).');

        // Dividend < Divisor → quotient = 0, remainder = dividend
        if CompareArrays(Dividend, DividendLen, Divisor, DivisorLen) < 0 then begin
            CopyPrefix(Dividend, Remainder, DividendLen);
            rLen := DividendLen;
            exit;
        end;

        // Diviseur sur 1 limb → chemin rapide O(m)
        if DivisorLen = 1 then begin
            SingleLimbMod(Dividend, DividendLen, Divisor[1], Remainder, rLen);
            exit;
        end;

        // Use Knuth "D Algorithm" to divide large number through limbs
        // Note : difference is AL is 1 index based, and we use little endian. Knuth algorithm is 0 based and use big endian.
        // https://skanthak.hier-im-netz.de/division.html

        // D.0 Define
        // U = Dividend
        // V = Divisor
        m := DividendLen - DivisorLen;
        //n := DivisorLen;

        // D.1 Normalize
        D := KnuthD1Normalize(Dividend, Divisor, m, DivisorLen); // Multiplie U et V par D

        // D.2 to D.6 division
        for j := m downto 0 do begin
            QHat := KnuthD3TrialQuotient(Dividend, Divisor, j, DivisorLen);
            if KnuthD4MultiplyAndSubtract(Dividend, Divisor, j, DivisorLen, QHat) then begin
                QHat := QHat - 1;
                KnuthD6AddBack(Dividend, Divisor, j, DivisorLen);
            end;
        end;

        // D.7 : unnormalize
        KnuthD7UnnormalizeRemainder(Dividend, DivisorLen, D);

        // D.8 : output Lengths
        rLen := 0;
        CopyArray(Remainder, Dividend, 1);
        rLen := Normalize(Remainder, DivisorLen + 1);
    end;
    #endregion

    #region Arith.ModInv
    /*procedure ModuloInverseArray(
        Dividend: array[32] of Integer; DividendLen: Integer;
        Divisor: array[32] of Integer; DivisorLen: Integer;
        var Remainder: array[32] of Integer; var rLen: Integer)
    var
        old_r: array[32] of Integer;
        old_r_len: Integer;
        new_r: array[32] of Integer;
        new_r_len: Integer;
        quot: array[32] of Integer;
        quot_len: Integer;
        prov_r: array[32] of Integer;
        prov_r_len: Integer;
        old_s_sign: Integer;
        old_s: array[32] of Integer;
        old_s_len: Integer;
        new_s_sign: Integer;
        new_s: array[32] of Integer;
        new_s_len: Integer;
        prov_s_sign: Integer;
        prov_s: array[32] of Integer;
        prov_s_len: Integer;
        mul_temp_s: array[32] of Integer;
        mul_temp_s_len: Integer;
        mul_s_sign: Integer;
    begin
        // Compute Dividend % Divisor directly into old_r to reduce the input
        DivideArrayWithRemainder(Dividend, DividendLen, Divisor, DivisorLen, old_r, old_r_len, quot, quot_len);
        if IsZeroArray(old_r, old_r_len) then begin
            Remainder[1] := 0;
            rLen := 1;
            exit;
        end;
        // Initialize
        CopyArray(new_r, Divisor, 1);
        new_r_len := DivisorLen;
        old_s_sign := 1;
        old_s[1] := 1;
        old_s_len := 1;
        while not IsZeroArray(new_r, new_r_len) do begin
            // Compute quotient and provisional remainder
            DivideArrayWithRemainder(old_r, old_r_len, new_r, new_r_len, prov_r, prov_r_len, quot, quot_len);
            // Compute provisional s
            MultiplyByPositive(quot, quot_len, new_s_sign, new_s, new_s_len, mul_s_sign, mul_temp_s, mul_temp_s_len);
            SubtractSigned(old_s_sign, old_s, old_s_len, mul_s_sign, mul_temp_s, mul_temp_s_len, prov_s_sign, prov_s, prov_s_len);
            // Update old to new
            CopyArray(old_r, new_r, 1);
            old_r_len := new_r_len;
            old_s_sign := new_s_sign;
            CopyArray(old_s, new_s, 1);
            old_s_len := new_s_len;
            // Update new to provisional
            CopyArray(new_r, prov_r, 1);
            new_r_len := prov_r_len;
            new_s_sign := prov_s_sign;
            CopyArray(new_s, prov_s, 1);
            new_s_len := prov_s_len;
        end;
        // Check if GCD is 1
        if not ((old_r_len = 1) and (old_r[1] = 1)) then begin
            Remainder[1] := 0;
            rLen := 1;
            exit;
        end;
        // Compute the modular inverse from old_s, handling sign
        if old_s_sign > 0 then begin
            // Positive: old_s % Divisor
            DivideArrayWithRemainder(old_s, old_s_len, Divisor, DivisorLen, Remainder, rLen, quot, quot_len);
        end else if old_s_sign < 0 then begin
            // Negative: Divisor - (magnitude % Divisor) if not zero
            DivideArrayWithRemainder(old_s, old_s_len, Divisor, DivisorLen, new_r, new_r_len, quot, quot_len);
            if IsZeroArray(new_r, new_r_len) then begin
                Remainder[1] := 0;
                rLen := 1;
            end else
                SubtractArrays(Divisor, DivisorLen, new_r, new_r_len, Remainder, rLen);
        end else begin
            // Zero: shouldn't happen
            Remainder[1] := 0;
            rLen := 1;
        end;
    end;*/
    procedure ModuloInverseArray(
        Dividend: array[32] of Integer; DividendLen: Integer;
        Divisor: array[32] of Integer; DivisorLen: Integer;
        var Remainder: array[32] of Integer; var rLen: Integer)
    var
        u: array[32] of Integer;
        u_len: Integer;
        v: array[32] of Integer;
        v_len: Integer;
        s_u: array[32] of Integer;
        s_u_len: Integer;
        s_u_sign: Integer;  // x1: coeff of dividend for u
        t_u: array[32] of Integer;
        t_u_len: Integer;
        t_u_sign: Integer;  // y1: coeff of divisor for u
        s_v: array[32] of Integer;
        s_v_len: Integer;
        s_v_sign: Integer;  // x2: coeff of dividend for v
        t_v: array[32] of Integer;
        t_v_len: Integer;
        t_v_sign: Integer;  // y2: coeff of divisor for v
        orig_a: array[32] of Integer;
        orig_a_len: Integer;
        orig_b: array[32] of Integer;
        orig_b_len: Integer;
        temp: array[32] of Integer;
        temp_len: Integer;
        temp_sign: Integer;
        quot: array[32] of Integer;
        quot_len: Integer;
        shift: Integer;
    begin
        // Initial mod to reduce dividend, into u
        DivideArrayWithRemainder(Dividend, DividendLen, Divisor, DivisorLen, u, u_len, quot, quot_len);
        if IsZeroArray(u, u_len) then begin
            Remainder[1] := 0;
            rLen := 1;
            exit;
        end;
        CopyArray(v, Divisor, 1);
        v_len := DivisorLen;

        // Remove common factors of 2
        shift := 0;
        while IsEvenArray(u, u_len) and IsEvenArray(v, v_len) do begin
            DivideBySmall(u, u_len, 2);
            DivideBySmall(v, v_len, 2);
            shift += 1;
        end;

        // Copy original shifted a and b
        CopyArray(orig_a, u, 1);
        orig_a_len := u_len;
        CopyArray(orig_b, v, 1);
        orig_b_len := v_len;

        // Initialize coefficients
        s_u_sign := 1;
        s_u[1] := 1;
        s_u_len := 1;  // x1 = 1
        t_u_sign := 0;
        t_u_len := 0;  // y1 = 0
        s_v_sign := 0;
        s_v_len := 0;  // x2 = 0
        t_v_sign := 1;
        t_v[1] := 1;
        t_v_len := 1;  // y2 = 1

        // Main loop
        while CompareArrays(u, u_len, v, v_len) <> 0 do begin
            if IsEvenArray(u, u_len) then begin
                DivideBySmall(u, u_len, 2);
                if IsEvenSigned(s_u_sign, s_u, s_u_len) and IsEvenSigned(t_u_sign, t_u, t_u_len) then begin
                    HalveSigned(s_u_sign, s_u, s_u_len);
                    HalveSigned(t_u_sign, t_u, t_u_len);
                end else begin
                    AddSigned(s_u_sign, s_u, s_u_len, 1, orig_b, orig_b_len, temp_sign, temp, temp_len);
                    FloorHalveSigned(temp_sign, temp, temp_len, s_u_sign, s_u, s_u_len);
                    SubtractSigned(t_u_sign, t_u, t_u_len, 1, orig_a, orig_a_len, temp_sign, temp, temp_len);
                    FloorHalveSigned(temp_sign, temp, temp_len, t_u_sign, t_u, t_u_len);
                end;
            end else if IsEvenArray(v, v_len) then begin
                DivideBySmall(v, v_len, 2);
                if IsEvenSigned(s_v_sign, s_v, s_v_len) and IsEvenSigned(t_v_sign, t_v, t_v_len) then begin
                    HalveSigned(s_v_sign, s_v, s_v_len);
                    HalveSigned(t_v_sign, t_v, t_v_len);
                end else begin
                    AddSigned(s_v_sign, s_v, s_v_len, 1, orig_b, orig_b_len, temp_sign, temp, temp_len);
                    FloorHalveSigned(temp_sign, temp, temp_len, s_v_sign, s_v, s_v_len);
                    SubtractSigned(t_v_sign, t_v, t_v_len, 1, orig_a, orig_a_len, temp_sign, temp, temp_len);
                    FloorHalveSigned(temp_sign, temp, temp_len, t_v_sign, t_v, t_v_len);
                end;
            end else if CompareArrays(u, u_len, v, v_len) > 0 then begin
                SubtractArrays(u, u_len, v, v_len, u, u_len);
                SubtractSigned(s_u_sign, s_u, s_u_len, s_v_sign, s_v, s_v_len, s_u_sign, s_u, s_u_len);
                SubtractSigned(t_u_sign, t_u, t_u_len, t_v_sign, t_v, t_v_len, t_u_sign, t_u, t_u_len);
            end else begin
                SubtractArrays(v, v_len, u, u_len, v, v_len);
                SubtractSigned(s_v_sign, s_v, s_v_len, s_u_sign, s_u, s_u_len, s_v_sign, s_v, s_v_len);
                SubtractSigned(t_v_sign, t_v, t_v_len, t_u_sign, t_u, t_u_len, t_v_sign, t_v, t_v_len);
            end;
        end;

        // Check if GCD is 1
        if (shift > 0) or not ((u_len = 1) and (u[1] = 1)) then begin
            Remainder[1] := 0;
            rLen := 1;
            exit;
        end;

        // Compute the modular inverse from s_u (coeff of dividend), handling sign
        if s_u_sign > 0 then begin
            DivideArrayWithRemainder(s_u, s_u_len, Divisor, DivisorLen, Remainder, rLen, quot, quot_len);
        end else if s_u_sign < 0 then begin
            DivideArrayWithRemainder(s_u, s_u_len, Divisor, DivisorLen, temp, temp_len, quot, quot_len);
            if IsZeroArray(temp, temp_len) then begin
                Remainder[1] := 0;
                rLen := 1;
            end else
                SubtractArrays(Divisor, DivisorLen, temp, temp_len, Remainder, rLen);
        end else begin
            Remainder[1] := 0;
            rLen := 1;
        end;
    end;
    #endregion

    #region Arith. Mul
    procedure MultiplyArrays(AArr: array[32] of Integer; ALen: Integer; BArr: array[32] of Integer; BLen: Integer; var ResultArr: array[32] of Integer; var ResultLen: Integer)
    var
        i: Byte;
        j: Byte;
        Carry: Integer;
        Temp: BigInteger;
    begin
        clear(ResultArr);
        for i := 1 to ALen do begin
            Carry := 0;
            for j := 1 to BLen do begin
                Temp := AArr[i];
                Temp *= BArr[j];
                Temp += ResultArr[i + j - 1] + Carry;
                ResultArr[i + j - 1] := Temp mod 1000000000;
                Carry := Temp div 1000000000;
            end;
            j := BLen + 1;
            while Carry > 0 do begin
                if i + j - 1 > ArrayLen(ResultArr) then
                    Error('Overflow in bigbiginteger multiplication result');
                Temp := Carry + ResultArr[i + j - 1];
                ResultArr[i + j - 1] := Temp mod 1000000000;
                Carry := Temp div 1000000000;
                j += 1;
            end;
        end;
        ResultLen := ALen + BLen;
        NormalizeLen(ResultArr, ResultLen);
    end;
    #endregion

    #region Arith. Sqr
    procedure SquareArrays(AArr: array[32] of Integer; ALen: Integer; var ResultArr: array[32] of Integer; var ResultLen: Integer)
    var
        i: Byte;
        j: Byte;
        Carry: BigInteger;
        Temp: BigInteger;
    begin
        Clear(ResultArr);
        for i := 1 to ALen do begin
            // Double the products for off-diagonal terms
            Carry := 0;
            for j := 1 to i - 1 do begin
                // Split operation to avoid Integer overflow
                Temp := 2L * AArr[i];
                Temp *= AArr[j];
                Temp += ResultArr[i + j - 1] + Carry;
                ResultArr[i + j - 1] := Temp mod 1000000000;
                Carry := Temp div 1000000000;
            end;
            // Square the diagonal term
            Temp := AArr[i];
            Temp *= AArr[i];
            Temp += Carry;
            ResultArr[2 * i - 1] := Temp mod 1000000000;
            Carry := Temp div 1000000000;

            // Propagate the carry starting from the next position
            j := 2 * i;
            while Carry > 0 do begin
                if j > ArrayLen(ResultArr) then
                    Error('Overflow in squaring');
                Temp := ResultArr[j];
                Temp += Carry;
                ResultArr[j] := Temp mod 1000000000;
                Carry := Temp div 1000000000;
                j += 1;
            end;
        end;
        ResultLen := Normalize(ResultArr, 2 * ALen);
    end;
    #endregion

    #region Arith. Pwr
    procedure PowerArrays(BaseArr: array[32] of Integer; BaseLen: Integer; ExpArr: array[32] of Integer; ExpLen: Integer; var ResultArr: array[32] of Integer; var ResultLen: Integer)
    var
        TempBase: array[32] of Integer;
        TempBaseLen: Integer;
        TempExp: array[32] of Integer;
        TempExpLen: Integer;
        TempMultiply: array[32] of Integer;
        TempMultiplyLen: Integer;
        TempSquare: array[32] of Integer;
        TempSquareLen: Integer;
        Bit: Integer;
    begin
        // Init result = 1
        Clear(ResultArr);
        ResultArr[1] := 1;
        ResultLen := 1;

        // Copy base and exponent into temporaires (pour ne pas modifier les entrées)
        CopyArray(TempBase, BaseArr, 1);
        TempBaseLen := BaseLen;
        CopyArray(TempExp, ExpArr, 1);
        TempExpLen := ExpLen;

        // Boucle : tant que exponent > 0 (en valeur)
        while not IsZeroArray(TempExp, TempExpLen) do begin
            // LSB : bit = TempExp mod 2
            Bit := TempExp[1] mod 2;

            // Si bit = 1 -> result = result * base
            if Bit = 1 then begin
                MultiplyArrays(ResultArr, ResultLen, TempBase, TempBaseLen, TempMultiply, TempMultiplyLen);
                // MultiplyArrays doit lever Error(...) si overflow
                CopyArray(ResultArr, TempMultiply, 1);
                ResultLen := TempMultiplyLen;
            end;

            // Shift right (divide exponent by 2)
            DivideBySmall(TempExp, TempExpLen, 2);          // suppose existante, qui met à jour les limbs
            NormalizeLen(TempExp, TempExpLen);

            // Si exponent > 0 en valeur alors on met la base au carré
            if not IsZeroArray(TempExp, TempExpLen) then begin
                SquareArrays(TempBase, TempBaseLen, TempSquare, TempSquareLen);
                // SquareArrays doit lever Error(...) si overflow
                CopyArray(TempBase, TempSquare, 1);
                TempBaseLen := TempSquareLen;
            end;
        end;
    end;
    #endregion

    #region Knuth Div Algo.
    local procedure KnuthD1Normalize(var U: array[33] of Integer; var V: array[32] of Integer; var m: Integer; n: Integer): Integer
    var
        D: Integer;
        i: Byte;
        Carry: Integer;
        Prod: BigInteger;
    begin
        // Knuth D Algorithm - Step D.1
        D := 1000000000 div (V[n] + 1);
        if D = 1 then
            exit(D); // no normalisation needed

        // Multiplier tous les chiffres de V par D
        for i := 1 to n do begin
            Prod := V[i];
            Prod *= D;
            Prod += Carry;
            V[i] := Prod mod 1000000000;
            Carry := Prod div 1000000000;
        end;

        // Multiplier tous les chiffres de U par D
        Carry := 0;
        for i := 1 to m + n do begin
            Prod := U[i];
            Prod *= D;
            Prod += Carry;
            U[i] := Prod mod 1000000000;
            Carry := Prod div 1000000000;
        end;

        if Carry > 0 then begin
            m += 1;
            if m + n <= 32 then
                U[m + n] := Carry
            else
                Error('Overflow in U array during normalization in Knuth division step D.1');
        end;

        exit(D);
    end;

    local procedure KnuthD3TrialQuotient(U: array[33] of Integer; V: array[32] of Integer; j: Byte; n: Integer): Integer
    var
        Uj: BigInteger;
        V1: Integer;
        V2: Integer;
        QHat, Limit : BigInteger;
        RHat: Integer;
    begin
        //Set Q̂ to (U[n+j] × B + U[n−1+j]) ÷ V[n−1];
        //Set R̂ to (U[n+j] × B + U[n−1+j]) % V[n−1];
        Uj := U[n + j + 1];
        Uj *= 1000000000;
        Uj += U[n + j];
        V1 := V[n];
        V2 := V[n - 1];
        QHat := Uj div V1;
        RHat := Uj mod V1;

        if (n > 1) then begin
            // Test if Q̂ equals B or Q̂ × V[n−2] is greater than R̂ × B + U[n−2+j];
            if V2 = 0 then
                Limit := 1000000000
            else begin
                Limit := RHat;
                Limit *= 1000000000;
                Limit += U[j + n - 1];
                Limit := Limit div V2;
            end;
            while (QHat >= 1000000000) or (QHat > Limit) do begin
                QHat := QHat - 1;
                RHat := RHat + V1;
                if RHat >= 1000000000 then
                    break;
                if V2 = 0 then
                    Limit := 1000000000
                else begin
                    Limit := RHat;
                    Limit *= 1000000000;
                    Limit += U[j + n - 1];
                    Limit := Limit div V2;
                end;
            end;
        end;

        exit(QHat);
    end;

    local procedure KnuthD4MultiplyAndSubtract(var U: array[33] of Integer; V: array[32] of Integer; j: Byte; n: Integer; QHat: Integer): Boolean
    var
        i: Byte;
        Carry: Integer;
        Prod: BigInteger;
        Low: Integer;
        High: Integer;
        Diff: Integer;
    begin
        /*
        Replace (U[n+j]U[n−1+j]…U[j]) by (U[n+j]U[n−1+j]…U[j]) − Q̂ × (V[n−1]…V[1]V[0]).
        (The digits (U[n+j]…U[j]) should be kept positive; if the result of this step is actually negative, (U[n+j]…U[j]) should be left as the true value plus Bn+1, namely as the B’s complement of the true value, and a borrow to the left should be remembered.)
        */
        Carry := 0;
        for i := 1 to n do begin
            Prod := QHat;
            Prod *= V[i];
            Prod += Carry;
            Low := Prod mod 1000000000;
            High := Prod div 1000000000;
            Diff := U[j + i] - Low;
            if Diff < 0 then begin
                Diff += 1000000000;
                High += 1;
            end;
            U[j + i] := Diff;
            Carry := High;
        end;

        // Dernier mot : U[j + n] -= carry
        Diff := U[j + n + 1] - Carry;
        U[j + n + 1] := Diff;

        // Si on a un emprunt final → correction nécessaire (D.4)
        exit(Diff < 0); // True if q̂ was too large
    end;

    local procedure KnuthD6AddBack(var U: array[33] of Integer; V: array[32] of Integer; j: Byte; n: Integer)
    var
        i: Byte;
        Carry: Integer;
        Sum: BigInteger;
    begin
        Carry := 0;

        for i := 1 to n do begin
            Sum := U[j + i];
            Sum += V[i];
            Sum += Carry;
            U[j + i] := Sum mod 1000000000;
            Carry := Sum div 1000000000;
        end;

        // Ajouter la dernière retenue si nécessaire
        U[j + n + 1] := U[j + n + 1] + Carry;
    end;

    local procedure KnuthD7UnnormalizeRemainder(var U: array[33] of Integer; n: Integer; D: Integer)
    var
        Remainder: BigInteger;
        i: Byte;
        Curr: BigInteger;
    begin
        Remainder := 0;

        for i := n downto 1 do begin
            Curr := Remainder;
            Curr *= 1000000000;
            Curr += U[i];
            U[i] := Curr div D;
            Remainder := Curr mod D;
        end;
    end;
    #endregion

    local procedure AddSigned(
        s1: Integer; a1: array[32] of Integer; l1: Integer;
        s2: Integer; a2: array[32] of Integer; l2: Integer;
        var sr: Integer; var ar: array[32] of Integer; var lr: Integer)
    begin
        if s1 = 0 then begin
            sr := s2;
            CopyArray(ar, a2, 1);
            lr := l2;
            exit;
        end;
        if s2 = 0 then begin
            sr := s1;
            CopyArray(ar, a1, 1);
            lr := l1;
            exit;
        end;
        if s1 = s2 then begin
            AddArrays(a1, l1, a2, l2, ar, lr);
            sr := s1;
        end else
            case CompareArrays(a1, l1, a2, l2) of
                1:
                    begin
                        SubtractArrays(a1, l1, a2, l2, ar, lr);
                        sr := s1;
                    end;
                -1:
                    begin
                        SubtractArrays(a2, l2, a1, l1, ar, lr);
                        sr := s2;
                    end;
                0:
                    begin
                        sr := 0;
                        lr := 0;
                    end;
            end;
    end;

    local procedure SubtractSigned(
        s1: Integer; a1: array[32] of Integer; l1: Integer;
        s2: Integer; a2: array[32] of Integer; l2: Integer;
        var sr: Integer; var ar: array[32] of Integer; var lr: Integer)
    begin
        AddSigned(s1, a1, l1, -s2, a2, l2, sr, ar, lr);
    end;

    local procedure MultiplyByPositive(
        q: array[32] of Integer; q_len: Integer;
        ss: Integer; s_arr: array[32] of Integer; s_len: Integer;
        var res_sign: Integer; var res_arr: array[32] of Integer; var res_len: Integer)
    begin
        if (ss = 0) or IsZeroArray(q, q_len) then begin
            res_sign := 0;
            res_len := 0;
            exit;
        end;
        res_sign := ss;
        MultiplyArrays(q, q_len, s_arr, s_len, res_arr, res_len);
    end;

    procedure SingleLimbMod(
        var U: array[32] of Integer; m: Integer; d: Integer;
        var R: array[32] of Integer; var rLen: Integer)
    var
        i: Byte;
        carry, tmp : Decimal;
    begin
        if d <= 0 then
            Error('Invalid divisor (<= 0).');

        Clear(R);

        carry := 0; // remainder
        for i := m downto 1 do begin
            tmp := carry * 1000000000 + U[i];
            // Only keep the remaining
            carry := tmp - (tmp div d) * d;
        end;

        if carry <> 0 then begin
            R[1] := carry;
            rLen := 1;
        end else
            rLen := 0;
    end;

    local procedure DivideBySmall(var Arr: array[32] of Integer; var Len: Integer; Small: Integer)
    var
        Remainder: Integer;
        Temp: BigInteger;
        i: Byte;
    begin
        Remainder := 0;
        for i := Len downto 1 do begin
            Temp := Remainder;
            Temp *= 1000000000;
            Temp += Arr[i];
            Arr[i] := Temp div Small;
            Remainder := Temp mod Small;
        end;
        NormalizeLen(Arr, Len);
    end;

    procedure MultiplyBySmall(var Arr: array[32] of Integer; var Len: Integer; Small: Integer)
    var
        Carry: BigInteger;
        From: BigInteger;
        Temp: BigInteger;
        j: Byte;
    begin
        Carry := 0;
        for j := 1 to Len do begin
            From := Arr[j];
            Temp := From * Small + Carry;
            Arr[j] := Temp mod 1000000000;
            Carry := Temp div 1000000000;
        end;
        while Carry > 0 do begin
            if Len >= ArrayLen(Arr) then
                Error('Overflow in big integer operation');
            Len += 1;
            Arr[Len] := Carry mod 1000000000;
            Carry := Carry div 1000000000;
        end;
    end;

    procedure NegateArray(var A: array[32] of Integer; ALen: Integer)
    var
        i: Byte;
    begin
        for i := 1 to ALen do
            A[i] := -A[i];
    end;

    procedure CompareArrays(A: array[32] of Integer; ALen: Integer; B: array[32] of Integer; BLen: Integer): Integer
    var
        i: Byte;
    begin
        if ALen > BLen then
            exit(1);
        if ALen < BLen then
            exit(-1);
        for i := ALen downto 1 do begin
            if A[i] > B[i] then
                exit(1);
            if A[i] < B[i] then
                exit(-1);
        end;
        exit(0);
    end;
}