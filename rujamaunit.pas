unit rujamaunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls;

type

  { TtamegatchiForm }

  TtamegatchiForm = class(TForm)
    bgImage: TImage;
    pictoHome1: TImage;
    PictoMenuPanel: TPanel;
    pictoHome10: TImage;
    pictoHome2: TImage;
    pictoHome3: TImage;
    pictoHome4: TImage;
    pictoHome5: TImage;
    pictoHome6: TImage;
    pictoHome7: TImage;
    pictoHome8: TImage;
    pictoHome9: TImage;
    ShadowImage: TImage;
    SpriteImage: TImage;
    MasterTimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure MasterTimerTimer(Sender: TObject);
    procedure pictoHomeClick(Sender: TObject);
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
  menuItems: array of string = ('home', 'health', 'food', 'yard', 'settings', 'bath', 'play', 'book', 'shop', 'exit');

implementation

{$R *.lfm}

{ TtamegatchiForm }

//Icon Attribution: Entypo pictograms by Daniel Bruce — www.entypo.com

procedure TtamegatchiForm.FormCreate(Sender: TObject);
var
  i: integer;
begin
  bgImage.Picture.PNG.LoadFromFile(GetCurrentDir + PathDelim + 'media\img\bg-lcd-off.png');

  settingList := TStringList.Create;
  settingList.Values['eggFrame'] := IntToStr(0);

  for i := 0 to PictoMenuPanel.ControlCount - 1 do
  begin
    (PictoMenuPanel.Controls[i] as TImage).Picture.PNG.LoadFromFile(GetCurrentDir + PathDelim +
      'media\img\pictograms\' + menuItems[StrToInt(Copy(PictoMenuPanel.Controls[i].GetNamePath, Length('pictoHome') + 1, 2)) -
      1] + '.png');
  end;
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

procedure TtamegatchiForm.pictoHomeClick(Sender: TObject);
begin
  WriteLn('menu: ', menuItems[StrToInt(Copy((Sender as TImage).GetNamePath, Length('pictoHome') + 1, 2)) - 1]);

  case menuItems[StrToInt(Copy((Sender as TImage).GetNamePath, Length('pictoHome') + 1, 2)) - 1] of
    'home':
    begin
    end;

    'exit':
      Application.Terminate;
  end;
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
