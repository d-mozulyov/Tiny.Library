unit Tiny.Namespace;

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
{ repository: https://github.com/d-mozulyov/Tiny.Rtti                          }
{******************************************************************************}

{$I TINY.DEFINES.inc}

interface
uses
  Tiny.Rtti, Tiny.Invoke, Tiny.Properties, UniConv;


type

{ TRttiNamespace object
  Universal storage for arbitrary namespace }

  TRttiNamespaceVmt = class(TRttiContextVmt)

  end;
  TRttiNamespaceVmtClass = class of TRttiNamespaceVmt;

  PRttiNamespaceVisibility = ^TRttiNamespaceVisibility;
  {$A1}
  TRttiNamespaceVisibility = object
    Fields: TMemberVisibilities;
    Properties: TMemberVisibilities;
    Methods: TMemberVisibilities;
  end;
  {$A4}

  PRttiNamespace = ^TRttiNamespace;
  {$A1}
  TRttiNamespace = object(TRttiContext)
  protected

  public
    Visibility: TRttiNamespaceVisibility;

    procedure Init(const AVmt: TRttiNamespaceVmtClass = nil; const AThreadSync: Boolean = False);
  end;
  {$A4}


implementation


{ TRttiNamespace }

procedure TRttiNamespace.Init(const AVmt: TRttiNamespaceVmtClass; const AThreadSync: Boolean);
const
  DEFAULT_VISIBILITY = [mvPublic, mvPublished];
var
  LVmt: TRttiNamespaceVmtClass;
begin
  LVmt := AVmt;
  if (not Assigned(LVmt)) then
  begin
    LVmt := TRttiNamespaceVmt;
  end;
  inherited Init(LVmt, AThreadSync);

  Visibility.Fields := DEFAULT_VISIBILITY;
  Visibility.Properties := DEFAULT_VISIBILITY;
  Visibility.Methods := DEFAULT_VISIBILITY;
end;

initialization
  {$ifdef UNICODE}
  @Tiny.Rtti._utf8_equal_utf8_ignorecase := Pointer(@UniConv.utf8_equal_utf8_ignorecase);
  {$endif}

end.
