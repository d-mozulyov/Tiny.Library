
procedure intercept_jump0;
const
  ITEM_OFFSET = 0 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump1;
const
  ITEM_OFFSET = 1 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump2;
const
  ITEM_OFFSET = 2 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump3;
const
  ITEM_OFFSET = 3 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump4;
const
  ITEM_OFFSET = 4 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump5;
const
  ITEM_OFFSET = 5 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump6;
const
  ITEM_OFFSET = 6 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump7;
const
  ITEM_OFFSET = 7 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump8;
const
  ITEM_OFFSET = 8 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump9;
const
  ITEM_OFFSET = 9 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump10;
const
  ITEM_OFFSET = 10 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump11;
const
  ITEM_OFFSET = 11 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump12;
const
  ITEM_OFFSET = 12 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump13;
const
  ITEM_OFFSET = 13 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump14;
const
  ITEM_OFFSET = 14 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump15;
const
  ITEM_OFFSET = 15 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump16;
const
  ITEM_OFFSET = 16 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump17;
const
  ITEM_OFFSET = 17 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump18;
const
  ITEM_OFFSET = 18 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump19;
const
  ITEM_OFFSET = 19 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump20;
const
  ITEM_OFFSET = 20 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump21;
const
  ITEM_OFFSET = 21 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump22;
const
  ITEM_OFFSET = 22 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump23;
const
  ITEM_OFFSET = 23 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump24;
const
  ITEM_OFFSET = 24 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump25;
const
  ITEM_OFFSET = 25 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump26;
const
  ITEM_OFFSET = 26 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump27;
const
  ITEM_OFFSET = 27 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump28;
const
  ITEM_OFFSET = 28 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump29;
const
  ITEM_OFFSET = 29 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump30;
const
  ITEM_OFFSET = 30 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump31;
const
  ITEM_OFFSET = 31 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump32;
const
  ITEM_OFFSET = 32 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump33;
const
  ITEM_OFFSET = 33 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump34;
const
  ITEM_OFFSET = 34 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump35;
const
  ITEM_OFFSET = 35 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump36;
const
  ITEM_OFFSET = 36 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump37;
const
  ITEM_OFFSET = 37 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump38;
const
  ITEM_OFFSET = 38 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump39;
const
  ITEM_OFFSET = 39 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump40;
const
  ITEM_OFFSET = 40 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump41;
const
  ITEM_OFFSET = 41 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump42;
const
  ITEM_OFFSET = 42 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump43;
const
  ITEM_OFFSET = 43 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump44;
const
  ITEM_OFFSET = 44 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump45;
const
  ITEM_OFFSET = 45 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump46;
const
  ITEM_OFFSET = 46 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump47;
const
  ITEM_OFFSET = 47 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump48;
const
  ITEM_OFFSET = 48 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump49;
const
  ITEM_OFFSET = 49 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump50;
const
  ITEM_OFFSET = 50 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump51;
const
  ITEM_OFFSET = 51 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump52;
const
  ITEM_OFFSET = 52 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump53;
const
  ITEM_OFFSET = 53 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump54;
const
  ITEM_OFFSET = 54 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump55;
const
  ITEM_OFFSET = 55 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump56;
const
  ITEM_OFFSET = 56 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump57;
const
  ITEM_OFFSET = 57 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump58;
const
  ITEM_OFFSET = 58 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump59;
const
  ITEM_OFFSET = 59 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump60;
const
  ITEM_OFFSET = 60 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump61;
const
  ITEM_OFFSET = 61 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump62;
const
  ITEM_OFFSET = 62 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump63;
const
  ITEM_OFFSET = 63 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump64;
const
  ITEM_OFFSET = 64 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump65;
const
  ITEM_OFFSET = 65 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump66;
const
  ITEM_OFFSET = 66 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump67;
const
  ITEM_OFFSET = 67 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump68;
const
  ITEM_OFFSET = 68 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump69;
const
  ITEM_OFFSET = 69 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump70;
const
  ITEM_OFFSET = 70 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump71;
const
  ITEM_OFFSET = 71 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump72;
const
  ITEM_OFFSET = 72 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump73;
const
  ITEM_OFFSET = 73 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump74;
const
  ITEM_OFFSET = 74 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump75;
const
  ITEM_OFFSET = 75 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump76;
const
  ITEM_OFFSET = 76 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump77;
const
  ITEM_OFFSET = 77 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump78;
const
  ITEM_OFFSET = 78 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump79;
const
  ITEM_OFFSET = 79 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump80;
const
  ITEM_OFFSET = 80 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump81;
const
  ITEM_OFFSET = 81 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump82;
const
  ITEM_OFFSET = 82 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump83;
const
  ITEM_OFFSET = 83 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump84;
const
  ITEM_OFFSET = 84 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump85;
const
  ITEM_OFFSET = 85 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump86;
const
  ITEM_OFFSET = 86 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump87;
const
  ITEM_OFFSET = 87 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump88;
const
  ITEM_OFFSET = 88 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump89;
const
  ITEM_OFFSET = 89 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump90;
const
  ITEM_OFFSET = 90 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump91;
const
  ITEM_OFFSET = 91 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump92;
const
  ITEM_OFFSET = 92 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump93;
const
  ITEM_OFFSET = 93 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump94;
const
  ITEM_OFFSET = 94 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump95;
const
  ITEM_OFFSET = 95 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump96;
const
  ITEM_OFFSET = 96 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump97;
const
  ITEM_OFFSET = 97 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump98;
const
  ITEM_OFFSET = 98 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump99;
const
  ITEM_OFFSET = 99 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump100;
const
  ITEM_OFFSET = 100 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump101;
const
  ITEM_OFFSET = 101 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump102;
const
  ITEM_OFFSET = 102 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump103;
const
  ITEM_OFFSET = 103 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump104;
const
  ITEM_OFFSET = 104 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump105;
const
  ITEM_OFFSET = 105 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump106;
const
  ITEM_OFFSET = 106 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump107;
const
  ITEM_OFFSET = 107 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump108;
const
  ITEM_OFFSET = 108 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump109;
const
  ITEM_OFFSET = 109 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump110;
const
  ITEM_OFFSET = 110 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump111;
const
  ITEM_OFFSET = 111 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump112;
const
  ITEM_OFFSET = 112 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump113;
const
  ITEM_OFFSET = 113 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump114;
const
  ITEM_OFFSET = 114 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump115;
const
  ITEM_OFFSET = 115 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump116;
const
  ITEM_OFFSET = 116 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump117;
const
  ITEM_OFFSET = 117 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump118;
const
  ITEM_OFFSET = 118 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump119;
const
  ITEM_OFFSET = 119 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump120;
const
  ITEM_OFFSET = 120 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump121;
const
  ITEM_OFFSET = 121 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump122;
const
  ITEM_OFFSET = 122 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump123;
const
  ITEM_OFFSET = 123 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump124;
const
  ITEM_OFFSET = 124 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump125;
const
  ITEM_OFFSET = 125 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump126;
const
  ITEM_OFFSET = 126 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump127;
const
  ITEM_OFFSET = 127 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump128;
const
  ITEM_OFFSET = 128 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump129;
const
  ITEM_OFFSET = 129 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump130;
const
  ITEM_OFFSET = 130 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump131;
const
  ITEM_OFFSET = 131 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump132;
const
  ITEM_OFFSET = 132 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump133;
const
  ITEM_OFFSET = 133 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump134;
const
  ITEM_OFFSET = 134 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump135;
const
  ITEM_OFFSET = 135 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump136;
const
  ITEM_OFFSET = 136 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump137;
const
  ITEM_OFFSET = 137 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump138;
const
  ITEM_OFFSET = 138 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump139;
const
  ITEM_OFFSET = 139 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump140;
const
  ITEM_OFFSET = 140 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump141;
const
  ITEM_OFFSET = 141 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump142;
const
  ITEM_OFFSET = 142 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump143;
const
  ITEM_OFFSET = 143 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump144;
const
  ITEM_OFFSET = 144 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump145;
const
  ITEM_OFFSET = 145 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump146;
const
  ITEM_OFFSET = 146 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump147;
const
  ITEM_OFFSET = 147 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump148;
const
  ITEM_OFFSET = 148 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump149;
const
  ITEM_OFFSET = 149 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump150;
const
  ITEM_OFFSET = 150 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump151;
const
  ITEM_OFFSET = 151 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump152;
const
  ITEM_OFFSET = 152 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump153;
const
  ITEM_OFFSET = 153 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump154;
const
  ITEM_OFFSET = 154 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump155;
const
  ITEM_OFFSET = 155 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump156;
const
  ITEM_OFFSET = 156 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump157;
const
  ITEM_OFFSET = 157 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump158;
const
  ITEM_OFFSET = 158 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump159;
const
  ITEM_OFFSET = 159 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump160;
const
  ITEM_OFFSET = 160 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump161;
const
  ITEM_OFFSET = 161 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump162;
const
  ITEM_OFFSET = 162 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump163;
const
  ITEM_OFFSET = 163 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump164;
const
  ITEM_OFFSET = 164 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump165;
const
  ITEM_OFFSET = 165 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump166;
const
  ITEM_OFFSET = 166 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump167;
const
  ITEM_OFFSET = 167 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump168;
const
  ITEM_OFFSET = 168 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump169;
const
  ITEM_OFFSET = 169 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump170;
const
  ITEM_OFFSET = 170 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump171;
const
  ITEM_OFFSET = 171 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump172;
const
  ITEM_OFFSET = 172 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump173;
const
  ITEM_OFFSET = 173 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump174;
const
  ITEM_OFFSET = 174 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump175;
const
  ITEM_OFFSET = 175 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump176;
const
  ITEM_OFFSET = 176 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump177;
const
  ITEM_OFFSET = 177 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump178;
const
  ITEM_OFFSET = 178 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump179;
const
  ITEM_OFFSET = 179 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump180;
const
  ITEM_OFFSET = 180 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump181;
const
  ITEM_OFFSET = 181 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump182;
const
  ITEM_OFFSET = 182 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump183;
const
  ITEM_OFFSET = 183 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump184;
const
  ITEM_OFFSET = 184 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump185;
const
  ITEM_OFFSET = 185 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump186;
const
  ITEM_OFFSET = 186 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump187;
const
  ITEM_OFFSET = 187 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump188;
const
  ITEM_OFFSET = 188 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump189;
const
  ITEM_OFFSET = 189 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump190;
const
  ITEM_OFFSET = 190 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump191;
const
  ITEM_OFFSET = 191 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump192;
const
  ITEM_OFFSET = 192 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump193;
const
  ITEM_OFFSET = 193 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump194;
const
  ITEM_OFFSET = 194 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump195;
const
  ITEM_OFFSET = 195 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump196;
const
  ITEM_OFFSET = 196 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump197;
const
  ITEM_OFFSET = 197 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump198;
const
  ITEM_OFFSET = 198 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump199;
const
  ITEM_OFFSET = 199 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump200;
const
  ITEM_OFFSET = 200 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump201;
const
  ITEM_OFFSET = 201 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump202;
const
  ITEM_OFFSET = 202 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump203;
const
  ITEM_OFFSET = 203 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump204;
const
  ITEM_OFFSET = 204 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump205;
const
  ITEM_OFFSET = 205 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump206;
const
  ITEM_OFFSET = 206 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump207;
const
  ITEM_OFFSET = 207 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump208;
const
  ITEM_OFFSET = 208 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump209;
const
  ITEM_OFFSET = 209 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump210;
const
  ITEM_OFFSET = 210 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump211;
const
  ITEM_OFFSET = 211 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump212;
const
  ITEM_OFFSET = 212 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump213;
const
  ITEM_OFFSET = 213 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump214;
const
  ITEM_OFFSET = 214 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump215;
const
  ITEM_OFFSET = 215 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump216;
const
  ITEM_OFFSET = 216 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump217;
const
  ITEM_OFFSET = 217 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump218;
const
  ITEM_OFFSET = 218 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump219;
const
  ITEM_OFFSET = 219 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump220;
const
  ITEM_OFFSET = 220 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump221;
const
  ITEM_OFFSET = 221 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump222;
const
  ITEM_OFFSET = 222 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump223;
const
  ITEM_OFFSET = 223 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump224;
const
  ITEM_OFFSET = 224 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump225;
const
  ITEM_OFFSET = 225 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump226;
const
  ITEM_OFFSET = 226 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump227;
const
  ITEM_OFFSET = 227 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump228;
const
  ITEM_OFFSET = 228 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump229;
const
  ITEM_OFFSET = 229 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump230;
const
  ITEM_OFFSET = 230 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump231;
const
  ITEM_OFFSET = 231 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump232;
const
  ITEM_OFFSET = 232 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump233;
const
  ITEM_OFFSET = 233 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump234;
const
  ITEM_OFFSET = 234 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump235;
const
  ITEM_OFFSET = 235 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump236;
const
  ITEM_OFFSET = 236 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump237;
const
  ITEM_OFFSET = 237 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump238;
const
  ITEM_OFFSET = 238 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump239;
const
  ITEM_OFFSET = 239 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump240;
const
  ITEM_OFFSET = 240 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump241;
const
  ITEM_OFFSET = 241 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump242;
const
  ITEM_OFFSET = 242 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump243;
const
  ITEM_OFFSET = 243 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump244;
const
  ITEM_OFFSET = 244 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump245;
const
  ITEM_OFFSET = 245 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump246;
const
  ITEM_OFFSET = 246 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump247;
const
  ITEM_OFFSET = 247 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump248;
const
  ITEM_OFFSET = 248 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump249;
const
  ITEM_OFFSET = 249 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump250;
const
  ITEM_OFFSET = 250 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump251;
const
  ITEM_OFFSET = 251 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump252;
const
  ITEM_OFFSET = 252 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump253;
const
  ITEM_OFFSET = 253 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump254;
const
  ITEM_OFFSET = 254 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump255;
const
  ITEM_OFFSET = 255 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump256;
const
  ITEM_OFFSET = 256 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump257;
const
  ITEM_OFFSET = 257 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump258;
const
  ITEM_OFFSET = 258 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump259;
const
  ITEM_OFFSET = 259 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump260;
const
  ITEM_OFFSET = 260 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump261;
const
  ITEM_OFFSET = 261 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump262;
const
  ITEM_OFFSET = 262 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump263;
const
  ITEM_OFFSET = 263 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump264;
const
  ITEM_OFFSET = 264 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump265;
const
  ITEM_OFFSET = 265 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump266;
const
  ITEM_OFFSET = 266 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump267;
const
  ITEM_OFFSET = 267 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump268;
const
  ITEM_OFFSET = 268 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump269;
const
  ITEM_OFFSET = 269 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump270;
const
  ITEM_OFFSET = 270 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump271;
const
  ITEM_OFFSET = 271 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump272;
const
  ITEM_OFFSET = 272 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump273;
const
  ITEM_OFFSET = 273 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump274;
const
  ITEM_OFFSET = 274 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump275;
const
  ITEM_OFFSET = 275 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump276;
const
  ITEM_OFFSET = 276 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump277;
const
  ITEM_OFFSET = 277 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump278;
const
  ITEM_OFFSET = 278 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump279;
const
  ITEM_OFFSET = 279 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump280;
const
  ITEM_OFFSET = 280 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump281;
const
  ITEM_OFFSET = 281 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump282;
const
  ITEM_OFFSET = 282 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump283;
const
  ITEM_OFFSET = 283 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump284;
const
  ITEM_OFFSET = 284 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump285;
const
  ITEM_OFFSET = 285 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump286;
const
  ITEM_OFFSET = 286 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump287;
const
  ITEM_OFFSET = 287 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump288;
const
  ITEM_OFFSET = 288 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump289;
const
  ITEM_OFFSET = 289 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump290;
const
  ITEM_OFFSET = 290 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump291;
const
  ITEM_OFFSET = 291 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump292;
const
  ITEM_OFFSET = 292 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump293;
const
  ITEM_OFFSET = 293 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump294;
const
  ITEM_OFFSET = 294 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump295;
const
  ITEM_OFFSET = 295 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump296;
const
  ITEM_OFFSET = 296 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump297;
const
  ITEM_OFFSET = 297 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump298;
const
  ITEM_OFFSET = 298 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump299;
const
  ITEM_OFFSET = 299 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump300;
const
  ITEM_OFFSET = 300 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump301;
const
  ITEM_OFFSET = 301 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump302;
const
  ITEM_OFFSET = 302 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump303;
const
  ITEM_OFFSET = 303 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump304;
const
  ITEM_OFFSET = 304 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump305;
const
  ITEM_OFFSET = 305 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump306;
const
  ITEM_OFFSET = 306 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump307;
const
  ITEM_OFFSET = 307 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump308;
const
  ITEM_OFFSET = 308 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump309;
const
  ITEM_OFFSET = 309 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump310;
const
  ITEM_OFFSET = 310 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump311;
const
  ITEM_OFFSET = 311 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump312;
const
  ITEM_OFFSET = 312 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump313;
const
  ITEM_OFFSET = 313 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump314;
const
  ITEM_OFFSET = 314 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump315;
const
  ITEM_OFFSET = 315 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump316;
const
  ITEM_OFFSET = 316 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump317;
const
  ITEM_OFFSET = 317 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump318;
const
  ITEM_OFFSET = 318 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump319;
const
  ITEM_OFFSET = 319 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump320;
const
  ITEM_OFFSET = 320 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump321;
const
  ITEM_OFFSET = 321 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump322;
const
  ITEM_OFFSET = 322 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump323;
const
  ITEM_OFFSET = 323 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump324;
const
  ITEM_OFFSET = 324 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump325;
const
  ITEM_OFFSET = 325 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump326;
const
  ITEM_OFFSET = 326 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump327;
const
  ITEM_OFFSET = 327 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump328;
const
  ITEM_OFFSET = 328 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump329;
const
  ITEM_OFFSET = 329 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump330;
const
  ITEM_OFFSET = 330 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump331;
const
  ITEM_OFFSET = 331 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump332;
const
  ITEM_OFFSET = 332 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump333;
const
  ITEM_OFFSET = 333 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump334;
const
  ITEM_OFFSET = 334 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump335;
const
  ITEM_OFFSET = 335 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump336;
const
  ITEM_OFFSET = 336 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump337;
const
  ITEM_OFFSET = 337 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump338;
const
  ITEM_OFFSET = 338 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump339;
const
  ITEM_OFFSET = 339 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump340;
const
  ITEM_OFFSET = 340 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump341;
const
  ITEM_OFFSET = 341 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump342;
const
  ITEM_OFFSET = 342 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump343;
const
  ITEM_OFFSET = 343 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump344;
const
  ITEM_OFFSET = 344 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump345;
const
  ITEM_OFFSET = 345 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump346;
const
  ITEM_OFFSET = 346 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump347;
const
  ITEM_OFFSET = 347 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump348;
const
  ITEM_OFFSET = 348 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump349;
const
  ITEM_OFFSET = 349 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump350;
const
  ITEM_OFFSET = 350 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump351;
const
  ITEM_OFFSET = 351 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump352;
const
  ITEM_OFFSET = 352 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump353;
const
  ITEM_OFFSET = 353 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump354;
const
  ITEM_OFFSET = 354 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump355;
const
  ITEM_OFFSET = 355 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump356;
const
  ITEM_OFFSET = 356 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump357;
const
  ITEM_OFFSET = 357 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump358;
const
  ITEM_OFFSET = 358 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump359;
const
  ITEM_OFFSET = 359 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump360;
const
  ITEM_OFFSET = 360 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump361;
const
  ITEM_OFFSET = 361 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump362;
const
  ITEM_OFFSET = 362 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump363;
const
  ITEM_OFFSET = 363 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump364;
const
  ITEM_OFFSET = 364 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump365;
const
  ITEM_OFFSET = 365 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump366;
const
  ITEM_OFFSET = 366 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump367;
const
  ITEM_OFFSET = 367 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump368;
const
  ITEM_OFFSET = 368 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump369;
const
  ITEM_OFFSET = 369 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump370;
const
  ITEM_OFFSET = 370 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump371;
const
  ITEM_OFFSET = 371 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump372;
const
  ITEM_OFFSET = 372 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump373;
const
  ITEM_OFFSET = 373 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump374;
const
  ITEM_OFFSET = 374 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump375;
const
  ITEM_OFFSET = 375 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump376;
const
  ITEM_OFFSET = 376 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump377;
const
  ITEM_OFFSET = 377 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump378;
const
  ITEM_OFFSET = 378 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump379;
const
  ITEM_OFFSET = 379 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump380;
const
  ITEM_OFFSET = 380 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump381;
const
  ITEM_OFFSET = 381 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump382;
const
  ITEM_OFFSET = 382 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump383;
const
  ITEM_OFFSET = 383 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump384;
const
  ITEM_OFFSET = 384 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump385;
const
  ITEM_OFFSET = 385 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump386;
const
  ITEM_OFFSET = 386 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump387;
const
  ITEM_OFFSET = 387 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump388;
const
  ITEM_OFFSET = 388 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump389;
const
  ITEM_OFFSET = 389 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump390;
const
  ITEM_OFFSET = 390 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump391;
const
  ITEM_OFFSET = 391 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump392;
const
  ITEM_OFFSET = 392 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump393;
const
  ITEM_OFFSET = 393 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump394;
const
  ITEM_OFFSET = 394 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump395;
const
  ITEM_OFFSET = 395 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump396;
const
  ITEM_OFFSET = 396 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump397;
const
  ITEM_OFFSET = 397 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump398;
const
  ITEM_OFFSET = 398 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump399;
const
  ITEM_OFFSET = 399 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump400;
const
  ITEM_OFFSET = 400 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump401;
const
  ITEM_OFFSET = 401 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump402;
const
  ITEM_OFFSET = 402 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump403;
const
  ITEM_OFFSET = 403 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump404;
const
  ITEM_OFFSET = 404 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump405;
const
  ITEM_OFFSET = 405 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump406;
const
  ITEM_OFFSET = 406 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump407;
const
  ITEM_OFFSET = 407 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump408;
const
  ITEM_OFFSET = 408 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump409;
const
  ITEM_OFFSET = 409 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump410;
const
  ITEM_OFFSET = 410 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump411;
const
  ITEM_OFFSET = 411 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump412;
const
  ITEM_OFFSET = 412 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump413;
const
  ITEM_OFFSET = 413 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump414;
const
  ITEM_OFFSET = 414 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump415;
const
  ITEM_OFFSET = 415 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump416;
const
  ITEM_OFFSET = 416 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump417;
const
  ITEM_OFFSET = 417 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump418;
const
  ITEM_OFFSET = 418 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump419;
const
  ITEM_OFFSET = 419 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump420;
const
  ITEM_OFFSET = 420 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump421;
const
  ITEM_OFFSET = 421 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump422;
const
  ITEM_OFFSET = 422 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump423;
const
  ITEM_OFFSET = 423 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump424;
const
  ITEM_OFFSET = 424 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump425;
const
  ITEM_OFFSET = 425 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump426;
const
  ITEM_OFFSET = 426 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump427;
const
  ITEM_OFFSET = 427 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump428;
const
  ITEM_OFFSET = 428 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump429;
const
  ITEM_OFFSET = 429 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump430;
const
  ITEM_OFFSET = 430 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump431;
const
  ITEM_OFFSET = 431 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump432;
const
  ITEM_OFFSET = 432 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump433;
const
  ITEM_OFFSET = 433 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump434;
const
  ITEM_OFFSET = 434 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump435;
const
  ITEM_OFFSET = 435 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump436;
const
  ITEM_OFFSET = 436 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump437;
const
  ITEM_OFFSET = 437 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump438;
const
  ITEM_OFFSET = 438 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump439;
const
  ITEM_OFFSET = 439 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump440;
const
  ITEM_OFFSET = 440 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump441;
const
  ITEM_OFFSET = 441 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump442;
const
  ITEM_OFFSET = 442 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump443;
const
  ITEM_OFFSET = 443 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump444;
const
  ITEM_OFFSET = 444 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump445;
const
  ITEM_OFFSET = 445 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump446;
const
  ITEM_OFFSET = 446 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump447;
const
  ITEM_OFFSET = 447 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump448;
const
  ITEM_OFFSET = 448 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump449;
const
  ITEM_OFFSET = 449 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump450;
const
  ITEM_OFFSET = 450 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump451;
const
  ITEM_OFFSET = 451 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump452;
const
  ITEM_OFFSET = 452 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump453;
const
  ITEM_OFFSET = 453 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump454;
const
  ITEM_OFFSET = 454 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump455;
const
  ITEM_OFFSET = 455 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump456;
const
  ITEM_OFFSET = 456 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump457;
const
  ITEM_OFFSET = 457 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump458;
const
  ITEM_OFFSET = 458 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump459;
const
  ITEM_OFFSET = 459 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump460;
const
  ITEM_OFFSET = 460 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump461;
const
  ITEM_OFFSET = 461 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump462;
const
  ITEM_OFFSET = 462 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump463;
const
  ITEM_OFFSET = 463 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump464;
const
  ITEM_OFFSET = 464 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump465;
const
  ITEM_OFFSET = 465 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump466;
const
  ITEM_OFFSET = 466 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump467;
const
  ITEM_OFFSET = 467 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump468;
const
  ITEM_OFFSET = 468 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump469;
const
  ITEM_OFFSET = 469 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump470;
const
  ITEM_OFFSET = 470 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump471;
const
  ITEM_OFFSET = 471 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump472;
const
  ITEM_OFFSET = 472 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump473;
const
  ITEM_OFFSET = 473 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump474;
const
  ITEM_OFFSET = 474 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump475;
const
  ITEM_OFFSET = 475 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump476;
const
  ITEM_OFFSET = 476 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump477;
const
  ITEM_OFFSET = 477 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump478;
const
  ITEM_OFFSET = 478 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump479;
const
  ITEM_OFFSET = 479 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump480;
const
  ITEM_OFFSET = 480 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump481;
const
  ITEM_OFFSET = 481 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump482;
const
  ITEM_OFFSET = 482 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump483;
const
  ITEM_OFFSET = 483 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump484;
const
  ITEM_OFFSET = 484 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump485;
const
  ITEM_OFFSET = 485 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump486;
const
  ITEM_OFFSET = 486 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump487;
const
  ITEM_OFFSET = 487 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump488;
const
  ITEM_OFFSET = 488 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump489;
const
  ITEM_OFFSET = 489 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump490;
const
  ITEM_OFFSET = 490 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump491;
const
  ITEM_OFFSET = 491 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump492;
const
  ITEM_OFFSET = 492 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump493;
const
  ITEM_OFFSET = 493 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump494;
const
  ITEM_OFFSET = 494 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump495;
const
  ITEM_OFFSET = 495 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump496;
const
  ITEM_OFFSET = 496 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump497;
const
  ITEM_OFFSET = 497 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump498;
const
  ITEM_OFFSET = 498 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump499;
const
  ITEM_OFFSET = 499 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump500;
const
  ITEM_OFFSET = 500 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump501;
const
  ITEM_OFFSET = 501 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump502;
const
  ITEM_OFFSET = 502 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump503;
const
  ITEM_OFFSET = 503 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump504;
const
  ITEM_OFFSET = 504 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump505;
const
  ITEM_OFFSET = 505 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump506;
const
  ITEM_OFFSET = 506 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump507;
const
  ITEM_OFFSET = 507 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump508;
const
  ITEM_OFFSET = 508 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump509;
const
  ITEM_OFFSET = 509 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump510;
const
  ITEM_OFFSET = 510 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump511;
const
  ITEM_OFFSET = 511 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump512;
const
  ITEM_OFFSET = 512 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump513;
const
  ITEM_OFFSET = 513 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump514;
const
  ITEM_OFFSET = 514 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump515;
const
  ITEM_OFFSET = 515 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump516;
const
  ITEM_OFFSET = 516 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump517;
const
  ITEM_OFFSET = 517 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump518;
const
  ITEM_OFFSET = 518 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump519;
const
  ITEM_OFFSET = 519 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump520;
const
  ITEM_OFFSET = 520 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump521;
const
  ITEM_OFFSET = 521 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump522;
const
  ITEM_OFFSET = 522 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump523;
const
  ITEM_OFFSET = 523 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump524;
const
  ITEM_OFFSET = 524 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump525;
const
  ITEM_OFFSET = 525 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump526;
const
  ITEM_OFFSET = 526 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump527;
const
  ITEM_OFFSET = 527 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump528;
const
  ITEM_OFFSET = 528 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump529;
const
  ITEM_OFFSET = 529 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump530;
const
  ITEM_OFFSET = 530 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump531;
const
  ITEM_OFFSET = 531 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump532;
const
  ITEM_OFFSET = 532 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump533;
const
  ITEM_OFFSET = 533 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump534;
const
  ITEM_OFFSET = 534 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump535;
const
  ITEM_OFFSET = 535 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump536;
const
  ITEM_OFFSET = 536 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump537;
const
  ITEM_OFFSET = 537 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump538;
const
  ITEM_OFFSET = 538 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump539;
const
  ITEM_OFFSET = 539 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump540;
const
  ITEM_OFFSET = 540 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump541;
const
  ITEM_OFFSET = 541 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump542;
const
  ITEM_OFFSET = 542 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump543;
const
  ITEM_OFFSET = 543 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump544;
const
  ITEM_OFFSET = 544 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump545;
const
  ITEM_OFFSET = 545 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump546;
const
  ITEM_OFFSET = 546 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump547;
const
  ITEM_OFFSET = 547 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump548;
const
  ITEM_OFFSET = 548 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump549;
const
  ITEM_OFFSET = 549 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump550;
const
  ITEM_OFFSET = 550 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump551;
const
  ITEM_OFFSET = 551 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump552;
const
  ITEM_OFFSET = 552 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump553;
const
  ITEM_OFFSET = 553 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump554;
const
  ITEM_OFFSET = 554 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump555;
const
  ITEM_OFFSET = 555 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump556;
const
  ITEM_OFFSET = 556 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump557;
const
  ITEM_OFFSET = 557 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump558;
const
  ITEM_OFFSET = 558 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump559;
const
  ITEM_OFFSET = 559 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump560;
const
  ITEM_OFFSET = 560 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump561;
const
  ITEM_OFFSET = 561 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump562;
const
  ITEM_OFFSET = 562 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump563;
const
  ITEM_OFFSET = 563 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump564;
const
  ITEM_OFFSET = 564 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump565;
const
  ITEM_OFFSET = 565 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump566;
const
  ITEM_OFFSET = 566 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump567;
const
  ITEM_OFFSET = 567 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump568;
const
  ITEM_OFFSET = 568 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump569;
const
  ITEM_OFFSET = 569 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump570;
const
  ITEM_OFFSET = 570 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump571;
const
  ITEM_OFFSET = 571 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump572;
const
  ITEM_OFFSET = 572 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump573;
const
  ITEM_OFFSET = 573 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump574;
const
  ITEM_OFFSET = 574 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump575;
const
  ITEM_OFFSET = 575 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump576;
const
  ITEM_OFFSET = 576 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump577;
const
  ITEM_OFFSET = 577 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump578;
const
  ITEM_OFFSET = 578 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump579;
const
  ITEM_OFFSET = 579 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump580;
const
  ITEM_OFFSET = 580 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump581;
const
  ITEM_OFFSET = 581 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump582;
const
  ITEM_OFFSET = 582 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump583;
const
  ITEM_OFFSET = 583 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump584;
const
  ITEM_OFFSET = 584 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump585;
const
  ITEM_OFFSET = 585 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump586;
const
  ITEM_OFFSET = 586 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump587;
const
  ITEM_OFFSET = 587 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump588;
const
  ITEM_OFFSET = 588 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump589;
const
  ITEM_OFFSET = 589 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump590;
const
  ITEM_OFFSET = 590 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump591;
const
  ITEM_OFFSET = 591 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump592;
const
  ITEM_OFFSET = 592 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump593;
const
  ITEM_OFFSET = 593 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump594;
const
  ITEM_OFFSET = 594 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump595;
const
  ITEM_OFFSET = 595 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump596;
const
  ITEM_OFFSET = 596 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump597;
const
  ITEM_OFFSET = 597 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump598;
const
  ITEM_OFFSET = 598 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump599;
const
  ITEM_OFFSET = 599 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump600;
const
  ITEM_OFFSET = 600 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump601;
const
  ITEM_OFFSET = 601 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump602;
const
  ITEM_OFFSET = 602 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump603;
const
  ITEM_OFFSET = 603 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump604;
const
  ITEM_OFFSET = 604 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump605;
const
  ITEM_OFFSET = 605 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump606;
const
  ITEM_OFFSET = 606 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump607;
const
  ITEM_OFFSET = 607 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump608;
const
  ITEM_OFFSET = 608 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump609;
const
  ITEM_OFFSET = 609 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump610;
const
  ITEM_OFFSET = 610 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump611;
const
  ITEM_OFFSET = 611 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump612;
const
  ITEM_OFFSET = 612 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump613;
const
  ITEM_OFFSET = 613 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump614;
const
  ITEM_OFFSET = 614 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump615;
const
  ITEM_OFFSET = 615 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump616;
const
  ITEM_OFFSET = 616 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump617;
const
  ITEM_OFFSET = 617 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump618;
const
  ITEM_OFFSET = 618 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump619;
const
  ITEM_OFFSET = 619 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump620;
const
  ITEM_OFFSET = 620 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump621;
const
  ITEM_OFFSET = 621 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump622;
const
  ITEM_OFFSET = 622 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump623;
const
  ITEM_OFFSET = 623 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump624;
const
  ITEM_OFFSET = 624 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump625;
const
  ITEM_OFFSET = 625 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump626;
const
  ITEM_OFFSET = 626 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump627;
const
  ITEM_OFFSET = 627 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump628;
const
  ITEM_OFFSET = 628 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump629;
const
  ITEM_OFFSET = 629 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump630;
const
  ITEM_OFFSET = 630 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump631;
const
  ITEM_OFFSET = 631 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump632;
const
  ITEM_OFFSET = 632 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump633;
const
  ITEM_OFFSET = 633 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump634;
const
  ITEM_OFFSET = 634 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump635;
const
  ITEM_OFFSET = 635 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump636;
const
  ITEM_OFFSET = 636 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump637;
const
  ITEM_OFFSET = 637 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump638;
const
  ITEM_OFFSET = 638 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump639;
const
  ITEM_OFFSET = 639 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump640;
const
  ITEM_OFFSET = 640 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump641;
const
  ITEM_OFFSET = 641 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump642;
const
  ITEM_OFFSET = 642 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump643;
const
  ITEM_OFFSET = 643 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump644;
const
  ITEM_OFFSET = 644 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump645;
const
  ITEM_OFFSET = 645 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump646;
const
  ITEM_OFFSET = 646 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump647;
const
  ITEM_OFFSET = 647 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump648;
const
  ITEM_OFFSET = 648 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump649;
const
  ITEM_OFFSET = 649 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump650;
const
  ITEM_OFFSET = 650 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump651;
const
  ITEM_OFFSET = 651 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump652;
const
  ITEM_OFFSET = 652 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump653;
const
  ITEM_OFFSET = 653 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump654;
const
  ITEM_OFFSET = 654 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump655;
const
  ITEM_OFFSET = 655 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump656;
const
  ITEM_OFFSET = 656 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump657;
const
  ITEM_OFFSET = 657 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump658;
const
  ITEM_OFFSET = 658 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump659;
const
  ITEM_OFFSET = 659 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump660;
const
  ITEM_OFFSET = 660 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump661;
const
  ITEM_OFFSET = 661 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump662;
const
  ITEM_OFFSET = 662 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump663;
const
  ITEM_OFFSET = 663 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump664;
const
  ITEM_OFFSET = 664 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump665;
const
  ITEM_OFFSET = 665 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump666;
const
  ITEM_OFFSET = 666 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump667;
const
  ITEM_OFFSET = 667 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump668;
const
  ITEM_OFFSET = 668 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump669;
const
  ITEM_OFFSET = 669 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump670;
const
  ITEM_OFFSET = 670 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump671;
const
  ITEM_OFFSET = 671 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump672;
const
  ITEM_OFFSET = 672 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump673;
const
  ITEM_OFFSET = 673 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump674;
const
  ITEM_OFFSET = 674 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump675;
const
  ITEM_OFFSET = 675 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump676;
const
  ITEM_OFFSET = 676 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump677;
const
  ITEM_OFFSET = 677 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump678;
const
  ITEM_OFFSET = 678 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump679;
const
  ITEM_OFFSET = 679 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump680;
const
  ITEM_OFFSET = 680 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump681;
const
  ITEM_OFFSET = 681 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump682;
const
  ITEM_OFFSET = 682 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump683;
const
  ITEM_OFFSET = 683 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump684;
const
  ITEM_OFFSET = 684 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump685;
const
  ITEM_OFFSET = 685 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump686;
const
  ITEM_OFFSET = 686 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump687;
const
  ITEM_OFFSET = 687 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump688;
const
  ITEM_OFFSET = 688 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump689;
const
  ITEM_OFFSET = 689 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump690;
const
  ITEM_OFFSET = 690 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump691;
const
  ITEM_OFFSET = 691 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump692;
const
  ITEM_OFFSET = 692 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump693;
const
  ITEM_OFFSET = 693 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump694;
const
  ITEM_OFFSET = 694 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump695;
const
  ITEM_OFFSET = 695 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump696;
const
  ITEM_OFFSET = 696 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump697;
const
  ITEM_OFFSET = 697 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump698;
const
  ITEM_OFFSET = 698 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump699;
const
  ITEM_OFFSET = 699 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump700;
const
  ITEM_OFFSET = 700 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump701;
const
  ITEM_OFFSET = 701 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump702;
const
  ITEM_OFFSET = 702 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump703;
const
  ITEM_OFFSET = 703 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump704;
const
  ITEM_OFFSET = 704 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump705;
const
  ITEM_OFFSET = 705 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump706;
const
  ITEM_OFFSET = 706 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump707;
const
  ITEM_OFFSET = 707 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump708;
const
  ITEM_OFFSET = 708 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump709;
const
  ITEM_OFFSET = 709 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump710;
const
  ITEM_OFFSET = 710 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump711;
const
  ITEM_OFFSET = 711 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump712;
const
  ITEM_OFFSET = 712 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump713;
const
  ITEM_OFFSET = 713 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump714;
const
  ITEM_OFFSET = 714 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump715;
const
  ITEM_OFFSET = 715 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump716;
const
  ITEM_OFFSET = 716 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump717;
const
  ITEM_OFFSET = 717 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump718;
const
  ITEM_OFFSET = 718 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump719;
const
  ITEM_OFFSET = 719 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump720;
const
  ITEM_OFFSET = 720 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump721;
const
  ITEM_OFFSET = 721 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump722;
const
  ITEM_OFFSET = 722 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump723;
const
  ITEM_OFFSET = 723 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump724;
const
  ITEM_OFFSET = 724 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump725;
const
  ITEM_OFFSET = 725 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump726;
const
  ITEM_OFFSET = 726 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump727;
const
  ITEM_OFFSET = 727 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump728;
const
  ITEM_OFFSET = 728 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump729;
const
  ITEM_OFFSET = 729 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump730;
const
  ITEM_OFFSET = 730 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump731;
const
  ITEM_OFFSET = 731 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump732;
const
  ITEM_OFFSET = 732 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump733;
const
  ITEM_OFFSET = 733 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump734;
const
  ITEM_OFFSET = 734 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump735;
const
  ITEM_OFFSET = 735 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump736;
const
  ITEM_OFFSET = 736 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump737;
const
  ITEM_OFFSET = 737 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump738;
const
  ITEM_OFFSET = 738 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump739;
const
  ITEM_OFFSET = 739 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump740;
const
  ITEM_OFFSET = 740 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump741;
const
  ITEM_OFFSET = 741 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump742;
const
  ITEM_OFFSET = 742 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump743;
const
  ITEM_OFFSET = 743 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump744;
const
  ITEM_OFFSET = 744 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump745;
const
  ITEM_OFFSET = 745 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump746;
const
  ITEM_OFFSET = 746 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump747;
const
  ITEM_OFFSET = 747 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump748;
const
  ITEM_OFFSET = 748 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump749;
const
  ITEM_OFFSET = 749 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump750;
const
  ITEM_OFFSET = 750 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump751;
const
  ITEM_OFFSET = 751 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump752;
const
  ITEM_OFFSET = 752 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump753;
const
  ITEM_OFFSET = 753 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump754;
const
  ITEM_OFFSET = 754 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump755;
const
  ITEM_OFFSET = 755 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump756;
const
  ITEM_OFFSET = 756 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump757;
const
  ITEM_OFFSET = 757 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump758;
const
  ITEM_OFFSET = 758 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump759;
const
  ITEM_OFFSET = 759 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump760;
const
  ITEM_OFFSET = 760 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump761;
const
  ITEM_OFFSET = 761 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump762;
const
  ITEM_OFFSET = 762 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump763;
const
  ITEM_OFFSET = 763 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump764;
const
  ITEM_OFFSET = 764 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump765;
const
  ITEM_OFFSET = 765 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump766;
const
  ITEM_OFFSET = 766 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump767;
const
  ITEM_OFFSET = 767 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump768;
const
  ITEM_OFFSET = 768 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump769;
const
  ITEM_OFFSET = 769 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump770;
const
  ITEM_OFFSET = 770 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump771;
const
  ITEM_OFFSET = 771 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump772;
const
  ITEM_OFFSET = 772 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump773;
const
  ITEM_OFFSET = 773 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump774;
const
  ITEM_OFFSET = 774 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump775;
const
  ITEM_OFFSET = 775 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump776;
const
  ITEM_OFFSET = 776 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump777;
const
  ITEM_OFFSET = 777 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump778;
const
  ITEM_OFFSET = 778 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump779;
const
  ITEM_OFFSET = 779 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump780;
const
  ITEM_OFFSET = 780 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump781;
const
  ITEM_OFFSET = 781 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump782;
const
  ITEM_OFFSET = 782 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump783;
const
  ITEM_OFFSET = 783 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump784;
const
  ITEM_OFFSET = 784 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump785;
const
  ITEM_OFFSET = 785 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump786;
const
  ITEM_OFFSET = 786 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump787;
const
  ITEM_OFFSET = 787 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump788;
const
  ITEM_OFFSET = 788 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump789;
const
  ITEM_OFFSET = 789 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump790;
const
  ITEM_OFFSET = 790 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump791;
const
  ITEM_OFFSET = 791 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump792;
const
  ITEM_OFFSET = 792 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump793;
const
  ITEM_OFFSET = 793 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump794;
const
  ITEM_OFFSET = 794 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump795;
const
  ITEM_OFFSET = 795 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump796;
const
  ITEM_OFFSET = 796 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump797;
const
  ITEM_OFFSET = 797 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump798;
const
  ITEM_OFFSET = 798 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump799;
const
  ITEM_OFFSET = 799 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump800;
const
  ITEM_OFFSET = 800 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump801;
const
  ITEM_OFFSET = 801 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump802;
const
  ITEM_OFFSET = 802 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump803;
const
  ITEM_OFFSET = 803 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump804;
const
  ITEM_OFFSET = 804 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump805;
const
  ITEM_OFFSET = 805 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump806;
const
  ITEM_OFFSET = 806 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump807;
const
  ITEM_OFFSET = 807 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump808;
const
  ITEM_OFFSET = 808 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump809;
const
  ITEM_OFFSET = 809 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump810;
const
  ITEM_OFFSET = 810 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump811;
const
  ITEM_OFFSET = 811 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump812;
const
  ITEM_OFFSET = 812 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump813;
const
  ITEM_OFFSET = 813 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump814;
const
  ITEM_OFFSET = 814 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump815;
const
  ITEM_OFFSET = 815 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump816;
const
  ITEM_OFFSET = 816 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump817;
const
  ITEM_OFFSET = 817 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump818;
const
  ITEM_OFFSET = 818 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump819;
const
  ITEM_OFFSET = 819 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump820;
const
  ITEM_OFFSET = 820 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump821;
const
  ITEM_OFFSET = 821 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump822;
const
  ITEM_OFFSET = 822 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump823;
const
  ITEM_OFFSET = 823 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump824;
const
  ITEM_OFFSET = 824 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump825;
const
  ITEM_OFFSET = 825 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump826;
const
  ITEM_OFFSET = 826 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump827;
const
  ITEM_OFFSET = 827 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump828;
const
  ITEM_OFFSET = 828 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump829;
const
  ITEM_OFFSET = 829 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump830;
const
  ITEM_OFFSET = 830 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump831;
const
  ITEM_OFFSET = 831 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump832;
const
  ITEM_OFFSET = 832 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump833;
const
  ITEM_OFFSET = 833 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump834;
const
  ITEM_OFFSET = 834 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump835;
const
  ITEM_OFFSET = 835 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump836;
const
  ITEM_OFFSET = 836 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump837;
const
  ITEM_OFFSET = 837 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump838;
const
  ITEM_OFFSET = 838 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump839;
const
  ITEM_OFFSET = 839 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump840;
const
  ITEM_OFFSET = 840 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump841;
const
  ITEM_OFFSET = 841 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump842;
const
  ITEM_OFFSET = 842 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump843;
const
  ITEM_OFFSET = 843 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump844;
const
  ITEM_OFFSET = 844 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump845;
const
  ITEM_OFFSET = 845 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump846;
const
  ITEM_OFFSET = 846 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump847;
const
  ITEM_OFFSET = 847 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump848;
const
  ITEM_OFFSET = 848 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump849;
const
  ITEM_OFFSET = 849 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump850;
const
  ITEM_OFFSET = 850 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump851;
const
  ITEM_OFFSET = 851 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump852;
const
  ITEM_OFFSET = 852 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump853;
const
  ITEM_OFFSET = 853 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump854;
const
  ITEM_OFFSET = 854 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump855;
const
  ITEM_OFFSET = 855 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump856;
const
  ITEM_OFFSET = 856 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump857;
const
  ITEM_OFFSET = 857 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump858;
const
  ITEM_OFFSET = 858 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump859;
const
  ITEM_OFFSET = 859 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump860;
const
  ITEM_OFFSET = 860 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump861;
const
  ITEM_OFFSET = 861 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump862;
const
  ITEM_OFFSET = 862 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump863;
const
  ITEM_OFFSET = 863 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump864;
const
  ITEM_OFFSET = 864 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump865;
const
  ITEM_OFFSET = 865 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump866;
const
  ITEM_OFFSET = 866 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump867;
const
  ITEM_OFFSET = 867 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump868;
const
  ITEM_OFFSET = 868 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump869;
const
  ITEM_OFFSET = 869 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump870;
const
  ITEM_OFFSET = 870 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump871;
const
  ITEM_OFFSET = 871 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump872;
const
  ITEM_OFFSET = 872 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump873;
const
  ITEM_OFFSET = 873 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump874;
const
  ITEM_OFFSET = 874 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump875;
const
  ITEM_OFFSET = 875 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump876;
const
  ITEM_OFFSET = 876 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump877;
const
  ITEM_OFFSET = 877 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump878;
const
  ITEM_OFFSET = 878 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump879;
const
  ITEM_OFFSET = 879 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump880;
const
  ITEM_OFFSET = 880 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump881;
const
  ITEM_OFFSET = 881 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump882;
const
  ITEM_OFFSET = 882 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump883;
const
  ITEM_OFFSET = 883 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump884;
const
  ITEM_OFFSET = 884 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump885;
const
  ITEM_OFFSET = 885 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump886;
const
  ITEM_OFFSET = 886 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump887;
const
  ITEM_OFFSET = 887 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump888;
const
  ITEM_OFFSET = 888 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump889;
const
  ITEM_OFFSET = 889 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump890;
const
  ITEM_OFFSET = 890 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump891;
const
  ITEM_OFFSET = 891 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump892;
const
  ITEM_OFFSET = 892 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump893;
const
  ITEM_OFFSET = 893 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump894;
const
  ITEM_OFFSET = 894 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump895;
const
  ITEM_OFFSET = 895 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump896;
const
  ITEM_OFFSET = 896 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump897;
const
  ITEM_OFFSET = 897 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump898;
const
  ITEM_OFFSET = 898 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump899;
const
  ITEM_OFFSET = 899 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump900;
const
  ITEM_OFFSET = 900 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump901;
const
  ITEM_OFFSET = 901 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump902;
const
  ITEM_OFFSET = 902 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump903;
const
  ITEM_OFFSET = 903 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump904;
const
  ITEM_OFFSET = 904 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump905;
const
  ITEM_OFFSET = 905 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump906;
const
  ITEM_OFFSET = 906 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump907;
const
  ITEM_OFFSET = 907 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump908;
const
  ITEM_OFFSET = 908 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump909;
const
  ITEM_OFFSET = 909 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump910;
const
  ITEM_OFFSET = 910 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump911;
const
  ITEM_OFFSET = 911 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump912;
const
  ITEM_OFFSET = 912 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump913;
const
  ITEM_OFFSET = 913 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump914;
const
  ITEM_OFFSET = 914 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump915;
const
  ITEM_OFFSET = 915 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump916;
const
  ITEM_OFFSET = 916 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump917;
const
  ITEM_OFFSET = 917 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump918;
const
  ITEM_OFFSET = 918 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump919;
const
  ITEM_OFFSET = 919 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump920;
const
  ITEM_OFFSET = 920 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump921;
const
  ITEM_OFFSET = 921 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump922;
const
  ITEM_OFFSET = 922 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump923;
const
  ITEM_OFFSET = 923 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump924;
const
  ITEM_OFFSET = 924 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump925;
const
  ITEM_OFFSET = 925 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump926;
const
  ITEM_OFFSET = 926 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump927;
const
  ITEM_OFFSET = 927 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump928;
const
  ITEM_OFFSET = 928 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump929;
const
  ITEM_OFFSET = 929 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump930;
const
  ITEM_OFFSET = 930 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump931;
const
  ITEM_OFFSET = 931 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump932;
const
  ITEM_OFFSET = 932 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump933;
const
  ITEM_OFFSET = 933 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump934;
const
  ITEM_OFFSET = 934 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump935;
const
  ITEM_OFFSET = 935 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump936;
const
  ITEM_OFFSET = 936 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump937;
const
  ITEM_OFFSET = 937 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump938;
const
  ITEM_OFFSET = 938 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump939;
const
  ITEM_OFFSET = 939 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump940;
const
  ITEM_OFFSET = 940 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump941;
const
  ITEM_OFFSET = 941 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump942;
const
  ITEM_OFFSET = 942 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump943;
const
  ITEM_OFFSET = 943 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump944;
const
  ITEM_OFFSET = 944 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump945;
const
  ITEM_OFFSET = 945 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump946;
const
  ITEM_OFFSET = 946 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump947;
const
  ITEM_OFFSET = 947 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump948;
const
  ITEM_OFFSET = 948 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump949;
const
  ITEM_OFFSET = 949 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump950;
const
  ITEM_OFFSET = 950 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump951;
const
  ITEM_OFFSET = 951 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump952;
const
  ITEM_OFFSET = 952 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump953;
const
  ITEM_OFFSET = 953 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump954;
const
  ITEM_OFFSET = 954 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump955;
const
  ITEM_OFFSET = 955 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump956;
const
  ITEM_OFFSET = 956 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump957;
const
  ITEM_OFFSET = 957 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump958;
const
  ITEM_OFFSET = 958 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump959;
const
  ITEM_OFFSET = 959 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump960;
const
  ITEM_OFFSET = 960 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump961;
const
  ITEM_OFFSET = 961 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump962;
const
  ITEM_OFFSET = 962 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump963;
const
  ITEM_OFFSET = 963 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump964;
const
  ITEM_OFFSET = 964 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump965;
const
  ITEM_OFFSET = 965 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump966;
const
  ITEM_OFFSET = 966 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump967;
const
  ITEM_OFFSET = 967 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump968;
const
  ITEM_OFFSET = 968 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump969;
const
  ITEM_OFFSET = 969 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump970;
const
  ITEM_OFFSET = 970 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump971;
const
  ITEM_OFFSET = 971 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump972;
const
  ITEM_OFFSET = 972 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump973;
const
  ITEM_OFFSET = 973 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump974;
const
  ITEM_OFFSET = 974 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump975;
const
  ITEM_OFFSET = 975 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump976;
const
  ITEM_OFFSET = 976 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump977;
const
  ITEM_OFFSET = 977 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump978;
const
  ITEM_OFFSET = 978 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump979;
const
  ITEM_OFFSET = 979 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump980;
const
  ITEM_OFFSET = 980 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump981;
const
  ITEM_OFFSET = 981 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump982;
const
  ITEM_OFFSET = 982 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump983;
const
  ITEM_OFFSET = 983 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump984;
const
  ITEM_OFFSET = 984 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump985;
const
  ITEM_OFFSET = 985 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump986;
const
  ITEM_OFFSET = 986 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump987;
const
  ITEM_OFFSET = 987 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump988;
const
  ITEM_OFFSET = 988 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump989;
const
  ITEM_OFFSET = 989 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump990;
const
  ITEM_OFFSET = 990 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump991;
const
  ITEM_OFFSET = 991 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump992;
const
  ITEM_OFFSET = 992 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump993;
const
  ITEM_OFFSET = 993 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump994;
const
  ITEM_OFFSET = 994 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump995;
const
  ITEM_OFFSET = 995 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump996;
const
  ITEM_OFFSET = 996 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump997;
const
  ITEM_OFFSET = 997 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump998;
const
  ITEM_OFFSET = 998 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump999;
const
  ITEM_OFFSET = 999 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump1000;
const
  ITEM_OFFSET = 1000 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump1001;
const
  ITEM_OFFSET = 1001 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump1002;
const
  ITEM_OFFSET = 1002 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump1003;
const
  ITEM_OFFSET = 1003 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump1004;
const
  ITEM_OFFSET = 1004 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump1005;
const
  ITEM_OFFSET = 1005 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump1006;
const
  ITEM_OFFSET = 1006 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump1007;
const
  ITEM_OFFSET = 1007 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump1008;
const
  ITEM_OFFSET = 1008 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump1009;
const
  ITEM_OFFSET = 1009 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump1010;
const
  ITEM_OFFSET = 1010 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump1011;
const
  ITEM_OFFSET = 1011 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump1012;
const
  ITEM_OFFSET = 1012 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump1013;
const
  ITEM_OFFSET = 1013 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump1014;
const
  ITEM_OFFSET = 1014 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump1015;
const
  ITEM_OFFSET = 1015 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump1016;
const
  ITEM_OFFSET = 1016 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump1017;
const
  ITEM_OFFSET = 1017 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump1018;
const
  ITEM_OFFSET = 1018 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump1019;
const
  ITEM_OFFSET = 1019 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump1020;
const
  ITEM_OFFSET = 1020 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump1021;
const
  ITEM_OFFSET = 1021 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump1022;
const
  ITEM_OFFSET = 1022 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

procedure intercept_jump1023;
const
  ITEM_OFFSET = 1023 * SizeOf(TRttiVirtualMethodData);
asm
  DB $89, $C8, $EB, $04, $8B, $44, $24, $04
  mov [esp - $18], edx
  mov edx, [eax - 4]
  add edx, ITEM_OFFSET
  jmp [edx]
end;

const
  INTERCEPT_JUMPS: array[0..1023] of Pointer = (
    @intercept_jump0,
    @intercept_jump1,
    @intercept_jump2,
    @intercept_jump3,
    @intercept_jump4,
    @intercept_jump5,
    @intercept_jump6,
    @intercept_jump7,
    @intercept_jump8,
    @intercept_jump9,
    @intercept_jump10,
    @intercept_jump11,
    @intercept_jump12,
    @intercept_jump13,
    @intercept_jump14,
    @intercept_jump15,
    @intercept_jump16,
    @intercept_jump17,
    @intercept_jump18,
    @intercept_jump19,
    @intercept_jump20,
    @intercept_jump21,
    @intercept_jump22,
    @intercept_jump23,
    @intercept_jump24,
    @intercept_jump25,
    @intercept_jump26,
    @intercept_jump27,
    @intercept_jump28,
    @intercept_jump29,
    @intercept_jump30,
    @intercept_jump31,
    @intercept_jump32,
    @intercept_jump33,
    @intercept_jump34,
    @intercept_jump35,
    @intercept_jump36,
    @intercept_jump37,
    @intercept_jump38,
    @intercept_jump39,
    @intercept_jump40,
    @intercept_jump41,
    @intercept_jump42,
    @intercept_jump43,
    @intercept_jump44,
    @intercept_jump45,
    @intercept_jump46,
    @intercept_jump47,
    @intercept_jump48,
    @intercept_jump49,
    @intercept_jump50,
    @intercept_jump51,
    @intercept_jump52,
    @intercept_jump53,
    @intercept_jump54,
    @intercept_jump55,
    @intercept_jump56,
    @intercept_jump57,
    @intercept_jump58,
    @intercept_jump59,
    @intercept_jump60,
    @intercept_jump61,
    @intercept_jump62,
    @intercept_jump63,
    @intercept_jump64,
    @intercept_jump65,
    @intercept_jump66,
    @intercept_jump67,
    @intercept_jump68,
    @intercept_jump69,
    @intercept_jump70,
    @intercept_jump71,
    @intercept_jump72,
    @intercept_jump73,
    @intercept_jump74,
    @intercept_jump75,
    @intercept_jump76,
    @intercept_jump77,
    @intercept_jump78,
    @intercept_jump79,
    @intercept_jump80,
    @intercept_jump81,
    @intercept_jump82,
    @intercept_jump83,
    @intercept_jump84,
    @intercept_jump85,
    @intercept_jump86,
    @intercept_jump87,
    @intercept_jump88,
    @intercept_jump89,
    @intercept_jump90,
    @intercept_jump91,
    @intercept_jump92,
    @intercept_jump93,
    @intercept_jump94,
    @intercept_jump95,
    @intercept_jump96,
    @intercept_jump97,
    @intercept_jump98,
    @intercept_jump99,
    @intercept_jump100,
    @intercept_jump101,
    @intercept_jump102,
    @intercept_jump103,
    @intercept_jump104,
    @intercept_jump105,
    @intercept_jump106,
    @intercept_jump107,
    @intercept_jump108,
    @intercept_jump109,
    @intercept_jump110,
    @intercept_jump111,
    @intercept_jump112,
    @intercept_jump113,
    @intercept_jump114,
    @intercept_jump115,
    @intercept_jump116,
    @intercept_jump117,
    @intercept_jump118,
    @intercept_jump119,
    @intercept_jump120,
    @intercept_jump121,
    @intercept_jump122,
    @intercept_jump123,
    @intercept_jump124,
    @intercept_jump125,
    @intercept_jump126,
    @intercept_jump127,
    @intercept_jump128,
    @intercept_jump129,
    @intercept_jump130,
    @intercept_jump131,
    @intercept_jump132,
    @intercept_jump133,
    @intercept_jump134,
    @intercept_jump135,
    @intercept_jump136,
    @intercept_jump137,
    @intercept_jump138,
    @intercept_jump139,
    @intercept_jump140,
    @intercept_jump141,
    @intercept_jump142,
    @intercept_jump143,
    @intercept_jump144,
    @intercept_jump145,
    @intercept_jump146,
    @intercept_jump147,
    @intercept_jump148,
    @intercept_jump149,
    @intercept_jump150,
    @intercept_jump151,
    @intercept_jump152,
    @intercept_jump153,
    @intercept_jump154,
    @intercept_jump155,
    @intercept_jump156,
    @intercept_jump157,
    @intercept_jump158,
    @intercept_jump159,
    @intercept_jump160,
    @intercept_jump161,
    @intercept_jump162,
    @intercept_jump163,
    @intercept_jump164,
    @intercept_jump165,
    @intercept_jump166,
    @intercept_jump167,
    @intercept_jump168,
    @intercept_jump169,
    @intercept_jump170,
    @intercept_jump171,
    @intercept_jump172,
    @intercept_jump173,
    @intercept_jump174,
    @intercept_jump175,
    @intercept_jump176,
    @intercept_jump177,
    @intercept_jump178,
    @intercept_jump179,
    @intercept_jump180,
    @intercept_jump181,
    @intercept_jump182,
    @intercept_jump183,
    @intercept_jump184,
    @intercept_jump185,
    @intercept_jump186,
    @intercept_jump187,
    @intercept_jump188,
    @intercept_jump189,
    @intercept_jump190,
    @intercept_jump191,
    @intercept_jump192,
    @intercept_jump193,
    @intercept_jump194,
    @intercept_jump195,
    @intercept_jump196,
    @intercept_jump197,
    @intercept_jump198,
    @intercept_jump199,
    @intercept_jump200,
    @intercept_jump201,
    @intercept_jump202,
    @intercept_jump203,
    @intercept_jump204,
    @intercept_jump205,
    @intercept_jump206,
    @intercept_jump207,
    @intercept_jump208,
    @intercept_jump209,
    @intercept_jump210,
    @intercept_jump211,
    @intercept_jump212,
    @intercept_jump213,
    @intercept_jump214,
    @intercept_jump215,
    @intercept_jump216,
    @intercept_jump217,
    @intercept_jump218,
    @intercept_jump219,
    @intercept_jump220,
    @intercept_jump221,
    @intercept_jump222,
    @intercept_jump223,
    @intercept_jump224,
    @intercept_jump225,
    @intercept_jump226,
    @intercept_jump227,
    @intercept_jump228,
    @intercept_jump229,
    @intercept_jump230,
    @intercept_jump231,
    @intercept_jump232,
    @intercept_jump233,
    @intercept_jump234,
    @intercept_jump235,
    @intercept_jump236,
    @intercept_jump237,
    @intercept_jump238,
    @intercept_jump239,
    @intercept_jump240,
    @intercept_jump241,
    @intercept_jump242,
    @intercept_jump243,
    @intercept_jump244,
    @intercept_jump245,
    @intercept_jump246,
    @intercept_jump247,
    @intercept_jump248,
    @intercept_jump249,
    @intercept_jump250,
    @intercept_jump251,
    @intercept_jump252,
    @intercept_jump253,
    @intercept_jump254,
    @intercept_jump255,
    @intercept_jump256,
    @intercept_jump257,
    @intercept_jump258,
    @intercept_jump259,
    @intercept_jump260,
    @intercept_jump261,
    @intercept_jump262,
    @intercept_jump263,
    @intercept_jump264,
    @intercept_jump265,
    @intercept_jump266,
    @intercept_jump267,
    @intercept_jump268,
    @intercept_jump269,
    @intercept_jump270,
    @intercept_jump271,
    @intercept_jump272,
    @intercept_jump273,
    @intercept_jump274,
    @intercept_jump275,
    @intercept_jump276,
    @intercept_jump277,
    @intercept_jump278,
    @intercept_jump279,
    @intercept_jump280,
    @intercept_jump281,
    @intercept_jump282,
    @intercept_jump283,
    @intercept_jump284,
    @intercept_jump285,
    @intercept_jump286,
    @intercept_jump287,
    @intercept_jump288,
    @intercept_jump289,
    @intercept_jump290,
    @intercept_jump291,
    @intercept_jump292,
    @intercept_jump293,
    @intercept_jump294,
    @intercept_jump295,
    @intercept_jump296,
    @intercept_jump297,
    @intercept_jump298,
    @intercept_jump299,
    @intercept_jump300,
    @intercept_jump301,
    @intercept_jump302,
    @intercept_jump303,
    @intercept_jump304,
    @intercept_jump305,
    @intercept_jump306,
    @intercept_jump307,
    @intercept_jump308,
    @intercept_jump309,
    @intercept_jump310,
    @intercept_jump311,
    @intercept_jump312,
    @intercept_jump313,
    @intercept_jump314,
    @intercept_jump315,
    @intercept_jump316,
    @intercept_jump317,
    @intercept_jump318,
    @intercept_jump319,
    @intercept_jump320,
    @intercept_jump321,
    @intercept_jump322,
    @intercept_jump323,
    @intercept_jump324,
    @intercept_jump325,
    @intercept_jump326,
    @intercept_jump327,
    @intercept_jump328,
    @intercept_jump329,
    @intercept_jump330,
    @intercept_jump331,
    @intercept_jump332,
    @intercept_jump333,
    @intercept_jump334,
    @intercept_jump335,
    @intercept_jump336,
    @intercept_jump337,
    @intercept_jump338,
    @intercept_jump339,
    @intercept_jump340,
    @intercept_jump341,
    @intercept_jump342,
    @intercept_jump343,
    @intercept_jump344,
    @intercept_jump345,
    @intercept_jump346,
    @intercept_jump347,
    @intercept_jump348,
    @intercept_jump349,
    @intercept_jump350,
    @intercept_jump351,
    @intercept_jump352,
    @intercept_jump353,
    @intercept_jump354,
    @intercept_jump355,
    @intercept_jump356,
    @intercept_jump357,
    @intercept_jump358,
    @intercept_jump359,
    @intercept_jump360,
    @intercept_jump361,
    @intercept_jump362,
    @intercept_jump363,
    @intercept_jump364,
    @intercept_jump365,
    @intercept_jump366,
    @intercept_jump367,
    @intercept_jump368,
    @intercept_jump369,
    @intercept_jump370,
    @intercept_jump371,
    @intercept_jump372,
    @intercept_jump373,
    @intercept_jump374,
    @intercept_jump375,
    @intercept_jump376,
    @intercept_jump377,
    @intercept_jump378,
    @intercept_jump379,
    @intercept_jump380,
    @intercept_jump381,
    @intercept_jump382,
    @intercept_jump383,
    @intercept_jump384,
    @intercept_jump385,
    @intercept_jump386,
    @intercept_jump387,
    @intercept_jump388,
    @intercept_jump389,
    @intercept_jump390,
    @intercept_jump391,
    @intercept_jump392,
    @intercept_jump393,
    @intercept_jump394,
    @intercept_jump395,
    @intercept_jump396,
    @intercept_jump397,
    @intercept_jump398,
    @intercept_jump399,
    @intercept_jump400,
    @intercept_jump401,
    @intercept_jump402,
    @intercept_jump403,
    @intercept_jump404,
    @intercept_jump405,
    @intercept_jump406,
    @intercept_jump407,
    @intercept_jump408,
    @intercept_jump409,
    @intercept_jump410,
    @intercept_jump411,
    @intercept_jump412,
    @intercept_jump413,
    @intercept_jump414,
    @intercept_jump415,
    @intercept_jump416,
    @intercept_jump417,
    @intercept_jump418,
    @intercept_jump419,
    @intercept_jump420,
    @intercept_jump421,
    @intercept_jump422,
    @intercept_jump423,
    @intercept_jump424,
    @intercept_jump425,
    @intercept_jump426,
    @intercept_jump427,
    @intercept_jump428,
    @intercept_jump429,
    @intercept_jump430,
    @intercept_jump431,
    @intercept_jump432,
    @intercept_jump433,
    @intercept_jump434,
    @intercept_jump435,
    @intercept_jump436,
    @intercept_jump437,
    @intercept_jump438,
    @intercept_jump439,
    @intercept_jump440,
    @intercept_jump441,
    @intercept_jump442,
    @intercept_jump443,
    @intercept_jump444,
    @intercept_jump445,
    @intercept_jump446,
    @intercept_jump447,
    @intercept_jump448,
    @intercept_jump449,
    @intercept_jump450,
    @intercept_jump451,
    @intercept_jump452,
    @intercept_jump453,
    @intercept_jump454,
    @intercept_jump455,
    @intercept_jump456,
    @intercept_jump457,
    @intercept_jump458,
    @intercept_jump459,
    @intercept_jump460,
    @intercept_jump461,
    @intercept_jump462,
    @intercept_jump463,
    @intercept_jump464,
    @intercept_jump465,
    @intercept_jump466,
    @intercept_jump467,
    @intercept_jump468,
    @intercept_jump469,
    @intercept_jump470,
    @intercept_jump471,
    @intercept_jump472,
    @intercept_jump473,
    @intercept_jump474,
    @intercept_jump475,
    @intercept_jump476,
    @intercept_jump477,
    @intercept_jump478,
    @intercept_jump479,
    @intercept_jump480,
    @intercept_jump481,
    @intercept_jump482,
    @intercept_jump483,
    @intercept_jump484,
    @intercept_jump485,
    @intercept_jump486,
    @intercept_jump487,
    @intercept_jump488,
    @intercept_jump489,
    @intercept_jump490,
    @intercept_jump491,
    @intercept_jump492,
    @intercept_jump493,
    @intercept_jump494,
    @intercept_jump495,
    @intercept_jump496,
    @intercept_jump497,
    @intercept_jump498,
    @intercept_jump499,
    @intercept_jump500,
    @intercept_jump501,
    @intercept_jump502,
    @intercept_jump503,
    @intercept_jump504,
    @intercept_jump505,
    @intercept_jump506,
    @intercept_jump507,
    @intercept_jump508,
    @intercept_jump509,
    @intercept_jump510,
    @intercept_jump511,
    @intercept_jump512,
    @intercept_jump513,
    @intercept_jump514,
    @intercept_jump515,
    @intercept_jump516,
    @intercept_jump517,
    @intercept_jump518,
    @intercept_jump519,
    @intercept_jump520,
    @intercept_jump521,
    @intercept_jump522,
    @intercept_jump523,
    @intercept_jump524,
    @intercept_jump525,
    @intercept_jump526,
    @intercept_jump527,
    @intercept_jump528,
    @intercept_jump529,
    @intercept_jump530,
    @intercept_jump531,
    @intercept_jump532,
    @intercept_jump533,
    @intercept_jump534,
    @intercept_jump535,
    @intercept_jump536,
    @intercept_jump537,
    @intercept_jump538,
    @intercept_jump539,
    @intercept_jump540,
    @intercept_jump541,
    @intercept_jump542,
    @intercept_jump543,
    @intercept_jump544,
    @intercept_jump545,
    @intercept_jump546,
    @intercept_jump547,
    @intercept_jump548,
    @intercept_jump549,
    @intercept_jump550,
    @intercept_jump551,
    @intercept_jump552,
    @intercept_jump553,
    @intercept_jump554,
    @intercept_jump555,
    @intercept_jump556,
    @intercept_jump557,
    @intercept_jump558,
    @intercept_jump559,
    @intercept_jump560,
    @intercept_jump561,
    @intercept_jump562,
    @intercept_jump563,
    @intercept_jump564,
    @intercept_jump565,
    @intercept_jump566,
    @intercept_jump567,
    @intercept_jump568,
    @intercept_jump569,
    @intercept_jump570,
    @intercept_jump571,
    @intercept_jump572,
    @intercept_jump573,
    @intercept_jump574,
    @intercept_jump575,
    @intercept_jump576,
    @intercept_jump577,
    @intercept_jump578,
    @intercept_jump579,
    @intercept_jump580,
    @intercept_jump581,
    @intercept_jump582,
    @intercept_jump583,
    @intercept_jump584,
    @intercept_jump585,
    @intercept_jump586,
    @intercept_jump587,
    @intercept_jump588,
    @intercept_jump589,
    @intercept_jump590,
    @intercept_jump591,
    @intercept_jump592,
    @intercept_jump593,
    @intercept_jump594,
    @intercept_jump595,
    @intercept_jump596,
    @intercept_jump597,
    @intercept_jump598,
    @intercept_jump599,
    @intercept_jump600,
    @intercept_jump601,
    @intercept_jump602,
    @intercept_jump603,
    @intercept_jump604,
    @intercept_jump605,
    @intercept_jump606,
    @intercept_jump607,
    @intercept_jump608,
    @intercept_jump609,
    @intercept_jump610,
    @intercept_jump611,
    @intercept_jump612,
    @intercept_jump613,
    @intercept_jump614,
    @intercept_jump615,
    @intercept_jump616,
    @intercept_jump617,
    @intercept_jump618,
    @intercept_jump619,
    @intercept_jump620,
    @intercept_jump621,
    @intercept_jump622,
    @intercept_jump623,
    @intercept_jump624,
    @intercept_jump625,
    @intercept_jump626,
    @intercept_jump627,
    @intercept_jump628,
    @intercept_jump629,
    @intercept_jump630,
    @intercept_jump631,
    @intercept_jump632,
    @intercept_jump633,
    @intercept_jump634,
    @intercept_jump635,
    @intercept_jump636,
    @intercept_jump637,
    @intercept_jump638,
    @intercept_jump639,
    @intercept_jump640,
    @intercept_jump641,
    @intercept_jump642,
    @intercept_jump643,
    @intercept_jump644,
    @intercept_jump645,
    @intercept_jump646,
    @intercept_jump647,
    @intercept_jump648,
    @intercept_jump649,
    @intercept_jump650,
    @intercept_jump651,
    @intercept_jump652,
    @intercept_jump653,
    @intercept_jump654,
    @intercept_jump655,
    @intercept_jump656,
    @intercept_jump657,
    @intercept_jump658,
    @intercept_jump659,
    @intercept_jump660,
    @intercept_jump661,
    @intercept_jump662,
    @intercept_jump663,
    @intercept_jump664,
    @intercept_jump665,
    @intercept_jump666,
    @intercept_jump667,
    @intercept_jump668,
    @intercept_jump669,
    @intercept_jump670,
    @intercept_jump671,
    @intercept_jump672,
    @intercept_jump673,
    @intercept_jump674,
    @intercept_jump675,
    @intercept_jump676,
    @intercept_jump677,
    @intercept_jump678,
    @intercept_jump679,
    @intercept_jump680,
    @intercept_jump681,
    @intercept_jump682,
    @intercept_jump683,
    @intercept_jump684,
    @intercept_jump685,
    @intercept_jump686,
    @intercept_jump687,
    @intercept_jump688,
    @intercept_jump689,
    @intercept_jump690,
    @intercept_jump691,
    @intercept_jump692,
    @intercept_jump693,
    @intercept_jump694,
    @intercept_jump695,
    @intercept_jump696,
    @intercept_jump697,
    @intercept_jump698,
    @intercept_jump699,
    @intercept_jump700,
    @intercept_jump701,
    @intercept_jump702,
    @intercept_jump703,
    @intercept_jump704,
    @intercept_jump705,
    @intercept_jump706,
    @intercept_jump707,
    @intercept_jump708,
    @intercept_jump709,
    @intercept_jump710,
    @intercept_jump711,
    @intercept_jump712,
    @intercept_jump713,
    @intercept_jump714,
    @intercept_jump715,
    @intercept_jump716,
    @intercept_jump717,
    @intercept_jump718,
    @intercept_jump719,
    @intercept_jump720,
    @intercept_jump721,
    @intercept_jump722,
    @intercept_jump723,
    @intercept_jump724,
    @intercept_jump725,
    @intercept_jump726,
    @intercept_jump727,
    @intercept_jump728,
    @intercept_jump729,
    @intercept_jump730,
    @intercept_jump731,
    @intercept_jump732,
    @intercept_jump733,
    @intercept_jump734,
    @intercept_jump735,
    @intercept_jump736,
    @intercept_jump737,
    @intercept_jump738,
    @intercept_jump739,
    @intercept_jump740,
    @intercept_jump741,
    @intercept_jump742,
    @intercept_jump743,
    @intercept_jump744,
    @intercept_jump745,
    @intercept_jump746,
    @intercept_jump747,
    @intercept_jump748,
    @intercept_jump749,
    @intercept_jump750,
    @intercept_jump751,
    @intercept_jump752,
    @intercept_jump753,
    @intercept_jump754,
    @intercept_jump755,
    @intercept_jump756,
    @intercept_jump757,
    @intercept_jump758,
    @intercept_jump759,
    @intercept_jump760,
    @intercept_jump761,
    @intercept_jump762,
    @intercept_jump763,
    @intercept_jump764,
    @intercept_jump765,
    @intercept_jump766,
    @intercept_jump767,
    @intercept_jump768,
    @intercept_jump769,
    @intercept_jump770,
    @intercept_jump771,
    @intercept_jump772,
    @intercept_jump773,
    @intercept_jump774,
    @intercept_jump775,
    @intercept_jump776,
    @intercept_jump777,
    @intercept_jump778,
    @intercept_jump779,
    @intercept_jump780,
    @intercept_jump781,
    @intercept_jump782,
    @intercept_jump783,
    @intercept_jump784,
    @intercept_jump785,
    @intercept_jump786,
    @intercept_jump787,
    @intercept_jump788,
    @intercept_jump789,
    @intercept_jump790,
    @intercept_jump791,
    @intercept_jump792,
    @intercept_jump793,
    @intercept_jump794,
    @intercept_jump795,
    @intercept_jump796,
    @intercept_jump797,
    @intercept_jump798,
    @intercept_jump799,
    @intercept_jump800,
    @intercept_jump801,
    @intercept_jump802,
    @intercept_jump803,
    @intercept_jump804,
    @intercept_jump805,
    @intercept_jump806,
    @intercept_jump807,
    @intercept_jump808,
    @intercept_jump809,
    @intercept_jump810,
    @intercept_jump811,
    @intercept_jump812,
    @intercept_jump813,
    @intercept_jump814,
    @intercept_jump815,
    @intercept_jump816,
    @intercept_jump817,
    @intercept_jump818,
    @intercept_jump819,
    @intercept_jump820,
    @intercept_jump821,
    @intercept_jump822,
    @intercept_jump823,
    @intercept_jump824,
    @intercept_jump825,
    @intercept_jump826,
    @intercept_jump827,
    @intercept_jump828,
    @intercept_jump829,
    @intercept_jump830,
    @intercept_jump831,
    @intercept_jump832,
    @intercept_jump833,
    @intercept_jump834,
    @intercept_jump835,
    @intercept_jump836,
    @intercept_jump837,
    @intercept_jump838,
    @intercept_jump839,
    @intercept_jump840,
    @intercept_jump841,
    @intercept_jump842,
    @intercept_jump843,
    @intercept_jump844,
    @intercept_jump845,
    @intercept_jump846,
    @intercept_jump847,
    @intercept_jump848,
    @intercept_jump849,
    @intercept_jump850,
    @intercept_jump851,
    @intercept_jump852,
    @intercept_jump853,
    @intercept_jump854,
    @intercept_jump855,
    @intercept_jump856,
    @intercept_jump857,
    @intercept_jump858,
    @intercept_jump859,
    @intercept_jump860,
    @intercept_jump861,
    @intercept_jump862,
    @intercept_jump863,
    @intercept_jump864,
    @intercept_jump865,
    @intercept_jump866,
    @intercept_jump867,
    @intercept_jump868,
    @intercept_jump869,
    @intercept_jump870,
    @intercept_jump871,
    @intercept_jump872,
    @intercept_jump873,
    @intercept_jump874,
    @intercept_jump875,
    @intercept_jump876,
    @intercept_jump877,
    @intercept_jump878,
    @intercept_jump879,
    @intercept_jump880,
    @intercept_jump881,
    @intercept_jump882,
    @intercept_jump883,
    @intercept_jump884,
    @intercept_jump885,
    @intercept_jump886,
    @intercept_jump887,
    @intercept_jump888,
    @intercept_jump889,
    @intercept_jump890,
    @intercept_jump891,
    @intercept_jump892,
    @intercept_jump893,
    @intercept_jump894,
    @intercept_jump895,
    @intercept_jump896,
    @intercept_jump897,
    @intercept_jump898,
    @intercept_jump899,
    @intercept_jump900,
    @intercept_jump901,
    @intercept_jump902,
    @intercept_jump903,
    @intercept_jump904,
    @intercept_jump905,
    @intercept_jump906,
    @intercept_jump907,
    @intercept_jump908,
    @intercept_jump909,
    @intercept_jump910,
    @intercept_jump911,
    @intercept_jump912,
    @intercept_jump913,
    @intercept_jump914,
    @intercept_jump915,
    @intercept_jump916,
    @intercept_jump917,
    @intercept_jump918,
    @intercept_jump919,
    @intercept_jump920,
    @intercept_jump921,
    @intercept_jump922,
    @intercept_jump923,
    @intercept_jump924,
    @intercept_jump925,
    @intercept_jump926,
    @intercept_jump927,
    @intercept_jump928,
    @intercept_jump929,
    @intercept_jump930,
    @intercept_jump931,
    @intercept_jump932,
    @intercept_jump933,
    @intercept_jump934,
    @intercept_jump935,
    @intercept_jump936,
    @intercept_jump937,
    @intercept_jump938,
    @intercept_jump939,
    @intercept_jump940,
    @intercept_jump941,
    @intercept_jump942,
    @intercept_jump943,
    @intercept_jump944,
    @intercept_jump945,
    @intercept_jump946,
    @intercept_jump947,
    @intercept_jump948,
    @intercept_jump949,
    @intercept_jump950,
    @intercept_jump951,
    @intercept_jump952,
    @intercept_jump953,
    @intercept_jump954,
    @intercept_jump955,
    @intercept_jump956,
    @intercept_jump957,
    @intercept_jump958,
    @intercept_jump959,
    @intercept_jump960,
    @intercept_jump961,
    @intercept_jump962,
    @intercept_jump963,
    @intercept_jump964,
    @intercept_jump965,
    @intercept_jump966,
    @intercept_jump967,
    @intercept_jump968,
    @intercept_jump969,
    @intercept_jump970,
    @intercept_jump971,
    @intercept_jump972,
    @intercept_jump973,
    @intercept_jump974,
    @intercept_jump975,
    @intercept_jump976,
    @intercept_jump977,
    @intercept_jump978,
    @intercept_jump979,
    @intercept_jump980,
    @intercept_jump981,
    @intercept_jump982,
    @intercept_jump983,
    @intercept_jump984,
    @intercept_jump985,
    @intercept_jump986,
    @intercept_jump987,
    @intercept_jump988,
    @intercept_jump989,
    @intercept_jump990,
    @intercept_jump991,
    @intercept_jump992,
    @intercept_jump993,
    @intercept_jump994,
    @intercept_jump995,
    @intercept_jump996,
    @intercept_jump997,
    @intercept_jump998,
    @intercept_jump999,
    @intercept_jump1000,
    @intercept_jump1001,
    @intercept_jump1002,
    @intercept_jump1003,
    @intercept_jump1004,
    @intercept_jump1005,
    @intercept_jump1006,
    @intercept_jump1007,
    @intercept_jump1008,
    @intercept_jump1009,
    @intercept_jump1010,
    @intercept_jump1011,
    @intercept_jump1012,
    @intercept_jump1013,
    @intercept_jump1014,
    @intercept_jump1015,
    @intercept_jump1016,
    @intercept_jump1017,
    @intercept_jump1018,
    @intercept_jump1019,
    @intercept_jump1020,
    @intercept_jump1021,
    @intercept_jump1022,
    @intercept_jump1023
    );

function get_intercept_jump(const AIndex, AMode: Integer): Pointer;
var
  LPtr: PByte;
begin
  if (AIndex < Low(INTERCEPT_JUMPS)) or (AIndex > High(INTERCEPT_JUMPS)) then
  begin
    Result := nil;
    Exit;
  end;

  LPtr := INTERCEPT_JUMPS[AIndex];
  Inc(LPtr, 8);

  case (AMode) of
    1: Dec(LPtr, 4);
    2: Dec(LPtr, 4 + 4);
  end;

  Result := LPtr;
end;
