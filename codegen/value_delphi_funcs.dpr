program value_delphi_funcs;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  Tiny.Rtti,
  uCommon;

type
  TUsedType = record
    RttiType: TRttiType;
    FuncName: string;
    TypeName: string;
    BufferName: string;
  end;
  PUsedType = ^TUsedType;

const
  USED_TYPES: array[0..19] of TUsedType = (
    (RttiType: rtPointer; FuncName: 'Pointer'; TypeName: 'Pointer'; BufferName: 'VPointer'),
    (RttiType: rtBoolean8; FuncName: 'Boolean'; TypeName: 'Boolean'; BufferName: 'VBoolean'),
    (RttiType: rtInt32; FuncName: 'Integer'; TypeName: 'Integer'; BufferName: 'VInt32'),
    (RttiType: rtUInt32; FuncName: 'Cardinal'; TypeName: 'Cardinal'; BufferName: 'VUInt32'),
    (RttiType: rtInt64; FuncName: 'Int64'; TypeName: 'Int64'; BufferName: 'VInt64'),
    (RttiType: rtUInt64; FuncName: 'UInt64'; TypeName: 'UInt64'; BufferName: 'VUInt64'),
    (RttiType: rtCurrency; FuncName: 'Currency'; TypeName: 'Currency'; BufferName: 'VCurrency'),
    (RttiType: rtFloat; FuncName: 'Single'; TypeName: 'Single'; BufferName: 'VSingle'),
    (RttiType: rtDouble; FuncName: 'Double'; TypeName: 'Double'; BufferName: 'VDouble'),
    (RttiType: rtLongDouble80; FuncName: 'Extended'; TypeName: 'Extended'; BufferName: 'VLongDouble'),
    (RttiType: rtDate; FuncName: 'Date'; TypeName: 'TDate'; BufferName: 'VDouble'),
    (RttiType: rtTime; FuncName: 'Time'; TypeName: 'TTime'; BufferName: 'VDouble'),
    (RttiType: rtDateTime; FuncName: 'DateTime'; TypeName: 'TDateTime'; BufferName: 'VDouble'),
    (RttiType: rtTimeStamp; FuncName: 'TimeStamp'; TypeName: 'TimeStamp'; BufferName: 'VInt64'),
    (RttiType: rtSBCSString; FuncName: 'AnsiString'; TypeName: 'AnsiString'; BufferName: ''),
    (RttiType: rtUnicodeString; FuncName: 'UnicodeString'; TypeName: 'UnicodeString'; BufferName: ''),
    (RttiType: rtObject; FuncName: 'Object'; TypeName: 'TObject'; BufferName: 'VPointer'),
    (RttiType: rtInterface; FuncName: 'Interface'; TypeName: 'IInterface'; BufferName: ''),
    (RttiType: rtClassRef; FuncName: 'Class'; TypeName: 'TClass'; BufferName: 'VClass'),
    (RttiType: rtBytes; FuncName: 'Bytes'; TypeName: 'TBytes'; BufferName: '')
  );


var
  i: Integer;
  Instance: string;
  Managed: Boolean;
  RttiTypeName: string;
  GetterFlag: Boolean;
  OperatorFlag: Boolean;
  UsedType: PUsedType;
  List: TStringList;

procedure __Add(const S: string);
begin
  Writeln(S);
  List.Add(S);
end;

procedure WriteSetter(const ARttiType: TRttiType; const AFuncName, ATypeName, ABufferName: string;
  const AOperator: Boolean);
var
  LManagedEx: Boolean;
  LOptions: string;
  LCopyFunc: string;
begin
  LManagedEx := (Managed) and (ARttiType <> rtInterface);

  if (AOperator) then
  begin
    AddFmt('class operator TValue.Implicit(const AValue: %s): TValue;', [ATypeName]);
  end else
  begin
    AddFmt('procedure TValue.Set%s(const AValue: %s);', [AFuncName, ATypeName]);
  end;

  Add('var');
  if (ARttiType <> rtInterface) then
  begin
    Add('  LManagedData: Pointer;');
  end;
  if (LManagedEx) then
  begin
    Add('  LTarget: Pointer;');
  end;
  if (Managed) then
  begin
    Add('  LStored: record');
    Add('    Source: NativeUInt;');
    Add('  end;');
  end;

  Add('begin');
  begin
    if (LManagedEx) then
    begin
      Add('  LStored.Source := NativeUInt(Pointer(AValue));');
      Add('');
    end;

    if (ARttiType = rtInterface) then
    begin
      AddFmt('  %sFExType.Options := Ord(rtInterface);', [Instance]);
      AddFmt('  %sFExType.CustomData := nil;', [Instance]);
      AddFmt('  if (Pointer(%sFManagedData) <> Pointer(AValue)) then', [Instance]);
      Add('  begin');
      Add('    LStored.Source := NativeUInt(Pointer(AValue));');
      AddFmt('    RTTI_COPY_FUNCS[RTTI_COPYINTERFACE_FUNC](nil, @%sFManagedData, @LStored.Source);', [Instance]);
      Add('  end;');
    end else
    if (Managed{LManagedEx}) then
    begin
      if (ARttiType = rtSBCSString) then
      begin
        LOptions := 'DefaultSBCSStringOptions';
      end else
      begin
        LOptions := Format('Ord(%s)', [RttiTypeName]);
      end;

      case ARttiType of
        rtSBCSString: LCopyFunc := 'RTTI_COPYSTRING_FUNC';
        rtUnicodeString: LCopyFunc := '{$ifdef UNICODE}RTTI_COPYSTRING_FUNC{$else}RTTI_COPYWIDESTRING_FUNC{$endif}';
        rtBytes: LCopyFunc := 'RTTI_COPYDYNARRAYSIMPLE_FUNC';
      end;

      AddFmt('  if (%sFExType.Options = %s) then', [Instance, LOptions]);
      Add('  begin');
      AddFmt('    LManagedData := Pointer(%sFManagedData);', [Instance]);
      Add('    if (Assigned(LManagedData)) then');
      Add('    begin');
      Add('      LTarget := @PRttiContainerInterface(LManagedData).Value;');
      Add('      if (PPointer(LTarget)^ <> Pointer(AValue)) then');
      Add('      begin');
      AddFmt('        RTTI_COPY_FUNCS[%s](nil, LTarget, @LStored.Source);', [LCopyFunc]);
      Add('      end;');
      Add('      Exit;');
      Add('    end;');
      Add('  end else');
      Add('  begin');
      AddFmt('    %sFExType.Options := %s;', [Instance, LOptions]);
      Add('  end;');
      Add('');
      AddFmt('  %sFExType.CustomData := nil;', [Instance]);
      AddFmt('  %sInternalInitData(RTTI_TYPE_RULES[%s], @LStored.Source);', [Instance, RttiTypeName]);
    end else
    begin
      AddFmt('  %sFBuffer.%s := AValue;', [Instance, ABufferName]);
      AddFmt('  %sFExType.Options := Ord(%s);', [Instance, RttiTypeName]);

      case ARttiType of
        rtInt32: AddFmt('  %sFExType.RangeData := @INT32_TYPE_DATA;', [Instance]);
        rtUInt32: AddFmt('  %sFExType.RangeData := @UINT32_TYPE_DATA;', [Instance]);
        rtInt64: AddFmt('  %sFExType.RangeData := @INT64_TYPE_DATA;', [Instance]);
        rtUInt64: AddFmt('  %sFExType.RangeData := @UINT64_TYPE_DATA;', [Instance]);
      else
        AddFmt('  %sFExType.CustomData := nil;', [Instance]);
      end;

      Add('');
      AddFmt('  LManagedData := Pointer(%sFManagedData);', [Instance]);
      Add('  if (LManagedData <> @RTTI_DUMMY_INTERFACE_DATA) then');
      Add('  begin');
      AddFmt('    Pointer(%sFManagedData) := @RTTI_DUMMY_INTERFACE_DATA;', [Instance]);
      Add('    if (Assigned(LManagedData)) then');
      Add('    begin');
      AddFmt('      %sInternalReleaseInterface(LManagedData);', [Instance]);
      Add('    end;');
      Add('  end;');
    end;
  end;
  Add('end;');
end;

procedure WriteGetter(const ARttiType: TRttiType; const AFuncName, ATypeName, ABufferName: string;
  const AOperator: Boolean);
var
  LManagedEx: Boolean;
  LCondition: string;
  LValue: string;
  LInternalFunc: string;
  LCopyFunc: string;
begin
  LManagedEx := (Managed) and (ARttiType <> rtInterface);

  if (AOperator) then
  begin
    AddFmt('class operator TValue.Implicit(const AValue: TValue): %s;', [ATypeName]);
  end else
  begin
    AddFmt('function TValue.Get%s: %s;', [AFuncName, ATypeName]);
  end;

  if (Managed) then
  begin
    Add('var');
    Add('  LManagedData: Pointer;');
    if (LManagedEx) then
    begin
      Add('  LSource: Pointer;');
    end;
  end;

  if (ARttiType = rtInterface) then
  begin
    LCondition := Format('(not Assigned(LManagedData)) or (%sFExType.BaseType in [rtInterface, rtClosure])', [Instance]);
    LInternalFunc := Format('%sInternalGetInterface(Result)', [Instance]);
  end else
  if (Managed{LManagedEx}) then
  begin
    LCondition := Format('(Assigned(LManagedData)) and (%sFExType.BaseType = %s)', [Instance, RttiTypeName]);
    LInternalFunc := Format('%sInternalGet%s(Result)', [Instance, AFuncName]);
  end else
  begin
    if (ARttiType = rtLongDouble80) then
    begin
      LCondition := Format('(Assigned(%sFManagedData)) and (%sFExType.BaseType in [rtLongDouble80, rtLongDouble96, rtLongDouble128])', [Instance, Instance]);
    end else
    begin
      LCondition := Format('(Assigned(%sFManagedData)) and (%sFExType.BaseType = %s)', [Instance, Instance, RttiTypeName]);
    end;

    LValue := Format('%sFBuffer.%s', [Instance, ABufferName]);
    LInternalFunc := Format('Result := %sInternalGet%s', [Instance, AFuncName]);
  end;

  Add('begin');
  if (Managed) then
  begin
    AddFmt('  LManagedData := Pointer(%sFManagedData);', [Instance]);
  end;
  AddFmt('  if %s then', [LCondition]);
  Add('  begin');
  if (ARttiType = rtInterface) then
  begin
    Add('    {$ifdef WEAKINTFREF}');
    Add('      Pointer(Result) := LManagedData;');
    Add('    {$else}');
    Add('      if (LManagedData <> Pointer(Result)) then');
    Add('      begin');
    AddFmt('        RTTI_COPY_FUNCS[RTTI_COPYINTERFACE_FUNC](nil, @Result, @%sFManagedData);', [Instance]);
    Add('      end;');
    Add('    {$endif}');
  end else
  if (Managed{LManagedEx}) then
  begin
    case ARttiType of
      rtSBCSString: LCopyFunc := 'RTTI_COPYSTRING_FUNC';
      rtUnicodeString: LCopyFunc := '{$ifdef UNICODE}RTTI_COPYSTRING_FUNC{$else}RTTI_COPYWIDESTRING_FUNC{$endif}';
      rtBytes: LCopyFunc := 'RTTI_COPYDYNARRAYSIMPLE_FUNC';
    end;

    Add('    LSource := @PRttiContainerInterface(LManagedData).Value;');
    Add('    if (PPointer(LSource)^ <> Pointer(Result)) then');
    Add('    begin');
    AddFmt('      RTTI_COPY_FUNCS[%s](nil, @Result, LSource);', [LCopyFunc]);
    Add('    end;');
  end else
  begin
    AddFmt('    Result := %s;', [LValue]);
  end;
  Add('  end else');
  Add('  begin');
  AddFmt('    %s;', [LInternalFunc]);
  Add('  end;');
  Add('end;');
end;


begin
  try
    List := TStringList.Create;
    try
      uCommon.AddProc := __Add;

      for OperatorFlag := False to True do
      begin
        if (OperatorFlag) then
        begin
          Add('{$ifdef OPERATORSUPPORT}');
        end;

        for GetterFlag := False to True do
        begin
          if (OperatorFlag) then
          begin
            if (GetterFlag) then
            begin
              Instance := 'AValue.';
            end else
            begin
              Instance := 'Result.';
            end;
          end else
          begin
            Instance := '';
          end;

          for i := Low(USED_TYPES) to High(USED_TYPES) do
          begin
            UsedType := @USED_TYPES[i];
            Managed := UsedType.RttiType in [rtSBCSString, rtUnicodeString, rtInterface, rtBytes];
            RttiTypeName := GetEnumName(TypeInfo(TRttiType), Ord(UsedType.RttiType)).AsString;

            if (OperatorFlag) and (UsedType.RttiType = rtLongDouble80) then
            begin
              Add('{$ifdef EXTENDEDSUPPORT}');
            end;

            if (GetterFlag) then
            begin
              WriteGetter(UsedType.RttiType, UsedType.FuncName, UsedType.TypeName,
                UsedType.BufferName, OperatorFlag);
            end else
            begin
              WriteSetter(UsedType.RttiType, UsedType.FuncName, UsedType.TypeName,
                UsedType.BufferName, OperatorFlag);
            end;

            if (OperatorFlag) and (UsedType.RttiType = rtLongDouble80) then
            begin
              Add('{$endif}');
            end;

            Add('');
          end;
        end;

        if (OperatorFlag) then
        begin
          Add('{$endif}');
        end;
      end;

      List.SaveToFile('value_delphi_funcs.txt');
    finally
      List.Free;
    end;


  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

  Write('Press Enter to quit');
  Readln;
end.
