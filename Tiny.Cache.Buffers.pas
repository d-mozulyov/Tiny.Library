unit Tiny.Cache.Buffers;

{******************************************************************************}
{ Copyright (c) Dmitry Mozulyov                                                }
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
{ repository: https://github.com/d-mozulyov/Tiny.Library                       }
{ previous location: https://github.com/d-mozulyov/CachedBuffers               }
{******************************************************************************}

{$I TINY.DEFINES.inc}

interface
uses
  {$ifdef UNITSCOPENAMES}System.Types{$else}Types{$endif},
  {$ifdef MSWINDOWS}
    {$ifdef UNITSCOPENAMES}Winapi.Windows, Winapi.ActiveX{$else}Windows, ActiveX{$endif},
  {$else .POSIX}
    {$ifdef FPC}
      BaseUnix,
    {$else}
      Posix.String_, Posix.SysStat, Posix.Unistd,
    {$endif}
  {$endif}
  {$ifdef UNITSCOPENAMES}System.SysUtils{$else}SysUtils{$endif},
  Tiny.Types;


type

{ ECachedBuffer class }

  ECachedBuffer = class(Exception);


{ TCachedBufferMemory record }

  TCachedBufferMemory = {$ifdef OPERATORSUPPORT}record{$else}object{$endif}
  public
    Handle: Pointer;
    PreviousSize: NativeUInt;
      Data: Pointer;
      Size: NativeUInt;
    Additional: Pointer;
    AdditionalSize: NativeUInt;
  private
    function GetEmpty: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetFixed: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetPreallocated: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    property Empty: Boolean read GetEmpty;
    property Fixed: Boolean read GetFixed;
    property Preallocated: Boolean read GetPreallocated;
  end;
  PCachedBufferMemory = ^TCachedBufferMemory;


{ TCachedBuffer abstract class }

  {$if (not Defined(FPC)) and (CompilerVersion >= 29)}
    {$define NEWISTREAM}
  {$ifend}

  TCachedBufferKind = (cbReader, cbWriter);
  TCachedBuffer = class;
  TCachedBufferCallback = function(const ASender: TCachedBuffer; AData: PByte; ASize: NativeUInt): NativeUInt of object;
  TCachedBufferProgress = procedure(const ASender: TCachedBuffer; var ACancel: Boolean) of object;
  PCachedBufferPreallocatedParam = ^TCachedBufferPreallocatedParam;
  TCachedBufferPreallocatedParam = packed record
    PreviousSize: NativeUInt;
    DataAlign: NativeUInt;
    DataSize: NativeUInt;
    AdditionalSize: NativeUInt;
  end;

  TCachedBuffer = class(TTinyObject, IStream)
  protected
    FMemory: TCachedBufferMemory;
    FKind: TCachedBufferKind;
    FFinishing: Boolean;
    FEOF: Boolean;
    FLimited: Boolean;
    FPositionBase: Int64;
    FLimit: Int64;
    FStart: PByte;
    FOverflow: PByte;
    FHighWritten: PByte;
    FCallback: TCachedBufferCallback;
    FOnProgress: TCachedBufferProgress;

    class function GetOptimalBufferSize(const AValue, ADefValue: NativeUInt; const ALimit: Int64 = 0): NativeUInt;
    function GetMargin: NativeInt; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    function GetPosition: Int64; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    procedure SetEOF(const AValue: Boolean);
    procedure SetLimit(const AValue: Int64);
    function CheckLimit(const AValue: Int64): Boolean; virtual;
    function DoFlush: NativeUInt;
    function DoWriterFlush: Boolean;
    function DoReaderFlush: Boolean;
    function DoProgress: Boolean;
    class function PreallocatedBufferSize(const AParam, AThreadBufferMemory: Pointer; const AThreadBufferMargin: NativeUInt): NativeInt; override;
  {$ifdef FPC}
  public
  {$endif}
    constructor PreallocatedCreate(const AParam: Pointer; const ABuffer: Pointer; const ASize: NativeUInt); override;
    constructor Create(const AKind: TCachedBufferKind; const ACallback: TCachedBufferCallback; const ABufferSize: NativeUInt = 0);
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    destructor Destroy; override;
  private
    // IStream implementation
    function InternalSeek(const AOffset: Int64; const AOrigin: Word): Int64;
    {$if Defined(FPC)}
      function Read(pv: Pointer; cb: DWORD; pcbRead: PDWORD): HRESULT; stdcall;
      function Write(pv: Pointer; cb: DWORD; pcbWritten: PDWORD): HRESULT; stdcall;
      function Seek(dlibMove: LargeUInt; dwOrigin: Longint; out libNewPosition: LargeUInt): HResult; stdcall;
      function SetSize(libNewSize: LargeUInt): HRESULT; stdcall;
      function CopyTo(stm: IStream; cb: LargeUInt; out cbRead: LargeUInt; out cbWritten: LargeUInt): HRESULT; stdcall;
      function Commit(grfCommitFlags: Longint): HRESULT; stdcall;
      function Revert: HRESULT; stdcall;
      function LockRegion(libOffset: LargeUInt;cb: LargeUInt; dwLockType: Longint): HRESULT; stdcall;
      function UnlockRegion(libOffset: LargeUInt; cb: LargeUInt; dwLockType: Longint): HRESULT; stdcall;
      function Stat(out statstg: TStatStg; grfStatFlag: Longint): HRESULT; stdcall;
      function Clone(out stm: IStream): HRESULT; stdcall;
    {$elseif not Defined(NEWISTREAM)}
      function Read(pv: Pointer; cb: Longint; pcbRead: PLongint): HResult; virtual; stdcall;
      function Write(pv: Pointer; cb: Longint; pcbWritten: PLongint): HResult; virtual; stdcall;
      function Seek(dlibMove: Largeint; dwOrigin: Longint; out libNewPosition: Largeint): HResult; virtual; stdcall;
      function SetSize(libNewSize: Largeint): HResult; virtual; stdcall;
      function CopyTo(stm: IStream; cb: Largeint; out cbRead: Largeint; out cbWritten: Largeint): HResult; virtual; stdcall;
      function Commit(grfCommitFlags: Longint): HResult; virtual; stdcall;
      function Revert: HResult; virtual; stdcall;
      function LockRegion(libOffset: Largeint; cb: Largeint; dwLockType: Longint): HResult; virtual; stdcall;
      function UnlockRegion(libOffset: Largeint; cb: Largeint; dwLockType: Longint): HResult; virtual; stdcall;
      function Stat(out statstg: TStatStg; grfStatFlag: Longint): HResult; virtual; stdcall;
      function Clone(out stm: IStream): HResult; virtual; stdcall;
    {$else .NEWISTREAM}
      function Read(pv: Pointer; cb: FixedUInt; pcbRead: PFixedUInt): HResult; virtual; stdcall;
      function Write(pv: Pointer; cb: FixedUInt; pcbWritten: PFixedUInt): HResult; virtual; stdcall;
      function Seek(dlibMove: Largeint; dwOrigin: DWORD; out libNewPosition: LargeUInt): HResult; virtual; stdcall;
      function SetSize(libNewSize: LargeUInt): HResult; virtual; stdcall;
      function CopyTo(stm: IStream; cb: LargeUInt; out cbRead: LargeUInt; out cbWritten: LargeUInt): HResult; virtual; stdcall;
      function Commit(grfCommitFlags: DWORD): HResult; virtual; stdcall;
      function Revert: HResult; virtual; stdcall;
      function LockRegion(libOffset: LargeUInt; cb: LargeUInt; dwLockType: DWORD): HResult; virtual; stdcall;
      function UnlockRegion(libOffset: LargeUInt; cb: LargeUInt; dwLockType: DWORD): HResult; virtual; stdcall;
      function Stat(out statstg: TStatStg; grfStatFlag: DWORD): HResult; virtual; stdcall;
      function Clone(out stm: IStream): HResult; virtual; stdcall;
    {$ifend}
  public
    Current: PByte;
    function Flush: NativeUInt;
    property Kind: TCachedBufferKind read FKind;
    property Overflow: PByte read FOverflow;
    property Margin: NativeInt read GetMargin;
    property EOF: Boolean read FEOF write SetEOF;
    property Limited: Boolean read FLimited;
    property Limit: Int64 read FLimit write SetLimit;
    property Memory: TCachedBufferMemory read FMemory;
    property Position: Int64 read GetPosition;
    property OnProgress: TCachedBufferProgress read FOnProgress write FOnProgress;
  end;
  TCachedBufferClass = class of TCachedBuffer;


{ TCachedReader class }

  TCachedWriter = class;

  TCachedReader = class(TCachedBuffer)
  protected
    procedure OverflowRead(var ABuffer; ASize: NativeUInt);
    function DoDirectPreviousRead(APosition: Int64; AData: PByte; ASize: NativeUInt): Boolean; virtual;
    function DoDirectFollowingRead(APosition: Int64; AData: PByte; ASize: NativeUInt): Boolean; virtual;
    procedure OverflowSkip(ASize: NativeUInt);
  public
    constructor Create(const ACallback: TCachedBufferCallback; const ABufferSize: NativeUInt = 0);
    procedure DirectRead(const APosition: Int64; var ABuffer; const ACount: NativeUInt);
    property Finishing: Boolean read FFinishing;
    procedure Skip(const ACount: NativeUInt); {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    procedure Export(const AWriter: TCachedWriter; const ACount: NativeUInt = 0); {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}

    // TStream-like data reading
    procedure Read(var ABuffer; const ACount: NativeUInt); reintroduce;
    procedure ReadData(var AValue: Boolean); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    {$ifdef ANSISTRSUPPORT}
    procedure ReadData(var AValue: AnsiChar); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    {$endif}
    procedure ReadData(var AValue: WideChar); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    procedure ReadData(var AValue: ShortInt); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    procedure ReadData(var AValue: Byte); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    procedure ReadData(var AValue: SmallInt); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    procedure ReadData(var AValue: Word); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    procedure ReadData(var AValue: Integer); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    procedure ReadData(var AValue: Cardinal); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    procedure ReadData(var AValue: Int64); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    {$if Defined(FPC) or (CompilerVersion >= 16)}
    procedure ReadData(var AValue: UInt64); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    {$ifend}
    procedure ReadData(var AValue: Single); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    procedure ReadData(var AValue: Double); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    {$if (not Defined(FPC)) or Defined(EXTENDEDSUPPORT)}
    procedure ReadData(var AValue: Extended); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    {$ifend}
    {$if not Defined(FPC) and (CompilerVersion >= 23)}
    procedure ReadData(var AValue: TExtended80Rec); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    {$ifend}
    procedure ReadData(var AValue: Currency); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    procedure ReadData(var AValue: TPoint); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    procedure ReadData(var AValue: TRect); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    {$ifdef SHORTSTRSUPPORT}
    procedure ReadData(var AValue: ShortString); overload;
    {$endif}
    {$ifdef ANSISTRSUPPORT}
    procedure ReadData(var AValue: AnsiString{$ifdef INTERNALCODEPAGE}; ACodePage: Word = 0{$endif}); overload;
    {$endif}
    {$ifdef MSWINDOWS}
    procedure ReadData(var AValue: WideString); overload;
    {$endif}
    {$ifdef UNICODE}
    procedure ReadData(var AValue: UnicodeString); overload;
    {$endif}
    procedure ReadData(var AValue: TBytes); overload;
    procedure ReadData(var AValue: Variant); overload;
  end;


{ TCachedWriter class }

  TCachedWriter = class(TCachedBuffer)
  protected
    procedure OverflowWrite(const ABuffer; ASize: NativeUInt);
    function DoDirectPreviousWrite(APosition: Int64; AData: PByte; ASize: NativeUInt): Boolean; virtual;
    function DoDirectFollowingWrite(APosition: Int64; AData: PByte; ASize: NativeUInt): Boolean; virtual;
  public
    constructor Create(const ACallback: TCachedBufferCallback; const ABufferSize: NativeUInt = 0);
    procedure DirectWrite(const APosition: Int64; const ABuffer; const ACount: NativeUInt);
    procedure Import(const AReader: TCachedReader; const ACount: NativeUInt = 0);

    // TStream-like data writing
    procedure Write(const ABuffer; const ACount: NativeUInt); reintroduce;
    procedure WriteData(const AValue: Boolean); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    {$ifdef ANSISTRSUPPORT}
    procedure WriteData(const AValue: AnsiChar); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    {$endif}
    procedure WriteData(const AValue: WideChar); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    procedure WriteData(const AValue: ShortInt); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    procedure WriteData(const AValue: Byte); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    procedure WriteData(const AValue: SmallInt); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    procedure WriteData(const AValue: Word); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    procedure WriteData(const AValue: Integer); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    procedure WriteData(const AValue: Cardinal); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    procedure WriteData(const AValue: Int64); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    {$if Defined(FPC) or (CompilerVersion >= 16)}
    procedure WriteData(const AValue: UInt64); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    {$ifend}
    procedure WriteData(const AValue: Single); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    procedure WriteData(const AValue: Double); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    {$if (not Defined(FPC)) or Defined(EXTENDEDSUPPORT)}
    procedure WriteData(const AValue: Extended); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    {$ifend}
    {$if not Defined(FPC) and (CompilerVersion >= 23)}
    procedure WriteData(const AValue: TExtended80Rec); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    {$ifend}
    procedure WriteData(const AValue: Currency); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    procedure WriteData(const AValue: TPoint); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    procedure WriteData(const AValue: TRect); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    {$ifdef SHORTSTRSUPPORT}
    procedure WriteData(const AValue: ShortString); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    {$endif}
    {$ifdef ANSISTRSUPPORT}
    procedure WriteData(const AValue: AnsiString); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    {$endif}
    {$ifdef MSWINDOWS}
    procedure WriteData(const AValue: WideString); overload;
    {$endif}
    {$ifdef UNICODE}
    procedure WriteData(const AValue: UnicodeString); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    {$endif}
    procedure WriteData(const AValue: TBytes); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    procedure WriteData(const AValue: Variant); overload;
  end;


{ TCachedReReader class }

  TCachedReReader = class(TCachedReader)
  protected
    FSource: TCachedReader;
    FOwner: Boolean;
  public
    constructor Create(const ACallback: TCachedBufferCallback; const ASource: TCachedReader; const AOwner: Boolean = False; const ABufferSize: NativeUInt = 0);
    destructor Destroy; override;

    property Source: TCachedReader read FSource;
    property Owner: Boolean read FOwner write FOwner;
  end;


{ TCachedReWriter class }

  TCachedReWriter = class(TCachedWriter)
  protected
    FTarget: TCachedWriter;
    FOwner: Boolean;
  public
    constructor Create(const ACallback: TCachedBufferCallback; const ATarget: TCachedWriter; const AOwner: Boolean = False; const ABufferSize: NativeUInt = 0);
    destructor Destroy; override;

    property Target: TCachedWriter read FTarget;
    property Owner: Boolean read FOwner write FOwner;
  end;


{ TCachedFileReader class }

  TCachedFileReader = class(TCachedReader)
  protected
    FFileName: string;
    FHandle: THandle;
    FHandleOwner: Boolean;
    FOffset: Int64;

    procedure InternalCreate(const ASize: Int64; const ASeeked: Boolean);
    function CheckLimit(const AValue: Int64): Boolean; override;
    function DoDirectPreviousRead(APosition: Int64; AData: PByte; ASize: NativeUInt): Boolean; override;
    function DoDirectFollowingRead(APosition: Int64; AData: PByte; ASize: NativeUInt): Boolean; override;
    function InternalCallback(const ASender: TCachedBuffer; AData: PByte; ASize: NativeUInt): NativeUInt;
  public
    constructor Create(const AFileName: string; const AOffset: Int64 = 0; const ASize: Int64 = 0);
    constructor CreateHandled(const AHandle: THandle; const ASize: Int64 = 0; const AHandleOwner: Boolean = False);
    destructor Destroy; override;

    property FileName: string read FFileName;
    property Handle: THandle read FHandle;
    property HandleOwner: Boolean read FHandleOwner write FHandleOwner;
    property Offset: Int64 read FOffset;
  end;


{ TCachedFileWriter class }

  TCachedFileWriter = class(TCachedWriter)
  protected
    FFileName: string;
    FHandle: THandle;
    FHandleOwner: Boolean;
    FOffset: Int64;

    function DoDirectPreviousWrite(APosition: Int64; AData: PByte; ASize: NativeUInt): Boolean; override;
    function DoDirectFollowingWrite(APosition: Int64; AData: PByte; ASize: NativeUInt): Boolean; override;
    function InternalCallback(const ASender: TCachedBuffer; AData: PByte; ASize: NativeUInt): NativeUInt;
  public
    constructor Create(const AFileName: string; const ASize: Int64 = 0);
    constructor CreateHandled(const AHandle: THandle; const ASize: Int64 = 0; const AHandleOwner: Boolean = False);
    destructor Destroy; override;

    property FileName: string read FFileName;
    property Handle: THandle read FHandle;
    property HandleOwner: Boolean read FHandleOwner write FHandleOwner;
    property Offset: Int64 read FOffset;
  end;


{ TCachedMemoryReader class }

  TCachedMemoryReader = class(TCachedReader)
  protected
    FPtr: Pointer;
    FSize: NativeUInt;
    FPtrMargin: NativeUInt;

    function CheckLimit(const AValue: Int64): Boolean; override;
    function InternalCallback(const ASender: TCachedBuffer; AData: PByte; ASize: NativeUInt): NativeUInt;
    function FixedCallback(const ASender: TCachedBuffer; AData: PByte; ASize: NativeUInt): NativeUInt;
  public
    constructor Create(const APtr: Pointer; const ASize: NativeUInt; const AFixed: Boolean = False);
    property Ptr: Pointer read FPtr;
    property Size: NativeUInt read FSize;
  end;


{ TCachedMemoryWriter class }

  TCachedMemoryWriter = class(TCachedWriter)
  protected
    FTemporary: Boolean;
    FPtr: Pointer;
    FSize: NativeUInt;
    FPtrMargin: NativeUInt;

    function CheckLimit(const AValue: Int64): Boolean; override;
    function InternalCallback(const ASender: TCachedBuffer; AData: PByte; ASize: NativeUInt): NativeUInt;
    function InternalTemporaryCallback(const ASender: TCachedBuffer; AData: PByte; ASize: NativeUInt): NativeUInt;
    function FixedCallback(const ASender: TCachedBuffer; AData: PByte; ASize: NativeUInt): NativeUInt;
  public
    constructor Create(const APtr: Pointer; const ASize: NativeUInt; const AFixed: Boolean = False);
    constructor CreateTemporary;
    destructor Destroy; override;
    property Temporary: Boolean read FTemporary;
    property Ptr: Pointer read FPtr;
    property Size: NativeUInt read FSize;
  end;


{ TCachedResourceReader class }

  TCachedResourceReader = class(TCachedMemoryReader)
  protected
    HGlobal: THandle;
    procedure InternalCreate(AInstance: THandle; AName, AResType: PChar; AFixed: Boolean);
  public
    constructor Create(const AInstance: THandle; const AResName: string; const AResType: PChar; const AFixed: Boolean = False);
    constructor CreateFromID(const AInstance: THandle; const AResID: Word; const AResType: PChar; const AFixed: Boolean = False);
    destructor Destroy; override;
  end;


implementation

{$ifdef FPC}
const
  INVALID_HANDLE_VALUE = THandle(-1);
{$endif}

const
  KB_SIZE = 1024;
  MEMORY_PAGE_SIZE = 4 * KB_SIZE;
  DEFAULT_CACHED_SIZE = 64 * KB_SIZE;
  MAX_PREALLOCATED_SIZE = 20 * MEMORY_PAGE_SIZE; // 80KB


{ Exceptions }

procedure RaisePointers;
begin
  raise ECachedBuffer.Create('Invalid current, overflow or buffer memory values');
end;

procedure RaiseEOF;
begin
  raise ECachedBuffer.Create('EOF buffer data modified');
end;

procedure RaiseReading;
begin
  raise ECachedBuffer.Create('Data reading error');
end;

procedure RaiseWriting;
begin
  raise ECachedBuffer.Create('Data writing error');
end;

procedure RaiseLimitValue(const AValue: Int64);
begin
  raise ECachedBuffer.CreateFmt('Invalid limit value %d', [AValue]);
end;

procedure RaiseVaraintType(const VType: Word);
begin
  raise ECachedBuffer.CreateFmt('Invalid variant type 0x%.4x', [VType]);
end;


{ Utilitarian functions }

function AllocateCachedBufferMemory(const APreviousSize, ABufferSize: NativeUInt): TCachedBufferMemory;
var
  LOffset: NativeUInt;
begin
  // detect sizes
  Result.PreviousSize := (APreviousSize + MEMORY_PAGE_SIZE - 1) and -MEMORY_PAGE_SIZE;
  Result.AdditionalSize := MEMORY_PAGE_SIZE;
  if (ABufferSize = 0) then
  begin
    Result.Size := DEFAULT_CACHED_SIZE;
  end else
  begin
    Result.Size := (ABufferSize + MEMORY_PAGE_SIZE - 1) and -MEMORY_PAGE_SIZE;
  end;

  // allocate
  GetMem(Result.Handle, Result.PreviousSize + Result.Size + Result.AdditionalSize + MEMORY_PAGE_SIZE);

  // align
  LOffset := NativeUInt(Result.Handle) and (MEMORY_PAGE_SIZE - 1);
  Inc(Result.PreviousSize, MEMORY_PAGE_SIZE - LOffset);
  Inc(Result.AdditionalSize, LOffset);
  Result.Data := Pointer(NativeUInt(Result.Handle) + Result.PreviousSize);
  Result.Additional := Pointer(NativeUInt(Result.Data) + Result.Size);
end;

function GetFileSize(AHandle: THandle): Int64;
var
  {$ifdef MSWINDOWS}
    P: TPoint;
  {$endif}
  {$ifdef POSIX}
    S: {$ifdef FPC}Stat{$else}_stat{$endif};
  {$endif}
begin
  {$ifdef MSWINDOWS}
    P.X := {$ifdef UNITSCOPENAMES}Winapi.{$endif}Windows.GetFileSize(AHandle, Pointer(@P.Y));
    if (P.Y = -1) then P.X := -1;
    Result := PInt64(@P)^;
  {$endif}

  {$ifdef POSIX}
    if ({$ifdef FPC}FpFStat{$else}fstat{$endif}(AHandle, S) = 0) then
      Result := S.st_size
    else
      Result := -1;
  {$endif}
end;

function DirectCachedFileMethod(const AInstance: TCachedBuffer;
  const AInstanceHandle: THandle; const AInstanceOffset, APosition: Int64;
  const AData: PByte; const ASize: NativeUInt): Boolean;
var
  LSeekValue: Int64;
  LPositionValue: Int64;
begin
  LSeekValue := FileSeek(AInstanceHandle, Int64(0), 1{soFromCurrent});
  try
    LPositionValue := APosition + AInstanceOffset;
    if (LPositionValue <> FileSeek(AInstanceHandle, LPositionValue, 0{soFromBeginning})) then
    begin
      Result := False;
    end else
    begin
      Result := (ASize = AInstance.FCallback(AInstance, AData, ASize));
    end;
  finally
    FileSeek(AInstanceHandle, LSeekValue, 0{soFromBeginning});
  end;
end;


{ TCachedBufferMemory }

function TCachedBufferMemory.GetEmpty: Boolean;
begin
  Result := (Data = nil);
end;

function TCachedBufferMemory.GetFixed: Boolean;
begin
  Result := (PreviousSize = 0) or (AdditionalSize = 0);
end;

function TCachedBufferMemory.GetPreallocated: Boolean;
begin
  Result := (Handle = nil);
end;


{ TCachedBuffer }

class function TCachedBuffer.GetOptimalBufferSize(const AValue, ADefValue: NativeUInt;
  const ALimit: Int64): NativeUInt;
var
  LSize: NativeUInt;
begin
  if (AValue <> 0) then
  begin
    Result := AValue;
    if (ALimit > 0) and (Result > ALimit) then Result := ALimit;
    Exit;
  end;

  if (ALimit <= 0) or (ALimit >= (ADefValue * 4)) then
  begin
    Result := ADefValue;
    Exit;
  end;

  LSize := ALimit;
  LSize := LSize shr 2;
  if (LSize = 0) then
  begin
    Result := MEMORY_PAGE_SIZE;
  end else
  begin
    Result := (LSize + MEMORY_PAGE_SIZE - 1) and -MEMORY_PAGE_SIZE;
  end;
end;

class function TCachedBuffer.PreallocatedBufferSize(const AParam, AThreadBufferMemory: Pointer;
  const AThreadBufferMargin: NativeUInt): NativeInt;
var
  LParam: PCachedBufferPreallocatedParam;
  LAlign: NativeInt;
  LInstanceSize, LTotalSize: NativeUInt;
  LData: Pointer;
begin
  LParam := AParam;
  LAlign := NativeInt(LParam.DataAlign + Byte(LParam.DataAlign = 0));
  LInstanceSize := NativeUInt((NativeInt(PInteger(NativeInt(Self) + vmtInstanceSize)^) + (DEFAULT_MEMORY_ALIGN - 1)) and -DEFAULT_MEMORY_ALIGN);

  LData := Pointer((NativeInt(AThreadBufferMemory) + NativeInt(LInstanceSize + LParam.PreviousSize) + LAlign) and -LAlign);
  LTotalSize := NativeUInt(LData) - NativeUInt(AThreadBufferMemory) + LParam.DataSize + LParam.AdditionalSize;
  if (AThreadBufferMargin >= LTotalSize) then
  begin
    Result := -NativeInt(LTotalSize - LInstanceSize);
  end else
  begin
    Result := LParam.PreviousSize + LParam.DataSize + LParam.AdditionalSize + NativeUInt(LAlign - 1);
  end;
end;

constructor TCachedBuffer.PreallocatedCreate(const AParam: Pointer;
  const ABuffer: Pointer; const ASize: NativeUInt);
var
  LParam: PCachedBufferPreallocatedParam;
  LAlign, LAdditionalSize: NativeInt;
  LData: Pointer;
begin
  LParam := AParam;
  LAlign := NativeInt(LParam.DataAlign + Byte(LParam.DataAlign = 0));

  LData := Pointer((NativeInt(ABuffer) + NativeInt(LParam.PreviousSize) + LAlign - 1) and -LAlign);
  LAdditionalSize := NativeInt(ABuffer) + NativeInt(ASize) - NativeInt(LData) - NativeInt(LParam.DataSize);
  if (LAdditionalSize < NativeInt(LParam.AdditionalSize)) then
  begin
    raise ECachedBuffer.Create('Invalid memory preallocation');
  end;

  FMemory.Data := LData;
  FMemory.PreviousSize := NativeUInt(LData) - NativeUInt(ABuffer);
  FMemory.Size := LParam.DataSize;
  FMemory.Additional := Pointer(NativeUInt(LData) + LParam.DataSize);
  FMemory.AdditionalSize := NativeUInt(LAdditionalSize);
end;

constructor TCachedBuffer.Create(const AKind: TCachedBufferKind;
  const ACallback: TCachedBufferCallback; const ABufferSize: NativeUInt);
var
  LSize: NativeUInt;
begin
  inherited Create;
  FKind := AKind;
  FCallback := ACallback;
  if (not Assigned(FCallback)) then
    raise ECachedBuffer.Create('Flush callback not defined');

  if (FMemory.Empty) then
  begin
    LSize := ABufferSize;
    if (LSize <> 0) and (AKind = cbWriter) and (LSize <= MEMORY_PAGE_SIZE) then
      Inc(LSize, MEMORY_PAGE_SIZE);
    FMemory := AllocateCachedBufferMemory(Ord(AKind = cbReader){4kb}, LSize);
  end;

  FOverflow := FMemory.Additional;
  if (AKind = cbWriter) then
  begin
    Current := FMemory.Data;
    FHighWritten := Current;
  end else
  begin
    Current := FOverflow;
    FPositionBase := -Int64(FMemory.Size);
  end;
  FStart := Current;
end;

procedure TCachedBuffer.AfterConstruction;
begin
  inherited;
  DoProgress;
end;

procedure TCachedBuffer.BeforeDestruction;
begin
  if (Kind = cbWriter) and (not FEOF) and (Assigned(FCallback)) then
    Flush;

  inherited;
end;

destructor TCachedBuffer.Destroy;
begin
  if (not FMemory.Preallocated) then
    FreeMem(FMemory.Handle);

  inherited;
end;

procedure TCachedBuffer.SetEOF(const AValue{True}: Boolean);
begin
  if (FEOF = AValue) then Exit;
  if (not AValue) then
    raise ECachedBuffer.Create('Can''t turn off EOF flag');

  FEOF := True;
  FFinishing := False;
  FLimited := True;
  FLimit := Self.Position;
  FStart := Current;
  FOverflow := Current;
end;

function TCachedBuffer.DoProgress: Boolean;
var
  LCancel: Boolean;
begin
  if (Assigned(FOnProgress)) then
  begin
    LCancel := FEOF;
    FOnProgress(Self, LCancel);

    if (LCancel) then
      SetEOF(True);
  end;

  Result := (not FEOF);
end;

function TCachedBuffer.GetMargin: NativeInt;
var
  P: NativeInt;
begin
  // Result := NativeInt(FOverflow) - NativeInt(Current);
  P := NativeInt(Current);
  Result := NativeInt(FOverflow);
  Dec(Result, P);
end;

function TCachedBuffer.GetPosition: Int64;
begin
  Result := FPositionBase + (NativeInt(Current) - NativeInt(FMemory.Data));
end;

function TCachedBuffer.CheckLimit(const AValue: Int64): Boolean;
begin
  Result := True;
end;

procedure TCachedBuffer.SetLimit(const AValue: Int64);
var
  LPosition, LMarginLimit: Int64;
  LMargin: NativeInt;
begin
  if (FLimited) and (AValue = FLimit) then Exit;

  // check limit value
  LPosition := Self.Position;
  if (FEOF) or (AValue < 0) or (LPosition > AValue) or
     ({IsReader and} FFinishing and (AValue > (LPosition + Self.Margin))) or
     (not CheckLimit(AValue)) then
    RaiseLimitValue(AValue);

  // fill parameters
  FLimited := True;
  FLimit := AValue;

  // detect margin limit is too small
  LMarginLimit := AValue - LPosition;
  LMargin := Self.Margin;
  if (LMarginLimit <= LMargin) then
  begin
    // correct Margin to MarginLimit value
    Dec(FOverflow, LMargin - NativeInt(LMarginLimit));

    // Finishing & EOF
    if (Kind = cbReader) then
    begin
      FFinishing := True;

      if (Current = FOverflow) then
      begin
        SetEOF({EOF := }True);
        DoProgress;
      end;
    end;
  end;
end;

function TCachedBuffer.Flush: NativeUInt;
var
  LDone: Boolean;
begin
  LDone := False;
  try
    Result := DoFlush;
    LDone := True;
  finally
    if (not LDone) then
    begin
      SetEOF({EOF := }True);
    end;
  end;
end;

function TCachedBuffer.DoFlush: NativeUInt;
var
  LCurrent, LOverflow, LMemoryLow, LMemoryHigh: NativeUInt;
  LNewPositionBase: Int64;
  LNewEOF: Boolean;
begin
  // out of range test
  LCurrent := NativeUInt(Current);
  LOverflow := NativeUInt(FOverflow);
  LMemoryLow := NativeUInt(FStart);
  LMemoryHigh := NativeUInt(FMemory.Additional) + FMemory.AdditionalSize;
  if (LMemoryLow <= $ffff) or (LCurrent <= $ffff) or (LOverflow <= $ffff) or
     (LCurrent < LMemoryLow) or (LCurrent >= LMemoryHigh) or
     (LOverflow < LMemoryLow) or (LOverflow >= LMemoryHigh) then RaisePointers;

  // EOF
  if (FEOF) then
  begin
    if (Current <> FOverflow) then RaiseEOF;
    Result := 0;
    Exit;
  end;

  // valid data reading/writing
  if (Kind = cbWriter) then
  begin
    if (FLimited) and (FLimit < Self.Position) then
      RaiseWriting;
  end else
  begin
    if (LCurrent > LOverflow) then
      RaiseReading;
  end;

  // idle flush
  if {IsReader and} (FFinishing) then
  begin
    Result := (LOverflow - LCurrent);

    if (Result = 0) then
    begin
      SetEOF(True);
      DoProgress;
    end;

    Exit;
  end;

  // flush buffer
  LNewPositionBase := Self.Position;
  if (LCurrent > LOverflow) then LNewPositionBase := LNewPositionBase - Int64(LCurrent - LOverflow);
  LNewEOF := False;
  if (Kind = cbWriter) then
  begin
    if (DoWriterFlush) then
      LNewEOF := True;
  end else
  begin
    if (DoReaderFlush) then
    begin
      FFinishing := True;
      if (Current = FOverflow{Margin = 0}) then LNewEOF := True;
    end;
  end;
  FPositionBase := LNewPositionBase;
  if (LNewEOF) then SetEOF(True);
  DoProgress;

  // Result
  Result := Self.Margin;
end;

function TCachedBuffer.DoWriterFlush: Boolean;
var
  LFlushSize, R: NativeUInt;
  LOverflowSize: NativeUInt;
  LMargin: NativeInt;
  LMarginLimit: Int64;
begin
  // Current correction
  if (NativeUInt(FHighWritten) > NativeUInt(Current)) then
    Current := FHighWritten;

  // flush size
  LFlushSize := NativeUInt(Current) - NativeUInt(FMemory.Data);
  Result := (LFlushSize < FMemory.Size);
  LOverflowSize := 0;
  if (LFlushSize > FMemory.Size) then
  begin
    LOverflowSize := LFlushSize - FMemory.Size;
    LFlushSize := FMemory.Size;
  end;

  // detect margin limit
  LMarginLimit := High(Int64);
  if (FLimited) then LMarginLimit := FLimit - Position;

  // run callback
  if (LFlushSize <> 0) then
  begin
    R := FCallback(Self, FMemory.Data, LFlushSize);
    if (R <> LFlushSize) then RaiseWriting;
  end;

  // current
  Current := FMemory.Data;
  if (LOverflowSize <> 0) then
  begin
    TinyMove(FOverflow^, Current^, LOverflowSize);
    Inc(Current, LOverflowSize);
  end;
  FHighWritten := Current;

  // overflow correction
  if (FLimited) then
  begin
    LMargin := Self.Margin;
    if (LMarginLimit < LMargin) then
      Dec(FOverflow, LMargin - NativeInt(LMarginLimit));
  end;
end;

function TCachedBuffer.DoReaderFlush: Boolean;
var
  LMargin: NativeUInt;
  LOldMemory, LNewMemory: TCachedBufferMemory;
  LMarginLimit: Int64;
  LFlushSize, R: NativeUInt;
begin
  LMargin := Self.Margin;

  // move margin data to previous memory
  if (LMargin > 0) then
  begin
    if (LMargin > FMemory.PreviousSize) then
    begin
      LOldMemory := FMemory;
      LNewMemory := AllocateCachedBufferMemory(LMargin, FMemory.Size);
      try
        TinyMove(Current^, Pointer(NativeUInt(LNewMemory.Data) - LMargin)^, LMargin);
        FMemory := LNewMemory;
      finally
        if (not LOldMemory.Preallocated) then
          FreeMem(LOldMemory.Handle);
      end;
    end else
    begin
      TinyMove(Current^, Pointer(NativeUInt(FMemory.Data) - LMargin)^, LMargin);
    end;
  end;

  // flush size
  LFlushSize := FMemory.Size;
  Result := False;
  if (FLimited) then
  begin
    LMarginLimit := FLimit - Position;
    if (LMarginLimit <= LFlushSize) then
    begin
      LFlushSize := LMarginLimit;
      Result := True;
    end;
  end;

  // run callback
  if (LFlushSize = 0) then
  begin
    R := LFlushSize{0};
  end else
  begin
    R := FCallback(Self, FMemory.Data, LFlushSize);
    if (R > LFlushSize) then RaiseReading;
    if (R < LFlushSize) then Result := True;
  end;

  // current/overflow
  FStart := Pointer(NativeUInt(FMemory.Data) - LMargin);
  Current := FStart;
  FOverflow := Pointer(NativeUInt(FMemory.Data) + R);
end;

procedure TCachedWriter.Write(const ABuffer; const ACount: NativeUInt);
{$ifNdef CPUINTELASM}
var
  P: PByte;
begin
  P := Current;
  Inc(P, ACount);

  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
  begin
    OverflowWrite(ABuffer, ACount);
  end else
  begin
    Current := P;
    Dec(P, ACount);
    TinyMove(ABuffer, P^, ACount);
  end;
end;
{$else .CPUX86 or .CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef CPUX86}
    xchg eax, ebx
    push eax
    mov eax, ecx
    add eax, [EBX].TCachedReader.Current
    cmp eax, [EBX].TCachedReader.FOverflow
    ja @Difficult

    mov [EBX].TCachedReader.Current, eax
    sub eax, ecx
    xchg eax, edx
    pop ebx
    jmp TinyMove
  {$else .CPUX64}
    mov rax, rcx
    mov rcx, r8
    add rcx, [RAX].TCachedReader.Current
    cmp rcx, [RAX].TCachedReader.FOverflow
    ja @Difficult

    mov [RAX].TCachedReader.Current, rcx
    sub rcx, r8
    xchg rcx, rdx
    jmp TinyMove
  {$endif}

@Difficult:
  {$ifdef CPUX86}
    xchg eax, ebx
    pop ebx
  {$else .CPUX64}
    xchg rax, rcx
  {$endif}
  jmp OverflowWrite
end;
{$endif}

procedure TCachedReader.Read(var ABuffer; const ACount: NativeUInt);
{$ifNdef CPUINTELASM}
var
  P: PByte;
begin
  P := Current;
  Inc(P, ACount);

  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
  begin
    OverflowRead(ABuffer, ACount);
  end else
  begin
    Current := P;
    Dec(P, ACount);
    TinyMove(P^, ABuffer, ACount);
  end;
end;
{$else .CPUX86 or .CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef CPUX86}
    xchg eax, ebx
    push eax
    mov eax, ecx
    add eax, [EBX].TCachedReader.Current
    cmp eax, [EBX].TCachedReader.FOverflow
    ja @Difficult

    mov [EBX].TCachedReader.Current, eax
    sub eax, ecx
    pop ebx
    jmp TinyMove
  {$else .CPUX64}
    mov rax, rcx
    mov rcx, r8
    add rcx, [RAX].TCachedReader.Current
    cmp rcx, [RAX].TCachedReader.FOverflow
    ja @Difficult

    mov [RAX].TCachedReader.Current, rcx
    sub rcx, r8
    jmp TinyMove
  {$endif}

@Difficult:
  {$ifdef CPUX86}
    xchg eax, ebx
    pop ebx
  {$else .CPUX64}
    xchg rax, rcx
  {$endif}
  jmp OverflowRead
end;
{$endif}

function TCachedBuffer.InternalSeek(const AOffset: Int64; const AOrigin: Word): Int64;
const
  soFromBeginning = 0;
  soFromCurrent = 1;
var
  LOffset: Int64;
  LTemp: Int64;
  LCount: NativeUInt;
begin
  Result := Self.Position;
  LOffset := AOffset;

  if (AOrigin = soFromBeginning) then
  begin
    LTemp := LOffset;
    LOffset := LOffset - Result;
    Result := LTemp{from beginning Offset};
  end;
  if (AOrigin <= soFromCurrent) and (LOffset = 0) then
    Exit;

  if (Self.Kind = cbReader) and (AOrigin <= soFromCurrent) and (LOffset > 0) then
  begin
    while (LOffset <> 0) do
    begin
      LCount := LOffset;
      if (LCount > NativeUInt(High(NativeInt))) then LCount := NativeUInt(High(NativeInt));
      LOffset := LOffset - Int64(LCount);

      TCachedReader(Self).Skip(LCount);
    end;
  end else
  begin
    raise ECachedBuffer.Create('Invalid seek operation');
  end;
end;

{$if Defined(FPC)}
function TCachedBuffer.Read(pv: Pointer; cb: DWORD; pcbRead: PDWORD): HRESULT;
{$elseif not Defined(NEWISTREAM)}
function TCachedBuffer.Read(pv: Pointer; cb: Longint; pcbRead: PLongint): HResult;
{$else .NEWISTREAM}
function TCachedBuffer.Read(pv: Pointer; cb: FixedUInt; pcbRead: PFixedUInt): HResult;
{$ifend}
var
  LNumRead: Longint;
begin
  if (FKind = cbWriter) then
  begin
    Result := S_FALSE;
    Exit;
  end;

  try
    if (pv = nil) then
    begin
      Result := STG_E_INVALIDPOINTER;
      Exit;
    end;

    if (cb <= 0) then
    begin
      LNumRead := 0;
    end else
    begin
      LNumRead := cb;
      TCachedReader(Self).Read(pv^, LNumRead);
    end;

    if (pcbRead <> nil) then pcbRead^ := LNumRead;
    Result := S_OK;
  except
    Result := S_FALSE;
  end;
end;

{$if Defined(FPC)}
function TCachedBuffer.Write(pv: Pointer; cb: DWORD; pcbWritten: PDWORD): HRESULT;
{$elseif not Defined(NEWISTREAM)}
function TCachedBuffer.Write(pv: Pointer; cb: Longint; pcbWritten: PLongint): HResult;
{$else .NEWISTREAM}
function TCachedBuffer.Write(pv: Pointer; cb: FixedUInt; pcbWritten: PFixedUInt): HResult;
{$ifend}
var
  LNumWritten: Longint;
begin
  if (FKind = cbReader) then
  begin
    Result := STG_E_CANTSAVE;
    Exit;
  end;

  try
    if (pv = nil) then
    begin
      Result := STG_E_INVALIDPOINTER;
      Exit;
    end;

    if (cb <= 0) then
    begin
      LNumWritten := 0;
    end else
    begin
      LNumWritten := cb;
      TCachedWriter(Self).Write(pv^, LNumWritten);
    end;

    if (pcbWritten <> nil) then pcbWritten^ := LNumWritten;
    Result := S_OK;
  except
    Result := STG_E_CANTSAVE;
  end;
end;

{$if Defined(FPC)}
function TCachedBuffer.Seek(dlibMove: LargeUInt; dwOrigin: Longint; out libNewPosition: LargeUInt): HRESULT;
{$elseif not Defined(NEWISTREAM)}
function TCachedBuffer.Seek(dlibMove: Largeint; dwOrigin: Longint; out libNewPosition: Largeint): HResult;
{$else .NEWISTREAM}
function TCachedBuffer.Seek(dlibMove: Largeint; dwOrigin: DWORD; out libNewPosition: LargeUInt): HResult;
{$ifend}
var
  LNewPos: Largeint;
begin
  try
    if (Integer(dwOrigin) < STREAM_SEEK_SET) or (dwOrigin > STREAM_SEEK_END) then
    begin
      Result := STG_E_INVALIDFUNCTION;
      Exit;
    end;

    LNewPos := InternalSeek(dlibMove, dwOrigin);
    if (@libNewPosition <> nil) then libNewPosition := LNewPos;
    Result := S_OK;
  except
    Result := STG_E_INVALIDPOINTER;
  end;
end;

{$if Defined(FPC)}
function TCachedBuffer.SetSize(libNewSize: LargeUInt): HRESULT;
{$elseif not Defined(NEWISTREAM)}
function TCachedBuffer.SetSize(libNewSize: Largeint): HResult;
{$else .NEWISTREAM}
function TCachedBuffer.SetSize(libNewSize: LargeUInt): HResult;
{$ifend}
begin
  try
    Self.Limit := libNewSize;
    Result := S_OK;
  except
    Result := E_UNEXPECTED;
  end;
end;

{$if Defined(FPC)}
function TCachedBuffer.CopyTo(stm: IStream; cb: LargeUInt; out cbRead: LargeUInt; out cbWritten: LargeUInt): HRESULT;
{$elseif not Defined(NEWISTREAM)}
function TCachedBuffer.CopyTo(stm: IStream; cb: Largeint; out cbRead: Largeint; out cbWritten: Largeint): HResult;
{$else .NEWISTREAM}
function TCachedBuffer.CopyTo(stm: IStream; cb: LargeUInt; out cbRead: LargeUInt; out cbWritten: LargeUInt): HResult;
{$ifend}
var
  N: NativeInt;
  W: Longint;
  LBytesRead, LBytesWritten: Largeint;
begin
  if (Kind = cbWriter) then
  begin
    Result := E_UNEXPECTED;
    Exit;
  end;

  LBytesRead := 0;
  LBytesWritten := 0;
  try
    while (cb > 0) do
    begin
      N := Self.Margin;
      if (N <= 0) then
      begin
        if (TCachedReader(Self).Finishing) then
        begin
          Break;
        end else
        begin
          Self.Flush;
          N := Self.Margin;
          if (N <= 0) then Break;
        end;
      end;

      {$if SizeOf(NativeInt) > SizeOf(Longint)}
      if (N > High(Longint)) then N := High(Longint);
      {$ifend}
      if (N > cb) then N := cb;
      Inc(LBytesRead, N);

      W := 0;
      Result := stm.Write(Self.Current, N, Pointer(@W));
      Inc(LBytesWritten, W);
      if (Result = S_OK) and (W <> N) then Result := E_FAIL;
      if (Result <> S_OK) then Exit;

      Inc(NativeInt(Self.Current), N);
      Dec(cb, N);
    end;

    if (@cbWritten <> nil) then cbWritten := LBytesWritten;
    if (@cbRead <> nil) then cbRead := LBytesRead;
    Result := S_OK;
  except
    Result := E_UNEXPECTED;
  end;
end;

{$if Defined(FPC)}
function TCachedBuffer.Commit(grfCommitFlags: Longint): HRESULT;
{$elseif not Defined(NEWISTREAM)}
function TCachedBuffer.Commit(grfCommitFlags: Longint): HResult;
{$else .NEWISTREAM}
function TCachedBuffer.Commit(grfCommitFlags: DWORD): HResult;
{$ifend}
begin
  Result := S_OK;
end;

{$if Defined(FPC)}
function TCachedBuffer.Revert: HRESULT;
{$elseif not Defined(NEWISTREAM)}
function TCachedBuffer.Revert: HResult;
{$else .NEWISTREAM}
function TCachedBuffer.Revert: HResult;
{$ifend}
begin
  Result := STG_E_REVERTED;
end;

{$if Defined(FPC)}
function TCachedBuffer.LockRegion(libOffset: LargeUInt;cb: LargeUInt; dwLockType: Longint): HRESULT;
{$elseif not Defined(NEWISTREAM)}
function TCachedBuffer.LockRegion(libOffset: Largeint; cb: Largeint; dwLockType: Longint): HResult;
{$else .NEWISTREAM}
function TCachedBuffer.LockRegion(libOffset: LargeUInt; cb: LargeUInt; dwLockType: DWORD): HResult;
{$ifend}
begin
  Result := STG_E_INVALIDFUNCTION;
end;

{$if Defined(FPC)}
function TCachedBuffer.UnlockRegion(libOffset: LargeUInt; cb: LargeUInt; dwLockType: Longint): HRESULT;
{$elseif not Defined(NEWISTREAM)}
function TCachedBuffer.UnlockRegion(libOffset: Largeint; cb: Largeint; dwLockType: Longint): HResult;
{$else .NEWISTREAM}
function TCachedBuffer.UnlockRegion(libOffset: LargeUInt; cb: LargeUInt; dwLockType: DWORD): HResult;
{$ifend}
begin
  Result := STG_E_INVALIDFUNCTION;
end;

{$if Defined(FPC)}
function TCachedBuffer.Stat(out statstg: TStatStg; grfStatFlag: Longint): HRESULT;
{$elseif not Defined(NEWISTREAM)}
function TCachedBuffer.Stat(out statstg: TStatStg; grfStatFlag: Longint): HResult;
{$else .NEWISTREAM}
function TCachedBuffer.Stat(out statstg: TStatStg; grfStatFlag: DWORD): HResult;
{$ifend}
begin
  Result := E_NOTIMPL;
end;

{$if Defined(FPC)}
function TCachedBuffer.Clone(out stm: IStream): HRESULT;
{$elseif not Defined(NEWISTREAM)}
function TCachedBuffer.Clone(out stm: IStream): HResult;
{$else .NEWISTREAM}
function TCachedBuffer.Clone(out stm: IStream): HResult;
{$ifend}
begin
  Result := E_NOTIMPL;
end;


{ TCachedReader }

constructor TCachedReader.Create(const ACallback: TCachedBufferCallback;
  const ABufferSize: NativeUInt);
begin
  inherited Create(cbReader, ACallback, ABufferSize);
end;

procedure TCachedReader.DirectRead(const APosition: Int64; var ABuffer;
  const ACount: NativeUInt);
var
  LDone: Boolean;
  LPositionHigh: Int64;
  LCachedLow, LCachedHigh: Int64;
  LCachedOffset, LBufferOffset, LSize: NativeUInt;
  {$ifdef SMALLINT}
    LSize64: Int64;
  {$endif}
begin
  if (ACount = 0) then Exit;

  LPositionHigh := APosition + Int64(ACount);
  LDone := (not FEOF) and (APosition >= 0) and ((not Limited) or (Limit >= LPositionHigh));
  if (LDone) then
  begin
    LCachedLow := FPositionBase - (NativeInt(FMemory.Data) - NativeInt(FStart));
    LCachedHigh := FPositionBase + (NativeInt(FOverflow) - NativeInt(FMemory.Data));

    // cached data copy
    LCachedOffset := 0;
    LBufferOffset := 0;
    LSize := 0;
    if (APosition >= LCachedLow) and (APosition < LCachedHigh) then
    begin
      LCachedOffset := (APosition - LCachedLow);
      LSize := (LCachedHigh - APosition);
    end else
    if (LPositionHigh > LCachedLow) and (APosition < LCachedHigh) then
    begin
      LBufferOffset := (LCachedLow - APosition);
      LSize := (LPositionHigh - LCachedLow);
    end;
    if (LSize <> 0) then
    begin
      if (LSize > ACount) then LSize := ACount;
      TinyMove(Pointer(NativeUInt(FStart) + LCachedOffset)^,
               Pointer(NativeUInt(@ABuffer) + LBufferOffset)^,
               LSize);
    end;

    // before cached
    if (APosition < LCachedLow) then
    begin
      {$ifdef LARGEINT}
        LSize := (LCachedLow - APosition);
      {$else .SMALLINT}
        LSize64 := (LCachedLow - APosition);
        LSize := LSize64;
        if (LSize <> LSize64) then LSize := ACount;
      {$endif}
      if (LSize > ACount) then LSize := ACount;
      LDone := DoDirectPreviousRead(APosition, @ABuffer, LSize);
    end;

    // after cached
    if (LDone) and (LPositionHigh > LCachedHigh) then
    begin
      {$ifdef LARGEINT}
        LSize := (LPositionHigh - LCachedHigh);
      {$else .SMALLINT}
        LSize64 := (LPositionHigh - LCachedHigh);
        LSize := LSize64;
        if (LSize <> LSize64) then LSize := ACount;
      {$endif}
      if (LSize > ACount) then LSize := ACount;
      LDone := DoDirectFollowingRead(LPositionHigh - Int64(LSize),
                                    Pointer(NativeUInt(@ABuffer) + (ACount - LSize)),
                                    LSize);
    end;
  end;

  if (not LDone) then
    raise ECachedBuffer.Create('Direct read failure');
end;

function TCachedReader.DoDirectPreviousRead(APosition: Int64; AData: PByte;
  ASize: NativeUInt): Boolean;
begin
  Result := False;
end;

function TCachedReader.DoDirectFollowingRead(APosition: Int64; AData: PByte;
  ASize: NativeUInt): Boolean;
var
  LPreviousSize, LFilledSize, LAllocatingSize: NativeUInt;
  {$ifdef SMALLINT}
    LAllocatingSize64: Int64;
  {$endif}
  LRemovableMemory, LNewMemory: TCachedBufferMemory;
  LNewStart: Pointer;
  LFlushSize, R: NativeUInt;
  LMarginLimit: Int64;
begin
  Result := False;
  if (NativeUInt(FStart) > NativeUInt(FMemory.Data))  or
    (NativeUInt(Current) < NativeUInt(FStart)) then Exit;
  LPreviousSize := NativeUInt(FMemory.Data) - NativeUInt(FStart);
  LFilledSize := NativeUInt(FOverflow) - NativeUInt(FMemory.Data);

  {$ifdef LARGEINT}
    LAllocatingSize := NativeUInt(APosition - Self.FPositionBase) + ASize;
  {$else .SMALLINT}
    LAllocatingSize64 := (APosition - Self.FPositionBase) + ASize;
    LAllocatingSize := LAllocatingSize64;
    if (LAllocatingSize <> LAllocatingSize64) then Exit;
  {$endif}

  // allocate
  try
    LNewMemory := AllocateCachedBufferMemory(LPreviousSize or {4kb minimum}1, LAllocatingSize);
    Result := True;
  except
  end;
  if (not Result) then Exit;

  // copy data, change pointers
  LRemovableMemory := LNewMemory;
  try
    LNewStart := Pointer(NativeUInt(LNewMemory.Data) - LPreviousSize);
    TinyMove(FStart^, LNewStart^, LPreviousSize + LFilledSize);

    FStart := LNewStart;
    Current := Pointer(NativeInt(Current) - NativeInt(FMemory.Data) + NativeInt(LNewMemory.Data));
    FOverflow := Pointer(NativeUInt(LNewMemory.Data) + LFilledSize);

    LRemovableMemory := FMemory;
    FMemory := LNewMemory;
  finally
    if (not LRemovableMemory.Preallocated) then
      FreeMem(LRemovableMemory.Handle);
  end;

  // fill buffer
  LFlushSize := NativeUInt(FMemory.Additional) - NativeUInt(FOverflow);
  if (FLimited) then
  begin
    LMarginLimit := FLimit - (Self.FPositionBase + Int64(LFilledSize));
    if (LMarginLimit <= LFlushSize) then
    begin
      LFlushSize := LMarginLimit;
      FFinishing := True;
    end;
  end;
  R := FCallback(Self, FOverflow, LFlushSize);
  if (R > LFlushSize) then RaiseReading;
  if (R < LFlushSize) then FFinishing := True;
  Inc(FOverflow, R);
  if (APosition + Int64(ASize) > Self.FPositionBase + Int64(NativeUInt(FOverflow) - NativeUInt(Memory.Data))) then
  begin
    Result := False;
    Exit;
  end;

  // data read
  TinyMove(Pointer(NativeUInt(APosition - Self.FPositionBase) + NativeUInt(FMemory.Data))^,
    AData^, ASize);
end;

// Margin < Size
procedure TCachedReader.OverflowRead(var ABuffer; ASize: NativeUInt);
var
  S: NativeUInt;
  LData: PByte;
  LMargin: NativeUInt;
begin
  LData := Pointer(@ABuffer);

  // last time failure reading
  if (NativeUInt(Current) > NativeUInt(FOverflow)) then
    RaiseReading;

  // limit test
  if (FLimited) and (Self.Position + Int64(ASize) > FLimit) then
    RaiseReading;

  // read Margin
  if (Current <> FOverflow) then
  begin
    LMargin := Self.Margin;

    TinyMove(Current^, LData^, LMargin);
    Inc(LData, LMargin);
    Inc(Current, LMargin);
    Dec(ASize, LMargin);
  end;

  // if read data is too large, we can read data directly
  if (ASize >= FMemory.Size) then
  begin
    S := ASize - (ASize mod FMemory.Size);
    Dec(ASize, S);

    if (Assigned(FOnProgress)) then
    begin
      while (S <> 0) do
      begin
        if (FMemory.Size <> FCallback(Self, LData, FMemory.Size)) then
          RaiseReading;

        Dec(S, FMemory.Size);
        Inc(LData, FMemory.Size);
        Inc(FPositionBase, FMemory.Size);

        DoProgress;
        if (FEOF) and ((S <> 0) or (ASize <> 0)) then
          RaiseReading;
      end;
    end else
    begin
      if (S <> FCallback(Self, LData, S)) then
        RaiseReading;

      Inc(LData, S);
      Inc(FPositionBase, S);
    end;
  end;

  // last Data bytes
  if (ASize <> 0) then
  begin
    Flush;
    if (NativeUInt(Self.Margin) < ASize) then RaiseReading;

    TinyMove(Current^, LData^, ASize);
    Inc(Current, ASize);
  end;
end;

procedure TCachedReader.ReadData(var AValue: Boolean);
var
  P: ^Boolean;
begin
  P := Pointer(Current);
  Inc(P);
  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
  begin
    OverflowRead(AValue, SizeOf(AValue));
  end else
  begin
    Pointer(Current) := P;
    Dec(P);
    AValue := P^;
  end;
end;

{$ifdef ANSISTRSUPPORT}
procedure TCachedReader.ReadData(var AValue: AnsiChar);
var
  P: ^AnsiChar;
begin
  P := Pointer(Current);
  Inc(P);
  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
  begin
    OverflowRead(AValue, SizeOf(AValue));
  end else
  begin
    Pointer(Current) := P;
    Dec(P);
    AValue := P^;
  end;
end;
{$endif}

procedure TCachedReader.ReadData(var AValue: WideChar);
var
  P: ^WideChar;
begin
  P := Pointer(Current);
  Inc(P);
  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
  begin
    OverflowRead(AValue, SizeOf(AValue));
  end else
  begin
    Pointer(Current) := P;
    Dec(P);
    AValue := P^;
  end;
end;

procedure TCachedReader.ReadData(var AValue: ShortInt);
var
  P: ^ShortInt;
begin
  P := Pointer(Current);
  Inc(P);
  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
  begin
    OverflowRead(AValue, SizeOf(AValue));
  end else
  begin
    Pointer(Current) := P;
    Dec(P);
    AValue := P^;
  end;
end;

procedure TCachedReader.ReadData(var AValue: Byte);
var
  P: ^Byte;
begin
  P := Pointer(Current);
  Inc(P);
  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
  begin
    OverflowRead(AValue, SizeOf(AValue));
  end else
  begin
    Pointer(Current) := P;
    Dec(P);
    AValue := P^;
  end;
end;

procedure TCachedReader.ReadData(var AValue: SmallInt);
var
  P: ^SmallInt;
begin
  P := Pointer(Current);
  Inc(P);
  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
  begin
    OverflowRead(AValue, SizeOf(AValue));
  end else
  begin
    Pointer(Current) := P;
    Dec(P);
    AValue := P^;
  end;
end;

procedure TCachedReader.ReadData(var AValue: Word);
var
  P: ^Word;
begin
  P := Pointer(Current);
  Inc(P);
  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
  begin
    OverflowRead(AValue, SizeOf(AValue));
  end else
  begin
    Pointer(Current) := P;
    Dec(P);
    AValue := P^;
  end;
end;

procedure TCachedReader.ReadData(var AValue: Integer);
var
  P: ^Integer;
begin
  P := Pointer(Current);
  Inc(P);
  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
  begin
    OverflowRead(AValue, SizeOf(AValue));
  end else
  begin
    Pointer(Current) := P;
    Dec(P);
    AValue := P^;
  end;
end;

procedure TCachedReader.ReadData(var AValue: Cardinal);
var
  P: ^Cardinal;
begin
  P := Pointer(Current);
  Inc(P);
  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
  begin
    OverflowRead(AValue, SizeOf(AValue));
  end else
  begin
    Pointer(Current) := P;
    Dec(P);
    AValue := P^;
  end;
end;

procedure TCachedReader.ReadData(var AValue: Int64);
var
  P: ^Int64;
begin
  P := Pointer(Current);
  Inc(P);
  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
  begin
    OverflowRead(AValue, SizeOf(AValue));
  end else
  begin
    Pointer(Current) := P;
    Dec(P);
    AValue := P^;
  end;
end;

{$if Defined(FPC) or (CompilerVersion >= 16)}
procedure TCachedReader.ReadData(var AValue: UInt64);
var
  P: ^UInt64;
begin
  P := Pointer(Current);
  Inc(P);
  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
  begin
    OverflowRead(AValue, SizeOf(AValue));
  end else
  begin
    Pointer(Current) := P;
    Dec(P);
    AValue := P^;
  end;
end;
{$ifend}

procedure TCachedReader.ReadData(var AValue: Single);
var
  P: ^Single;
begin
  P := Pointer(Current);
  Inc(P);
  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
  begin
    OverflowRead(AValue, SizeOf(AValue));
  end else
  begin
    Pointer(Current) := P;
    Dec(P);
    AValue := P^;
  end;
end;

procedure TCachedReader.ReadData(var AValue: Double);
var
  P: ^Double;
begin
  P := Pointer(Current);
  Inc(P);
  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
  begin
    OverflowRead(AValue, SizeOf(AValue));
  end else
  begin
    Pointer(Current) := P;
    Dec(P);
    AValue := P^;
  end;
end;

{$if (not Defined(FPC)) or Defined(EXTENDEDSUPPORT)}
procedure TCachedReader.ReadData(var AValue: Extended);
var
  P: ^Extended;
begin
  P := Pointer(Current);
  Inc(P);
  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
  begin
    OverflowRead(AValue, SizeOf(AValue));
  end else
  begin
    Pointer(Current) := P;
    Dec(P);
    AValue := P^;
  end;
end;
{$ifend}

{$if not Defined(FPC) and (CompilerVersion >= 23)}
procedure TCachedReader.ReadData(var AValue: TExtended80Rec);
var
  P: ^TExtended80Rec;
begin
  P := Pointer(Current);
  Inc(P);
  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
  begin
    OverflowRead(AValue, SizeOf(AValue));
  end else
  begin
    Pointer(Current) := P;
    Dec(P);
    AValue := P^;
  end;
end;
{$ifend}

procedure TCachedReader.ReadData(var AValue: Currency);
var
  P: ^Currency;
begin
  P := Pointer(Current);
  Inc(P);
  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
  begin
    OverflowRead(AValue, SizeOf(AValue));
  end else
  begin
    Pointer(Current) := P;
    Dec(P);
    AValue := P^;
  end;
end;

procedure TCachedReader.ReadData(var AValue: TPoint);
var
  P: ^TPoint;
begin
  P := Pointer(Current);
  Inc(P);
  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
  begin
    OverflowRead(AValue, SizeOf(AValue));
  end else
  begin
    Pointer(Current) := P;
    Dec(P);
    AValue := P^;
  end;
end;

procedure TCachedReader.ReadData(var AValue: TRect);
var
  P: ^TRect;
begin
  P := Pointer(Current);
  Inc(P);
  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
  begin
    OverflowRead(AValue, SizeOf(AValue));
  end else
  begin
    Pointer(Current) := P;
    Dec(P);
    AValue := P^;
  end;
end;

{$ifdef SHORTSTRSUPPORT}
procedure TCachedReader.ReadData(var AValue: ShortString{; MaxLength: Byte});
var
  P: PByte;
  L, M, S: NativeInt;
begin
  P := Current;
  if (NativeUInt(P) >= NativeUInt(Self.Overflow)) then
  begin
    if (Flush < SizeOf(Byte)) then RaiseReading;
    P := Current;
  end;

  L := P^;
  Inc(P);
  Current := P;

  M := High(AValue);
  if (M < L) then
  begin
    PByte(@AValue)^ := M;
    S := L - M;
    Read(AValue[1], M);

    P := Current;
    Inc(P, S);
    Current := P;
    if (NativeUInt(P) >= NativeUInt(Self.Overflow)) then Flush;
  end else
  begin
    PByte(@AValue)^ := L;
    Read(AValue[1], L);
  end;
end;
{$endif}

{$ifdef ANSISTRSUPPORT}
procedure TCachedReader.ReadData(var AValue: AnsiString{$ifdef INTERNALCODEPAGE}; ACodePage: Word{$endif});
{$ifdef INTERNALCODEPAGE}
const
  ASTR_OFFSET_CODEPAGE = {$ifdef FPC}SizeOf(NativeInt) * 3{$else .DELPHI}12{$endif};
{$endif}
var
  L: Integer;
begin
  ReadData(L);
  SetLength(AValue, L);

  if (L <> 0) then
  begin
    {$ifdef INTERNALCODEPAGE}
    PWord(PAnsiChar(Pointer(AValue)) - ASTR_OFFSET_CODEPAGE)^ := ACodePage;
    {$endif}
    Read(Pointer(AValue)^, L);
  end;
end;
{$endif}

{$ifdef MSWINDOWS}
procedure TCachedReader.ReadData(var AValue: WideString);
var
  L: Integer;
begin
  ReadData(L);
  SetLength(AValue, L);
  if (L <> 0) then Read(Pointer(AValue)^, L*2);
end;
{$endif}

{$ifdef UNICODE}
procedure TCachedReader.ReadData(var AValue: UnicodeString);
var
  L: Integer;
begin
  ReadData(L);
  SetLength(AValue, L);
  if (L <> 0) then Read(Pointer(AValue)^, L*2);
end;
{$endif}

procedure TCachedReader.ReadData(var AValue: TBytes);
var
  L: Integer;
begin
  ReadData(L);
  SetLength(AValue, L);
  if (L <> 0) then Read(Pointer(AValue)^, L);
end;

procedure TCachedReader.ReadData(var AValue: Variant);
const
  varDeepData = $BFE8;
var
  LVarData: PVarData;
begin
  LVarData := @TVarData(AValue);
  if (LVarData.VType and varDeepData <> 0) then
  begin
    case LVarData.VType of
      {$ifdef ANSISTRSUPPORT}
      varString:
      begin
        AnsiString(LVarData.VString) := '';
        Exit;
      end;
      {$endif}
      {$ifdef WIDESTRSUPPORT}
      varOleStr:
      begin
        WideString(LVarData.VPointer{VOleStr}) := '';
        Exit;
      end;
      {$endif}
      {$ifdef UNICODE}
      varUString:
      begin
        UnicodeString(LVarData.VString) := '';
        Exit;
      end;
      {$endif}
    else
      {$if Defined(FPC) or (CompilerVersion >= 15)}
        if (Assigned(VarClearProc)) then
        begin
          VarClearProc(LVarData^);
        end else
        RaiseVaraintType(LVarData.VType);
      {$else}
        VarClear(Value);
      {$ifend}
    end;
  end;
  LVarData.VPointer := nil;

  ReadData(LVarData.VType);
  case LVarData.VType of
    varBoolean,
    varShortInt,
    varByte: ReadData(LVarData.VByte);

    varSmallInt,
    varWord: ReadData(LVarData.VWord);

    varInteger,
    varLongWord,
    varSingle: ReadData(LVarData.VInteger);

    varDouble,
    varCurrency,
    varDate,
    varInt64,
    $15{varUInt64}: ReadData(LVarData.VInt64);

    {$ifdef ANSISTRSUPPORT}
    varString:
    begin
      ReadData(AnsiString(LVarData.VPointer));
      Exit;
    end;
    {$endif}
    {$ifdef WIDESTRSUPPORT}
    varOleStr:
    begin
      ReadData(WideString(LVarData.VPointer));
      Exit;
    end;
    {$endif}
    {$ifdef UNICODE}
    varUString:
    begin
      ReadData(UnicodeString(LVarData.VPointer));
      Exit;
    end;
    {$endif}
  else
    RaiseVaraintType(LVarData.VType);
  end;
end;

procedure TCachedReader.Skip(const ACount: NativeUInt);
var
  P: PByte;
begin
  P := Current;
  Inc(P, ACount);
  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
  begin
    OverflowSkip(ACount);
  end else
  begin
    Current := P;
  end;
end;

procedure TCachedReader.OverflowSkip(ASize: NativeUInt);
var
  S: NativeUInt;
  LDone: Boolean;
begin
  LDone := False;
  if (not FEOF) and ((not FLimited) or (FLimit >= (Self.Position + Int64(ASize)))) then
  begin
    repeat
      S := NativeUInt(FOverflow) - NativeUInt(Current);
      if (S > ASize) then S := ASize;
      Current := FOverflow;
      Dec(ASize, S);
      if (ASize <> 0) then Flush;
    until (FEOF) or (ASize = 0);

    LDone := (ASize = 0);
  end;

  if (not LDone) then
    raise ECachedBuffer.Create('Cached reader skip failure');
end;

procedure TCachedReader.Export(const AWriter: TCachedWriter;
  const ACount: NativeUInt);
begin
  AWriter.Import(Self, ACount);
end;

{ TCachedWriter }

constructor TCachedWriter.Create(const ACallback: TCachedBufferCallback;
  const ABufferSize: NativeUInt);
begin
  inherited Create(cbWriter, ACallback, ABufferSize);
end;

procedure TCachedWriter.DirectWrite(const APosition: Int64; const ABuffer;
  const ACount: NativeUInt);
var
  LDone: Boolean;
  LPositionHigh: Int64;
  LCachedLow, LCachedHigh: Int64;
  LCachedOffset, LBufferOffset, LSize: NativeUInt;
  {$ifdef SMALLINT}
    LSize64: Int64;
  {$endif}
  LHighWritten: NativeUInt;
begin
  if (ACount = 0) then Exit;

  LPositionHigh := APosition + Int64(ACount);
  LDone := (not FEOF) and (APosition >= 0) and ((not Limited) or (Limit >= LPositionHigh));
  if (LDone) then
  begin
    LCachedLow := FPositionBase - (NativeInt(FMemory.Data) - NativeInt(FStart));
    LCachedHigh := FPositionBase + (NativeInt(FOverflow) - NativeInt(FMemory.Data));

    // cached data copy
    LCachedOffset := 0;
    LBufferOffset := 0;
    LSize := 0;
    if (APosition >= LCachedLow) and (APosition < LCachedHigh) then
    begin
      LCachedOffset := (APosition - LCachedLow);
      LSize := (LCachedHigh - APosition);
    end else
    if (LPositionHigh > LCachedLow) and (APosition < LCachedHigh) then
    begin
      LBufferOffset := (LCachedLow - APosition);
      LSize := (LPositionHigh - LCachedLow);
    end;
    if (LSize <> 0) then
    begin
      if (LSize > ACount) then LSize := ACount;
      TinyMove(Pointer(NativeUInt(@ABuffer) + LBufferOffset)^,
               Pointer(NativeUInt(FStart) + LCachedOffset)^,
               LSize);

      LHighWritten := NativeUInt(FStart) + LCachedOffset + LSize;
      if (LHighWritten > NativeUInt(Self.FHighWritten)) then Self.FHighWritten := Pointer(LHighWritten);
    end;

    // before cached
    if (APosition < LCachedLow) then
    begin
      {$ifdef LARGEINT}
        LSize := (LCachedLow - APosition);
      {$else .SMALLINT}
        LSize64 := (LCachedLow - APosition);
        LSize := LSize64;
        if (LSize <> LSize64) then LSize := ACount;
      {$endif}
      if (LSize > ACount) then LSize := ACount;
      LDone := DoDirectPreviousWrite(APosition, @ABuffer, LSize);
    end;

    // after cached
    if (LDone) and (LPositionHigh > LCachedHigh) then
    begin
      {$ifdef LARGEINT}
        LSize := (LPositionHigh - LCachedHigh);
      {$else .SMALLINT}
        LSize64 := (LPositionHigh - LCachedHigh);
        LSize := LSize64;
        if (LSize <> LSize64) then LSize := ACount;
      {$endif}
      if (LSize > ACount) then LSize := ACount;
      LDone := DoDirectFollowingWrite(LPositionHigh - Int64(LSize),
        Pointer(NativeUInt(@ABuffer) + (ACount - LSize)), LSize);
    end;
  end;

  if (not LDone) then
    raise ECachedBuffer.Create('Direct write failure');
end;

function TCachedWriter.DoDirectPreviousWrite(APosition: Int64; AData: PByte;
  ASize: NativeUInt): Boolean;
begin
  Result := False;
end;

function TCachedWriter.DoDirectFollowingWrite(APosition: Int64; AData: PByte;
  ASize: NativeUInt): Boolean;
var
  LPreviousSize, LFilledSize, LAllocatingSize: NativeUInt;
  {$ifdef SMALLINT}
    LAllocatingSize64: Int64;
  {$endif}
  LRemovableMemory, LNewMemory: TCachedBufferMemory;
begin
  Result := False;
  if (NativeUInt(Current) < NativeUInt(FMemory.Data)) then
  begin
    LPreviousSize := NativeUInt(FMemory.Data) - NativeUInt(Current);
    LFilledSize := 0;
  end else
  begin
    LPreviousSize := 0;
    LFilledSize := NativeUInt(Current) - NativeUInt(FMemory.Data);
  end;

  {$ifdef LARGEINT}
    LAllocatingSize := NativeUInt(APosition - Self.FPositionBase) + ASize;
  {$else .SMALLINT}
    LAllocatingSize64 := (APosition - Self.FPositionBase) + ASize;
    LAllocatingSize := LAllocatingSize64;
    if (LAllocatingSize <> LAllocatingSize64) then Exit;
  {$endif}

  // allocate
  try
    LNewMemory := AllocateCachedBufferMemory(LPreviousSize{default = 0}, LAllocatingSize);
    Result := True;
  except
  end;
  if (not Result) then Exit;

  // copy data, change pointers
  LRemovableMemory := LNewMemory;
  try
    TinyMove(Pointer(NativeUInt(FMemory.Data) - LPreviousSize)^,
      Pointer(NativeUInt(LNewMemory.Data) - LPreviousSize)^, LPreviousSize + LFilledSize);

    Current := Pointer(NativeInt(Current) - NativeInt(FMemory.Data) + NativeInt(LNewMemory.Data));
    FOverflow := LNewMemory.Additional;

    LRemovableMemory := FMemory;
    FMemory := LNewMemory;
  finally
    if (not LRemovableMemory.Preallocated) then
      FreeMem(LRemovableMemory.Handle);
  end;

  // data write
  FHighWritten := Pointer(NativeUInt(APosition - Self.FPositionBase) + NativeUInt(FMemory.Data));
  TinyMove(AData^, Pointer(NativeUInt(FHighWritten) - ASize)^, ASize);
end;

// Margin < Size
procedure TCachedWriter.OverflowWrite(const ABuffer; ASize: NativeUInt);
var
  S: NativeUInt;
  LData: PByte;
  LMargin: NativeInt;
begin
  LData := Pointer(@ABuffer);

  // limit test
  if (FLimited) and (Self.Position + Int64(ASize) > FLimit) then
    RaiseWriting;

  // write margin to buffer if used
  if (Current <> FMemory.Data) then
  begin
    if (NativeUInt(Current) < NativeUInt(FOverflow)) then
    begin
      LMargin := Self.Margin;
      TinyMove(LData^, Current^, LMargin);

      Current := Self.Overflow;
      Inc(LData, LMargin);
      Dec(ASize, LMargin);
    end;

    Flush();
  end;

  // if written data is too large, we can write data directly
  if (ASize >= FMemory.Size) then
  begin
    S := ASize - (ASize mod FMemory.Size);
    Dec(ASize, S);

    if (Assigned(FOnProgress)) then
    begin
      while (S <> 0) do
      begin
        if (FMemory.Size <> FCallback(Self, LData, FMemory.Size)) then
          RaiseWriting;

        Dec(S, FMemory.Size);
        Inc(LData, FMemory.Size);
        Inc(FPositionBase, FMemory.Size);

        DoProgress;
        if (FEOF) and ((S <> 0) or (ASize <> 0)) then
          RaiseWriting;
      end;
    end else
    begin
      if (S <> FCallback(Self, LData, S)) then
        RaiseWriting;

      Inc(LData, S);
      Inc(FPositionBase, S);
    end;
  end;

  // last Data bytes
  if (ASize <> 0) then
  begin
    TinyMove(LData^, Current^, ASize);
    Inc(Current, ASize);
  end;
end;

procedure TCachedWriter.WriteData(const AValue: Boolean);
var
  P: ^Boolean;
begin
  P := Pointer(Current);
  P^ := AValue;
  Inc(P);
  Pointer(Current) := P;
  if (NativeUInt(P) >= NativeUInt(Self.FOverflow)) then Flush;
end;

{$ifdef ANSISTRSUPPORT}
procedure TCachedWriter.WriteData(const AValue: AnsiChar);
var
  P: ^AnsiChar;
begin
  P := Pointer(Current);
  P^ := AValue;
  Inc(P);
  Pointer(Current) := P;
  if (NativeUInt(P) >= NativeUInt(Self.FOverflow)) then Flush;
end;
{$endif}

procedure TCachedWriter.WriteData(const AValue: WideChar);
var
  P: ^WideChar;
begin
  P := Pointer(Current);
  P^ := AValue;
  Inc(P);
  Pointer(Current) := P;
  if (NativeUInt(P) >= NativeUInt(Self.FOverflow)) then Flush;
end;

procedure TCachedWriter.WriteData(const AValue: ShortInt);
var
  P: ^ShortInt;
begin
  P := Pointer(Current);
  P^ := AValue;
  Inc(P);
  Pointer(Current) := P;
  if (NativeUInt(P) >= NativeUInt(Self.FOverflow)) then Flush;
end;

procedure TCachedWriter.WriteData(const AValue: Byte);
var
  P: ^Byte;
begin
  P := Pointer(Current);
  P^ := AValue;
  Inc(P);
  Pointer(Current) := P;
  if (NativeUInt(P) >= NativeUInt(Self.FOverflow)) then Flush;
end;

procedure TCachedWriter.WriteData(const AValue: SmallInt);
var
  P: ^SmallInt;
begin
  P := Pointer(Current);
  P^ := AValue;
  Inc(P);
  Pointer(Current) := P;
  if (NativeUInt(P) >= NativeUInt(Self.FOverflow)) then Flush;
end;

procedure TCachedWriter.WriteData(const AValue: Word);
var
  P: ^Word;
begin
  P := Pointer(Current);
  P^ := AValue;
  Inc(P);
  Pointer(Current) := P;
  if (NativeUInt(P) >= NativeUInt(Self.FOverflow)) then Flush;
end;

procedure TCachedWriter.WriteData(const AValue: Integer);
var
  P: ^Integer;
begin
  P := Pointer(Current);
  P^ := AValue;
  Inc(P);
  Pointer(Current) := P;
  if (NativeUInt(P) >= NativeUInt(Self.FOverflow)) then Flush;
end;

procedure TCachedWriter.WriteData(const AValue: Cardinal);
var
  P: ^Cardinal;
begin
  P := Pointer(Current);
  P^ := AValue;
  Inc(P);
  Pointer(Current) := P;
  if (NativeUInt(P) >= NativeUInt(Self.FOverflow)) then Flush;
end;

procedure TCachedWriter.WriteData(const AValue: Int64);
var
  P: ^Int64;
begin
  P := Pointer(Current);
  P^ := AValue;
  Inc(P);
  Pointer(Current) := P;
  if (NativeUInt(P) >= NativeUInt(Self.FOverflow)) then Flush;
end;

{$if Defined(FPC) or (CompilerVersion >= 16)}
procedure TCachedWriter.WriteData(const AValue: UInt64);
var
  P: ^UInt64;
begin
  P := Pointer(Current);
  P^ := AValue;
  Inc(P);
  Pointer(Current) := P;
  if (NativeUInt(P) >= NativeUInt(Self.FOverflow)) then Flush;
end;
{$ifend}

procedure TCachedWriter.WriteData(const AValue: Single);
var
  P: ^Single;
begin
  P := Pointer(Current);
  P^ := AValue;
  Inc(P);
  Pointer(Current) := P;
  if (NativeUInt(P) >= NativeUInt(Self.FOverflow)) then Flush;
end;

procedure TCachedWriter.WriteData(const AValue: Double);
var
  P: ^Double;
begin
  P := Pointer(Current);
  P^ := AValue;
  Inc(P);
  Pointer(Current) := P;
  if (NativeUInt(P) >= NativeUInt(Self.FOverflow)) then Flush;
end;

{$if (not Defined(FPC)) or Defined(EXTENDEDSUPPORT)}
procedure TCachedWriter.WriteData(const AValue: Extended);
var
  P: ^Extended;
begin
  P := Pointer(Current);
  P^ := AValue;
  Inc(P);
  Pointer(Current) := P;
  if (NativeUInt(P) >= NativeUInt(Self.FOverflow)) then Flush;
end;
{$ifend}

{$if not Defined(FPC) and (CompilerVersion >= 23)}
procedure TCachedWriter.WriteData(const AValue: TExtended80Rec);
var
  P: ^TExtended80Rec;
begin
  P := Pointer(Current);
  P^ := AValue;
  Inc(P);
  Pointer(Current) := P;
  if (NativeUInt(P) >= NativeUInt(Self.FOverflow)) then Flush;
end;
{$ifend}

procedure TCachedWriter.WriteData(const AValue: Currency);
var
  P: ^Currency;
begin
  P := Pointer(Current);
  P^ := AValue;
  Inc(P);
  Pointer(Current) := P;
  if (NativeUInt(P) >= NativeUInt(Self.FOverflow)) then Flush;
end;

procedure TCachedWriter.WriteData(const AValue: TPoint);
var
  P: ^TPoint;
begin
  P := Pointer(Current);
  P^ := AValue;
  Inc(P);
  Pointer(Current) := P;
  if (NativeUInt(P) >= NativeUInt(Self.FOverflow)) then Flush;
end;

procedure TCachedWriter.WriteData(const AValue: TRect);
var
  P: ^TRect;
begin
  P := Pointer(Current);
  P^ := AValue;
  Inc(P);
  Pointer(Current) := P;
  if (NativeUInt(P) >= NativeUInt(Self.FOverflow)) then Flush;
end;

{$ifdef SHORTSTRSUPPORT}
procedure TCachedWriter.WriteData(const AValue: ShortString);
begin
  Write(AValue, Length(AValue) + 1);
end;
{$endif}

{$ifdef ANSISTRSUPPORT}
procedure TCachedWriter.WriteData(const AValue: AnsiString);
var
  P: PInteger;
begin
  P := Pointer(AValue);
  if (P = nil) then
  begin
    WriteData(Integer(0));
  end else
  begin
    {$if Defined(FPC) and Defined(LARGEINT)}
      Dec(NativeInt(P), SizeOf(NativeInt));
      WriteData(P^);
      Write(Pointer(PAnsiChar(P) + SizeOf(NativeInt))^, P^);
    {$else}
      Dec(P);
      Write(P^, P^ + SizeOf(Integer));
    {$ifend}
  end;
end;
{$endif}

{$ifdef MSWINDOWS}
procedure TCachedWriter.WriteData(const AValue: WideString);
var
  P: PInteger;
begin
  P := Pointer(AValue);
  if (P = nil) then
  begin
    WriteData(Integer(0));
  end else
  begin
    Dec(P);
    WriteData(P^ shr 1);
    Write(Pointer(PAnsiChar(P) + SizeOf(Integer))^, P^);
  end;
end;
{$endif}

{$ifdef UNICODE}
procedure TCachedWriter.WriteData(const AValue: UnicodeString);
var
  P: PInteger;
begin
  P := Pointer(AValue);
  if (P = nil) then
  begin
    WriteData(Integer(0));
  end else
  begin
    {$if Defined(FPC) and Defined(LARGEINT)}
      Dec(NativeInt(P), SizeOf(NativeInt));
      WriteData(P^);
      Write(Pointer(PAnsiChar(P) + SizeOf(NativeInt))^, P^ shl 1);
    {$else}
      Dec(P);
      Write(P^, P^ shl 1 + SizeOf(Integer));
    {$ifend}
  end;
end;
{$endif}

procedure TCachedWriter.WriteData(const AValue: TBytes);
var
  P: PNativeInt;
  {$if Defined(FPC) and Defined(LARGEINT)}
  L: Integer;
  {$ifend}
begin
  P := Pointer(AValue);
  if (P = nil) then
  begin
    WriteData(Integer(0));
  end else
  begin
    Dec(P);
    {$if Defined(FPC) and Defined(LARGEINT)}
      L := P^ {$ifdef FPC}+ 1{$endif};
      Inc(P);
      WriteData(L);
      Write(P^, L);
    {$else}
      Write(P^, P^ + SizeOf(Integer));
    {$ifend}
  end;
end;

procedure TCachedWriter.WriteData(const AValue: Variant);
var
  VType: Word;
  VPtr: Pointer;
begin
  VType := TVarData(AValue).VType;
  VPtr := @TVarData(AValue).VByte;

  if (VType and varByRef <> 0) then
  begin
    VType := VType and (not varByRef);
    VPtr := PPointer(VPtr)^;
  end;

  WriteData(VType);
  case VType of
    varBoolean,
    varShortInt,
    varByte: WriteData(PByte(VPtr)^);

    varSmallInt,
    varWord: WriteData(PWord(VPtr)^);

    varInteger,
    varLongWord,
    varSingle: WriteData(PInteger(VPtr)^);

    varDouble,
    varCurrency,
    varDate,
    varInt64,
    $15{varUInt64}: WriteData(PInt64(VPtr)^);

    {$ifdef ANSISTRSUPPORT}
    varString:
    begin
      WriteData(PAnsiString(VPtr)^);
      Exit;
    end;
    {$endif}
    {$ifdef WIDESTRSUPPORT}
    varOleStr:
    begin
      WriteData(PWideString(VPtr)^);
      Exit;
    end;
    {$endif}
    {$ifdef UNICODE}
    varUString:
    begin
      WriteData(PUnicodeString(VPtr)^);
      Exit;
    end;
    {$endif}
  else
    RaiseVaraintType(VType);
  end;
end;

procedure TCachedWriter.Import(const AReader: TCachedReader;
  const ACount: NativeUInt);
var
  LSize, LReadLimit: NativeUInt;
begin
  LReadLimit := ACount;
  if (ACount = 0) then LReadLimit := High(NativeUInt);

  if (AReader <> nil) then
  while (not AReader.EOF) and (LReadLimit <> 0) do
  begin
    if (NativeUInt(AReader.Current) > NativeUInt(AReader.Overflow)) then Break;
    LSize := NativeUInt(AReader.Overflow) - NativeUInt(AReader.Current);
    if (LSize > LReadLimit) then LSize := LReadLimit;

    Self.Write(AReader.Current^, LSize);
    Inc(AReader.Current, LSize);
    Dec(LReadLimit, LSize);

    if (LReadLimit <> 0) then
      AReader.Flush;
  end;

  if (LReadLimit <> 0) and (ACount <> 0) then
    raise ECachedBuffer.Create('Cached writer import failure');
end;


{ TCachedReReader }

constructor TCachedReReader.Create(const ACallback: TCachedBufferCallback;
  const ASource: TCachedReader; const AOwner: Boolean;
  const ABufferSize: NativeUInt);
begin
  FSource := ASource;
  FOwner := AOwner;
  inherited Create(ACallback, GetOptimalBufferSize(ABufferSize, DEFAULT_CACHED_SIZE, ASource.Limit));
end;

destructor TCachedReReader.Destroy;
begin
  if (FOwner) then FSource.Free;
  inherited;
end;


{ TCachedReWriter }


constructor TCachedReWriter.Create(const ACallback: TCachedBufferCallback;
  const ATarget: TCachedWriter; const AOwner: Boolean;
  const ABufferSize: NativeUInt);
begin
  FTarget := ATarget;
  FOwner := AOwner;
  inherited Create(ACallback, GetOptimalBufferSize(ABufferSize, DEFAULT_CACHED_SIZE, ATarget.Limit));
end;

destructor TCachedReWriter.Destroy;
begin
  if (FOwner) then FTarget.Free;
  inherited;
end;


{ TCachedFileReader }

constructor TCachedFileReader.Create(const AFileName: string; const AOffset,
  ASize: Int64);
begin
  FFileName := AFileName;
  FHandleOwner := True;
  FOffset := AOffset;
  {$ifdef MSWINDOWS}
  FHandle := {$ifdef UNITSCOPENAMES}Winapi.{$endif}Windows.{$ifdef UNICODE}CreateFileW{$else}CreateFile{$endif}
    (PChar(AFileName), $0001{FILE_READ_DATA}, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_FLAG_SEQUENTIAL_SCAN, 0);
  {$else}
  FHandle := FileOpen(AFileName, fmOpenRead or fmShareDenyNone);
  {$endif}
  if (FHandle = INVALID_HANDLE_VALUE) then
    raise ECachedBuffer.CreateFmt('Cannot open file:'#13'%s', [AFileName]);

  InternalCreate(ASize, (AOffset = 0));
end;

constructor TCachedFileReader.CreateHandled(const AHandle: THandle;
  const ASize: Int64; const AHandleOwner: Boolean);
begin
  FHandle := AHandle;
  FHandleOwner := AHandleOwner;
  FOffset := FileSeek(FHandle, Int64(0), 1{soFromCurrent});
  if (FHandle = INVALID_HANDLE_VALUE) or (FOffset < 0) then
    raise ECachedBuffer.Create('Invalid file handle');

  InternalCreate(ASize, True);
end;

procedure TCachedFileReader.InternalCreate(const ASize: Int64; const ASeeked: Boolean);
var
  LFileSize: Int64;
begin
  LFileSize := GetFileSize(FHandle);

  if (FOffset < 0) or (FOffset > LFileSize) or
    ((not ASeeked) and (FOffset <> FileSeek(FHandle, FOffset, 0{soFromBeginning}))) then
    raise ECachedBuffer.CreateFmt('Invalid offset %d in %d bytes file'#13'%s',
      [FOffset, LFileSize, FFileName]);

  LFileSize := LFileSize - Offset;
  if (LFileSize = 0) then
  begin
    FKind := cbReader; // inherited Create;
    EOF := True;
  end else
  begin
    if (ASize > 0) and (ASize < LFileSize) then LFileSize := ASize;

    inherited Create(InternalCallback, GetOptimalBufferSize(0, DEFAULT_CACHED_SIZE, LFileSize));
    Limit := LFileSize;
  end;
end;

destructor TCachedFileReader.Destroy;
begin
  inherited;

  if (FHandleOwner) and (FHandle <> 0) and
    (FHandle <> INVALID_HANDLE_VALUE) then FileClose(FHandle);
end;

function TCachedFileReader.CheckLimit(const AValue: Int64): Boolean;
begin
  Result := (AValue <= (GetFileSize(FHandle) - FOffset));
end;

function TCachedFileReader.InternalCallback(const ASender: TCachedBuffer; AData: PByte;
  ASize: NativeUInt): NativeUInt;
var
  LCount, LReadingSize: Integer;
begin
  Result := 0;

  repeat
    if (ASize > NativeUInt(High(Integer))) then LReadingSize := High(Integer)
    else LReadingSize := ASize;

    LCount := FileRead(FHandle, AData^, LReadingSize);
    if (LCount < 0) then RaiseLastOSError;

    Inc(AData, LCount);
    Dec(ASize, LCount);
    Inc(Result, LCount);
  until (LCount <> LReadingSize) or (ASize = 0);
end;

function TCachedFileReader.DoDirectPreviousRead(APosition: Int64; AData: PByte;
  ASize: NativeUInt): Boolean;
begin
  Result := DirectCachedFileMethod(Self, FHandle, FOffset, APosition, AData, ASize);
end;

function TCachedFileReader.DoDirectFollowingRead(APosition: Int64; AData: PByte;
  ASize: NativeUInt): Boolean;
begin
  Result := DirectCachedFileMethod(Self, FHandle, FOffset, APosition, AData, ASize);
end;


{ TCachedFileWriter }

constructor TCachedFileWriter.Create(const AFileName: string; const ASize: Int64);
var
  LHandle: THandle;
begin
  FFileName := AFileName;
  {$ifdef MSWINDOWS}
  LHandle := {$ifdef UNITSCOPENAMES}Winapi.{$endif}Windows.{$ifdef UNICODE}CreateFileW{$else}CreateFile{$endif}
    (PChar(AFileName), $0002{FILE_WRITE_DATA}, FILE_SHARE_READ, nil, CREATE_ALWAYS, 0, 0);
  {$else}
  LHandle := FileCreate(AFileName);
  {$endif}
  if (LHandle = INVALID_HANDLE_VALUE) then
    raise ECachedBuffer.CreateFmt('Cannot create file:'#13'%s', [AFileName]);

  CreateHandled(LHandle, ASize, True);
end;

constructor TCachedFileWriter.CreateHandled(const AHandle: THandle;
  const ASize: Int64; const AHandleOwner: Boolean);
begin
  FHandle := AHandle;
  FHandleOwner := AHandleOwner;
  FOffset := FileSeek(FHandle, Int64(0), 1{soFromCurrent});
  if (FHandle = INVALID_HANDLE_VALUE) or (FOffset < 0) then
    raise ECachedBuffer.Create('Invalid file handle');

  inherited Create(InternalCallback, GetOptimalBufferSize(0, DEFAULT_CACHED_SIZE, ASize));
  if (ASize > 0) then
    Limit := ASize;
end;

destructor TCachedFileWriter.Destroy;
begin
  inherited;

  if (FHandleOwner) and (FHandle <> 0) and
    (FHandle <> INVALID_HANDLE_VALUE) then FileClose(FHandle);
end;

function TCachedFileWriter.InternalCallback(const ASender: TCachedBuffer; AData: PByte;
  ASize: NativeUInt): NativeUInt;
var
  LCount, LWritingSize: Integer;
begin
  Result := 0;

  repeat
    if (ASize > NativeUInt(High(Integer))) then LWritingSize := High(Integer)
    else LWritingSize := ASize;

    LCount := FileWrite(FHandle, AData^, LWritingSize);
    if (LCount < 0) then RaiseLastOSError;

    Inc(AData, LCount);
    Dec(ASize, LCount);
    Inc(Result, LCount);
  until (LCount <> LWritingSize) or (ASize = 0);
end;

function TCachedFileWriter.DoDirectPreviousWrite(APosition: Int64; AData: PByte;
  ASize: NativeUInt): Boolean;
begin
  Result := DirectCachedFileMethod(Self, FHandle, FOffset, APosition, AData, ASize);
end;

function TCachedFileWriter.DoDirectFollowingWrite(APosition: Int64; AData: PByte;
  ASize: NativeUInt): Boolean;
begin
  Result := DirectCachedFileMethod(Self, FHandle, FOffset, APosition, AData, ASize);
end;


{ TCachedMemoryReader }

constructor TCachedMemoryReader.Create(const APtr: Pointer;
  const ASize: NativeUInt; const AFixed: Boolean);
begin
  FPtr := APtr;
  FSize := ASize;
  FPtrMargin := ASize;

  if (APtr = nil) or (ASize = 0) then
  begin
    FKind := cbReader; // inherited Create;
    EOF := True;
  end else
  if (AFixed) then
  begin
    FKind := cbReader;
    FCallback := FixedCallback;
    FMemory.Data := APtr;
    FMemory.Size := ASize;
    FMemory.Additional := Pointer(NativeUInt(APtr) + ASize);
    Current := APtr;
    FOverflow := FMemory.Additional;
    FStart := APtr;
    FFinishing := True;
    Limit := ASize;
  end else
  begin
    inherited Create(InternalCallback, GetOptimalBufferSize(0, DEFAULT_CACHED_SIZE, ASize));
    Limit := ASize;
  end;
end;

function TCachedMemoryReader.CheckLimit(const AValue: Int64): Boolean;
begin
  Result := (AValue <= Size);
end;

function TCachedMemoryReader.InternalCallback(const ASender: TCachedBuffer; AData: PByte;
  ASize: NativeUInt): NativeUInt;
begin
  Result := ASize;
  if (Result > FPtrMargin) then Result := FPtrMargin;

  TinyMove(Pointer(NativeUInt(FPtr) + Self.FSize - FPtrMargin)^, AData^, Result);
  Dec(FPtrMargin, Result);
end;

function TCachedMemoryReader.FixedCallback(const ASender: TCachedBuffer; AData: PByte;
  ASize: NativeUInt): NativeUInt;
begin
  RaiseReading;
  Result := 0;
end;


{ TCachedMemoryWriter }

constructor TCachedMemoryWriter.Create(const APtr: Pointer;
  const ASize: NativeUInt; const AFixed: Boolean);
begin
  FPtr := APtr;
  FSize := ASize;
  FPtrMargin := ASize;

  if (APtr = nil) or (ASize = 0) then
  begin
    FKind := cbWriter; // inherited Create;
    EOF := True;
  end else
  if (AFixed) then
  begin
    FKind := cbWriter;
    FCallback := FixedCallback;
    FMemory.Data := APtr;
    FMemory.Size := ASize;
    FMemory.Additional := Pointer(NativeUInt(APtr) + ASize);
    Current := APtr;
    FOverflow := FMemory.Additional;
    FHighWritten := Current;
    FStart := APtr;
    Limit := ASize;
  end else
  begin
    inherited Create(InternalCallback, GetOptimalBufferSize(0, DEFAULT_CACHED_SIZE, ASize));
    Limit := ASize;
  end;
end;

constructor TCachedMemoryWriter.CreateTemporary;
begin
  inherited Create(InternalTemporaryCallback);
end;

destructor TCachedMemoryWriter.Destroy;
begin
  inherited;
  if (FTemporary) then FreeMem(FPtr);
end;

function TCachedMemoryWriter.CheckLimit(const AValue: Int64): Boolean;
begin
  if (not FTemporary) then
  begin
    Result := (AValue <= Size);
  end else
  begin
    Result := True;
  end;
end;

function TCachedMemoryWriter.InternalCallback(const ASender: TCachedBuffer;
  AData: PByte; ASize: NativeUInt): NativeUInt;
begin
  Result := ASize;
  if (Result > FPtrMargin) then Result := FPtrMargin;

  TinyMove(AData^, Pointer(NativeUInt(FPtr) + Self.FSize - FPtrMargin)^, Result);
  Dec(FPtrMargin, Result);
end;

function TCachedMemoryWriter.InternalTemporaryCallback(const ASender: TCachedBuffer;
  AData: PByte; ASize: NativeUInt): NativeUInt;
var
  LNewPtrSize: NativeUInt;
begin
  if (ASize <> 0) then
  begin
    LNewPtrSize := Self.FSize + ASize;
    Self.FSize := LNewPtrSize;
    ReallocMem(FPtr, LNewPtrSize);

    TinyMove(AData^, Pointer(NativeUInt(FPtr) + LNewPtrSize - ASize)^, ASize);
  end;

  Result := ASize;
end;

function TCachedMemoryWriter.FixedCallback(const ASender: TCachedBuffer; AData: PByte;
  ASize: NativeUInt): NativeUInt;
begin
  Result := ASize;
end;


{ TCachedResourceReader }

{$ifdef FPC}
function FindResource(AModuleHandle: TFPResourceHMODULE; AResourceName, AResourceType: PChar): TFPResourceHandle;
{$ifdef MSWINDOWS}
begin
  Result := Windows.FindResourceW(AModuleHandle, AResourceName, AResourceType);
end;
{$else}
var
  LBufferString: string;
  LBufferName, LBufferType: UTF8String;
  LResourceName, LResourceType: PAnsiChar;
begin
  LResourceName := Pointer(AResourceName);
  if (NativeUInt(AResourceName) <= High(Word)) then
  begin
    LBufferString := AResourceName;
    LBufferName := UTF8String(LBufferString);
    LResourceName := PAnsiChar(LBufferName);
  end;

  LResourceType := Pointer(AResourceType);
  if (NativeUInt(AResourceType) <= High(Word)) then
  begin
    LBufferString := AResourceType;
    LBufferType := UTF8String(LBufferString);
    LResourceType := PAnsiChar(LBufferType);
  end;

  Result := System.FindResource(AModuleHandle, LResourceName, LResourceType);
end;
{$endif}
{$endif}

procedure TCachedResourceReader.InternalCreate(AInstance: THandle; AName,
  AResType: PChar; AFixed: Boolean);

  procedure RaiseNotFound;
  var
    V: NativeUInt;
    N, T: string;
  begin
    V := NativeUInt(AName);
    if (V <= High(Word)) then N := '#' + string(IntToStr(Integer(V)))
    else N := '"' + string(AName) + '"';

    V := NativeUInt(AResType);
    if (V <= High(Word)) then T := '#' + string(IntToStr(Integer(V)))
    else T := '"' + string(AResType) + '"';

    raise ECachedBuffer.CreateFmt('Resource %s (%s) not found', [N, T]);
  end;

var
  HResInfo: THandle;
begin
  HResInfo := FindResource(AInstance, AName, AResType);
  if (HResInfo = 0) then RaiseNotFound;
  HGlobal := LoadResource(AInstance, HResInfo);
  if (HGlobal = 0) then RaiseNotFound;
  inherited Create(LockResource(HGlobal), SizeOfResource(AInstance, HResInfo), AFixed);
end;

constructor TCachedResourceReader.Create(const AInstance: THandle;
  const AResName: string; const AResType: PChar; const AFixed: Boolean);
begin
  InternalCreate(AInstance, PChar(AResName), AResType, AFixed);
end;

constructor TCachedResourceReader.CreateFromID(const AInstance: THandle;
  const AResID: Word; const AResType: PChar; const AFixed: Boolean);
begin
  InternalCreate(AInstance, PChar(NativeUInt(AResID)), AResType, AFixed);
end;

destructor TCachedResourceReader.Destroy;
begin
  inherited;
  UnlockResource(HGlobal);
  FreeResource(HGlobal);
end;

end.
