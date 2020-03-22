
{ RTTI defines }

{$ifdef RTTION_ALL}
  {$define RTTION}
  {$define RTTION_FIELDS_ALL}
  {$define RTTION_PROPERTIES_ALL}
  {$define RTTION_METHODS_ALL}
{$endif}
{$ifdef RTTION_FIELDS_ALL}
  {$define RTTION_FIELDS}
{$endif}
{$ifdef RTTION_PROPERTIES_ALL}
  {$define RTTION_PROPERTIES}
{$endif}
{$ifdef RTTION_METHODS_ALL}
  {$define RTTION_METHODS}
{$endif}
{$ifdef RTTION}
  {$define RTTION_INTERFACE}
  {$define RTTION_FIELDS}
  {$define RTTION_PROPERTIES}
  {$define RTTION_METHODS}
{$endif}


{ Compiler options }

{$ifdef FPC}
  {$MODE DELPHIUNICODE}
  {$ASMMODE INTEL}
  {$define INLINESUPPORT}
  {$define INLINESUPPORTSIMPLE}
  {$define OPERATORSUPPORT}
  {$define STATICSUPPORT}
  {$define SMALLOBJECTSUPPORT}
  {$define CLASSCONSTRUCTORSUPPORT}
  {$define GENERICSUPPORT}
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
    {$WARN SYMBOL_DEPRECATED OFF}
  {$ifend}
  {$if CompilerVersion >= 20}
    {$define INLINESUPPORT}
    {$define SMALLOBJECTSUPPORT}
    {$define CLASSCONSTRUCTORSUPPORT}
  {$ifend}
  {$if CompilerVersion >= 17}
    {$define INLINESUPPORTSIMPLE}
  {$ifend}
  {$if CompilerVersion >= 18}
    {$define OPERATORSUPPORT}
  {$ifend}
  {$if CompilerVersion >= 18.5}
    {$define STATICSUPPORT}
  {$ifend}
  {$if CompilerVersion >= 20}
    {$define GENERICSUPPORT}
    {$define GENERICMETHODSUPPORT}
    {$define SYSARRAYSUPPORT}
  {$ifend}
  {$if CompilerVersion < 23}
    {$define CPUX86}
  {$ifend}
  {$if CompilerVersion >= 23}
    {$define UNITSCOPENAMES}
    {$define RETURNADDRESS}
  {$ifend}
  {$if CompilerVersion >= 21}
    {$WEAKLINKRTTI ON}
    {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
    {$define EXTENDEDRTTI}
  {$ifend}
  {$if CompilerVersion >= 33}
    {$define MANAGEDRECORDS}
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
  {$if Defined(NEXTGEN)}
    {$POINTERMATH ON}
  {$ifend}
{$endif}
{$if (not Defined(FPC)) and Defined(IOS) and Defined(CPUARM32) and (CompilerVersion < 28)}
  {$define ARM_NO_VFP_USE}
{$ifend}
{$if Defined(CPUX86) or (Defined(CPUX64) and not Defined(MSWINDOWS))}
  {$define EXTENDEDSUPPORT}
{$ifend}
{$if (not Defined(FPC)) and Defined(POSIX64)}
  {$define HFASUPPORT}
{$ifend}
{$if Defined(FPC) or Defined(MSWINDOWS)}
  {$define OBJLINKSUPPORT}
{$ifend}
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
{$if Defined(CPUINTEL) and Defined(POSIX)}
  {$ifdef CPUX86}
    {$define POSIXINTEL32}
  {$else}
    {$define POSIXINTEL64}
  {$endif}
{$ifend}
{$if Defined(CPUX64) or Defined(CPUARM64)}
  {$define LARGEINT}
{$else}
  {$define SMALLINT}
{$ifend}
{$ifdef KOL_MCK}
  {$define KOL}
{$endif}


{ RTTI including }

{$ifdef RTTION_INTERFACE}
  {$M+}
{$endif}
{$ifdef EXTENDEDRTTI}
  {$ifdef RTTION_FIELDS}
    {$ifdef RTTION_FIELDS_ALL}
      {$RTTI EXPLICIT FIELDS([vcPrivate, vcProtected, vcPublic, vcPublished])}
    {$else}
      {$RTTI EXPLICIT FIELDS([vcPublic, vcPublished])}
    {$endif}
  {$endif}
  {$ifdef RTTION_PROPERTIES}
    {$ifdef RTTION_PROPERTIES_ALL}
      {$RTTI EXPLICIT PROPERTIES([vcPrivate, vcProtected, vcPublic, vcPublished])}
    {$else}
      {$RTTI EXPLICIT PROPERTIES([vcPublic, vcPublished])}
    {$endif}
  {$endif}
  {$ifdef RTTION_METHODS}
    {$ifdef RTTION_METHODS_ALL}
      {$RTTI EXPLICIT METHODS([vcPrivate, vcProtected, vcPublic, vcPublished])}
    {$else}
      {$RTTI EXPLICIT METHODS([vcPublic, vcPublished])}
    {$endif}
  {$endif}
{$endif}
