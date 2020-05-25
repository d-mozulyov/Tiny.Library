program InvokeTypes;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  uCommon;

var
  List: TStringList;

procedure Add(const S: string);
begin
  Writeln(S);
  List.Add(S);
end;

procedure AddFmt(const AFmtStr: string; const AArgs: array of const);
begin
  Add(Format(AFmtStr, AArgs));
end;

begin
  try
    List := TStringList.Create;
    try
      ForEachInvokeDecl(
        procedure(const ADecl: TInvokeDecl; const ADeclKind, ADeclName: string)
        var
          LTypes: TInvokeTypes;
        begin
          LTypes := [itOutputGeneral, itSingle, itDouble, itFPU, itHFA, itReturnPtr];
          if (ADecl <> idRegister) then
          begin
            LTypes := LTypes - [itHFA, itReturnPtr];
          end;

          ForEachInvokeType(
            procedure(const AType: TInvokeType; const ATypeKind, ATypeName: string)
            var
              LSignature: TInvokeSignature;
            begin
              case ADecl of
                idRegister: LSignature := isGeneralExtended;
                idMicrosoft: LSignature := isMicrosoftGeneralExtended;
              else
                LSignature := isGeneral;
              end;

              ForEachInvokeSignature(
                procedure(const ASignatureTitle, ASignature: string; const AGenCount, AExtCount, AArgs: Integer)
                begin
                  AddFmt('typedef %s %s (*func_%s)(%s);',
                    [
                      ADeclName,
                      ATypeKind,
                      InvokeFuncName(ADeclKind, ATypeKind, ASignatureTitle),
                      ASignature
                    ]);
                end, LSignature, (ADecl = idRegister), ADecl in [idCdecl, idStdCall]);
            end, LTypes);
        end, [idRegister, idMicrosoft, idCdecl, idStdCall], True);

        // safecall
        ForEachInvokeSignature(
          procedure(const ASignatureTitle, ASignature: string; const AGenCount, AExtCount, AArgs: Integer)
          begin
            AddFmt('typedef STDCALL gen (*func_safecall_%s)(%s);',
              [
                ASignatureTitle,
                ASignature
              ]);
          end, isMicrosoftGeneralExtended, True, False);

      List.SaveToFile('..\..\c\rtti\tiny.invoke.functypes.inc');
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
