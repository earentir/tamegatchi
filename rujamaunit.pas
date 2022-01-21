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
    ScreensImage: TImage;
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
  imgRootPath: string;


implementation

{$R *.lfm}

{ TtamegatchiForm }

//Icon Attribution: Entypo pictograms by Daniel Bruce — www.entypo.com

procedure TtamegatchiForm.FormCreate(Sender: TObject);
var
  i: integer;
begin
  imgRootPath := GetCurrentDir + PathDelim + 'media' + PathDelim + 'img' + PathDelim;

  bgImage.Picture.PNG.LoadFromFile(imgRootPath + 'bg-lcd-off.png');

  settingList := TStringList.Create;
  settingList.Values['Frame'] := IntToStr(0);
  settingList.Values['Room'] := 'home';

  for i := 0 to PictoMenuPanel.ControlCount - 1 do
  begin
    (PictoMenuPanel.Controls[i] as TImage).Picture.PNG.LoadFromFile(imgRootPath + 'pictograms' + PathDelim +
      menuItems[StrToInt(Copy(PictoMenuPanel.Controls[i].GetNamePath, Length('pictoHome') + 1, 2)) - 1] + '.png');
  end;
end;

//Mask On bitmap to make rest of the form transparent
procedure TtamegatchiForm.FormPaint(Sender: TObject);
var
  maskpicture: TPicture;
begin
  maskpicture := TPicture.Create;
  maskpicture.PNG.LoadFromFile(imgRootPath + 'bg-lcd-off.png');
  SetShape(maskpicture.Bitmap);
end;

function AnimateObject(objectName: string; index: integer): string;
var
  imagefilename: array of string = ('default', 'skewl1', 'skewr1', 'move1', 'move2', 'move1', 'default', 'skewl1', 'skewr1');
begin
  if StrToInt(settingList.Values['Frame']) < Length(imagefilename) then
  begin
    Result := imgRootPath + objectName + PathDelim + imagefilename[index];
  end
  else
  begin
    settingList.Values['Frame'] := IntToStr(0);
    Result := imgRootPath + objectName + PathDelim + imagefilename[0];
  end;
end;

procedure TtamegatchiForm.MasterTimerTimer(Sender: TObject);
begin
  SpriteImage.Picture.png.LoadFromFile(AnimateObject('cat\1\', StrToInt(settingList.Values['Frame'])) + '.png');
  ShadowImage.Picture.png.LoadFromFile(AnimateObject('cat\1\', StrToInt(settingList.Values['Frame'])) + '-shadow' + '.png');
  settingList.Values['Frame'] := IntToStr(StrToInt(settingList.Values['Frame']) + 1);
end;

procedure TtamegatchiForm.pictoHomeClick(Sender: TObject);
var
  roomFromMenu: string;
begin
  roomFromMenu := menuItems[StrToInt(Copy((Sender as TImage).GetNamePath, Length('pictoHome') + 1, 2)) - 1];

  //writeLn(roomFromMenu);
  //writeLn(settingList.Values['Room']);
  if (roomFromMenu = settingList.Values['Room']) then
  begin
    ScreensImage.Picture.PNG.Clear;
    settingList.Values['Room'] := 'home';
  end
  else
  begin
    case menuItems[StrToInt(Copy((Sender as TImage).GetNamePath, Length('pictoHome') + 1, 2)) - 1] of
      'home':
        ScreensImage.Picture.PNG.LoadFromFile(imgRootPath + 'screens' + PathDelim + 'health.png');

      'food':
        ScreensImage.Picture.PNG.LoadFromFile(imgRootPath + 'screens' + PathDelim + 'health.png');

      'yard':
        ScreensImage.Picture.PNG.LoadFromFile(imgRootPath + 'screens' + PathDelim + 'health.png');

      'health':
        ScreensImage.Picture.PNG.LoadFromFile(imgRootPath + 'screens' + PathDelim + 'health.png');

      'play':
        ScreensImage.Picture.PNG.LoadFromFile(imgRootPath + 'screens' + PathDelim + 'health.png');

      'path':
        ScreensImage.Picture.PNG.LoadFromFile(imgRootPath + 'screens' + PathDelim + 'health.png');

      'book':
        ScreensImage.Picture.PNG.LoadFromFile(imgRootPath + 'screens' + PathDelim + 'health.png');

      'exit':
        Application.Terminate;
    end;

    settingList.Values['Room'] := roomFromMenu;
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
