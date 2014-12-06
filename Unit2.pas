unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ToolWin, ComCtrls, ExtCtrls;

type
  TForm2 = class(TForm)
    Button1: TButton;
    Timer1: TTimer;
    ProcessListBox: TListBox;
    Edit1: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    lp: Integer;
  public
    { Public declarations }
  end;

var
  Form2: TForm2;
  aaa: TStringList;


implementation

{$R *.dfm}

function GetHWndByPID(const hPID: THandle): THandle;
    type
    PEnumInfo = ^TEnumInfo;
    TEnumInfo = record
    ProcessID: DWORD;
    HWND: THandle;
  end;

    function EnumWindowsProc(Wnd: DWORD; var EI: TEnumInfo): Bool; stdcall;
    var
        PID: DWORD;
    begin
        GetWindowThreadProcessID(Wnd, @PID);
        Result := (PID <> EI.ProcessID) or
                (not IsWindowVisible(WND)) or
                (not IsWindowEnabled(WND));

        if not Result then EI.HWND := WND; //break on return FALSE
    end;

    function FindMainWindow(PID: DWORD): DWORD;
    var
        EI: TEnumInfo;
    begin
        EI.ProcessID := PID;
        EI.HWND := 0;
        EnumWindows(@EnumWindowsProc, Integer(@EI));
        Result := EI.HWND;
    end;

begin
    if hPID<>0 then
        Result:=FindMainWindow(hPID)
    else
        Result:=0;
end;

function EnumProcess(hHwnd: HWND;lParam : integer): boolean; stdcall;
var
  pPid : DWORD;
  //inta: Integer;
  title, className,txt: string;

begin
  if(hHwnd=NULL) then
  begin
   result := false;
  end
  else
  begin
   GetWindowThreadProcessId(hHwnd,pPid);
   SetLength(className, 255);
   SetLength(className, GetClassName(hHwnd, PChar(className), Length(className)));
   SetLength(title, 255);
   SetLength(title, GetWindowText(hHwnd, PChar(title), Length(title)));
   txt:='';
   if Form2.Edit1.Text='' then
   begin
      Form2.ProcessListBox.Items.Add('Class Name = ' + className +
          '; Title = ' + title +
          '; HWND = ' + IntToStr(hHwnd) +
          '; Pid = ' + IntToStr(pPid));
   end else
   begin
     if pPid=StrToInt(Form2.Edit1.Text) then
        Form2.ProcessListBox.Items.Add('Class Name = ' + className +
          '; Title = ' + title +
          '; HWND = ' + IntToStr(hHwnd) +
          '; Pid = ' + IntToStr(pPid));


        aaa.Add('Class Name = ' + className +
          '; Title = ' + title +
          '; HWND = ' + IntToStr(hHwnd) +
          '; Pid = ' + IntToStr(pPid));

        aaa.SaveToFile('d:\test.log');

   end;

    result := true;
  end;
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
  if Timer1.Enabled then Timer1.Enabled:=False else Timer1.Enabled:=True;
  //if Timer1.Enabled=False then ProcessListBox.Clear;
end;

procedure TForm2.Timer1Timer(Sender: TObject);
var
    pPid : DWORD;
    title, className : string;
    hHwnd: THandle;
begin
  aaa:= TStringList.Create;
  if ProcessListBox.Count > 0 then
  ProcessListBox.Clear;
  lp := 0;

  if EnumWindows(@EnumProcess,lp) = false then
      Form2.ProcessListBox.Items.Add('Error: Could not obtain process window hook from system.');
  aaa.Free;
end;

end.
