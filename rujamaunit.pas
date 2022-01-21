unit rujamaunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls;

type

  { TtamegatchiForm }

  TtamegatchiForm = class(TForm)
    bgImage: TImage;
    ShadowImage: TImage;
    SpriteImage: TImage;
    MasterTimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure MasterTimerTimer(Sender: TObject);
    procedure SpriteImageMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
    procedure SpriteImageMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure SpriteImageMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
  private

  public

  end;

var
  tamegatchiForm: TtamegatchiForm;
  settingList: TStringList;
  canMoveForm: boolean;
  mouseX, mouseY: integer;

implementation

{$R *.lfm}

{ TtamegatchiForm }

procedure TtamegatchiForm.FormCreate(Sender: TObject);
begin
  bgImage.Picture.PNG.LoadFromFile(GetCurrentDir + PathDelim + 'media\img\bg-lcd-off.png');

  settingList := TStringList.Create;
  settingList.Values['eggFrame'] := IntToStr(0);

end;

//Mask On bitmap to make rest of the form transparent
procedure TtamegatchiForm.FormPaint(Sender: TObject);
var
  maskpicture: TPicture;
begin
  maskpicture := TPicture.Create;
  maskpicture.PNG.LoadFromFile(GetCurrentDir + PathDelim + 'media\img\bg-lcd-off.png');
  SetShape(maskpicture.Bitmap);
end;

function AnimateObject(objectName: string; index: integer): string;
var
  imagefilename: array of string = ('-default', '-skewl1', '-skewr1', '-jump1', '-jump2', '-jump1', '-default', '-skewl1', '-skewr1');
begin
  if StrToInt(settingList.Values['eggFrame']) < Length(imagefilename) then
  begin
    Result := GetCurrentDir + PathDelim + 'media\img\' + objectName + PathDelim + objectName + imagefilename[index];
  end
  else
  begin
    settingList.Values['eggFrame'] := IntToStr(0);
    Result := GetCurrentDir + PathDelim + 'media\img\' + objectName + PathDelim + objectName + imagefilename[0];
  end;
end;

procedure TtamegatchiForm.MasterTimerTimer(Sender: TObject);
begin
  SpriteImage.Picture.png.LoadFromFile(AnimateObject('egg', StrToInt(settingList.Values['eggFrame'])) + '.png');
  ShadowImage.Picture.png.LoadFromFile(AnimateObject('egg', StrToInt(settingList.Values['eggFrame'])) + '-shadow' + '.png');
  settingList.Values['eggFrame'] := IntToStr(StrToInt(settingList.Values['eggFrame']) + 1);
end;

procedure TtamegatchiForm.SpriteImageMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  canMoveForm := True;
  mouseX := X;
  mouseY := Y;
end;

procedure TtamegatchiForm.SpriteImageMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
begin
  if canMoveForm then
  begin
    tamegatchiForm.Left := tamegatchiForm.Left + X - mouseX;
    tamegatchiForm.Top := tamegatchiForm.Top + Y - mouseY;
  end;
end;

procedure TtamegatchiForm.SpriteImageMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  canMoveForm := False;
end;

end.
