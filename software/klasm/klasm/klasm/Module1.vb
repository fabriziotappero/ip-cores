Imports System.IO

Module Module1

    Dim strs() As String
    Dim pass As Integer
    Dim lname As String
    Dim address As Int32
    Public ofs As System.IO.TextWriter
    Public lfs As System.IO.TextWriter
    Public labels As New Collection
    Public symbols As New Collection
    Dim iline As String
    Dim lnc As Integer

    Sub Main()
        Dim tr As TextReader
        Dim fn As String
        Dim args() As String
        Dim text As String
        Dim lines() As String
        Dim line As String
        Dim n As Integer
        Dim s As String
        Dim delimiters As String = " ," & vbTab
        Dim p() As Char = delimiters.ToCharArray()

        args = System.Environment.GetCommandLineArgs()
        lname = args(1)
        lname = lname.Replace(".s", ".lst")
        lname = lname.Replace(".asm", ".lst")
        tr = System.IO.File.OpenText(args(1))
        text = tr.ReadToEnd()
        tr.Close()
        text = text.Replace(vbCr, "")
        lines = text.Split(vbLf.ToCharArray)
        For pass = 1 To 2
            If pass = 2 Then
                ofs = System.IO.File.CreateText(args(2))
                lfs = System.IO.File.CreateText(lname)
            End If
            address = 0
            lnc = 0
            For Each iline In lines
                lnc = lnc + 1
                line = iline
                n = line.IndexOf(";")
                If n >= 0 Then
                    line = line.Substring(0, n - 1)
                End If
                line = line.Trim()
                line = CompressSpaces(line)
                line = line.Replace(", ", ",")
                If line.Length = 0 Then
                    emitEmptyLine(iline)    ' there could be comments on the line
                Else
                    strs = line.Split(p)
                    s = strs(0)
                    s = s.Trim()
                    If s.EndsWith(":") Then
                        ProcessLabel(s)
                    Else
                        ProcessOp(s)
                    End If
                End If
            Next
        Next
        ofs.Close()
        lfs.Close()
    End Sub

    Function CompressSpaces(ByVal s As String) As String
        Dim l As Integer
        Do
            l = s.Length
            s = s.Replace(vbTab, " ")
            s = s.Replace("  ", " ")
        Loop While s.Length <> l
        Return s
    End Function

    Sub ProcessTrap(ByVal n As Integer, ByVal m As Integer)
        Dim oc As Integer
        Dim Cra As Integer

        Cra = GetCrRegister(strs(1))
        oc = n << 26
        oc = oc Or (Cra << 21)
        oc = oc Or (m << 16)
        emit(oc)
    End Sub

    Sub ProcessSet(ByVal n As Integer, ByVal m As Integer)
        Dim oc As Integer
        Dim Cra As Integer
        Dim Rt As Integer

        Cra = GetCrRegister(strs(1))
        Rt = GetRegister(strs(2))
        oc = n << 26
        oc = oc Or (Cra << 21)
        oc = oc Or (m << 16)
        oc = oc Or (Rt << 11)
        emit(oc)
    End Sub

    Sub ProcessBranch(ByVal oc As Integer, ByVal func As Integer)
        Dim opcode As Integer
        Dim ra As Int64
        Dim rb As Int64
        Dim imm As Int64
        Dim disp As Int64
        Dim L As Label
        Dim P As LabelPatch

        ra = GetCrRegister(strs(1))
        strs(2) = strs(2).Trim
        Try
            L = labels.Item(strs(2))
        Catch
            L = Nothing
        End Try
        If L Is Nothing Then
            L = New Label
            L.name = strs(2)
            L.address = -1
            L.slot = -1
            L.defined = False
            labels.Add(L, L.name)
        End If
        If Not L.defined Then
            P = New LabelPatch
            P.type = "B"
            P.address = address
            L.PatchAddresses.Add(P)
        End If
        'If slot = 2 Then
        '    imm = ((L.address - address - 16) + (L.slot << 2)) >> 2
        'Else
        disp = L.address - (address + 4)
        'End If
        'imm = (L.address + (L.slot << 2)) >> 2
        opcode = oc << 26
        opcode = opcode Or (ra << 21)
        opcode = opcode Or (func << 16)
        opcode = opcode Or (disp And &HFFFF)
        emit(opcode)
    End Sub

    Sub ProcessRRop(ByVal n As Integer, ByVal m As Integer, ByVal rc As Boolean)
        Dim oc As Integer
        Dim Rt As Integer
        Dim Ra As Integer
        Dim Rb As Integer

        Rt = GetRegister(strs(1))
        Ra = GetRegister(strs(2))
        Rb = GetRegister(strs(3))
        oc = n << 26
        oc = oc Or (Ra << 21)
        oc = oc Or (Rb << 16)
        oc = oc Or (Rt << 11)
        oc = oc Or m
        If rc Then oc = oc Or 64
        emit(oc)
    End Sub

    Sub ProcessCRRop(ByVal n As Integer, ByVal m As Integer)
        Dim oc As Integer
        Dim Rt As Integer
        Dim Ra As Integer
        Dim Rb As Integer

        Rt = GetCrRegister(strs(1))
        Ra = GetCrRegister(strs(2))
        Rb = GetCrRegister(strs(3))
        oc = n << 26
        oc = oc Or Ra << 21
        oc = oc Or Rb << 16
        oc = oc Or Rt << 11
        oc = oc Or (m << 1)
        emit(oc)
    End Sub

    Sub ProcessCmpOp(ByVal n As Integer, ByVal m As Integer)
        Dim oc As Integer
        Dim CRt As Integer
        Dim Ra As Integer
        Dim Rb As Integer

        CRt = GetCrRegister(strs(1))
        Ra = GetRegister(strs(2))
        Rb = GetRegister(strs(3))
        oc = n << 26
        oc = oc Or (Ra << 21)
        oc = oc Or (Rb << 16)
        oc = oc Or (CRt << 13)
        oc = oc Or m
        emit(oc)
    End Sub

    Sub ProcessCmpiOp(ByVal n As Integer)
        Dim oc As Integer
        Dim CRt As Integer
        Dim Ra As Integer
        Dim imm As Integer

        CRt = GetCrRegister(strs(1))
        Ra = GetRegister(strs(2))
        imm = GetImmediate(strs(3))
        oc = n << 26
        oc = oc Or (Ra << 21)
        oc = oc Or (CRt << 18)
        If imm < -32767 Or imm > 32767 Then
            oc = oc Or &H8000
            emit(oc)
            emit1(imm, True)
        Else
            oc = oc Or (imm And &HFFFF)
            emit(oc)
        End If
    End Sub

    Sub ProcessLdi(ByVal n As Integer)
        Dim oc As Integer
        Dim Rt As Integer
        Dim Ra As Integer
        Dim imm As Integer

        Rt = GetRegister(strs(1))
        Ra = 0
        imm = GetImmediate(strs(2))
        oc = n << 26
        oc = oc Or Ra << 21
        oc = oc Or Rt << 16
        If imm < -32767 Or imm > 32767 Then
            oc = oc Or &H8000
            emit(oc)
            emit1(imm, True)
        Else
            oc = oc Or (imm And &HFFFF)
            emit(oc)
        End If
    End Sub

    Sub ProcessExec()
        Dim oc As Integer
        Dim Ra As Integer

        Ra = GetRegister(strs(1))
        oc = 1 << 26
        oc = oc Or (Ra << 21)
        oc = oc Or 63
        emit(oc)
    End Sub

    Sub ProcessOri(ByVal n As Integer)
        Dim oc As Integer
        Dim Rt As Integer
        Dim Ra As Integer
        Dim imm As Integer

        If strs(1).ToLower = "cr" Then
            imm = GetImmediate(strs(2))
            oc = 19 << 26
            Select Case (strs(0))
                Case "andi"
                    oc = oc Or (8 << 16)
                Case "ori"
                    oc = oc Or (9 << 16)
                Case "eori"
                    oc = oc Or (10 << 16)
            End Select
            If imm < -32767 Or imm > 32767 Then
                oc = oc Or &H8000
                emit(oc)
                emit1(imm, True)
            Else
                oc = oc Or (imm And &HFFFF)
                emit(oc)
            End If
            Return
        End If
        Rt = GetRegister(strs(1))
        Ra = GetRegister(strs(2))
        imm = GetImmediate(strs(3))
        oc = n << 26
        oc = oc Or Ra << 21
        oc = oc Or Rt << 16
        If imm < -32767 Or imm > 32767 Then
            oc = oc Or &H8000
            emit(oc)
            emit1(imm, True)
        Else
            oc = oc Or (imm And &HFFFF)
            emit(oc)
        End If
    End Sub

    Sub ParseAm(ByRef offset As Integer, ByRef reg1 As Integer, ByRef reg2 As Integer)
        Dim s() As String
        Dim t() As String

        offset = 0
        reg1 = 0
        reg2 = 0
        s = strs(2).Split("(".ToCharArray)
        If s(0).Length > 0 Then
            offset = GetImmediate(s(0))
        Else
            offset = 0
        End If
        If s.Length > 1 Then
            s(1) = s(1).TrimEnd(")".ToCharArray)
            t = s(1).Split("+".ToCharArray)
            reg1 = GetRegister(t(0))
            If t.Length = 2 Then
                reg2 = GetRegister(t(1))
            Else
                reg2 = 0
            End If
        End If
    End Sub

    Sub ProcessLabel(ByVal s As String)
        Dim L As Label
        Dim M As Label

        s = s.TrimEnd(":")
        L = New Label
        L.name = s
        L.address = address
        L.defined = True
        If labels.Count > 0 Then
            Try
                M = labels.Item(s)
            Catch
                M = Nothing
            End Try
        Else
            M = Nothing
        End If
        If M Is Nothing Then
            labels.Add(L, L.name)
        Else
            M.defined = True
            M.address = L.address
            M.slot = L.slot
        End If
        emitLabel(L.name)
    End Sub


    Sub ProcessEquate()
        Dim sym As Symbol
        Dim sym2 As Symbol

        If strs(1).ToUpper = "EQU" Then
            sym = New Symbol
            sym.name = strs(0)
            sym.value = GetImmediate(strs(2))
            If symbols Is Nothing Then
                symbols = New Collection
            Else
                Try
                    sym2 = symbols.Item(sym.name)
                Catch
                    sym2 = Nothing
                End Try
            End If
            If sym2 Is Nothing Then
                symbols.Add(sym, sym.name)
            End If
            emitEmptyLine(iline)
        End If
    End Sub

    Sub ProcessMov()
        Dim oc As Integer
        Dim Ra As Integer
        Dim Rt As Integer
        Dim Crt As Integer
        Dim Cra As Integer

        oc = 1 << 26
        Rt = GetRegister(strs(1))
        Ra = GetRegister(strs(2))
        Crt = GetCrRegister(strs(1))
        Cra = GetCrRegister(strs(2))
        If Crt <> -1 And Cra <> -1 Then
            oc = oc Or (Crt << 16)
            oc = oc Or (Cra << 21)
            oc = oc Or 48
            emit(oc)
            Return
        End If
        If Crt <> -1 And Ra <> -1 Then
            oc = oc Or (Crt << 16)
            oc = oc Or (Ra << 21)
            oc = oc Or 50
            emit(oc)
            Return
        End If
        If Rt <> -1 And Cra <> -1 Then
            oc = oc Or (Cra << 21)
            oc = oc Or (Rt << 16)
            oc = oc Or 49
            emit(oc)
            Return
        End If
        If Rt <> -1 Then
            Select Case (strs(2).ToLower)
                Case "usp"
                    oc = oc Or (Rt << 16)
                    oc = oc Or 33
                    emit(oc)
                    Return
                Case "im"
                    oc = oc Or (Rt << 16)
                    oc = oc Or 54
                    emit(oc)
                    Return
            End Select
        Else
            Select Case (strs(1))
                ' MOV USP,Rn
            Case "usp"
                    oc = 1 << 26
                    oc = oc Or (Ra << 21)
                    oc = oc Or 32
                    emit(oc)
                    Return
                    ' MOV IM,Rn
                Case "im"
                    oc = 1 << 26
                    oc = oc Or (Ra << 21)
                    oc = oc Or 53
                    emit(oc)
                    Return
            End Select
        End If
    End Sub

    Sub ProcessOrg()
        Dim imm As Int32
        imm = GetImmediate(strs(1))
        address = imm
        emitLabel("")
    End Sub

    ' PUSH R1/R2/R3/R4/R5
    '
    Sub ProcessPush(ByVal n As Integer)
        Dim oc As Integer
        Dim rs() As String
        Dim regs(5) As Integer
        Dim c As Integer

        rs = strs(1).Split("/".ToCharArray)
        For c = 1 To 5
            If rs.Length < c Then
                regs(c - 1) = 0
            Else
                regs(c - 1) = GetRegister(rs(c - 1))
            End If
        Next
        oc = n << 26
        oc = oc Or regs(0) << 21
        oc = oc Or regs(1) << 16
        oc = oc Or regs(2) << 11
        oc = oc Or regs(3) << 6
        oc = oc Or regs(4) << 1
        emit(oc)
    End Sub

    ' JSR SomeSubroutine
    ' JSR (R1+R2)
    '
    Sub ProcessJsr(ByVal n As Integer)
        Dim oc As Integer
        Dim adr As Integer
        Dim Ra As Integer
        Dim Rb As Integer
        Dim s() As String
        Dim t() As String
        Dim m As Integer

        Ra = 0
        Rb = 0
        m = strs(1).IndexOf("(")
        If m >= 0 Then
            s = strs(1).Split("(".ToCharArray)
            t = s(1).Split("+".ToCharArray)
            Ra = GetRegister(t(0))
            If t.Length > 1 Then
                Rb = GetRegister(t(1))
            End If
            oc = 2 << 26
            oc = oc Or (Ra << 21)
            oc = oc Or (Rb << 16)
            oc = oc Or n
            emit(oc)
        Else
            adr = GetImmediate(strs(1))
            oc = n << 26
            oc = oc Or (adr And &H3FFFFFF)
            emit(oc)
        End If
    End Sub

    Sub ProcessMemop(ByVal n As Integer, ByVal m As Integer)
        Dim oc As Integer
        Dim Ra As Integer
        Dim Rb As Integer
        Dim Rt As Integer
        Dim offs As Integer

        Rt = GetRegister(strs(1))
        ParseAm(offs, Ra, Rb)
        If Ra <> 0 And Rb <> 0 Then
            oc = n << 26
            oc = oc Or (Ra << 21)
            oc = oc Or (Rb << 16)
            oc = oc Or m
            emit(oc)
        Else
            oc = n << 26
            oc = oc Or (Ra << 21)
            oc = oc Or (Rt << 16)
            If offs < -32767 Or offs > 32767 Then
                oc = oc Or &H8000
                emit(oc)
                emit1(offs, True)
            Else
                oc = oc Or (offs And &HFFFF)
                emit(oc)
            End If
        End If
    End Sub

    Sub ProcessLink(ByVal n As Integer)
        Dim oc As Integer
        Dim Ra As Integer
        Dim imm As Integer

        Ra = GetRegister(strs(1))
        imm = GetImmediate(strs(2))
        oc = n << 26
        oc = oc Or (Ra << 21)
        oc = oc Or (Ra << 16)
        oc = oc Or (imm And &HFFFF)
        emit(oc)
    End Sub

    Sub ProcessUnlk(ByVal n As Integer, ByVal m As Integer)
        Dim oc As Integer
        Dim Ra As Integer

        Ra = GetRegister(strs(1))
        oc = n << 26
        oc = oc Or m
        oc = oc Or (Ra << 21)
        oc = oc Or (Ra << 16)
        emit(oc)
    End Sub

    Sub ProcessRts(ByVal n As Integer, ByVal m As Integer)
        Dim oc As Integer
        Dim offs As Integer
        Dim imm As Integer
        Dim k As Integer

        k = 1
        offs = 0
        imm = 0
        If strs.Length = 2 Then
            offs = GetImmediate(strs(1))
            k = k + 1
        End If
        If strs.Length > 1 Then
            imm = GetImmediate(strs(k))
        End If
        oc = n << 26
        oc = oc Or m
        oc = oc Or (offs << 22)
        oc = oc Or ((imm And &HFFFF) << 6)
        emit(oc)
    End Sub

    Sub ProcessStop(ByVal n As Integer, ByVal m As Integer)
        Dim oc As Integer

        oc = n << 26
        oc = n Or m
        emit(oc)
    End Sub

    Sub ProcessOp(ByVal s As String)
        Select Case (s.ToLower)
            Case "org"
                ProcessOrg()
            Case "add"
                ProcessRRop(2, 4, False)
            Case "add."
                ProcessRRop(2, 4, True)
            Case "sub"
                ProcessRRop(2, 5, False)
            Case "sub."
                ProcessRRop(2, 5, True)
            Case "cmp"
                ProcessCmpOp(2, 6)
            Case "and"
                ProcessRRop(2, 8, False)
            Case "and."
                ProcessRRop(2, 8, True)
            Case "or"
                ProcessRRop(2, 9, False)
            Case "or."
                ProcessRRop(2, 9, True)
            Case "eor"
                ProcessRRop(2, 10, False)
            Case "eor."
                ProcessRRop(2, 10, True)
            Case "nand"
                ProcessRRop(2, 12, False)
            Case "nand."
                ProcessRRop(2, 12, True)
            Case "nor"
                ProcessRRop(2, 13, False)
            Case "nor."
                ProcessRRop(2, 13, True)
            Case "enor"
                ProcessRRop(2, 14, False)
            Case "enor."
                ProcessRRop(2, 14, True)
            Case "cror"
                ProcessCRRop(19, 449)
            Case "crorc"
                ProcessCRRop(19, 417)
            Case "crand"
                ProcessCRRop(19, 257)
            Case "crandc"
                ProcessCRRop(19, 129)
            Case "crxor"
                ProcessCRRop(19, 193)
            Case "crnor"
                ProcessCRRop(19, 33)
            Case "crnand"
                ProcessCRRop(19, 225)
            Case "crxnor"
                ProcessCRRop(19, 289)
            Case "shl"
                ProcessRRop(2, 16, False)
            Case "shl."
                ProcessRRop(2, 16, True)
            Case "shr"
                ProcessRRop(2, 17, False)
            Case "shr."
                ProcessRRop(2, 17, True)
            Case "rol"
                ProcessRRop(2, 18, False)
            Case "rol."
                ProcessRRop(2, 18, True)
            Case "ror"
                ProcessRRop(2, 19, False)
            Case "ror."
                ProcessRRop(2, 19, True)
            Case "min"
                ProcessRRop(2, 23, False)
            Case "min."
                ProcessRRop(2, 23, True)
            Case "max"
                ProcessRRop(2, 24, False)
            Case "max."
                ProcessRRop(2, 24, True)
            Case "ldi"
                ProcessLdi(9)
            Case "addi"
                ProcessOri(4)
            Case "subi"
                ProcessOri(5)
            Case "cmpi"
                ProcessCmpiOp(6)
            Case "andi"
                ProcessOri(8)
            Case "ori"
                ProcessOri(9)
            Case "eori"
                ProcessOri(10)
            Case "bra"
                ProcessBranch(16, 0)
            Case "bhi"
                ProcessBranch(16, 2)
            Case "bls"
                ProcessBranch(16, 3)
            Case "bhs"
                ProcessBranch(16, 4)
            Case "blo"
                ProcessBranch(16, 5)
            Case "bne"
                ProcessBranch(16, 6)
            Case "beq"
                ProcessBranch(16, 7)
            Case "bvc"
                ProcessBranch(16, 8)
            Case "bvs"
                ProcessBranch(16, 9)
            Case "bpl"
                ProcessBranch(16, 10)
            Case "bmi"
                ProcessBranch(16, 11)
            Case "bge"
                ProcessBranch(16, 12)
            Case "blt"
                ProcessBranch(16, 13)
            Case "bgt"
                ProcessBranch(16, 14)
            Case "ble"
                ProcessBranch(16, 15)
            Case "trap"
                ProcessTrap(17, 0)
            Case "thi"
                ProcessTrap(17, 2)
            Case "tls"
                ProcessTrap(17, 3)
            Case "ths"
                ProcessTrap(17, 4)
            Case "tlo"
                ProcessTrap(17, 5)
            Case "tne"
                ProcessTrap(17, 6)
            Case "teq"
                ProcessTrap(17, 7)
            Case "tvc"
                ProcessTrap(17, 8)
            Case "tvs"
                ProcessTrap(17, 9)
            Case "tpl"
                ProcessTrap(17, 10)
            Case "tmi"
                ProcessTrap(17, 11)
            Case "tge"
                ProcessTrap(17, 12)
            Case "tlt"
                ProcessTrap(17, 13)
            Case "tgt"
                ProcessTrap(17, 14)
            Case "tle"
                ProcessTrap(17, 15)
            Case "set"
                ProcessSet(18, 0)
            Case "shi"
                ProcessSet(18, 2)
            Case "sls"
                ProcessSet(18, 3)
            Case "shs"
                ProcessSet(18, 4)
            Case "slo"
                ProcessSet(18, 5)
            Case "sne"
                ProcessSet(18, 6)
            Case "seq"
                ProcessSet(18, 7)
            Case "svc"
                ProcessSet(18, 8)
            Case "svs"
                ProcessSet(18, 9)
            Case "spl"
                ProcessSet(18, 10)
            Case "smi"
                ProcessSet(18, 11)
            Case "sge"
                ProcessSet(18, 12)
            Case "slt"
                ProcessSet(18, 13)
            Case "sgt"
                ProcessSet(18, 14)
            Case "sle"
                ProcessSet(18, 15)
            Case "sw"
                ProcessMemop(56, 0)
            Case "sh"
                ProcessMemop(57, 0)
            Case "sb"
                ProcessMemop(58, 0)
            Case "lw"
                ProcessMemop(48, 0)
            Case "lh"
                ProcessMemop(49, 0)
            Case "lb"
                ProcessMemop(50, 0)
            Case "lhu"
                ProcessMemop(51, 0)
            Case "lbu"
                ProcessMemop(52, 0)
            Case "tas"
                ProcessMemop(46, 0)
            Case "swx"
                ProcessMemop(2, 56)
            Case "shx"
                ProcessMemop(2, 57)
            Case "sbx"
                ProcessMemop(2, 58)
            Case "lwx"
                ProcessMemop(2, 48)
            Case "lhx"
                ProcessMemop(2, 49)
            Case "lbx"
                ProcessMemop(2, 50)
            Case "lhux"
                ProcessMemop(2, 51)
            Case "lbux"
                ProcessMemop(2, 52)
            Case "jmp"
                ProcessJsr(20)
            Case "jsr"
                ProcessJsr(21)
            Case "push"
                ProcessPush(59)
            Case "pop"
                ProcessPush(53)
            Case "link"
                ProcessLink(54)
            Case "unlk"
                ProcessUnlk(1, 24)
            Case "rts"
                ProcessRts(0, 34)
            Case "stop"
                ProcessStop(0, 53)
            Case "mov"
                ProcessMov()
            Case "exec"
                ProcessExec()
            Case Else
                ProcessEquate()
        End Select
    End Sub

    Sub emitEmptyLine(ByVal ln As String)
        Dim s As String
        If pass = 2 Then
            s = "                " & "  " & vbTab & "           " & vbTab & vbTab & ln
            lfs.WriteLine(s)
        End If
    End Sub

    Sub emitLabel(ByVal lbl As String)
        Dim s As String

        If pass = 2 Then
            s = Hex(address).PadLeft(8, "0") & vbTab & "           " & vbTab & vbTab & iline
            lfs.WriteLine(s)
        End If
    End Sub

    Function GetRegister(ByVal s As String) As Integer
        Dim r As Int16
        If s.StartsWith("R") Or s.StartsWith("r") Then
            s = s.TrimStart("Rr".ToCharArray)
            Try
                r = Int16.Parse(s)
            Catch
                r = -1
            End Try
            Return r
        Else
            Return -1
        End If
    End Function

    Function GetCrRegister(ByVal s As String) As Integer
        Dim r As Int16
        If s.ToLower.StartsWith("cr") Then
            s = s.Substring(2)
            Try
                r = Int16.Parse(s)
            Catch
                r = -1
            End Try
            Return r
        Else
            Return -1
        End If
    End Function

    Function GetImmediate(ByVal s As String) As Int64
        Dim s1 As String
        Dim s2 As String
        Dim s3 As String
        Dim n As Int64
        Dim q As Integer
        Dim sym As Symbol
        Dim L As Label

        s = s.TrimStart("#".ToCharArray)
        s = s.Replace("_", "")
        If s.Length = 0 Then Return 0
        If s.Chars(0) = "$" Then
            s1 = "&H" & s.Substring(1)
            n = Val(s1)
        ElseIf s.Chars(0) = "0" Then
            If s.Length = 1 Then Return 0
            If s.Chars(1) = "x" Or s.Chars(1) = "X" Then
                If s.Length >= 18 Then
                    s1 = "&H0000" & s.Substring(2, 6) & "&"
                    s2 = "&H0000" & s.Substring(8, 6) & "&"
                    s3 = "&H0000" & s.Substring(14) & "&"
                    n = Val(s1) << 40
                    n = n Or (Val(s2) << 16)
                    n = n Or Val(s3)
                Else
                    s1 = "&H" & s.Substring(2)
                    n = Val(s1)
                End If
            End If
        Else
            If s.Chars(0) > "9" Then
                sym = Nothing
                Try
                    sym = symbols.Item(s)
                Catch
                    sym = Nothing
                End Try
                If Not sym Is Nothing Then
                    n = sym.value
                    Return n
                End If
                Try
                    L = labels.Item(s)
                Catch ex As Exception
                    L = Nothing
                End Try
                If Not L Is Nothing Then
                    n = L.address
                    Return n
                End If
            End If
            n = Int64.Parse(s)
        End If
        Return n
    End Function

    Overloads Sub emit(ByVal n As Int32)
        emit1(n, False)
    End Sub

    Sub emit1(ByVal n As Int32, ByVal pfx As Boolean)
        Dim wdhi As Int64
        Dim wdlo As Int64
        Dim s As String

        If pass = 2 Then
            If pfx Then
                s = Hex(address).PadLeft(8, "0") & vbTab & Hex(n).PadLeft(8, "0") & vbTab
            Else
                s = Hex(address).PadLeft(8, "0") & vbTab & Hex(n).PadLeft(8, "0") & vbTab & vbTab & iline
            End If
            lfs.WriteLine(s)
        End If
        If pass = 2 Then
            s = "32'h" & Hex(address) & ":" & vbTab & "romout <= 32'h" & Hex(n).PadLeft(8, "0") & ";"
            ofs.WriteLine(s)
        End If
        address = address + 4

    End Sub

End Module
