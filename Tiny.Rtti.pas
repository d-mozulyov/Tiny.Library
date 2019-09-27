unit Tiny.Rtti;

{******************************************************************************}
{ Copyright (c) 2019 Dmitry Mozulyov                                           }
{                                                                              }
{ Permission is hereby granted, free of charge, to any person obtaining a copy }
{ of this software and associated documentation files (the "Software"), to deal}
{ in the Software without restriction, including without limitation the rights }
{ to use, copy, modify, merge, publish, distribute, sublicense, and/or sell    }
{ copies of the Software, and to permit persons to whom the Software is        }
{ furnished to do so, subject to the following conditions:                     }
{                                                                              }
{ The above copyright notice and this permission notice shall be included in   }
{ all copies or substantial portions of the Software.                          }
{                                                                              }
{ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR   }
{ IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,     }
{ FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE  }
{ AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER       }
{ LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,}
{ OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN    }
{ THE SOFTWARE.                                                                }
{                                                                              }
{ email: softforyou@inbox.ru                                                   }
{ skype: dimandevil                                                            }
{ repository: https://github.com/d-mozulyov/Tiny.Rtti                          }
{******************************************************************************}

// compiler directives
{$ifdef FPC}
  {$MODE DELPHIUNICODE}
  {$ASMMODE INTEL}
  {$define INLINESUPPORT}
  {$define INLINESUPPORTSIMPLE}
  {$define OPERATORSUPPORT}
  {$define ANSISTRSUPPORT}
  {$define SHORTSTRSUPPORT}
  {$define WIDESTRSUPPORT}
  {$ifdef MSWINDOWS}
    {$define WIDESTRLENSHIFT}
  {$endif}
  {$define INTERNALCODEPAGE}
  {$ifdef CPU386}
    {$define CPUX86}
  {$endif}
  {$ifdef CPUX86_64}
    {$define CPUX64}
  {$endif}
  {$if Defined(CPUARM) or Defined(UNIX)}
    {$define POSIX}
  {$ifend}
{$else}
  {$if CompilerVersion >= 24}
    {$LEGACYIFEND ON}
  {$ifend}
  {$if CompilerVersion >= 15}
    {$WARN UNSAFE_CODE OFF}
    {$WARN UNSAFE_TYPE OFF}
    {$WARN UNSAFE_CAST OFF}
  {$ifend}
  {$if CompilerVersion >= 20}
    {$define INLINESUPPORT}
  {$ifend}
  {$if CompilerVersion >= 17}
    {$define INLINESUPPORTSIMPLE}
  {$ifend}
  {$if CompilerVersion >= 18}
    {$define OPERATORSUPPORT}
  {$ifend}
  {$if CompilerVersion < 23}
    {$define CPUX86}
  {$else}
    {$define UNITSCOPENAMES}
  {$ifend}
  {$if CompilerVersion >= 21}
    {$WEAKLINKRTTI ON}
    {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
  {$ifend}
  {$if (not Defined(NEXTGEN)) or (CompilerVersion >= 31)}
    {$define ANSISTRSUPPORT}
  {$ifend}
  {$ifNdef NEXTGEN}
    {$define SHORTSTRSUPPORT}
  {$endif}
  {$if Defined(MSWINDOWS) or (Defined(MACOS) and not Defined(IOS))}
    {$define WIDESTRSUPPORT}
  {$ifend}
  {$if Defined(MSWINDOWS) or (Defined(WIDESTRSUPPORT) and (CompilerVersion <= 21))}
    {$define WIDESTRLENSHIFT}
  {$ifend}
  {$if Defined(ANSISTRSUPPORT) and (CompilerVersion >= 20)}
    {$define INTERNALCODEPAGE}
  {$ifend}
{$endif}
{$U-}{$V+}{$B-}{$X+}{$T+}{$P+}{$H+}{$J-}{$Z1}{$A4}
{$O+}{$R-}{$I-}{$Q-}{$W-}
{$ifdef CPUX86}
  {$if not Defined(NEXTGEN)}
    {$define CPUX86ASM}
    {$define CPUINTELASM}
  {$ifend}
  {$define CPUINTEL}
{$endif}
{$ifdef CPUX64}
  {$if (not Defined(POSIX)) or Defined(FPC)}
    {$define CPUX64ASM}
    {$define CPUINTELASM}
  {$ifend}
  {$define CPUINTEL}
{$endif}
{$if Defined(CPUX64) or Defined(CPUARM64)}
  {$define LARGEINT}
{$else}
  {$define SMALLINT}
{$ifend}
{$ifdef KOL_MCK}
  {$define KOL}
{$endif}

interface


type
  // standard types
  {$ifdef FPC}
    PUInt64 = ^UInt64;
    PBoolean = ^Boolean;
    PString = ^string;
  {$else}
    {$if CompilerVersion < 16}
      UInt64 = Int64;
      PUInt64 = ^UInt64;
    {$ifend}
    {$if CompilerVersion < 21}
      NativeInt = Integer;
      NativeUInt = Cardinal;
    {$ifend}
    {$if CompilerVersion < 22}
      PNativeInt = ^NativeInt;
      PNativeUInt = ^NativeUInt;
    {$ifend}
    PWord = ^Word;
  {$endif}
  {$if SizeOf(Extended) >= 10}
    {$define EXTENDEDSUPPORT}
  {$ifend}
  TBytes = {$if (not Defined(FPC)) and (CompilerVersion >= 23)}TArray<Byte>{$else}array of Byte{$ifend};
  PBytes = ^TBytes;

  // compiler independent char/string types
  {$ifdef ANSISTRSUPPORT}
    {$if Defined(NEXTGEN) and (CompilerVersion >= 31)}
      AnsiChar = type System.UTF8Char;
      PAnsiChar = ^AnsiChar;
      AnsiString = type System.RawByteString;
      PAnsiString = ^AnsiString;
      UTF8Char = System.UTF8Char;
      PUTF8Char = System.PUTF8Char;
      {$POINTERMATH ON}
    {$else}
      AnsiChar = System.AnsiChar;
      PAnsiChar = System.PAnsiChar;
      AnsiString = System.AnsiString;
      PAnsiString = System.PAnsiString;
      UTF8Char = type System.AnsiChar;
      PUTF8Char = ^UTF8Char;
    {$ifend}
    UTF8String = System.UTF8String;
    PUTF8String = System.PUTF8String;
    {$ifdef UNICODE}
      RawByteString = System.RawByteString;
      {$ifdef FPC}
      PRawByteString = ^RawByteString;
      {$else}
      PRawByteString = System.PRawByteString;
      {$endif}
    {$else}
      RawByteString = type AnsiString;
      PRawByteString = ^RawByteString;
    {$endif}
  {$else}
    AnsiChar = type Byte;
    PAnsiChar = ^AnsiChar;
    UTF8Char = type AnsiChar;
    PUTF8Char = ^UTF8Char;
    AnsiString = array of AnsiChar;
    PAnsiString = ^AnsiString;
    UTF8String = type AnsiString;
    PUTF8String = ^UTF8String;
    RawByteString = type AnsiString;
    PRawByteString = ^RawByteString;
  {$endif}
  {$ifdef SHORTSTRSUPPORT}
    ShortString = System.ShortString;
    PShortString = System.PShortString;
  {$else}
    ShortString = array[0{length}..255] of AnsiChar{/UTF8Char};
    PShortString = ^ShortString;
  {$endif}
  {$ifdef WIDESTRSUPPORT}
    WideString = System.WideString;
    PWideString = System.PWideString;
  {$else}
    WideString = array of WideChar;
    PWideString = ^WideString;
  {$endif}
  {$ifdef UNICODE}
    {$ifdef FPC}
    UnicodeChar = System.WideChar;
    PUnicodeChar = System.PWideChar;
    {$else}
    UnicodeChar = System.Char;
    PUnicodeChar = System.PChar;
    {$endif}
    UnicodeString = System.UnicodeString;
    PUnicodeString = System.PUnicodeString;
  {$else}
    UnicodeChar = System.WideChar;
    PUnicodeChar = System.PWideChar;
    UnicodeString = System.WideString;
    PUnicodeString = System.PWideString;
  {$endif}
  WideChar = System.WideChar;
  PWideChar = System.PWideChar;
  UCS4Char = System.UCS4Char;
  PUCS4Char = System.PUCS4Char;
  UCS4String = System.UCS4String;
  PUCS4String = ^UCS4String;

type
  // dynamic array
  PDynArrayRec = ^TDynArrayRec;
  TDynArrayRec = object
  private
  {$ifdef FPC}
    function GetLength: NativeInt; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetLength(const AValue: NativeInt); {$ifdef INLINESUPPORT}inline;{$endif}
  {$else .DELPHI}
    function GetHigh: NativeInt; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetHigh(const AValue: NativeInt); {$ifdef INLINESUPPORT}inline;{$endif}
  {$endif}
  public
  {$ifdef FPC}
    property Length: NativeInt read GetLength write SetLength;
  {$else .DELPHI}
    property High: NativeInt read GetHigh write SetHigh;
  {$endif}
  public
  {$ifdef FPC}
    RefCount: NativeInt;
    High: NativeInt;
  {$else .DELPHI}
    {$ifdef LARGEINT}_Padding: Integer;{$endif}
    RefCount: Integer;
    Length: NativeInt;
  {$endif}
  end;

  // native unicode string
  {$ifdef UNICODE}
    PUnicodeStrRec = ^TUnicodeStrRec;
    TUnicodeStrRec = packed record
    case Integer of
      0:
      (
      {$ifdef FPC}
        CodePageElemSize: Integer;
        {$ifdef LARGEINT}_Padding: Integer;{$endif}
        RefCount: NativeInt;
        Length: NativeInt;
      {$else .DELPHI}
        {$ifdef LARGEINT}_Padding: Integer;{$endif}
        CodePageElemSize: Integer;
        RefCount: Integer;
        Length: Integer;
      {$endif}
      );
      1:
      (
        {$if (not Defined(FPC)) and Defined(LARGEINT)}_: Integer;{$ifend}
        CodePage: Word;
        ElementSize: Word;
      );
    end;
  const
    {$ifdef FPC}
      USTR_OFFSET_LENGTH = SizeOf(NativeInt);
      USTR_OFFSET_REFCOUNT = USTR_OFFSET_LENGTH + SizeOf(NativeInt);
      USTR_OFFSET_CODEPAGE = SizeOf(TUnicodeStrRec);
    {$else .DELPHI}
      USTR_OFFSET_LENGTH = 4{SizeOf(Integer)};
      USTR_OFFSET_REFCOUNT = USTR_OFFSET_LENGTH + SizeOf(Integer);
      USTR_OFFSET_CODEPAGE = USTR_OFFSET_REFCOUNT + {ElemSize}SizeOf(Word) + {CodePage}SizeOf(Word);
    {$endif}
  {$endif}

type
  // ansi string
  PAnsiStrRec = ^TAnsiStrRec;
  {$if not Defined(ANSISTRSUPPORT)}
    TAnsiStrRec = TDynArrayRec;
  const
    {$ifdef FPC}
      // None
    {$else .DELPHI}
      ASTR_OFFSET_LENGTH = {$ifdef SMALLINT}4{$else}8{$endif}{SizeOf(NativeInt)};
      ASTR_OFFSET_REFCOUNT = ASTR_OFFSET_LENGTH + SizeOf(Integer);
    {$endif}
  {$elseif not Defined(INTERNALCODEPAGE)}
    TAnsiStrRec = packed record
      RefCount: Integer;
      Length: Integer;
    end;
  const
    {$ifdef FPC}
      // None
    {$else .DELPHI}
      ASTR_OFFSET_LENGTH = 4{SizeOf(Integer)};
      ASTR_OFFSET_REFCOUNT = ASTR_OFFSET_LENGTH + SizeOf(Integer);
    {$endif}
  {$else .INTERNALCODEPAGE}
    TAnsiStrRec = TUnicodeStrRec;
  const
    ASTR_OFFSET_LENGTH = USTR_OFFSET_LENGTH;
    ASTR_OFFSET_REFCOUNT = USTR_OFFSET_REFCOUNT;
    ASTR_OFFSET_CODEPAGE = USTR_OFFSET_CODEPAGE;
  {$ifend}

type
  // wide string
  PWideStrRec = ^TWideStrRec;
  {$if not Defined(WIDESTRSUPPORT)}
    TWideStrRec = TDynArrayRec;
  const
    WSTR_OFFSET_LENGTH = {$ifdef SMALLINT}4{$else}8{$endif}{SizeOf(NativeInt)};
  {$elseif Defined(MSWINDOWS)}
    TWideStrRec = object
    private
      function GetLength: Integer; {$ifdef INLINESUPPORT}inline;{$endif}
      procedure SetLength(const AValue: Integer); {$ifdef INLINESUPPORT}inline;{$endif}
    public
      property Length: Integer read GetLength write SetLength;
    public
      Size: Integer;
    end;
  const
    WSTR_OFFSET_SIZE = 4{SizeOf(Integer)};
  {$else .INTERNALCODEPAGE}
    TWideStrRec = TUnicodeStrRec;
  const
    WSTR_OFFSET_LENGTH = USTR_OFFSET_LENGTH;
  {$ifend}

  // unicode string emulation
  {$ifNdef UNICODE}
type  
    PUnicodeStrRec = PWideStrRec;
    TUnicodeStrRec = TWideStrRec;
  const
    USTR_OFFSET_SIZE = WSTR_OFFSET_SIZE;
  {$endif}


// short string length helpers
function ShortStringLength(const S: ShortString): Byte; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
procedure SetShortStringLength(var S: ShortString; const AValue: Byte); {$if (not Defined(SHORTSTRSUPPORT)) and Defined(INLINESUPPORTSIMPLE)}inline;{$ifend}

implementation


{ short string length helpers }

function ShortStringLength(const S: ShortString): Byte;
begin
  {$ifdef SHORTSTRSUPPORT}
    Result := System.Length(S);
  {$else}
    Result := S[0];
  {$endif}
end;

procedure SetShortStringLength(var S: ShortString; const AValue: Byte);
begin
  {$ifdef SHORTSTRSUPPORT}
    System.SetLength(S, AValue);
  {$else}
    S[0] := AValue;
  {$endif}
end;


{ TDynArrayRec }

{$ifdef FPC}
function TDynArrayRec.GetLength: NativeInt;
begin
  Result := High + 1;
end;

procedure TDynArrayRec.SetLength(const AValue: NativeInt);
begin
  High := AValue - 1;
end;
{$else .DELPHI}
function TDynArrayRec.GetHigh: NativeInt;
begin
  Result := Length - 1;
end;

procedure TDynArrayRec.SetHigh(const AValue: NativeInt);
begin
  Length := AValue + 1;
end;
{$endif}


{ TWideStrRec }

{$ifdef MSWINDOWS}
function TWideStrRec.GetLength: Integer;
begin
  Result := Size shr 1;
end;

procedure TWideStrRec.SetLength(const AValue: Integer);
begin
  Size := AValue + AValue;
end;
{$endif}



end.
