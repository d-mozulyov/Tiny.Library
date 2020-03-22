(*
 * This software is distributed under BSD license.
 *
 * Copyright (c) 2006-2010 Iztok Kacin, Cromis (iztok.kacin@gmail.com).
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, this
 *   list of conditions and the following disclaimer in the documentation and/or
 *   other materials provided with the distribution.
 * - Neither the name of the Iztok Kacin nor the names of its contributors may be
 *   used to endorse or promote products derived from this software without specific
 *   prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * ==================================================================================
 * Common unit for Cromis library
 * ==================================================================================
 * 08/03/2010 (1.0.0)
 *   - Initial release
 *   - IAnyValue, TAnyValue implementations
 * ==================================================================================
 * 26/07/2010 (1.0.1)
 *   - Added avtDateTime
 * ==================================================================================
 * 15/08/2010 (1.0.2)
 *   - Added Items property to enable iteration over all values
 *   - Added Count property
 * ==================================================================================
 * 08/10/2010 (1.0.3)
 *   - Use generic list instead of interface list for newer compilers
 * ==================================================================================
 * 28/12/2010 (1.0.4)
 *   - Create new interface object for each assignment to avoid interface sharing
 * ==================================================================================
 * 13/06/2011 (1.0.5)
 *   - Added AnsiString support
 * ==================================================================================
 * 16/06/2011 (1.1.0)
 *   - TAnyValue detached from interfaces. Uses Variants as internal storage
 *   - AsPointer, AsVariant properties added to TAnyValue and IAnyValue
 * ==================================================================================
 * 17/06/2011 (1.1.1)
 *   - IAnyValue uses TAnyValue now internally
 * ==================================================================================
 * 21/06/2011 (1.2.0)
 *   - TAnyValue uses TVarRec for simple data types and Variants for complex ones
 * ==================================================================================
 * 23/06/2011 (1.3.0)
 *   - TAnyValue uses TVarRec for simple data types and array of byes for complex ones
 * ==================================================================================
 * 03/02/2013 (1.4.0)
 *   - Compiler defines to finetune speed vs memory consumption
 * ==================================================================================
 * 05/02/2013 (1.4.1)
 *   - Controlled type conversions
 *   - Redesigned defines to control memory consumption
 * ==================================================================================
 * 06/02/2013 (1.4.2)
 *   - Speed optimizations
 * ==================================================================================
 * 07/02/2013 (1.4.3)
 *   - Speed optimizations
 * ==================================================================================
 * 17/02/2013 (2.0.0)
 *   - Complete rewrite, smaller memory footprint, faster speed
 *   - Array, Variants and Exception support
 * ==================================================================================
 * 18/02/2013 (2.0.1)
 *   - TAnyArray implementation added
 *   - Array enumerator
 * ==================================================================================
 * 20/02/2013 (2.0.2)
 *   - TAnyArray gets streams support
 *   - More casts added for TAnyValue
 * ==================================================================================
 * 23/02/2013 (2.0.3)
 *   - TAnyValue gets name-value pairs support
 * ==================================================================================
 * 27/02/2013 (2.1.0)
 *   - TAnyArray uses sliced arrays for data structure
 *   - LoadFromStream / SaveToStream can now take callback procedure if needed
 * ==================================================================================
 * 10/03/2013 (2.2.0)
 *   - IAnyArray sliced array rewritten to be more efficient
 * ==================================================================================
 * 08/07/2013 (2.2.1)
 *   - Fixed bug in sorting algorithm
 *   - Additional CreateAnyArray overload
 * ==================================================================================
 * 12/09/2013 (2.3.0)
 *   - "AnyValue_HookingOn" and "AnyValue_HookingOff" defines added
 *   - Under x64 automatically swithces to safe mode. Manual control over hooking 
 * ==================================================================================
 * 17/12/2013 (2.3.1)
 *   - Support to get most data types as pointer
 * ==================================================================================
 * 08/01/2014 (2.3.1)
 *   - Removed inline from Equal functions
 * ==================================================================================
 * 22/02/2014 (2.4.0)
 *   - Extracted ValueList to its own unit Cromis.ValueList.pas
 * ==================================================================================
*)
unit Cromis.AnyValue;

interface

{$IFDEF CPUX64}
  {$IFNDEF AnyValue_HookingOn}
    {$DEFINE AnyValue_HookingOff}
  {$ENDIF}
{$ENDIF}

{$IFDEF AnyValue_HookingOn}
  {$UNDEF AnyValue_HookingOff}
{$ENDIF}

uses
  Windows, SysUtils, Classes, TypInfo, Variants, Math,

  // cromis units
  {$IFNDEF AnyValue_HookingOff}Cromis.Detours,{$ENDIF}Cromis.Unicode;

const
  atInteger       = 0;
  atBoolean       = 1;
  atChar          = 2;
  atExtended      = 3;
  atString        = 4;
  atPointer       = 5;
  atPChar         = 6;
  atObject        = 7;
  atClass         = 8;
  atWideChar      = 9;
  atPWideChar     = 10;
  atAnsiString    = 11;
  atCurrency      = 12;
  atVariant       = 13;
  atInterface     = 14;
  atWideString    = 15;
  atInt64         = 16;
  atUnicodeString = 17;
  atCardinal      = 18;
  atDouble        = 19;

const
  cDynArrayGrowthFactor = 1.6180339887498948482045868343656;
  cDefArraySliceSize = 5000;
  cMinSliceDataSize = 100;
  cSliceBufferMpl = 1.1;

type
  TValueType =
  (
    avtNone,
    avtBoolean,
    avtInteger,
    avtInt64,
    avtCardinal,
    avtFloat,
    avtString,
    avtObject,
    avtPointer,
    avtInterface,
    avtAnsiString,
    avtWideString,
    avtDateTime,
    avtDouble,
    avtArray,
    avtVariant,
    avtException,
    avtNamedValue
  );

  PValueData = ^TValueData;
  TValueData = record { do not pack this record; it is compiler-generated }
    case Byte of
      atCardinal:  (VCardinal: Cardinal);
      atInteger:   (VInteger: Integer);
      atBoolean:   (VBoolean: Boolean);
      atPointer:   (VPointer: Pointer);
      atObject:    (VObject: TObject);
      atInt64:     (VInt64: Int64);
      atDouble:    (VDouble: Double);
  end;

  // value data type depends on the SafeMode define
  TValueDataType = {$IFDEF AnyValue_HookingOff}TValueData{$ELSE}IInterface{$ENDIF};

  // predeclare the enumerators
  IAnyArrayEnumerator = Interface;
  IAnyArrayEnumerable = Interface;
  IAnyArrayEnumerate = Interface;

  // predeclare the array
  IAnyArray = Interface;

  // pointers to records
  PNamedValue = ^TNamedValue;
  PAnyValue = ^TAnyValue;

  TAnyValue = packed record
  private
    ValueData: TValueDataType;
    {$IFDEF AnyValue_HookingOff}
      IntfData : IInterface;
    {$ELSE}
      {$IFNDEF CPUX64}
        Padding : array [0..3] of Byte;
      {$ENDIF}
    {$ENDIF}
    ValueType: TValueType;
    function GetAsInt64: Int64; inline;
    function GetAsFloat: Extended; inline;
    function GetAsDouble: Double; inline;
    function GetAsString: string; inline;
    function GetAsObject: TObject; inline;
    function GetAsBoolean: Boolean; inline;
    function GetAsInteger: Integer; inline;
    function GetAsPointer: Pointer; inline;
    function GetAsVariant: Variant; inline;
    function GetAsCardinal: Cardinal; inline;
    function GetAsDateTime: TDateTime; inline;
    function GetAsException: Exception; inline;
    function GetAsInterface: IInterface; inline;
    function GetAsWideString: WideString; inline;
    function GetAsNamedValue: PNamedValue; inline;
    function GetAsArrayItem(const Idx: Integer): TAnyValue; overload;
    function GetAsArrayItem(const Name: string): TAnyValue; overload;
    // complex non inline getters
    function GetAsInt64WithCast: Int64;
    function GetAsFloatWithCast: Extended;
    function GetAsStringWithCast: string;
    function GetAsDoubleWithCast: Double;
    function GetAsObjectWithCast: TObject;
    function GetAsBooleanWithCast: Boolean;
    function GetAsIntegerWithCast: Integer;
    function GetAsPointerWithCast: Pointer;
    function GetAsVariantWithCast: Variant;
    function GetAsCardinalWithCast: Cardinal;
    function GetAsDateTimeWithCast: TDateTime;
    function GetAsExceptionWithCast: Exception;
    function GetAsInterfaceWithCast: IInterface;
    function GetAsWideStringWithCast: WideString;
   {$IFDEF UNICODE}
    function GetAsAnsiString: AnsiString; inline;
    function GetAsAnsiStringWithCast: AnsiString;
   {$ENDIF}
    procedure SetAsInt64(const Value: Int64); inline;
    procedure SetAsFloat(const Value: Extended); inline;
    procedure SetAsDouble(const Value: Double); inline;
    procedure SetAsString(const Value: string); inline;
    procedure SetAsObject(const Value: TObject); inline;
    procedure SetAsBoolean(const Value: Boolean); inline;
    procedure SetAsInteger(const Value: Integer); inline;
    procedure SetAsPointer(const Value: Pointer); inline;
    procedure SetAsVariant(const Value: Variant); inline;
    procedure SetAsCardinal(const Value: Cardinal); inline;
    procedure SetAsDateTime(const Value: TDateTime); inline;
    procedure SetAsException(const Value: Exception); inline;
    procedure SetAsInterface(const Value: IInterface); inline;
    procedure SetAsWideString(const Value: WideString); inline;
    procedure SetAsNamedValue(const Name: string; const Value: TAnyValue);
    procedure SetAsArrayItem(const Idx: Integer; const Value: TAnyValue); overload; inline;
    procedure SetAsArrayItem(const Name: string; const Value: TAnyValue); overload; inline;
   {$IFDEF UNICODE}
    procedure SetAsAnsiString(const Value: AnsiString); inline;
   {$ENDIF}
    class procedure RemoveWarnings; inline; static;
  public
    procedure Clear;
    function IsNil: Boolean; inline;
    function IsEmpty: Boolean; inline;
    function ValueSize: Integer; inline;
    function GetAsArray: IAnyArray; inline;
    function EnsureAsArray: IAnyArray;
    function GetValueType: TValueType; inline;
    function Enum: IAnyArrayEnumerate; inline;
    class function Null: TAnyValue; static; inline;
    procedure Assign(const Value: PAnyValue); inline;
    function Equal(const Value: TAnyValue): Boolean; overload;
    function Equal(const Value: PAnyValue): Boolean; overload;
    class operator Implicit(const Value: Int64): TAnyValue;
    class operator Implicit(const Value: Boolean): TAnyValue;
    class operator Implicit(const Value: Variant): TAnyValue;
    class operator Implicit(const Value: Cardinal): TAnyValue;
    class operator Implicit(const Value: Extended): TAnyValue;
    class operator Implicit(const Value: Double): TAnyValue;
    class operator Implicit(const Value: Integer): TAnyValue;
    class operator Implicit(const Value: string): TAnyValue;
    class operator Implicit(const Value: Exception): TAnyValue;
    class operator Implicit(const Value: IInterface): TAnyValue;
    class operator Implicit(const Value: WideString): TAnyValue;
   {$IFDEF UNICODE}
    class operator Implicit(const Value: AnsiString): TAnyValue;
   {$ENDIF}
    class operator Implicit(const Value: Pointer): TAnyValue;
    class operator Implicit(const Value: TObject): TAnyValue;
    class operator Implicit(const Value: TDateTime): TAnyValue;
    class operator Implicit(const Value: array of TAnyValue): TAnyValue;
    class operator Implicit(const Value: TAnyValue): Int64; inline;
    class operator Implicit(const Value: TAnyValue): Double; inline;
    class operator Implicit(const Value: TAnyValue): Variant; inline;
    class operator Implicit(const Value: TAnyValue): Cardinal; inline;
    class operator Implicit(const Value: TAnyValue): Extended; inline;
    class operator Implicit(const Value: TAnyValue): TObject; inline;
    class operator Implicit(const Value: TAnyValue): string; inline;
    class operator Implicit(const Value: TAnyValue): Integer; inline;
    class operator Implicit(const Value: TAnyValue): Exception; inline;
    class operator Implicit(const Value: TAnyValue): WideString; inline;
   {$IFDEF UNICODE}
    class operator Implicit(const Value: TAnyValue): AnsiString; inline;
   {$ENDIF}
    class operator Implicit(const Value: TAnyValue): Boolean; inline;
    class operator Implicit(const Value: TAnyValue): Pointer; inline;
    class operator Implicit(const Value: TAnyValue): TDateTime; inline;
    class operator Implicit(const Value: TAnyValue): IInterface; inline;
    property AsInt64: Int64 read GetAsInt64 write SetAsInt64;
    property AsFloat: Extended read GetAsFloat write SetAsFloat;
    property AsDouble: Double read GetAsDouble write SetAsDouble;
    property AsString: string read GetAsString write SetAsString;
    property AsObject: TObject read GetAsObject write SetAsObject;
    property AsBoolean: Boolean read GetAsBoolean write SetAsBoolean;
    property AsInteger: Integer read GetAsInteger write SetAsInteger;
    property AsPointer: Pointer read GetAsPointer write SetAsPointer;
    property AsVariant: Variant read GetAsVariant write SetAsVariant;
    property AsCardinal: Cardinal read GetAsCardinal write SetAsCardinal;
    property AsDateTime: TDateTime read GetAsDateTime write SetAsDateTime;
    property AsException: Exception read GetAsException write SetAsException;
    property AsInterface: IInterface read GetAsInterface write SetAsInterface;
    property AsWideString: WideString read GetAsWideString write SetAsWideString;
    property AsArrayItem[const Idx: Integer]: TAnyValue read GetAsArrayItem write SetAsArrayItem; default;
    property AsArrayItem[const Name: string]: TAnyValue read GetAsArrayItem write SetAsArrayItem; default;
   {$IFDEF UNICODE}
    property AsAnsiString: AnsiString read GetAsAnsiString write SetAsAnsiString;
   {$ENDIF}
  end;

  // declare the array of TAnyValue
  TArrayMode = (amSlicedArray, amDynamicArray);
  TAnyValues = array of TAnyValue;
  PArraySlice = ^TArraySlice;
  PAnyValues = ^TAnyValues;

  TAnyValuesLoadCallback = procedure(const Stream: TStream;
                                     const ValueType: TValueType;
                                     const Value: PAnyValue;
                                     var Handled: Boolean);
  TAnyValuesSaveCallback = procedure(const Stream: TStream;
                                     const Value: PAnyValue;
                                     var Handled: Boolean);
  TAnyValuesCompareCallback = function(Item1, Item2: PAnyValue): Integer;
{$IF CompilerVersion >= 20}
  TAnyValuesLoadFunc = reference to procedure(const Stream: TStream;
                                              const ValueType: TValueType;
                                              const Value: PAnyValue;
                                              var Handled: Boolean);
  TAnyValuesSaveFunc = reference to procedure(const Stream: TStream;
                                              const Value: PAnyValue;
                                              var Handled: Boolean);
  TAnyValuesCompareFunc = reference to function(Item1, Item2: PAnyValue): Integer;
{$IFEND}
  TAnyValuesLoadHandler = {$IF CompilerVersion >= 20}TAnyValuesLoadFunc{$ELSE}TAnyValuesLoadCallback{$IFEND};
  TAnyValuesSaveHandler = {$IF CompilerVersion >= 20}TAnyValuesSaveFunc{$ELSE}TAnyValuesSaveCallback{$IFEND};
  TAnyValuesCompare = {$IF CompilerVersion >= 20}TAnyValuesCompareFunc{$ELSE}TAnyValuesCompareCallback{$IFEND};

  TNamedValue = packed record
    Name: string;
    Value: TAnyValue;
  end;

  TArraySlice = record
    Last: Integer;
    Start: Integer;
    Index: Integer;
    Data: TAnyValues;
  end;

  // array of slices
  PSliceData = ^TSliceData;
  TSliceData = array of PArraySlice;

{$IFDEF AnyValue_HookingOff}
  IAnyValueStringData = interface
  ['{EEB17601-043D-4409-80A0-67C5133FB510}']
    function GetValue: string;
    procedure SetValue(const value: string);
    property Value: string read GetValue write SetValue;
  end; { IAnyValueStringData }

  TAnyValueStringData = class(TInterfacedObject, IAnyValueStringData)
  strict private
    FValue: string;
  public
    constructor Create(const Value: string);
    function GetValue: string;
    procedure SetValue(const Value: string);
    property Value: string read GetValue write SetValue;
  end; { TAnyValueStringData }

  IAnyValueWideStringData = interface
  ['{7368C7E5-FB8A-45B7-8FBB-D1C19287A0C9}']
    function GetValue: WideString;
    procedure SetValue(const value: WideString);
    property Value: WideString read GetValue write SetValue;
  end; { IAnyValueWideStringData }

  TAnyValueWideStringData = class(TInterfacedObject, IAnyValueWideStringData)
  strict private
    FValue: WideString;
  public
    constructor Create(const Value: WideString);
    function GetValue: WideString;
    procedure SetValue(const Value: WideString);
    property Value: WideString read GetValue write SetValue;
  end; { TAnyValueWideStringData }

{$IFDEF UNICODE}
  IAnyValueAnsiStringData = interface
  ['{DD94000B-0B09-460E-883D-1318974A7381}']
    function GetValue: AnsiString;
    procedure SetValue(const value: AnsiString);
    property Value: AnsiString read GetValue write SetValue;
  end; { IAnyValueAnsiStringData }

  TAnyValueAnsiStringData = class(TInterfacedObject, IAnyValueAnsiStringData)
  strict private
    FValue: AnsiString;
  public
    constructor Create(const Value: AnsiString);
    function GetValue: AnsiString;
    procedure SetValue(const Value: AnsiString);
    property Value: AnsiString read GetValue write SetValue;
  end; { TAnyValueAnsiStringData }
{$ENDIF}

  IAnyValueExtendedData = interface
  ['{AE431567-96EB-4BF6-BAF1-7F8DF9C73711}']
    function GetValue: Extended;
    procedure SetValue(const value: Extended);
    property Value: Extended read GetValue write SetValue;
  end; { IOmniExtendedData }

  TAnyValueExtendedData = class(TInterfacedObject, IAnyValueExtendedData)
  strict private
    FValue: Extended;
  public
    constructor Create(const Value: Extended);
    function GetValue: Extended;
    procedure SetValue(const Value: Extended);
    property Value: Extended read GetValue write SetValue;
  end; { TOmniExtendedData }

  IAnyValueVariantData = interface
  ['{C36013E8-ED17-4AB0-96F6-2B181D129D6B}']
    function GetValue: Variant;
    procedure SetValue(const Value: Variant);
    property Value: Variant read GetValue write SetValue;
  end; { IAnyValueVariantData }

  TAnyValueVariantData = class(TInterfacedObject, IAnyValueVariantData)
  strict private
    FValue: Variant;
  public
    constructor Create(const Value: Variant);
    function GetValue: Variant;
    procedure SetValue(const Value: Variant);
    property Value: Variant read GetValue write SetValue;
  end; { TAnyValueVariantData }

  IAnyValueNamedData = interface
  ['{5E97C74F-DB95-4E5B-B33D-5E9DDF72DBA6}']
    function GetValue: TNamedValue;
    function GetAsPNamedValue: PNamedValue;
    procedure SetValue(const Value: TNamedValue);
    property Value: TNamedValue read GetValue write SetValue;
  end; { IAnyValueVariantData }

  TAnyValueNamedData = class(TInterfacedObject, IAnyValueNamedData)
  strict private
    FValue: TNamedValue;
  public
    function GetValue: TNamedValue;
    function GetAsPNamedValue: PNamedValue;
    procedure SetValue(const Value: TNamedValue);
    property Value: TNamedValue read GetValue write SetValue;
  end; { TAnyValueNamedData }
{$ENDIF}

  IAnyArray = Interface(IInterface)
  ['{3E194356-2097-419F-A7A7-B388C2C404C1}']
    function GetCount: Integer;
    function GetValues: TAnyValues;
    function GetSliceSize: Integer;
    function GetArrayMode: TArrayMode;
    function GetSliceCount: Integer;
    function GetSliceBufferMpl: Double;
    function GetItem(const Idx: Integer): TAnyValue;
    procedure SetItem(const Idx: Integer; const Value: TAnyValue);
    procedure SetSliceBufferMpl(const Value: Double);
    procedure SetArrayMode(const Value: TArrayMode);
    procedure SetSliceCount(const Value: Integer);
    procedure SetSliceSize(const Value: Integer);
    procedure Grow;
    procedure Clear;
    procedure Reverse;
    function Pop: TAnyValue;
    function Shift: TAnyValue;
    function Clone: IAnyArray;
    function PushNull: PAnyValue;
    function RawData: PSliceData;
    procedure Assign(const AnyArray: IAnyArray);
    procedure SaveToStream(const Stream: TStream; const SaveCallback: TAnyValuesSaveCallback = nil); overload;
    procedure LoadFromStream(const Stream: TStream; const LoadCallback: TAnyValuesLoadCallback = nil); overload;
  {$IF CompilerVersion >= 20}
    procedure SaveToStream(const Stream: TStream; const SaveFunc: TAnyValuesSaveFunc); overload;
    procedure LoadFromStream(const Stream: TStream; const LoadFunc: TAnyValuesLoadFunc); overload;
  {$IFEND}
    procedure Exchange(const Index1, Index2: Integer);
    function Equal(const Value: IAnyArray): Boolean;
    procedure Push(const Value: TAnyValue); overload;
    procedure Push(const Value: array of TAnyValue); overload;
    procedure Push(const Value: string; const Delimiter: Char); overload;
    procedure Unshift(const Value: TAnyValue); overload;
    procedure Unshift(const Value: array of TAnyValue); overload;
    procedure Unshift(const Value: string; const Delimiter: Char); overload;
    procedure AddNamed(const Name: string; const Value: TAnyValue);
    procedure DeleteIndex(const Index: Integer); overload;
    procedure DeleteIndex(const Index: Integer; const Elements: Integer); overload;
    procedure DeleteValue(const Value: TAnyValue; const AllInstances: Boolean = True); overload;
    procedure DeleteValue(const Value: array of TAnyValue; const AllInstances: Boolean = True); overload;
    procedure Insert(const Index: Integer; const Value: string; const Delimiter: Char); overload;
    procedure Insert(const Index: Integer; const Value: array of TAnyValue); overload;
    procedure Insert(const Index: Integer; const Value: TAnyValue); overload;
    procedure Sort(const Compare: TAnyValuesCompareCallback); overload;
  {$IF CompilerVersion >= 20}
    procedure Sort(const Compare: TAnyValuesCompareFunc); overload;
  {$IFEND}
    function Last: TAnyValue;
    function First: TAnyValue;
    function Enum: IAnyArrayEnumerate;
    function RawItem(const Index: Integer): PAnyValue;
    function IndexOf(const Value: TAnyValue): Integer;
    function IndexOfNamed(const Name: string): Integer;
    function LastIndexOf(const Value: TAnyValue): Integer;
    function FindNamed(const Name: string): TAnyValue;
    function Contains(const Value: TAnyValue): Boolean;
    function GetAsString(const Delimiter: Char = ','): string;
    function Slice(Start: Integer; Stop: Integer = -1): IAnyArray;
    property Item[const Idx: Integer]: TAnyValue read GetItem write SetItem; default;
    property SliceBufferMpl: Double read GetSliceBufferMpl write SetSliceBufferMpl;
    property ArrayMode: TArrayMode read GetArrayMode write SetArrayMode;
    property SliceCount: Integer read GetSliceCount write SetSliceCount;
    property SliceSize: Integer read GetSliceSize write SetSliceSize;
    property Values: TAnyValues read GetValues;
    property Count: Integer read GetCount;
  end;

  IAnyArrayEnumerator = Interface(IInterface)
  ['{C87850CB-3FBB-45C5-967A-6FA389BCCBDC}']
    // getters and setters
    function _GetCurrent: PAnyValue;
    // iterator function and procedures
    function MoveNext: Boolean;
    property Current: PAnyValue read _GetCurrent;
  end;

  IAnyArrayEnumerable = Interface(IInterface)
  ['{3F2CB92A-847A-4692-B314-E3A9CEF66F4D}']
    function GetEnumerator: IAnyArrayEnumerator;
  end;

  IAnyArrayEnumerate = Interface(IInterface)
  ['{E3AFE3FC-6EED-40D5-831F-C1E90EB0404E}']
    function Forward: IAnyArrayEnumerable;
    function Reverse: IAnyArrayEnumerable;
  end;

  function CreateAnyArray(const Mode: TArrayMode; const Size: Integer = cDefArraySliceSize): IAnyArray; overload;
  function CreateAnyArray(const Values: string; const Delimiter: Char): IAnyArray; overload;
  function CreateAnyArray(const Values: array of TAnyValue): IAnyArray; overload;
  function CreateAnyArray(const Values: TAnyValues): IAnyArray; overload;
  function CreateAnyArray(const SliceSize: Integer): IAnyArray; overload;
  function CreateAnyArray(const Values: TAnyValue): IAnyArray; overload;
  function CreateAnyArray: IAnyArray; overload;

  // return the array of TAnyValue as PAnyValueArray pointer
  function NamedValue(const Name: string; const Value: TAnyValue): TNamedValue;
  function AnyValues(const Value: array of TAnyValue): TAnyValue;

  procedure CopyAnyValue(dest, source: PAnyValue);
  procedure FinalizeAnyValue(p : PAnyValue);

{$IFNDEF AnyValue_HookingOff}
  // direct access to hooking
  procedure InitializeHooks;
  procedure FinalizeHooks;
{$ENDIF}

implementation

type
  TAnyArray = class(TInterfacedOBject, IAnyArray)
  private
    FSumCount: Integer;
    FSliceSize: Integer;
    FArrayMode: TArrayMode;
    FSliceData: TSliceData;
    FSliceCount: Integer;
    FSliceBufferMpl: Double;
    function GetCount: Integer;
    function GetValues: TAnyValues;
    function GetSliceSize: Integer;
    function GetArrayMode: TArrayMode;
    function GetSliceCount: Integer;
    function GetSliceBufferMpl: Double;
    procedure SetSliceSize(const Value: Integer);
    procedure SetSliceCount(const Value: Integer);
    procedure SetArrayMode(const Value: TArrayMode);
    procedure SetSliceBufferMpl(const Value: Double);
    function GetItem(const Idx: Integer): TAnyValue; inline;
    procedure SetItem(const Idx: Integer; const Value: TAnyValue); inline;
    function GetSliceByIndex(const Index: Integer; var SliceIndex: Integer): PArraySlice; inline;
    function GetSliceByValue(const Value: TAnyValue; var SliceIndex: Integer): PArraySlice;
    function GetSliceByName(const Name: string; var SliceIndex: Integer): PArraySlice;
    procedure DoInitializeArray(const SliceSize: Integer = cDefArraySliceSize);
    procedure UpdateUpperSlices(const ItemSlice: PArraySlice; Delta: Integer);
    procedure RepositionSliceData(const ItemSlice: PArraySlice);
    procedure DoLoadFromStream(const Stream: TStream;
                               const UseHandler: Boolean;
                               const LoadCallback: TAnyValuesLoadHandler);
    procedure DoSaveToStream(const Stream: TStream;
                             const UseHandler: Boolean;
                             const SaveCallback: TAnyValuesSaveHandler);
    function ArrayIsInvalid: Boolean;
    function GetLastSlice: PArraySlice;
    procedure RestructureSlicedArray;
    procedure DoAcquireNewSlice;
  public
    constructor Create(const aMode: TArrayMode; const aSize: Integer = cDefArraySliceSize); overload;
    constructor Create(const Values: TAnyValues; const aLastPos: Integer); overload;
    constructor Create(const Values: string; const Delimiter: Char); overload;
    constructor Create(const Values: array of TAnyValue); overload;
    constructor Create(const Values: TAnyValues); overload;
    constructor Create(const SliceSize: Integer); overload;
    constructor Create(const Values: TAnyValue); overload;
    constructor Create; overload;
    destructor Destroy; override;
    procedure Grow; inline;
    procedure Clear;
    procedure Reverse;
    function Pop: TAnyValue;
    function Shift: TAnyValue;
    function Clone: IAnyArray;
    function PushNull: PAnyValue;
    function RawData: PSliceData;
    procedure Assign(const AnyArray: IAnyArray);
    procedure SaveToStream(const Stream: TStream; const SaveCallback: TAnyValuesSaveCallback = nil); overload;
    procedure LoadFromStream(const Stream: TStream; const LoadCallback: TAnyValuesLoadCallback = nil); overload;
  {$IF CompilerVersion >= 20}
    procedure SaveToStream(const Stream: TStream; const SaveFunc: TAnyValuesSaveFunc); overload;
    procedure LoadFromStream(const Stream: TStream; const LoadFunc: TAnyValuesLoadFunc); overload;
  {$IFEND}
    procedure Exchange(const Index1, Index2: Integer);
    function Equal(const Value: IAnyArray): Boolean;
    procedure Push(const Value: TAnyValue); overload;
    procedure Push(const Value: array of TAnyValue); overload;
    procedure Push(const Value: string; const Delimiter: Char); overload;
    procedure Unshift(const Value: TAnyValue); overload;
    procedure Unshift(const Value: array of TAnyValue); overload;
    procedure Unshift(const Value: string; const Delimiter: Char); overload;
    procedure AddNamed(const Name: string; const Value: TAnyValue);
    procedure DeleteIndex(const Index: Integer); overload;
    procedure DeleteIndex(const Index: Integer; const Elements: Integer); overload;
    procedure DeleteValue(const Value: TAnyValue; const AllInstances: Boolean = True); overload;
    procedure DeleteValue(const Value: array of TAnyValue; const AllInstances: Boolean = True); overload;
    procedure Insert(const Index: Integer; const Value: string; const Delimiter: Char); overload;
    procedure Insert(const Index: Integer; const Value: array of TAnyValue); overload;
    procedure Insert(const Index: Integer; const Value: TAnyValue); overload;
    procedure Sort(const Compare: TAnyValuesCompareCallback); overload;
  {$IF CompilerVersion >= 20}
    procedure Sort(const Compare: TAnyValuesCompareFunc); overload;
  {$IFEND}
    function Last: TAnyValue;
    function First: TAnyValue;
    function Enum: IAnyArrayEnumerate;
    function RawItem(const Index: Integer): PAnyValue;
    function IndexOf(const Value: TAnyValue): Integer;
    function IndexOfNamed(const Name: string): Integer;
    function LastIndexOf(const Value: TAnyValue): Integer;
    function FindNamed(const Name: string): TAnyValue;
    function Contains(const Value: TAnyValue): Boolean;
    function Slice(Start: Integer; Stop: Integer = -1): IAnyArray;
    function GetAsString(const Delimiter: Char = ','): string;
    property Item[const Idx: Integer]: TAnyValue read GetItem write SetItem; default;
    property SliceBufferMpl: Double read GetSliceBufferMpl write SetSliceBufferMpl;
    property ArrayMode: TArrayMode read GetArrayMode write SetArrayMode;
    property SliceCount: Integer read GetSliceCount write SetSliceCount;
    property SliceSize: Integer read GetSliceSize write SetSliceSize;
    property Values: TAnyValues read GetValues;
    property Count: Integer read GetCount;
  end;

  //**************************************************************************************//
  //******************** ENUMERATORS FOR THE VALUES AND POINTERS *************************//
  //**************************************************************************************//

  TAnyArrayForwardEnumerator = class(TInterfacedObject, IAnyArrayEnumerator)
  private
    FIndex: Integer;
    FSliceIdx: Integer;
    FSliceData: PSliceData;
    FSliceCount: Integer;
    function _GetCurrent: PAnyValue; inline;
  public
    constructor Create(const SliceData: PSliceData; const SliceCount: Integer);
    property Current: PAnyValue read _GetCurrent;
    function MoveNext: Boolean; inline;
  end;

  TAnyArrayReverseEnumerator = class(TInterfacedObject, IAnyArrayEnumerator)
  private
    FIndex: Integer;
    FSliceIdx: Integer;
    FSliceData: PSliceData;
    FSliceCount: Integer;
    function _GetCurrent: PAnyValue;
  public
    constructor Create(const SliceData: PSliceData; const SliceCount: Integer);
    property Current: PAnyValue read _GetCurrent;
    function MoveNext: Boolean; inline;
  end;

  TAnyArrayEnumerable = class(TInterfacedObject, IAnyArrayEnumerable)
  private
    FEnumerator: IAnyArrayEnumerator;
  public
    constructor Create(const Enumerator: IAnyArrayEnumerator);
    function GetEnumerator: IAnyArrayEnumerator;
  end;

  TAnyArrayEnumerate = class(TInterfacedObject, IAnyArrayEnumerate)
  private
    FSliceData: PSliceData;
    FSliceCount: Integer;
  public
    constructor Create(const SliceData: PSliceData; const SliceCount: Integer);
    function Forward: IAnyArrayEnumerable;
    function Reverse: IAnyArrayEnumerable;
  end;

  //**************************************************************************************//
  //**************************************************************************************//

{$IFNDEF AnyValue_HookingOff}
var
  IsHooked: Boolean;
  vValueInfo: PTypeInfo;
  // old address of System._FinalizeRecord
  OldCopyRecord: procedure(Dest, Source, TypeInfo: Pointer);
  OldAddRefRecord: procedure(p: Pointer; typeInfo: Pointer);
  OldFinalizeRecord: procedure(p: Pointer; typeInfo: Pointer);
  OldInitializeRecord: procedure(p: Pointer; typeInfo: Pointer);
{$ENDIF}

function CreateAnyArray(const Mode: TArrayMode; const Size: Integer): IAnyArray;
begin
  Result := TAnyArray.Create(Mode, Size);
end;

function CreateAnyArray(const Values: string; const Delimiter: Char): IAnyArray;
begin
  Result := TAnyArray.Create(Values, Delimiter);
end;

function CreateAnyArray(const Values: array of TAnyValue): IAnyArray;
begin
  Result := TAnyArray.Create(Values);
end;

function CreateAnyArray(const Values: TAnyValues): IAnyArray;
begin
  Result := TAnyArray.Create(Values);
end;

function CreateAnyArray(const Values: TAnyValue): IAnyArray;
begin
  Result := TAnyArray.Create(Values);
end;

function CreateAnyArray(const SliceSize: Integer): IAnyArray;
begin
  Result := TAnyArray.Create(SliceSize);
end;

function CreateAnyArray: IAnyArray;
begin
  Result := TAnyArray.Create;
end;

function AnyValues(const Value: array of TAnyValue): TAnyValue;
begin
  Result.EnsureAsArray.Push(Value);
end;

function NamedValue(const Name: string; const Value: TAnyValue): TNamedValue;
begin
  Result.Name := Name;
  Result.Value := Value;
end;

procedure SlicedQuickSort(Values: IAnyArray; L, R: Integer; SCompare: TAnyValuesCompare);
var
  I, J: Integer;
  T: TAnyValue;
  P: TAnyValue;
begin
  repeat
    I := L;
    J := R;
    CopyAnyValue(@P, Values.RawItem((L + R) shr 1));
    repeat
      while SCompare(Values.RawItem(I), @P) < 0 do
        Inc(I);
      while SCompare(Values.RawItem(J), @P) > 0 do
        Dec(J);
      if I <= J then
      begin
        if I <> J then
        begin
          CopyAnyValue(@T, Values.RawItem(I));
          CopyAnyValue(Values.RawItem(I), Values.RawItem(J));
          CopyAnyValue(Values.RawItem(J), @T);
        end;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then
      SlicedQuickSort(Values, L, J, SCompare);
    L := I;
  until I >= R;
end;

{ TAnyValue }

procedure TAnyValue.Assign(const Value: PAnyValue);
begin
  CopyAnyValue(@Self, Value);
end;

procedure TAnyValue.Clear;
begin
  FinalizeAnyValue(@Self);
end;

{$IFDEF UNICODE}
function TAnyValue.GetAsAnsiString: AnsiString;
begin
  if ValueType = avtAnsiString then
  {$IFDEF AnyValue_HookingOff}
    Result := (IntfData as IAnyValueAnsiStringData).Value
  {$ELSE}
    Result := AnsiString(PValueData(@ValueData).VPointer)
  {$ENDIF}
  else
    Result := GetAsAnsiStringWithCast;
end;

function TAnyValue.GetAsAnsiStringWithCast: AnsiString;
var
  Element: PAnyValue;
  NamedValue: PNamedValue;
begin
  case ValueType of
    avtNone: Result := '';
    avtInt64: Result := AnsiString(IntToStr(AsInt64));
    avtBoolean: Result := AnsiString(BoolToStr(AsBoolean, True));
    avtCardinal: Result := AnsiString(IntToStr(AsCardinal));
    avtInteger: Result := AnsiString(IntToStr(AsInteger));
    avtDouble: Result := AnsiString(FloatToStr(AsDouble));
    avtFloat: Result := AnsiString(FloatToStr(AsFloat));
    avtException: Result := AnsiString(IntToStr(AsInt64));
    avtVariant: Result := AnsiString(VarToStr(AsVariant));
    avtWideString: Result := AnsiString(AsWideString);
    avtDateTime: Result := AnsiString(DateTimeToStr(AsDateTime));
    avtPointer, avtObject, avtInterface: Result := AnsiString(IntToStr(AsInteger));
    avtString: Result := AnsiString(AsString);
    avtNamedValue:
      begin
        NamedValue := GetAsNamedValue;
        Result := AnsiString(Format('[%s,%s]', [NamedValue.Name, NamedValue.Value.AsString]));
      end;
    avtArray:
      begin
        Result := '[';

        for Element in GetAsArray.Enum.Forward do
        begin
          if Result <> '[' then
            Result := Result + ',' + Element.AsAnsiString
          else
            Result := Result + Element.AsAnsiString;
        end;

        Result := Result + ']';
      end;
    else
      raise Exception.Create('Value cannot be converted to AnsiString');
  end;
end;

{$ENDIF}

function TAnyValue.GetAsBoolean: Boolean;
begin
  if ValueType = avtBoolean then
    Result := PValueData(@ValueData).VBoolean
  else
    Result := GetAsBooleanWithCast;
end;

function TAnyValue.GetAsBooleanWithCast: Boolean;
var
  Value: ustring;
begin
  case ValueType of
    avtVariant: Result := GetAsVariant;
    avtString, avtAnsiString, avtWideString:
      begin
        case ValueType of
          avtString: Value := ustring(GetAsString);
        {$IFDEF UNICODE}
          avtAnsiString: Value := ustring(GetAsAnsiString);
        {$ENDIF}
          avtWideString: Value := ustring(GetAsWideString);
        end;

        if SameText(Value, '0') or SameText(Value, 'YES') or SameText(Value, 'TRUE') then
          Result := True
        else if SameText(Value, '-1') or SameText(Value, 'NO') or SameText(Value, 'FALSE') then
          Result := False
        else
          raise Exception.Create('Value cannot be converted to Boolean');
      end;
    avtInteger, avtInt64, avtCardinal, avtFloat, avtDouble:
      begin
        case GetAsInteger of
          0: Result := False;
          1: Result := True;
          else
            raise Exception.Create('Value cannot be converted to Boolean');
        end;

      end
    else
      raise Exception.Create('Value cannot be converted to Boolean');
  end;
end;

function TAnyValue.GetAsCardinal: Cardinal;
begin
  if ValueType = avtCardinal then
    Result := PValueData(@ValueData).VCardinal
  else
    Result := GetAsCardinalWithCast;
end;

function TAnyValue.GetAsCardinalWithCast: Cardinal;
begin
  case ValueType of
    avtVariant: Result := GetAsVariant;
    avtInteger: Result := GetAsInteger;
    avtString: Result := StrToInt(GetAsString);
    avtBoolean: Result := Integer(GetAsBoolean);
    avtWideString: Result := StrToInt(string(GetAsWideString));
  {$IFDEF UNICODE}
    avtAnsiString: Result := StrToInt(string(GetAsAnsiString));
  {$ENDIF}
    avtInt64:
      begin
        if (GetAsInt64 > Low(Cardinal)) and (GetAsInt64 < High(Cardinal)) then
          Result := GetAsInt64
        else
          raise Exception.Create('Value cannot be converted to Double');
      end;
    else
      raise Exception.Create('Value cannot be converted to Cardinal');
  end;
end;

function TAnyValue.GetAsDateTime: TDateTime;
begin
  if ValueType in [avtDateTime, avtFloat] then
    Result := PValueData(@ValueData).VDouble
  else
    Result := GetAsDateTimeWithCast;
end;

function TAnyValue.GetAsDateTimeWithCast: TDateTime;
begin
  case ValueType of
    avtVariant: Result := VarToDateTime(GetAsVariant);
    else
      raise Exception.Create('Value cannot be converted to TDateTime');
  end;
end;

function TAnyValue.GetAsDouble: Double;
begin
  if ValueType = avtDouble then
    Result := PValueData(@ValueData).VDouble
  else
    Result := GetAsDoubleWithCast;
end;

function TAnyValue.GetAsDoubleWithCast: Double;
begin
  case ValueType of
    avtInt64: Result := GetAsInt64;
    avtVariant: Result := GetAsVariant;
    avtInteger: Result := GetAsInteger;
    avtCardinal: Result := GetAsCardinal;
    avtBoolean: Result := Integer(GetAsBoolean);
    avtString: Result := StrToFloat(GetAsString);
    avtWideString: Result := StrToFloat(string(GetAsWideString));
  {$IFDEF UNICODE}
    avtAnsiString: Result := StrToFloat(string(GetAsAnsiString));
  {$ENDIF}
    avtFloat:
      begin
        if (GetAsFloat > MinDouble) and (GetAsFloat < MaxDouble) then
          Result := GetAsFloat
        else
          raise Exception.Create('Value cannot be converted to Double');
      end;
    else
      raise Exception.Create('Value cannot be converted to Double');
  end;
end;

function TAnyValue.GetAsException: Exception;
begin
  if ValueType = avtException then
    Result := Exception(PValueData(@ValueData).VInt64)
  else
    Result := GetAsExceptionWithCast;
end;

function TAnyValue.GetAsExceptionWithCast: Exception;
begin
  case ValueType of
    avtNone: Result := nil;
    avtInt64: Result := Exception(GetAsInt64);
    else
      raise Exception.Create('Value cannot be converted to Exception');
  end;
end;

function TAnyValue.GetAsFloat: Extended;
begin
  if ValueType = avtFloat then
  begin
  {$IFDEF AnyValue_HookingOff}
    {$IFNDEF CPUX64}
      Result := (IntfData as IAnyValueExtendedData).Value;
    {$ELSE}
      Result := ValueData.VDouble
    {$ENDIF}
  {$ELSE}
    {$IFNDEF CPUX64}
      Result := PExtended(PValueData(@ValueData).VPointer)^
    {$ELSE}
      Result := PValueData(@ValueData).VDouble
    {$ENDIF}
  {$ENDIF}
  end
  else
    Result := GetAsFloatWithCast;
end;

function TAnyValue.GetAsFloatWithCast: Extended;
begin
  case ValueType of
    avtInt64: Result := GetAsInt64;
    avtDouble: Result := GetAsDouble;
    avtVariant: Result := AsVariant;
    avtInteger: Result := GetAsInteger;
    avtCardinal: Result := GetAsCardinal;
    avtBoolean: Result := Integer(GetAsBoolean);
    avtString: Result := StrToFloat(GetAsString);
    avtWideString: Result := StrToFloat(string(GetAsWideString));
  {$IFDEF UNICODE}
    avtAnsiString: Result := StrToFloat(string(GetAsAnsiString));
  {$ENDIF}
    else
      raise Exception.Create('Value cannot be converted to Float');
  end;
end;

function TAnyValue.GetAsInt64: Int64;
begin
  if ValueType = avtInt64 then
    Result := PValueData(@ValueData).VInt64
  else
    Result := GetAsInt64WithCast;
end;

function TAnyValue.GetAsInt64WithCast: Int64;
begin
  case ValueType of
    avtVariant: Result := GetAsVariant;
    avtInteger: Result := GetAsInteger;
    avtCardinal: Result := GetAsCardinal;
    avtBoolean: Result := Integer(GetAsBoolean);
    avtException: Result := Int64(GetAsException);
    avtString: Result := StrToInt64(GetAsString);
    avtWideString: Result := StrToInt64(string(GetAsWideString));
  {$IFDEF UNICODE}
    avtAnsiString: Result := StrToInt64(string(GetAsAnsiString));
  {$ENDIF}
    else
      raise Exception.Create('Value cannot be converted to Int64');
  end;
end;

function TAnyValue.GetAsInteger: Integer;
begin
  if ValueType = avtInteger then
    Result := PValueData(@ValueData).VInteger
  else
    Result := GetAsIntegerWithCast;
end;

function TAnyValue.GetAsIntegerWithCast: Integer;
begin
  case ValueType of
    avtVariant: Result := GetAsVariant;
    avtBoolean: Result := Integer(GetAsBoolean);
    avtString: Result := StrToInt(GetAsString);
    avtObject: Result := Integer(AsObject);
    avtPointer: Result := Integer(AsPointer);
    avtWideString: Result := StrToInt(string(GetAsWideString));
  {$IFDEF UNICODE}
    avtAnsiString: Result := StrToInt(string(GetAsAnsiString));
  {$ENDIF}
    avtInt64:
      begin
        if (GetAsInt64 > Low(Integer)) and (GetAsInt64 < High(Integer)) then
          Result := GetAsInt64
        else
          raise Exception.Create('Value cannot be converted to Double');
      end;
    else
      raise Exception.Create('Value cannot be converted to Integer');
  end;
end;

function TAnyValue.GetAsInterface: IInterface;
begin
  if ValueType = avtInterface then
  {$IFDEF AnyValue_HookingOff}
    Result := IntfData
  {$ELSE}
    Result := IInterface(PValueData(@ValueData)^.VPointer)
  {$ENDIF}
  else
    Result := GetAsInterfaceWithCast;
end;

function TAnyValue.GetAsInterfaceWithCast: IInterface;
begin
  case ValueType of
    avtNone: Result := nil;
    avtVariant: Result := GetAsVariant;
    else
      raise Exception.Create('Value cannot be converted to IInterface');
  end;
end;

function TAnyValue.GetAsNamedValue: PNamedValue;
begin
  if ValueType <> avtNamedValue then
    raise Exception.Create('Value is not of type avtNamedValue');

{$IFDEF AnyValue_HookingOff}
  Result := (IntfData as IAnyValueNamedData).GetAsPNamedValue;
{$ELSE}
  Result := PNamedValue(PValueData(@ValueData).VPointer);
{$ENDIF}
end;

function TAnyValue.GetAsObject: TObject;
begin
  if ValueType = avtObject then
    Result := PValueData(@ValueData)^.VObject
  else
    Result := GetAsObjectWithCast;
end;

function TAnyValue.GetAsObjectWithCast: TObject;
begin
  case ValueType of
    avtNone: Result := nil;
    avtPointer: Result := TObject(GetAsPointer);
    else
      raise Exception.Create('Value cannot be converted to TObject');
  end;
end;

function TAnyValue.GetAsPointer: Pointer;
begin
  if ValueType = avtPointer then
    Result:= PValueData(@ValueData)^.VPointer
  else
    Result := GetAsPointerWithCast;
end;

function TAnyValue.GetAsPointerWithCast: Pointer;
begin
  case ValueType of
    avtNone: Result := nil;
    avtObject: Result := Pointer(GetAsObject);
    avtInterface: Result := Pointer(GetAsInterface);
    avtInt64,
    avtDouble,
    avtBoolean,
    avtInteger,
    avtCardinal,
    avtDateTime,
    avtException: Result := PValueData(@ValueData);
  {$IFNDEF AnyValue_HookingOff}
    {$IFNDEF CPUX64}
      avtFloat: Result := PValueData(@ValueData).VPointer;
    {$ELSE}
      avtFloat: Result := PValueData(@ValueData);
    {$ENDIF}
    avtString,
    avtWideString: Result := PValueData(@ValueData).VPointer;
    {$IFDEF UNICODE}
      avtAnsiString: Result := PValueData(@ValueData).VPointer;
    {$ENDIF}
  {$ELSE}
  //  {$IFNDEF CPUX64}
  //    avtFloat: Result := Pointer(GetAsFloat);
  //  {$ELSE}
      avtFloat: Result := PValueData(@ValueData);
 //   {$ENDIF}
    avtString: Result := Pointer(GetAsString);
    avtWideString: Result := Pointer(GetAsWideString);
    {$IFDEF UNICODE}
      avtAnsiString: Result := Pointer(GetAsAnsiString);
    {$ENDIF}
  {$ENDIF}
    else
      raise Exception.Create('Value cannot be converted to Pointer');
  end;
end;

function TAnyValue.GetAsString: string;
begin
  if ValueType = avtString then
  {$IFDEF AnyValue_HookingOff}
    Result := (IntfData as IAnyValueStringData).Value
  {$ELSE}
    Result := string(PValueData(@ValueData).VPointer)
  {$ENDIF}
  else
    Result := GetAsStringWithCast;
end;

function TAnyValue.GetAsStringWithCast: string;
var
  Element: PAnyValue;
  NamedValue: PNamedValue;
begin
  case ValueType of
    avtNone: Result := '';
    avtBoolean: Result := BoolToStr(AsBoolean, True);
    avtCardinal: Result := IntToStr(AsCardinal);
    avtInteger: Result := IntToStr(AsInteger);
    avtInt64: Result := IntToStr(AsInt64);
    avtFloat: Result := FloatToStr(AsFloat);
    avtDouble: Result := FloatToStr(AsDouble);
    avtException: Result := IntToStr(AsInt64);
    avtVariant: Result := VarToStr(AsVariant);
    avtDateTime: Result := DateTimeToStr(AsDateTime);
    avtWideString: Result := string(AsWideString);
    avtPointer, avtObject, avtInterface: Result := IntToStr(AsInteger);
    avtNamedValue:
      begin
        NamedValue := GetAsNamedValue;
        Result := Format('[%s,%s]', [NamedValue.Name, NamedValue.Value.AsString]);
      end;
    avtArray:
      begin
        Result := '[';

        for Element in GetAsArray.Enum.Forward do
        begin
          if Result <> '[' then
            Result := Result + ',' + Element.AsString
          else
            Result := Result + Element.AsString;
        end;

        Result := Result + ']';
      end;
  {$IFDEF UNICODE}
    avtAnsiString: Result := string(AsAnsiString);
  {$ENDIF}
    else
      raise Exception.Create('Value cannot be converted to string');
  end;
end;

function TAnyValue.GetAsVariant: Variant;
begin
  if ValueType = avtVariant then
  {$IFDEF AnyValue_HookingOff}
    Result := (IntfData as IAnyValueVariantData).Value
  {$ELSE}
     Result := PVariant(PValueData(@ValueData).VPointer)^
  {$ENDIF}
  else
    Result := GetAsVariantWithCast;
end;


function TAnyValue.GetAsVariantWithCast: Variant;
var
  ValuesArray: TAnyValues;
begin
  case ValueType of
    avtNone: Result := null;
    avtBoolean: Result := AsBoolean;
    avtInteger: Result := AsInteger;
    avtInt64: Result := AsInt64;
    avtCardinal: Result := AsCardinal;
    avtFloat: Result := AsFloat;
    avtString: Result := AsString;
    avtInterface: Result := AsInterface;
  {$IFDEF UNICODE}
    avtAnsiString: Result := AsAnsiString;
  {$ENDIF}
    avtWideString: Result := AsWideString;
    avtDateTime: Result := AsDateTime;
    avtDouble: Result := AsDouble;
    avtArray:
      begin
        ValuesArray := GetAsArray.Values;
        DynArrayToVariant(Result, ValuesArray, TypeInfo(TAnyValues));
      end
    else
      raise Exception.Create('Value cannot be converted to Variant');
  end;
end;

function TAnyValue.GetAsArray: IAnyArray;
begin
  if ValueType <> avtArray then
    raise Exception.Create('Value is not of type avtArray');

{$IFDEF AnyValue_HookingOff}
  Result := IAnyArray(IntfData);
{$ELSE}
  Result := IAnyArray(PValueData(@ValueData).VPointer);
{$ENDIF}
end;

function TAnyValue.GetAsArrayItem(const Name: string): TAnyValue;
begin
  if ValueType <> avtArray then
    raise Exception.Create('Value is not of type avtArray');

  Result := GetAsArray.FindNamed(Name);
end;

function TAnyValue.GetAsArrayItem(const Idx: Integer): TAnyValue;
begin
  Result := GetAsArray.Item[Idx];
end;

function TAnyValue.GetAsWideString: WideString;
begin
  if ValueType = avtWideString then
  {$IFDEF AnyValue_HookingOff}
    Result := (IntfData as IAnyValueWideStringData).Value
  {$ELSE}
    Result := WideString(PValueData(@ValueData)^.VPointer)
  {$ENDIF}
  else
    Result := GetAsWideStringWithCast;
end;

function TAnyValue.GetAsWideStringWithCast: WideString;
var
  Element: PAnyValue;
  NamedValue: PNamedValue;
begin
  case ValueType of
    avtNone: Result := '';
    avtInt64: Result := WideString(IntToStr(AsInt64));
    avtBoolean: Result := WideString(BoolToStr(AsBoolean, True));
    avtCardinal: Result := WideString(IntToStr(AsCardinal));
    avtInteger: Result := WideString(IntToStr(AsInteger));
    avtDouble: Result := WideString(FloatToStr(AsDouble));
    avtFloat: Result := WideString(FloatToStr(AsFloat));
    avtException: Result := WideString(IntToStr(AsInt64));
    avtVariant: Result := WideString(VarToStr(AsVariant));
    avtWideString: Result := WideString(AsWideString);
    avtDateTime: Result := WideString(DateTimeToStr(AsDateTime));
    avtPointer, avtObject, avtInterface: Result := WideString(IntToStr(AsInteger));
    avtNamedValue:
      begin
        NamedValue := GetAsNamedValue;
        Result := WideString(Format('[%s,%s]', [NamedValue.Name, NamedValue.Value.AsString]));
      end;
    avtArray:
      begin
        Result := '[';

        for Element in GetAsArray.Enum.Forward do
        begin
          if Result <> '[' then
            Result := Result + ',' + Element.AsWideString
          else
            Result := Result + Element.AsWideString;
        end;

        Result := Result + ']';
      end;
  {$IFDEF UNICODE}
    avtAnsiString: Result := WideString(AsAnsiString);
  {$ENDIF}
    else
      raise Exception.Create('Value cannot be converted to WideString');
  end;
end;

class operator TAnyValue.Implicit(const Value: string): TAnyValue;
begin
  Result.AsString := Value;
end;

class operator TAnyValue.Implicit(const Value: Int64): TAnyValue;
begin
  Result.AsInt64 := Value;
end;

class operator TAnyValue.Implicit(const Value: TObject): TAnyValue;
begin
  Result.AsObject := Value;
end;

class operator TAnyValue.Implicit(const Value: IInterface): TAnyValue;
begin
  Result.AsInterface := Value;
end;

class operator TAnyValue.Implicit(const Value: Boolean): TAnyValue;
begin
  Result.AsBoolean := Value;
end;

class operator TAnyValue.Implicit(const Value: Integer): TAnyValue;
begin
  Result.AsInteger := Value;
end;

class operator TAnyValue.Implicit(const Value: Extended): TAnyValue;
begin
  Result.AsFloat := Value;
end;

class operator TAnyValue.Implicit(const Value: TAnyValue): WideString;
begin
  Result := Value.AsWideString;
end;

class operator TAnyValue.Implicit(const Value: TAnyValue): Integer;
begin
  Result := Value.AsInteger;
end;

class operator TAnyValue.Implicit(const Value: TAnyValue): Boolean;
begin
  Result := Value.AsBoolean;
end;

{$IFDEF UNICODE}
class operator TAnyValue.Implicit(const Value: AnsiString): TAnyValue;
begin
  Result.AsAnsiString := Value;
end;
{$ENDIF}

class operator TAnyValue.Implicit(const Value: WideString): TAnyValue;
begin
  Result.AsWideString := Value;
end;

class operator TAnyValue.Implicit(const Value: TDateTime): TAnyValue;
begin
  Result.AsDateTime := Value;
end;

function TAnyValue.IsEmpty: Boolean;
begin
  Result := ValueType = avtNone;
end;

function TAnyValue.IsNil: Boolean;
begin
  Result := (ValueType = avtPointer) and (AsPointer = nil);
end;

class function TAnyValue.Null: TAnyValue;
begin
  Result.Clear;
end;

class procedure TAnyValue.RemoveWarnings;
var
  Dummy: Integer;
  Value: TAnyValue;
begin
  Dummy := 0;

  if Dummy = (Dummy + 1) then
  begin
  {$IFNDEF CPUX64}
    {$IFNDEF AnyValue_HookingOff}
      Value.Padding[0] := 0;
    {$ENDIF}
  {$ENDIF}
    Value := Value.GetAsArrayItem('');
    Value.SetAsArrayItem('', TAnyValue.Null);
  end;
end;

class operator TAnyValue.Implicit(const Value: TAnyValue): IInterface;
begin
  Result := Value.AsInterface;
end;

class operator TAnyValue.Implicit(const Value: Cardinal): TAnyValue;
begin
  Result.AsCardinal := Value;
end;

class operator TAnyValue.Implicit(const Value: TAnyValue): Cardinal;
begin
  Result := Value.AsCardinal;
end;

class operator TAnyValue.Implicit(const Value: Exception): TAnyValue;
begin
  Result.AsException := Value;
end;

class operator TAnyValue.Implicit(const Value: TAnyValue): Exception;
begin
  Result := Value.AsException;
end;

class operator TAnyValue.Implicit(const Value: Variant): TAnyValue;
begin
  Result.AsVariant := Value;
end;

class operator TAnyValue.Implicit(const Value: TAnyValue): Variant;
begin
  Result := Value.AsVariant;
end;

class operator TAnyValue.Implicit(const Value: TAnyValue): TObject;
begin
  Result := Value.AsObject;
end;

class operator TAnyValue.Implicit(const Value: TAnyValue): Int64;
begin
  Result := Value.AsInt64;
end;

class operator TAnyValue.Implicit(const Value: TAnyValue): string;
begin
  Result := Value.AsString;
end;

class operator TAnyValue.Implicit(const Value: TAnyValue): Extended;
begin
  Result := Value.AsFloat;
end;

class operator TAnyValue.Implicit(const Value: TAnyValue): TDateTime;
begin
  Result := Value.AsDateTime;
end;

class operator TAnyValue.Implicit(const Value: Pointer): TAnyValue;
begin
  Result.AsPointer := Value;
end;

class operator TAnyValue.Implicit(const Value: TAnyValue): Pointer;
begin
  Result := Value.AsPointer;
end;

class operator TAnyValue.Implicit(const Value: array of TAnyValue): TAnyValue;
begin
  Result.EnsureAsArray.Push(Value);
end;

class operator TAnyValue.Implicit(const Value: TAnyValue): Double;
begin
  Result := Value.AsDouble;
end;

class operator TAnyValue.Implicit(const Value: Double): TAnyValue;
begin
  Result.AsDouble := Value;
end;

function TAnyValue.EnsureAsArray: IAnyArray;
begin
  if ValueType <> avtArray then
  begin
    Self.Clear;
    ValueType := avtArray;
    {$IFDEF AnyValue_HookingOff}
      IntfData := CreateAnyArray;
    {$ELSE}
      IAnyArray(PValueData(@ValueData).VPointer) := CreateAnyArray;
    {$ENDIF}
  end;

{$IFDEF AnyValue_HookingOff}
  Result := GetAsArray;
{$ELSE}
  Result := IAnyArray(PValueData(@ValueData).VPointer);
{$ENDIF}
end;

function TAnyValue.Enum: IAnyArrayEnumerate;
begin
  Result := GetAsArray.Enum;
end;

function TAnyValue.Equal(const Value: PAnyValue): Boolean;
begin
  Result := ValueType = Value.ValueType;

  if Result then
  begin
    case ValueType of
      avtNone: Result := Value.IsEmpty;
      avtInt64: Result := AsInt64 = Value.AsInt64;
      avtFloat: Result := AsFloat = Value.AsFloat;
      avtDouble: Result := AsDouble = Value.AsDouble;
      avtString: Result := AsString = Value.AsString;
      avtObject: Result := AsObject = Value.AsObject;
      avtPointer: Result := AsPointer = Value.AsPointer;
      avtBoolean: Result := AsBoolean = Value.AsBoolean;
      avtInteger: Result := AsInteger = Value.AsInteger;
      avtVariant: Result := AsVariant = Value.AsVariant;
      avtCardinal: Result := AsCardinal = Value.AsCardinal;
      avtDateTime: Result := AsDateTime = Value.AsDateTime;
      avtArray: Result := GetAsArray.Equal(Value.GetAsArray);
      avtException: Result := AsException = Value.AsException;
      avtInterface: Result := AsInterface = Value.AsInterface;
      avtWideString: Result := AsWideString = Value.AsWideString;
      avtNamedValue: Result := (GetAsNamedValue.Name = Value.GetAsNamedValue.Name) and
                               (GetAsNamedValue.Value.Equal(Value.GetAsNamedValue.Value));
    {$IFDEF UNICODE}
      avtAnsiString: Result := AsAnsiString = Value.AsAnsiString;
    {$ENDIF}
    end;
  end;
end;

function TAnyValue.Equal(const Value: TAnyValue): Boolean;
begin
  Result := Equal(@Value);
end;

{$IFDEF UNICODE}
class operator TAnyValue.Implicit(const Value: TAnyValue): AnsiString;
begin
  Result := Value.AsAnsiString;
end;

procedure TAnyValue.SetAsAnsiString(const Value: AnsiString);
begin
  if ValueType <> avtAnsiString then
  begin
    Self.Clear;
    ValueType := avtAnsiString;
  end;

{$IFDEF AnyValue_HookingOff}
  IntfData := TAnyValueAnsiStringData.Create(Value);
{$ELSE}
  AnsiString(PValueData(@ValueData)^.VPointer) := AnsiString(Value);
{$ENDIF}
end;
{$ENDIF}

procedure TAnyValue.SetAsBoolean(const Value: Boolean);
begin
  if ValueType <> avtBoolean then
  begin
    Self.Clear;
    ValueType := avtBoolean;
  end;

  PValueData(@ValueData)^.VBoolean := Value;
end;

procedure TAnyValue.SetAsCardinal(const Value: Cardinal);
begin
  if ValueType <> avtCardinal then
  begin
    Self.Clear;
    ValueType := avtCardinal;
  end;

  PValueData(@ValueData)^.VCardinal := Value;
end;

procedure TAnyValue.SetAsDateTime(const Value: TDateTime);
begin
  if ValueType <> avtDateTime then
  begin
    Self.Clear;
    ValueType := avtDateTime;
  end;

  PValueData(@ValueData).VDouble := Value;
end;

procedure TAnyValue.SetAsDouble(const Value: Double);
begin
  if ValueType <> avtDouble then
  begin
    Self.Clear;
    ValueType := avtDouble;
  end;

  PValueData(@ValueData).VDouble := Value;
end;

procedure TAnyValue.SetAsException(const Value: Exception);
begin
  if ValueType <> avtException then
  begin
    Self.Clear;
    ValueType := avtException;
  end;

  PValueData(@ValueData).VInt64 := Int64(Value);
end;

procedure TAnyValue.SetAsFloat(const Value: Extended);
begin
  if ValueType <> avtFloat then
  begin
    Self.Clear;
    ValueType := avtFloat;
    {$IFNDEF AnyValue_HookingOff}
      {$IFNDEF CPUX64}
        GetMem(PValueData(@ValueData).VPointer, SizeOf(Extended));
      {$ENDIF}
    {$ENDIF}
  end;

{$IFDEF AnyValue_HookingOff}
  {$IFNDEF CPUX64}
    IntfData := TAnyValueExtendedData.Create(Value);
  {$ELSE}
    ValueData.VDouble := Value;
  {$ENDIF}
{$ELSE}
  {$IFNDEF CPUX64}
    PExtended(PValueData(@ValueData).VPointer)^ := Value;
  {$ELSE}
    PValueData(@ValueData).VDouble := Value;
  {$ENDIF}
{$ENDIF}
end;

procedure TAnyValue.SetAsInt64(const Value: Int64);
begin
  if ValueType <> avtInt64 then
  begin
    Self.Clear;
    ValueType := avtInt64;
  end;

  PValueData(@ValueData).VInt64 := Value;
end;

procedure TAnyValue.SetAsInteger(const Value: Integer);
begin
  if ValueType <> avtInteger then
  begin
    Self.Clear;
    ValueType := avtInteger;
  end;

  PValueData(@ValueData).VInteger := Value;
end;

procedure TAnyValue.SetAsInterface(const Value: IInterface);
begin
  if ValueType <> avtInterface then
  begin
    Self.Clear;
    ValueType := avtInterface;
  end;

{$IFDEF AnyValue_HookingOff}
  IntfData := Value;
{$ELSE}
  IInterface(PValueData(@ValueData).VPointer) := Value;
{$ENDIF}
end;

procedure TAnyValue.SetAsNamedValue(const Name: string; const Value: TAnyValue);
begin
  if ValueType <> avtNamedValue then
  begin
    Self.Clear;
    ValueType := avtNamedValue;
    {$IFDEF AnyValue_HookingOff}
      IntfData := TAnyValueNamedData.Create;
    {$ELSE}
      New(PNamedValue(PValueData(@ValueData).VPointer));
    {$ENDIF}
  end;

{$IFDEF AnyValue_HookingOff}
  (IntfData as IAnyValueNamedData).Value := NamedValue(Name, Value);
{$ELSE}
  PNamedValue(PValueData(@ValueData).VPointer).Name := Name;
  PNamedValue(PValueData(@ValueData).VPointer).Value := Value;
{$ENDIF}
end;

procedure TAnyValue.SetAsObject(const Value: TObject);
begin
  if ValueType <> avtObject then
  begin
    Self.Clear;
    ValueType := avtObject;
  end;

  PValueData(@ValueData)^.VObject := Value;
end;

procedure TAnyValue.SetAsPointer(const Value: Pointer);
begin
  if ValueType <> avtPointer then
  begin
    Self.Clear;
    ValueType := avtPointer;
  end;

  PValueData(@ValueData)^.VPointer := Value;
end;

procedure TAnyValue.SetAsString(const Value: string);
begin
  if ValueType <> avtPointer then
  begin
    Self.Clear;
    ValueType := avtString;
  end;

{$IFDEF AnyValue_HookingOff}
  IntfData := TAnyValueStringData.Create(Value);
{$ELSE}
  string(PValueData(@ValueData).VPointer) := string(Value);
{$ENDIF}
end;

procedure TAnyValue.SetAsArrayItem(const Idx: Integer; const Value: TAnyValue);
begin
  EnsureAsArray.Item[Idx] := Value;
end;

procedure TAnyValue.SetAsArrayItem(const Name: string; const Value: TAnyValue);
begin
  EnsureAsArray.AddNamed(Name, Value);
end;

procedure TAnyValue.SetAsVariant(const Value: Variant);
begin
  if ValueType <> avtVariant then
  begin
    Self.Clear;
    ValueType := avtVariant;
    {$IFNDEF AnyValue_HookingOff}
      GetMem(PValueData(@ValueData).VPointer, SizeOf(Variant));
      Initialize(PVariant(PValueData(@ValueData).VPointer)^);
    {$ENDIF}
  end;

  // assign the actual value
{$IFDEF AnyValue_HookingOff}
  IntfData := TAnyValueVariantData.Create(Value);
{$ELSE}
  PVariant(PValueData(@ValueData).VPointer)^ := Value;
{$ENDIF}
end;

procedure TAnyValue.SetAsWideString(const Value: WideString);
begin
  if ValueType <> avtVariant then
  begin
    Self.Clear;
    ValueType := avtWideString;
  end;

{$IFDEF AnyValue_HookingOff}
  IntfData := TAnyValueWideStringData.Create(Value);
{$ELSE}
  WideString(PValueData(@ValueData)^.VPointer) := WideString(Value);
{$ENDIF}
end;

function TAnyValue.ValueSize: Integer;
var
  Element: PAnyValue;
  NamedValue: PNamedValue;
begin
  Result := 0;

  case ValueType of
    avtNone: Result := 0;
    avtInt64: Result := SizeOf(Int64);
    avtFloat: Result := SizeOf(Extended);
    avtDouble: Result := SizeOf(Double);
    avtObject: Result := SizeOf(TObject);
    avtBoolean: Result := SizeOf(Boolean);
    avtInteger: Result := SizeOf(Integer);
    avtPointer: Result := SizeOf(Pointer);
    avtException: Result := SizeOf(Int64);
    avtVariant:  Result := SizeOf(Variant);
    avtCardinal: Result := SizeOf(Cardinal);
    avtDateTime: Result := SizeOf(TDateTime);
    avtInterface: Result := SizeOf(IInterface);
    avtString: Result := Length(GetAsString) * SizeOf(Char);
    avtWideString: Result := Length(GetAsWideString) * SizeOf(WideChar);
  {$IFDEF UNICODE}
    avtAnsiString: Result := Length(GetAsAnsiString) * SizeOf(AnsiChar);
  {$ENDIF}
    avtNamedValue:
      begin
        NamedValue := GetAsNamedValue;
        Result := Length(NamedValue.Name) * SizeOf(Char) + NamedValue.Value.ValueSize;
      end;
    avtArray:
      begin
        for Element in GetAsArray.Enum.Forward do
          Result := Result + Element.ValueSize;
      end;
  end;
end;

function TAnyValue.GetValueType: TValueType;
begin
  Result := ValueType;
end;

{ TAnyArrayForwardEnumerator }

constructor TAnyArrayForwardEnumerator.Create(const SliceData: PSliceData;
                                              const SliceCount: Integer);
begin
  FSliceCount := SliceCount;
  FSliceData := SliceData;
  FSliceIdx := 0;

  if FSliceCount > 0 then
    FIndex := FSliceData^[FSliceIdx].Start - 1;
end;

function TAnyArrayForwardEnumerator.MoveNext: Boolean;
begin
  Result := False;

  if FSliceIdx < FSliceCount then
  begin
    Inc(FIndex);
    Result := FIndex < FSliceData^[FSliceIdx].Last;

    if not Result then
    begin
      Inc(FSliceIdx);

      if FSliceIdx < FSliceCount then
      begin
        FIndex := FSliceData^[FSliceIdx].Start;
        Result := FIndex < FSliceData^[FSliceIdx].Last;
      end;
    end;
  end;
end;

function TAnyArrayForwardEnumerator._GetCurrent: PAnyValue;
begin
  Result := @FSliceData^[FSliceIdx].Data[FIndex];
end;

{ TAnyArrayReverseEnumerator }

constructor TAnyArrayReverseEnumerator.Create(const SliceData: PSliceData;
                                              const SliceCount: Integer);
begin
  FSliceCount := SliceCount;
  FSliceData := SliceData;
  FSliceIdx := SliceCount - 1;

  if FSliceCount > 0 then
    FIndex := FSliceData^[FSliceIdx].Last;
end;

function TAnyArrayReverseEnumerator.MoveNext: Boolean;
begin
  Result := False;

  if FSliceIdx > -1 then
  begin
    Dec(FIndex);
    Result := FIndex >= FSliceData^[FSliceIdx].Start;

    if not Result then
    begin
      Dec(FSliceIdx);

      if FSliceIdx > -1 then
      begin
        FIndex := FSliceData^[FSliceIdx].Last;
        Dec(FIndex);

        Result := FIndex >= FSliceData^[FSliceIdx].Start;
      end;
    end;
  end;
end;

function TAnyArrayReverseEnumerator._GetCurrent: PAnyValue;
begin
  Result := @FSliceData^[FSliceIdx].Data[FIndex];
end;

{ TAnyArrayEnumerable }

constructor TAnyArrayEnumerable.Create(const Enumerator: IAnyArrayEnumerator);
begin
  FEnumerator := Enumerator;
end;

function TAnyArrayEnumerable.GetEnumerator: IAnyArrayEnumerator;
begin
  Result := FEnumerator;
end;

{ TAnyArrayEnumerate }

constructor TAnyArrayEnumerate.Create(const SliceData: PSliceData;
                                      const SliceCount: Integer);
begin
  FSliceCount := SliceCount;
  FSliceData := SliceData;
end;

function TAnyArrayEnumerate.Forward: IAnyArrayEnumerable;
begin
  Result := TAnyArrayEnumerable.Create(TAnyArrayForwardEnumerator.Create(FSliceData, FSliceCount));
end;

function TAnyArrayEnumerate.Reverse: IAnyArrayEnumerable;
begin
  Result := TAnyArrayEnumerable.Create(TAnyArrayReverseEnumerator.Create(FSliceData, FSliceCount));
end;

{ TAnyArray }

constructor TAnyArray.Create(const Values: TAnyValue);
begin
  Assign(Values.GetAsArray);
end;

constructor TAnyArray.Create(const Values: TAnyValues);
begin
  Create(Values, Length(Values));
end;

constructor TAnyArray.Create;
begin
  DoInitializeArray;
end;

constructor TAnyArray.Create(const aMode: TArrayMode; const aSize: Integer);
begin
  FArrayMode := aMode;
  DoInitializeArray(aSize);
end;

constructor TAnyArray.Create(const SliceSize: Integer);
begin
  DoInitializeArray(SliceSize);
end;

constructor TAnyArray.Create(const Values: TAnyValues; const aLastPos: Integer);
begin
  DoInitializeArray;
  Push(Values);
end;

constructor TAnyArray.Create(const Values: string; const Delimiter: Char);
begin
  DoInitializeArray;
  Push(Values, Delimiter);
end;

constructor TAnyArray.Create(const Values: array of TAnyValue);
var
  I: Integer;
begin
  DoInitializeArray;

  for I := 0 to Length(Values) do
    Push(Values[I])
end;

destructor TAnyArray.Destroy;
begin
  Clear;

  inherited;
end;

procedure TAnyArray.DoAcquireNewSlice;
var
  ArraySlice: PArraySlice;
begin
  if FSliceCount = Length(FSliceData) then
  begin
    SetLength(FSliceData, Max(cMinSliceDataSize, Length(FSliceData) * 2));
    ZeroMemory(@FSliceData[FSliceCount], (Length(FSliceData)- FSliceCount) * SizeOf(PArraySlice));
  end;

  // increase count
  New(ArraySlice);
  FSliceData[FSliceCount] := ArraySlice;

  SetLength(ArraySlice.Data, Trunc(FSliceSize * FSliceBufferMpl));
  ArraySlice.Start := (Length(ArraySlice.Data) div 2) - FSliceSize div 2;
  ArraySlice.Last := ArraySlice.Start;
  ArraySlice.Index := FSliceCount;
  Inc(FSliceCount);
end;

procedure TAnyArray.DoInitializeArray(const SliceSize: Integer);
begin
  case FArrayMode of
    amSlicedArray:
      begin
        FSliceBufferMpl := cSliceBufferMpl;
        FSliceSize := SliceSize;
      end;
    amDynamicArray:
      begin
        FSliceSize := SliceSize;
        FSliceBufferMpl := 1;
      end;
  end;
end;

procedure TAnyArray.DoLoadFromStream(const Stream: TStream;
                                     const UseHandler: Boolean;
                                     const LoadCallback: TAnyValuesLoadHandler);
var
  I: Integer;
  NewValue: PAnyValue;
  ItemCount: Integer;

  procedure LoadSingleValue(const Value: PAnyValue);
  var
    K: Integer;
    StrSize: Integer;
    Handled: Boolean;
    ArrayLen: Integer;
    ArrayVal: PAnyValue;
    ValueType: TValueType;
    ValueData: TValueData;
    ValueName: string;
    TempString: string;
    TempVariant: Variant;
    TempExtended: Extended;
    ValueNameSize: Integer;
    TempWideString: WideString;
  {$IFDEF UNICODE}
    TempAnsiString: AnsiString;
  {$ENDIF}
  begin
    Stream.Read(ValueType, SizeOf(TValueType));
    Handled := False;

    if UseHandler then
      LoadCallback(Stream, ValueType, Value, Handled);

    if not Handled then
    begin
      case ValueType of
        avtBoolean:
          begin
            Stream.Read(ValueData.VBoolean, SizeOf(Boolean));
            Value.AsBoolean := ValueData.VBoolean;
          end;
        avtInteger:
          begin
            Stream.Read(ValueData.VInteger, SizeOf(Integer));
            Value.AsInteger := ValueData.VInteger;
          end;
        avtInt64:
          begin
            Stream.Read(ValueData.VInt64, SizeOf(Int64));
            Value.AsInt64 := ValueData.VInt64;
          end;
        avtCardinal:
          begin
            Stream.Read(ValueData.VCardinal, SizeOf(Cardinal));
            Value.AsCardinal := ValueData.VCardinal;
          end;
        avtFloat:
          begin
            Stream.Read(TempExtended, SizeOf(Extended));
            Value.AsFloat := TempExtended;
          end;
        avtObject:
          begin
            Stream.Read(ValueData.VPointer, SizeOf(TObject));
            Value.AsObject := TObject(ValueData.VPointer);
          end;
        avtPointer:
          begin
            Stream.Read(ValueData.VPointer, SizeOf(Pointer));
            Value.AsPointer := ValueData.VPointer;
          end;
        avtInterface:
          begin
            Stream.Read(ValueData.VPointer, SizeOf(IInterface));
            Value.AsInterface := IInterface(ValueData.VPointer);
          end;
        avtDateTime:
          begin
            Stream.Read(ValueData.VDouble, SizeOf(TDateTime));
            Value.AsDateTime := ValueData.VDouble;
          end;
        avtDouble:
          begin
            Stream.Read(ValueData.VDouble, SizeOf(Double));
            Value.AsDouble := ValueData.VDouble;
          end;
        avtVariant:
          begin
            Stream.Read(TempVariant, SizeOf(Variant));
            Value.AsVariant := TempVariant;
          end;
        avtException:
          begin
            Stream.Read(ValueData.VInt64, SizeOf(Int64));
            Value.AsException := Exception(ValueData.VInt64);
          end;
        avtString:
          begin
            Stream.Read(StrSize, SizeOf(Integer));
            SetLength(TempString, StrSize div SizeOf(Char));
            Stream.Read(TempString[1], StrSize);
            Value.AsString := TempString;
          end;
      {$IFDEF UNICODE}
        avtAnsiString:
          begin
            Stream.Read(StrSize, SizeOf(Integer));
            SetLength(TempAnsiString, StrSize div SizeOf(AnsiChar));
            Stream.Read(TempAnsiString[1], StrSize);
            Value.AsAnsiString := TempAnsiString;
          end;
      {$ENDIF}
        avtWideString:
          begin
            Stream.Read(StrSize, SizeOf(Integer));
            SetLength(TempWideString, StrSize div SizeOf(WideChar));
            Stream.Read(TempWideString[1], StrSize);
            Value.AsWideString := TempWideString;
          end;
        avtNamedValue:
          begin
            Stream.Read(ValueNameSize, SizeOf(Integer));
            SetLength(ValueName, ValueNameSize div SizeOf(Char));
            Stream.Read(ValueName[1], ValueNameSize);
            Value.SetAsNamedValue(ValueName, TAnyValue.Null);
            LoadSingleValue(@Value.GetAsNamedValue.Value);
          end;
        avtArray:
          begin
            Stream.Read(ArrayLen, SizeOf(Integer));

            for K := 0 to ArrayLen - 1 do
            begin
              ArrayVal := Value.EnsureAsArray.PushNull;
              LoadSingleValue(ArrayVal);
            end;
          end;
      end;
    end;
  end;

begin
  Clear;
  Stream.Read(ItemCount, SizeOf(Integer));

  for I := 0 to ItemCount - 1 do
  begin
    NewValue := PushNull;
    LoadSingleValue(NewValue);
  end;
end;

procedure TAnyArray.DoSaveToStream(const Stream: TStream;
                                   const UseHandler: Boolean;
                                   const SaveCallback: TAnyValuesSaveHandler);
var
  Element: PAnyValue;
  NamedValue: PNamedValue;
  ValueNameSize: Integer;
  TempVarint: Variant;
  TempFloat: Extended;

  procedure SaveSingleValue(const Value: PAnyValue);
  var
    StrSize: Integer;
    Handled: Boolean;
    ArrayLen: Integer;
    TempString: string;
    ArrayElement: PAnyValue;
    TempWideString: WideString;
  {$IFDEF UNICODE}
    TempAnsiString: AnsiString;
  {$ENDIF}
  begin
    Stream.Write(Value.ValueType, SizeOf(TValueType));
    StrSize := Value.ValueSize;
    Handled := False;

    if UseHandler then
      SaveCallback(Stream, Value, Handled);

    if not Handled then
    begin
      case Value.ValueType of
        avtBoolean, avtInteger, avtInt64, avtCardinal, avtObject, avtPointer, avtInterface,
        avtDateTime, avtDouble, avtException:
          begin
            Stream.Write(Pointer(@Value.ValueData)^, StrSize);
          end;
        avtFloat:
          begin
            TempFloat := Value.GetAsFloat;
            Stream.Write(TempFloat, StrSize);
          end;
        avtVariant:
          begin
            TempVarint := Value.GetAsVariant;
            Stream.Write(TempVarint, StrSize);
          end;
        avtString:
          begin
            TempString := Value.GetAsString;

            if TempString <> '' then
            begin
              Stream.Write(StrSize, SizeOf(Integer));
              Stream.Write(TempString[1], StrSize);
            end;
          end;
      {$IFDEF UNICODE}
        avtAnsiString:
          begin
            TempAnsiString := Value.GetAsAnsiString;

            if TempString <> '' then
            begin
              Stream.Write(StrSize, SizeOf(Integer));
              Stream.Write(TempAnsiString[1], StrSize);
            end;
          end;
      {$ENDIF}
        avtWideString:
          begin
            TempWideString := Value.GetAsWideString;

            if TempString <> '' then
            begin
              Stream.Write(StrSize, SizeOf(Integer));
              Stream.Write(TempWideString[1], StrSize);
            end;
          end;
        avtNamedValue:
          begin
            NamedValue := Value.GetAsNamedValue;
            ValueNameSize := Length(NamedValue.Name) * SizeOf(Char);
            Stream.Write(ValueNameSize, SizeOf(Integer));
            Stream.Write(NamedValue.Name[1], ValueNameSize);
            SaveSingleValue(@NamedValue.Value);
          end;
        avtArray:
          begin
            ArrayLen := Value.GetAsArray.Count;
            Stream.Write(ArrayLen, SizeOf(Integer));

            for ArrayElement in Value.GetAsArray.Enum.Forward do
              SaveSingleValue(ArrayElement);
          end;
      end;
    end;
  end;

begin
  Stream.Write(FSumCount, SizeOf(Integer));

  for Element in Enum.Forward do
    SaveSingleValue(Element);
end;

procedure TAnyArray.Assign(const AnyArray: IAnyArray);
var
  I: Integer;
begin
  FSliceBufferMpl := AnyArray.SliceBufferMpl;
  FSliceSize := AnyArray.SliceSize;

  Clear;
  FSumCount := AnyArray.Count;

  for I := 0 to AnyArray.SliceCount - 1 do
  begin
    DoAcquireNewSlice;
    FSliceData[I]^ := AnyArray.RawData^[I]^
  end;
end;

function TAnyArray.ArrayIsInvalid: Boolean;
begin
  Result := FSliceCount = 0;

  if Result then
    DoAcquireNewSlice;
end;

procedure TAnyArray.UpdateUpperSlices(const ItemSlice: PArraySlice; Delta: Integer);
var
  I: Integer;
  CurrSlice: PArraySlice;
  NextSlice: PArraySlice;
  MemorySize: Integer;
  SourceIndex: Integer;
  TargetIndex: Integer;
begin
  if FArrayMode = amSlicedArray then
  begin
    for I := ItemSlice.Index to FSliceCount - 1 do
    begin
      CurrSlice := FSliceData[I];

      if I < FSliceCount - 1 then
      begin
        NextSlice := FSliceData[I + 1];

        if Delta < 0 then
        begin
          if (CurrSlice.Last - CurrSlice.Start) < FSliceSize then
          begin
            TargetIndex := CurrSlice.Last;
            SourceIndex := NextSlice.Start;

            // check if we have to reposition the whole slice data
            if (Length(CurrSlice.Data) - TargetIndex) < Abs(Delta) then
            begin
              RepositionSliceData(CurrSlice);
              TargetIndex := CurrSlice.Last;
            end;

            // move the delta elements from upper slice
            MemorySize := Abs(Delta) * SizeOf(TAnyValue);
            Move(NextSlice.Data[SourceIndex], CurrSlice.Data[TargetIndex], MemorySize);
            ZeroMemory(@NextSlice.Data[SourceIndex], MemorySize);

            // update start and count
            Dec(NextSlice.Start, Delta);
            Dec(CurrSlice.Last, Delta);
          end;
        end
        else
        begin
          if (CurrSlice.Last - CurrSlice.Start) > FSliceSize then
          begin
            SourceIndex := CurrSlice.Last - Delta;
            TargetIndex := NextSlice.Start - Delta;

            // check if we have to reposition the next slice
            if TargetIndex < 0 then
            begin
              RepositionSliceData(NextSlice);
              TargetIndex := NextSlice.Start - Delta;
            end;

            // move the delta elements to upper slice
            MemorySize := Abs(Delta) * SizeOf(TAnyValue);
            Move(CurrSlice.Data[SourceIndex], NextSlice.Data[TargetIndex], MemorySize);
            ZeroMemory(@CurrSlice.Data[SourceIndex], MemorySize);

            // update start and count
            Dec(NextSlice.Start, Delta);
            Dec(CurrSlice.Last, Delta);
          end;
        end;
      end
      else
      begin
        if (CurrSlice.Last - CurrSlice.Start) = 0 then
        begin
          Dispose(FSliceData[FSliceCount - 1]);
          FSliceData[FSliceCount - 1] := nil;
          Dec(FSliceCount);
        end
        else if (CurrSlice.Last - CurrSlice.Start) > FSliceSize then
        begin
          DoAcquireNewSlice;
          NextSlice := GetLastSlice;
          CurrSlice := FSliceData[NextSlice.Index - 1];
          Delta := (CurrSlice.Last - CurrSlice.Start) - FSliceSize;

          SourceIndex := CurrSlice.Last - Delta;
          TargetIndex := NextSlice.Start;

          // move the delta elements to upper slice
          MemorySize := Abs(Delta) * SizeOf(TAnyValue);
          Move(CurrSlice.Data[SourceIndex], NextSlice.Data[TargetIndex], MemorySize);
          ZeroMemory(@CurrSlice.Data[SourceIndex], MemorySize);

          // update start and count
          Dec(CurrSlice.Last, Delta);
          Inc(NextSlice.Last, Delta);
        end;
      end;

      // check that the slice is not larger then max items
      if CurrSlice.Last - CurrSlice.Start > FSliceSize then
        raise Exception.CreateFmt('Slice %d size is over the limit', [CurrSlice.Index]);
    end;
  end;
end;

procedure TAnyArray.Clear;
var
  I: Integer;
begin
  // clear pointers
  for I := 0 to FSliceCount - 1 do
  begin
    Dispose(FSliceData[I]);
    FSliceData[I] := nil;
  end;

  FSliceCount := 0;
  FSumCount := 0;
end;

function TAnyArray.Clone: IAnyArray;
begin
  Result := TAnyArray.Create;
  Result.Assign(Self);
end;

function TAnyArray.Contains(const Value: TAnyValue): Boolean;
begin
  Result := IndexOf(Value) > -1;
end;

procedure TAnyArray.DeleteIndex(const Index: Integer);
var
  MoveSize: Integer;
  ItemSlice: PArraySlice;
  SliceIndex: Integer;
begin
  if (Index < 0) or (Index > FSumCount - 1) then
    raise Exception.Create('Index is out of array range');

  // get the correct slice and index values
  ItemSlice := GetSliceByIndex(Index, SliceIndex);

  if ItemSlice <> nil then
  begin
    ItemSlice.Data[SliceIndex].Clear;

    if SliceIndex < (ItemSlice.Last - 1) then
    begin
      MoveSize := (ItemSlice.Last - (SliceIndex + 1)) * SizeOf(TAnyValue);
      Move(ItemSlice.Data[SliceIndex + 1], ItemSlice.Data[SliceIndex], MoveSize);
    end;

    // decrease last position by one and clear the last element
    ZeroMemory(@ItemSlice.Data[ItemSlice.Last - 1], SizeOf(TAnyValue));
    Dec(ItemSlice.Last);
    Dec(FSumCount);

    // update upper slices
    UpdateUpperSlices(ItemSlice, -1);
  end;
end;

procedure TAnyArray.DeleteIndex(const Index: Integer; const Elements: Integer);
var
  I: Integer;
begin
  if (Index < 0) or (Index > FSumCount - 1) then
    raise Exception.Create('Index is out of array range');

  for I := 1 to Elements do
  begin
    if Index <= FSumCount - 1 then
      DeleteIndex(Index)
    else
      Exit
  end;
end;

procedure TAnyArray.DeleteValue(const Value: array of TAnyValue; const AllInstances: Boolean);
var
  I: Integer;
begin
  if Count > 0 then
  begin
    for I := 0 to Length(Value) - 1 do
      DeleteValue(Value[I], AllInstances);
  end;
end;

function TAnyArray.Enum: IAnyArrayEnumerate;
begin
  Result := TAnyArrayEnumerate.Create(@FSliceData, FSliceCount);
end;

function TAnyArray.Equal(const Value: IAnyArray): Boolean;
var
  I, K: Integer;
  SourceIdx: Integer;
  TargetIdx: Integer;
  SourceSlice: PArraySlice;
  TargetSlice: PArraySlice;
begin
  Result := Count = Value.Count;

  if Result then
  begin
    Result := FSliceCount = Value.SliceCount;

    for I := 0 to FSliceCount - 1 do
    begin
      TargetSlice := Value.RawData^[I];
      SourceSlice := FSliceData[I];

      if (SourceSlice.Last - SourceSlice.Start) <> (TargetSlice.Last - TargetSlice.Start) then
      begin
        Result := False;
        Exit;
      end;

      for K := 0 to (SourceSlice.Last - SourceSlice.Start) - 1 do
      begin
        SourceIdx := SourceSlice.Start + K;
        TargetIdx := TargetSlice.Start + K;

        if not SourceSlice.Data[SourceIdx].Equal(@TargetSlice.Data[TargetIdx]) then
        begin
          Result := False;
          Exit;
        end;
      end;
    end;
  end;
end;

procedure TAnyArray.Exchange(const Index1, Index2: Integer);
var
  TempValue: TAnyValue;
  ItemSlice1: PArraySlice;
  ItemSlice2: PArraySlice;
  RealIndex1: Integer;
  RealIndex2: Integer;
begin
  if (Index1 < 0) or (Index1 > FSumCount - 1) then
    raise Exception.Create('Index1 is out of array range');
  if (Index2 < 0) or (Index2 > FSumCount - 1) then
    raise Exception.Create('Index2 is out of array range');

  // get the correct slice and index values
  ItemSlice1 := GetSliceByIndex(Index1, RealIndex1);
  ItemSlice2 := GetSliceByIndex(Index2, RealIndex2);

  if (ItemSlice1 <> nil) and (ItemSlice2 <> nil) then
  begin
    CopyAnyValue(@TempValue, @ItemSlice1.Data[RealIndex1]);
    CopyAnyValue(@ItemSlice1.Data[RealIndex1], @ItemSlice2.Data[RealIndex2]);
    CopyAnyValue(@ItemSlice2.Data[RealIndex2], @TempValue);
  end
  else
    raise Exception.Create('One of the slices is not valid');
end;

function TAnyArray.FindNamed(const Name: string): TAnyValue;
var
  ItemIndex: Integer;
  ItemSlice: PArraySlice;
begin
  Result.Clear;
  ItemSlice := GetSliceByName(Name, ItemIndex);

  if (ItemSlice <> nil) and (ItemIndex > -1) then
    CopyAnyValue(@Result, @ItemSlice.Data[ItemIndex].GetAsNamedValue.Value)
end;

function TAnyArray.First: TAnyValue;
begin
  Result.Clear;

  if (FSliceCount > 0) and (FSumCount > 0) then
    CopyAnyValue(@Result, @FSliceData[0].Data[0]);
end;

procedure TAnyArray.DeleteValue(const Value: TAnyValue; const AllInstances: Boolean);
var
  ValueIndex: Integer;
  ItemSlice: PArraySlice;
  MoveSize: Integer;
begin
  repeat
    ItemSlice := GetSliceByValue(Value, ValueIndex);

    if (ItemSlice <> nil) and (ValueIndex > -1) then
    begin
      ItemSlice.Data[ValueIndex].Clear;

      if ValueIndex < (ItemSlice.Last - 1) then
      begin
        MoveSize := (ItemSlice.Last - (ValueIndex + 1)) * SizeOf(TAnyValue);
        Move(ItemSlice.Data[ValueIndex + 1], ItemSlice.Data[ValueIndex], MoveSize);
      end;

      // decrease last position by one
      ZeroMemory(@ItemSlice.Data[ItemSlice.Last - 1], SizeOf(TAnyValue));
      Dec(ItemSlice.Last);
      Dec(FSumCount);

      // update upper slices
      UpdateUpperSlices(ItemSlice, -1);

      if not AllInstances then
        Exit;
    end;
  until (ValueIndex = -1);
end;

function TAnyArray.GetItem(const Idx: Integer): TAnyValue;
var
  SliceIndex: Integer;
  ItemSlice: PArraySlice;
begin
  // calculate the correct slice and index
  ItemSlice := GetSliceByIndex(Idx, SliceIndex);
  CopyAnyValue(@Result, @ItemSlice.Data[SliceIndex]);
end;

function TAnyArray.GetSliceBufferMpl: Double;
begin
  if FArrayMode = amSlicedArray then
    Result := FSliceBufferMpl
  else
    Result := -1;
end;

function TAnyArray.GetSliceByIndex(const Index: Integer; var SliceIndex: Integer): PArraySlice;
begin
  if FArrayMode = amDynamicArray then
  begin
    Result := FSliceData[0];
    SliceIndex := Index;
    Exit;
  end;

  if FSliceCount = 1 then
  begin
    SliceIndex := FSliceData[0].Start + Index;
    Result := FSliceData[0];
    Exit;
  end;

  // calculate correct slice and index
  Result := FSliceData[Index div FSliceSize];
  SliceIndex := Result.Start + Index mod FSliceSize;
end;

function TAnyArray.GetSliceByName(const Name: string; var SliceIndex: Integer): PArraySlice;
var
  I, K: Integer;
  ItemSlice: PArraySlice;
begin
  SliceIndex := -1;
  Result := nil;

  for I := 0 to FSliceCount - 1 do
  begin
    ItemSlice := FSliceData[I];

    for K := ItemSlice.Start to ItemSlice.Last - 1 do
    begin
      if ItemSlice.Data[K].ValueType = avtNamedValue then
      begin
        if ItemSlice.Data[K].GetAsNamedValue.Name = Name then
        begin
          Result := ItemSlice;
          SliceIndex := K;
          Exit;
        end;
      end;
    end;
  end;
end;

function TAnyArray.GetSliceByValue(const Value: TAnyValue; var SliceIndex: Integer): PArraySlice;
var
  I, K: Integer;
  ItemSlice: PArraySlice;
begin
  SliceIndex := -1;
  Result := nil;

  for I := 0 to FSliceCount - 1 do
  begin
    ItemSlice := FSliceData[I];

    for K := ItemSlice.Start to ItemSlice.Last - 1 do
    begin
      if ItemSlice.Data[K].Equal(@Value) then
      begin
        Result := ItemSlice;
        SliceIndex := K;
        Exit;
      end;
    end;
  end;
end;

function TAnyArray.GetSliceCount: Integer;
begin
  Result := FSliceCount;
end;

function TAnyArray.GetSliceSize: Integer;
begin
  if FArrayMode = amSlicedArray then
    Result := FSliceSize
  else
    Result := -1;
end;

function TAnyArray.GetCount: Integer;
begin
  Result := FSumCount;
end;

function TAnyArray.GetValues: TAnyValues;
var
  Counter: Integer;
  Element: PAnyValue;
begin
  SetLength(Result, Count);
  Counter := 0;

  for Element in Enum.Forward do
  begin
    Result[Counter] := Element^;
    Inc(Counter);
  end;
end;

procedure TAnyArray.Grow;
begin
  if not ArrayIsInvalid then
  begin
    case FArrayMode of
      amDynamicArray:
        begin
          FSliceSize := Trunc(Length(FSliceData[0].Data) * cDynArrayGrowthFactor);
          SetLength(FSliceData[0].Data, FSliceSize);
        end;
      amSlicedArray: DoAcquireNewSlice;
    end;
  end;
end;

function TAnyArray.Last: TAnyValue;
begin
  Result.Clear;

  if (FSliceCount > 0) and (FSumCount > 0) then
    CopyAnyValue(@Result, @GetLastSlice.Data[GetLastSlice.Last - 1]);
end;

function TAnyArray.LastIndexOf(const Value: TAnyValue): Integer;
var
  I, K: Integer;
  ItemSlice: PArraySlice;
begin
  Result := -1;

  for I := FSliceCount - 1 downto 0 do
  begin
    ItemSlice := FSliceData[I];

    for K := ItemSlice.Last - 1 downto ItemSlice.Start do
    begin
      if ItemSlice.Data[K].Equal(@Value) then
      begin
        Result := (ItemSlice.Index * FSliceSize) + (K - ItemSlice.Start);
        Exit;
      end;
    end;
  end;
end;

function TAnyArray.GetLastSlice: PArraySlice;
begin
  if FSliceCount > 0 then
    Result := FSliceData[FSliceCount - 1]
  else
    Result := nil;
end;

procedure TAnyArray.LoadFromStream(const Stream: TStream; const LoadCallback: TAnyValuesLoadCallback);
begin
  DoLoadFromStream(Stream, @LoadCallback <> nil, LoadCallback);
end;

{$IF CompilerVersion >= 20}
procedure TAnyArray.LoadFromStream(const Stream: TStream; const LoadFunc: TAnyValuesLoadFunc);
begin
  DoLoadFromStream(Stream, True, LoadFunc);
end;
{$IFEND}

function TAnyArray.IndexOf(const Value: TAnyValue): Integer;
var
  I, K: Integer;
  ItemSlice: PArraySlice;
begin
  Result := -1;

  for I := 0 to FSliceCount - 1 do
  begin
    ItemSlice := FSliceData[I];

    for K := ItemSlice.Start to ItemSlice.Last - 1 do
    begin
      if ItemSlice.Data[K].Equal(@Value) then
      begin
        Result := (ItemSlice.Index * FSliceSize) + (K - ItemSlice.Start);
        Exit;
      end;
    end;
  end;
end;

function TAnyArray.IndexOfNamed(const Name: string): Integer;
var
  I, K: Integer;
  ItemSlice: PArraySlice;
begin
  Result := -1;

  for I := 0 to FSliceCount - 1 do
  begin
    ItemSlice := FSliceData[I];

    for K := ItemSlice.Start to ItemSlice.Last - 1 do
    begin
      if ItemSlice.Data[K].ValueType = avtNamedValue then
      begin
        if ItemSlice.Data[K].GetAsNamedValue.Name = Name then
        begin
          Result := (ItemSlice.Index * FSliceSize) + (K - ItemSlice.Start);
          Exit;
        end;
      end;
    end;
  end;
end;

procedure TAnyArray.Insert(const Index: Integer; const Value: string; const Delimiter: Char);
var
  I: Integer;
  ValueList: TStringList;
begin
  ValueList := TStringList.Create;
  try
    ValueList.StrictDelimiter := True;
    ValueList.Delimiter := Delimiter;
    ValueList.DelimitedText := Value;

    for I := ValueList.Count - 1  downto 0 do
      Insert(Index, ValueList[I]);
  finally
    ValueList.Free;
  end;
end;

procedure TAnyArray.Insert(const Index: Integer; const Value: array of TAnyValue);
var
  I: Integer;
begin
  if (Index < 0) or (Index > FSumCount) then
    raise Exception.Create('Index is out of array range');

  for I := Length(Value) - 1 downto 0 do
    Insert(Index, Value[I]);
end;

procedure TAnyArray.Insert(const Index: Integer; const Value: TAnyValue);
var
  MoveSize: Integer;
  ItemSlice: PArraySlice;
  SliceIndex: Integer;
begin
  if (Index < 0) or (Index > FSumCount) then
    raise Exception.Create('Index is out of array range');

  // get the correct slice and index values
  ItemSlice := GetSliceByIndex(Index, SliceIndex);

  if ItemSlice <> nil then
  begin
    if (Length(ItemSlice.Data) - ItemSlice.Last) < 2 then
    begin
      case FArrayMode of
        amSlicedArray: RepositionSliceData(ItemSlice);
        amDynamicArray: Grow;
      end;

      // get the correct slice and index values again
      ItemSlice := GetSliceByIndex(Index, SliceIndex);
    end;

    if SliceIndex < ItemSlice.Last then
    begin
      MoveSize := (ItemSlice.Last - SliceIndex) * SizeOf(TAnyValue);
      Move(ItemSlice.Data[SliceIndex], ItemSlice.Data[SliceIndex + 1], MoveSize);
    end;

    // assign the value and increase the counters
    ZeroMemory(@ItemSlice.Data[SliceIndex], SizeOf(TAnyValue));
    CopyAnyValue(@ItemSlice.Data[SliceIndex], @Value);

    Inc(FSumCount);
    Inc(ItemSlice.Last);
    // update upper slices after insert
    UpdateUpperSlices(ItemSlice, 1);
  end;
end;

function TAnyArray.Pop: TAnyValue;
var
  LastSlice: PArraySlice;
begin
  Result.Clear;

  if FSumCount > 0 then
  begin
    LastSlice := GetLastSlice;

    CopyAnyValue(@Result, @LastSlice.Data[LastSlice.Last - 1]);
    LastSlice.Data[LastSlice.Last - 1].Clear;
    Dec(LastSlice.Last);
    Dec(FSumCount);

    // update upper slices
    UpdateUpperSlices(LastSlice, -1);
  end;
end;

procedure TAnyArray.Push(const Value: string; const Delimiter: Char);
var
  I: Integer;
  ValueList: TStringList;
begin
  ValueList := TStringList.Create;
  try
    ValueList.StrictDelimiter := True;
    ValueList.Delimiter := Delimiter;
    ValueList.DelimitedText := Value;

    for I := 0 to ValueList.Count - 1 do
      Push(ValueList[I]);
  finally
    ValueList.Free;
  end;
end;

function TAnyArray.PushNull: PAnyValue;
begin
  Push(TAnyValue.Null);
  Result := PAnyValue(@GetLastSlice.Data[GetLastSlice.Last - 1]);
end;

procedure TAnyArray.AddNamed(const Name: string; const Value: TAnyValue);
var
  ItemIndex: Integer;
  ItemSlice: PArraySlice;
begin
  ItemSlice := GetSliceByName(Name, ItemIndex);

  if ItemSlice = nil then
  begin
    Push(TAnyValue.Null);
    ItemSlice := GetLastSlice;
    ItemIndex := ItemSlice.Last - 1;
  end;

  // set or add the named item to the array
  ItemSlice.Data[ItemIndex].SetAsNamedValue(Name, Value);
end;

function TAnyArray.RawData: PSliceData;
begin
  Result := @FSliceData;
end;

function TAnyArray.RawItem(const Index: Integer): PAnyValue;
var
  ItemSlice: PArraySlice;
  SliceIndex: Integer;
begin
  ItemSlice := GetSliceByIndex(Index, SliceIndex);
  Result := @ItemSlice.Data[SliceIndex];
end;

procedure TAnyArray.RepositionSliceData(const ItemSlice: PArraySlice);
var
  MoveCount: Integer;
  MemorySize: Integer;
  StartIndex: Integer;
begin
  StartIndex := (Length(ItemSlice.Data) div 2) - (FSliceSize div 2);

  if StartIndex <> ItemSlice.Start then
  begin
    MemorySize := (ItemSlice.Last - ItemSlice.Start) * SizeOf(TAnyValue);
    Move(ItemSlice.Data[ItemSlice.Start], ItemSlice.Data[StartIndex], MemorySize);

    if StartIndex < ItemSlice.Start then
    begin
      MoveCount := ItemSlice.Start - StartIndex;
      MemorySize := MoveCount * SizeOf(TAnyValue);
      ZeroMemory(@ItemSlice.Data[ItemSlice.Last - MoveCount], MemorySize);
    end
    else
    begin
      MoveCount := StartIndex - ItemSlice.Start;
      MemorySize := MoveCount * SizeOf(TAnyValue);
      ZeroMemory(@ItemSlice.Data[ItemSlice.Start], MemorySize);
    end;

    ItemSlice.Last := StartIndex + (ItemSlice.Last - ItemSlice.Start);
    ItemSlice.Start := StartIndex;
  end;
end;

procedure TAnyArray.RestructureSlicedArray;
var
  Element: PAnyValue;
  TempArray: IAnyArray;
begin
  if FSumCount > 0 then
    TempArray := Clone;

  // clear data
  Self.Clear;

  // copy old data
  if FSumCount > 0 then
    for Element in TempArray.Enum.Forward do
      Push(Element^);
end;

procedure TAnyArray.Reverse;
var
  Element: PAnyValue;
  TempArray: IAnyArray;
begin
  TempArray := Clone;
  Clear;

  for Element in TempArray.Enum.Reverse do
    Push(Element^);
end;

procedure TAnyArray.Push(const Value: array of TAnyValue);
var
  I: Integer;
begin
  for I := 0 to Length(Value) - 1 do
    Push(Value[I]);
end;

procedure TAnyArray.Push(const Value: TAnyValue);
var
  LastSlice: PArraySlice;
begin
  LastSlice := GetLastSlice;

  if (FSliceCount = 0) or ((LastSlice.Last - LastSlice.Start) >= FSliceSize) then
  begin
    Grow;
    LastSlice := GetLastSlice;
  end
  else if LastSlice.Last = Length(LastSlice.Data) then
    RepositionSliceData(LastSlice);

  CopyAnyValue(@LastSlice.Data[LastSlice.Last], @Value);
  Inc(LastSlice.Last);
  Inc(FSumCount)
end;

procedure TAnyArray.SaveToStream(const Stream: TStream; const SaveCallback: TAnyValuesSaveCallback);
begin
  DoSaveToStream(Stream, @SaveCallback <> nil, SaveCallback)
end;

{$IF CompilerVersion >= 20}
procedure TAnyArray.SaveToStream(const Stream: TStream; const SaveFunc: TAnyValuesSaveFunc);
begin
  DoSaveToStream(Stream, True, SaveFunc)
end;
{$IFEND}

procedure TAnyArray.SetItem(const Idx: Integer; const Value: TAnyValue);
var
  SliceIndex: Integer;
  ItemSlice: PArraySlice;
begin
  if FSliceCount = 1 then
  begin
    CopyAnyValue(@FSliceData[0].Data[Idx], @Value);
    Exit;
  end;

  ItemSlice := GetSliceByIndex(Idx, SliceIndex);
  CopyAnyValue(@ItemSlice.Data[SliceIndex], @Value);
end;

procedure TAnyArray.SetArrayMode(const Value: TArrayMode);
begin
  if FArrayMode <> Value then
  begin
    FArrayMode := Value;
    Clear;

    case FArrayMode of
      amDynamicArray: DoInitializeArray;
      amSlicedArray: DoInitializeArray(cDefArraySliceSize);
    end
  end;
end;

procedure TAnyArray.SetSliceBufferMpl(const Value: Double);
begin
  if FArrayMode = amDynamicArray then
    raise Exception.Create('Cannot set slice size for amDynamicArray');

  if FSliceBufferMpl <> Value then
  begin
    FSliceBufferMpl := Value;
    RestructureSlicedArray;
  end;
end;

procedure TAnyArray.SetSliceCount(const Value: Integer);
var
  I: Integer;
begin
  if Value <> FSliceCount then
  begin
    if FSliceCount < Value then
    begin
      for I := FSliceCount to Value - 1 do
      begin
        DoAcquireNewSlice;
        SetLength(FSliceData[I].Data, Trunc(FSliceSize * FSliceBufferMpl));
        FSliceData[I].Start := (Length(FSliceData[I].Data) div 2) - FSliceSize div 2;
        FSliceData[I].Last := FSliceData[I].Start;
        FSliceData[I].Index := I;
      end;
    end;
  end;
end;

procedure TAnyArray.SetSliceSize(const Value: Integer);
begin
  if FSliceSize < 10 then
    raise Exception.Create('Slice size cannot be smaller then 10');

  if FArrayMode = amDynamicArray then
    raise Exception.Create('Cannot set slice size for amDynamicArray');

  if FSliceSize <> Value then
  begin
    FSliceSize := Value;
    RestructureSlicedArray;
  end;
end;

function TAnyArray.Shift: TAnyValue;
begin
  Result.Clear;

  if FSumCount > 0 then
  begin
    CopyAnyValue(@Result, @FSliceData[0].Data[0]);
    DeleteIndex(0);
  end;
end;

function TAnyArray.Slice(Start, Stop: Integer): IAnyArray;
var
  I: Integer;
  ItemIndex: Integer;
  ItemSlice: PArraySlice;
begin
  Result := TAnyArray.Create;

  if Stop = -1 then
    Stop := FSumCount;
  if Stop > FSumCount - 1 then
    Stop := FSumCount;
  if Start < 0 then
    Start := 0;

  // get the correct slice and index values
  ItemSlice := GetSliceByIndex(Start, ItemIndex);

  for I := Start to Stop - 1 do
  begin
    Result.Push(ItemSlice.Data[ItemIndex]);
    Inc(ItemIndex);

    if ItemIndex > (ItemSlice.Last - ItemSlice.Start) then
    begin
      if ItemSlice.Index = FSliceCount - 1 then
        Exit;

      ItemSlice := FSliceData[ItemSlice.Index + 1];
      ItemIndex := 0;
    end;
  end;
end;

procedure TAnyArray.Sort(const Compare: TAnyValuesCompareCallback);
begin
  if Count > 0 then
    SlicedQuickSort(Self, 0, FSumCount - 1, Compare);
end;

procedure TAnyArray.Unshift(const Value: TAnyValue);
begin
  if FSumCount > 0 then
    Insert(0, Value)
  else
    Push(Value);
end;

procedure TAnyArray.Unshift(const Value: array of TAnyValue);
begin
  if FSumCount > 0 then
    Insert(0, Value)
  else
    Push(Value);
end;

procedure TAnyArray.Unshift(const Value: string; const Delimiter: Char);
begin
  if FSumCount > 0 then
    Insert(0, Value, Delimiter)
  else
    Push(Value, Delimiter);
end;

{$IF CompilerVersion >= 20}
procedure TAnyArray.Sort(const Compare: TAnyValuesCompareFunc);
begin
  if Count > 0 then
    SlicedQuickSort(Self, 0, FSumCount - 1, Compare);
end;
{$IFEND}

function TAnyArray.GetArrayMode: TArrayMode;
begin
  Result := FArrayMode;
end;

function TAnyArray.GetAsString(const Delimiter: Char): string;
var
  Element: PAnyValue;
  ValueList: TStringList;
begin
  ValueList := TStringList.Create;
  try
    ValueList.StrictDelimiter := True;
    ValueList.Delimiter := Delimiter;

    for Element in Enum.Forward do
      ValueList.Add(Element.AsString);

    Result := ValueList.DelimitedText;
  finally
    ValueList.Free;
  end;
end;

// ********************************************************
// BEGIN of improved TAnyValue specific System.pas routines
// ********************************************************

procedure InitializeAnyValue(p: Pointer; typeInfo: Pointer);
begin
  // set type to none and erase all data
  ZeroMemory(p, SizeOf(TAnyValue))
end;

{$IFNDEF AnyValue_HookingOff}
procedure FinalizeAnyValue(p : PAnyValue);
begin
  if p.ValueType <> avtNone then
  begin
    case p.ValueType of
      avtVariant:
        begin
          Finalize(PVariant(PValueData(@p.ValueData).VPointer)^);
          FreeMem(PValueData(@p.ValueData).VPointer);
        end;
      avtString: Finalize(string(PValueData(@p.ValueData).VPointer));
      avtAnsiString: Finalize(AnsiString(PValueData(@p.ValueData).VPointer));
      avtWideString: Finalize(WideString(PValueData(@p.ValueData).VPointer));
      avtNamedValue: Dispose(PNamedValue(PValueData(@p.ValueData).VPointer));
      avtInterface, avtArray: Finalize(IInterface(PValueData(@p.ValueData).VPointer));
    {$IFNDEF CPUX64}
      avtFloat: FreeMem(PValueData(@p.ValueData).VPointer);
    {$ENDIF}
    end;

    ZeroMemory(p, SizeOf(TAnyValue))
  end;
end;

procedure CopyAnyValue(dest, source : PAnyValue);
var
  dstData: PValueData;
  srcData: PValueData;
begin
  dstData := PValueData(@dest.ValueData);
  srcData := PValueData(@source.ValueData);

  if dest.ValueType <> source.ValueType then
  begin
    // only finalize if there is a type
    if dest.ValueType <> avtNone then
      FinalizeAnyValue(dest);
    // assign the value type for dest
    dest.ValueType := source.ValueType;

    case dest.ValueType of
      avtNamedValue: New(PNamedValue(dstData.VPointer));
      avtArray: IAnyArray(dstData.VPointer) := TAnyArray.Create;
      avtVariant:
        begin
          GetMem(dstData.VPointer, SizeOf(Variant));
          Initialize(PVariant(dstData.VPointer)^);
        end;
    {$IFNDEF CPUX64}
      avtFloat: GetMem(dstData.VPointer, SizeOf(Extended));
    {$ENDIF}
    end;
  end;

  case source.ValueType of
  {$IFNDEF CPUX64}
    avtFloat: PExtended(dstData.VPointer)^ := PExtended(srcData.VPointer)^;
  {$ENDIF}
    avtString: string(dstData.VPointer) := string(srcData.VPointer);
    avtVariant: PVariant(dstData.VPointer)^ := PVariant(srcData.VPointer)^;
    avtInterface: IInterface(dstData.VPointer) := IInterface(srcData.VPointer);
    avtWideString: WideString(dstData.VPointer) := WideString(srcData.VPointer);
    avtAnsiString: AnsiString(dstData.VPointer) := AnsiString(srcData.VPointer);
    avtNamedValue: PNamedValue(dstData.VPointer)^ := PNamedValue(srcData.VPointer)^;
    avtArray: IAnyArray(dstData.VPointer).Assign(IAnyArray(srcData.VPointer));
  else
    dstData^ := srcData^;
  end;
end;
{$ELSE}
procedure FinalizeAnyValue(p : PAnyValue);
begin
  p^.IntfData := nil;
  ZeroMemory(p, SizeOf(TAnyValue))
end;

procedure CopyAnyValue(dest, source : PAnyValue);
begin
  dest^ := source^;
end;
{$ENDIF}

// ******************************************************
// END of improved TAnyValue specific System.pas routines
// ******************************************************

// ********************************************************
// BEGIN of custom routines that are targets of detours
// ********************************************************

{$IFNDEF AnyValue_HookingOff}
procedure CustomInitializeRecord(p: Pointer; typeInfo: Pointer);
begin
  if vValueInfo = typeInfo then
    InitializeAnyValue(PAnyValue(p), typeInfo)
  else
    OldInitializeRecord(p, typeInfo);
end;

procedure CustomFinalizeRecord(p: Pointer; typeInfo: Pointer);
begin
  if vValueInfo = typeInfo then
    FinalizeAnyValue(PAnyValue(p))
  else
    OldFinalizeRecord(p, typeInfo);
end;

procedure CustomCopyRecord(Dest, Source, TypeInfo: Pointer);
begin
  if vValueInfo = typeInfo then
    CopyAnyValue(PAnyValue(Dest), PAnyValue(Source))
  else
    OldCopyRecord(Dest, Source, typeInfo);
end;

procedure CustomAddRefRecord(p: Pointer; typeInfo: Pointer);
begin
  if not (vValueInfo = typeInfo) then
    OldAddRefRecord(p, typeInfo);
end;
{$ENDIF}

// ********************************************************
// END of custom routines that are targets of detours
// ********************************************************

// ********************************************************
// BEGIN functions that get the adress of detour targets
// ********************************************************

{$IFNDEF AnyValue_HookingOff}
function GetCopyRecordAddress: Pointer;
asm
{$IFDEF CPUX64}
  mov rcx, offset System.@CopyRecord;
  mov @Result, rcx;
{$ELSE}
  mov @Result, offset System.@CopyRecord;
{$ENDIF}
end;

function GetFinalizeRecordAddress: Pointer;
asm
{$IFDEF CPUX64}
  mov rcx, offset System.@FinalizeRecord;
  mov @Result, rcx;
{$ELSE}
  mov @Result, offset System.@FinalizeRecord;
{$ENDIF}
end;

function GetInitializeRecordAddress: Pointer;
asm
{$IFDEF CPUX64}
  mov rcx, offset System.@InitializeRecord;
  mov @Result, rcx;
{$ELSE}
  mov @Result, offset System.@InitializeRecord;
{$ENDIF}
end;

function GetAddRefRecordAddress: Pointer;
asm
{$IFDEF CPUX64}
  mov rcx, offset System.@AddRefRecord;
  mov @Result, rcx;
{$ELSE}
  mov @Result, offset System.@AddRefRecord;
{$ENDIF}
end;
{$ENDIF}

// ********************************************************
// END functions that get the adress of detour targets
// ********************************************************

{$IFNDEF AnyValue_HookingOff}
procedure InitializeHooks;
begin
  vValueInfo := TypeInfo(TAnyValue);

  if not IsHooked then
  begin
    IsHooked := True;
    @OldCopyRecord := InterceptCreate(GetCopyRecordAddress, @CustomCopyRecord);
    @OldAddRefRecord := InterceptCreate(GetAddRefRecordAddress, @CustomAddRefRecord);
    @OldFinalizeRecord := InterceptCreate(GetFinalizeRecordAddress, @CustomFinalizeRecord);
    @OldInitializeRecord := InterceptCreate(GetInitializeRecordAddress, @CustomInitializeRecord);
  end;
end;

procedure FinalizeHooks;
begin
  if IsHooked then
  begin
    InterceptRemove(@OldInitializeRecord, @CustomInitializeRecord);
    InterceptRemove(@OldFinalizeRecord, @CustomFinalizeRecord);
    InterceptRemove(@OldAddRefRecord, @CustomAddRefRecord);
    InterceptRemove(@OldCopyRecord, @CustomCopyRecord);
    IsHooked := False;
  end;
end;
{$ENDIF}

{$IFDEF AnyValue_HookingOff}
{ TAnyValueStringData }

constructor TAnyValueStringData.Create(const Value: string);
begin
  FValue := Value;
end;

function TAnyValueStringData.GetValue: string;
begin
  Result := FValue;
end;

procedure TAnyValueStringData.SetValue(const Value: string);
begin
  FValue := Value;
end;

{ TAnyValueWideStringData }

constructor TAnyValueWideStringData.Create(const Value: WideString);
begin
  FValue := Value;
end;

function TAnyValueWideStringData.GetValue: WideString;
begin
  Result := FValue;
end;

procedure TAnyValueWideStringData.SetValue(const Value: WideString);
begin
  FValue := Value;
end;

{ TAnyValueExtendedData }

constructor TAnyValueExtendedData.Create(const Value: Extended);
begin
  FValue := Value;
end;

function TAnyValueExtendedData.GetValue: Extended;
begin
  Result := FValue;
end;

procedure TAnyValueExtendedData.SetValue(const Value: Extended);
begin
  FValue := Value;
end;

{$IFDEF UNICODE}
{ TAnyValueAnsiStringData }

constructor TAnyValueAnsiStringData.Create(const Value: AnsiString);
begin
  FValue := Value;
end;

function TAnyValueAnsiStringData.GetValue: AnsiString;
begin
  Result := FValue;
end;

procedure TAnyValueAnsiStringData.SetValue(const Value: AnsiString);
begin
  FValue := Value;
end;
{$ENDIF}

{ TAnyValueVariantData }

constructor TAnyValueVariantData.Create(const Value: Variant);
begin
  FValue := Value;
end;

function TAnyValueVariantData.GetValue: Variant;
begin
  Result := FValue;
end;

procedure TAnyValueVariantData.SetValue(const Value: Variant);
begin
  FValue := Value;
end;

{ TAnyValueNamedData }

function TAnyValueNamedData.GetAsPNamedValue: PNamedValue;
begin
  Result := PNamedValue(@FValue)
end;

function TAnyValueNamedData.GetValue: TNamedValue;
begin
  Result := FValue;
end;

procedure TAnyValueNamedData.SetValue(const Value: TNamedValue);
begin
  FValue := Value;
end;
{$ENDIF}

initialization
  TAnyValue.RemoveWarnings;
{$IFNDEF AnyValue_HookingOff}
  InitializeHooks;
{$ENDIF}

finalization
{$IFNDEF AnyValue_HookingOff}
  FinalizeHooks;
{$ENDIF}

end.
