unit rujamaunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls;

type

  { TtamegatchiForm }

  TtamegatchiForm = class(TForm)
    bgImage: TImage;
    HealthMarkerImage: TImage;
    FoodMarkerImage: TImage;
    BathMarkerImage: TImage;
    BookMarkerImage: TImage;
    PlayMarkerImage: TImage;
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
    procedure InitializeSettings;
    procedure PlayAnimation(objectName: string);
  public

  end;

var
  tamegatchiForm: TtamegatchiForm;
  settingList: TStringList;
  canMoveForm: boolean;
  mouseX, mouseY: integer;
  menuItems: array of string = ('home', 'health', 'food', 'yard', 'settings', 'bath', 'play', 'book', 'shop', 'exit');
//imgRootPath: string;


implementation

{$R *.lfm}

{ TtamegatchiForm }

//Icon Attribution: Entypo pictograms by Daniel Bruce — www.entypo.com

function fn(number: real): string;
begin
  Result := FormatFloat('#.#', number);
end;

function updateStats: string;  // If < 4 then - 1/8 on lifetick, > 4 +1 1/8 on lifetick
begin
  Result := fn((StrToInt(settingList.Values['food']) / 2) + ((StrToInt(settingList.Values['book']) / 100) * 10) +
    ((StrToInt(settingList.Values['play']) / 100) * 25) + ((StrToInt(settingList.Values['bath']) / 100) * 15));
end;

procedure TtamegatchiForm.InitializeSettings;
begin
  settingList := TStringList.Create;
  settingList.Values['Frame'] := IntToStr(0);
  settingList.Values['Room'] := 'home';

  settingList.Values['timeunits'] := '0';
  settingList.Values['lifeticks'] := IntToStr(5 * 4);

  settingList.Values['health'] := '8'; // 4.6 (initial)
  settingList.Values['food'] := '1'; //50%  4    //0.5  //   0 = Dead
  settingList.Values['book'] := '1'; //10%  0.4  //0.1  // 1-3 = Bad
  settingList.Values['play'] := '1'; //25%  2    //0.2  // 4-6 = Good
  settingList.Values['bath'] := '1'; //15%  1.2  //0.2  // 6-8 = Excelent

  settingList.Values['imgrootpath'] := GetCurrentDir + PathDelim + 'media' + PathDelim + 'img' + PathDelim;
end;

function getSSetting(setting: string): string;
begin
  Result := settingList.Values[setting];
end;

function getISetting(setting: string): integer;
begin
  Result := StrToInt(settingList.Values[setting]);
end;

procedure TtamegatchiForm.FormCreate(Sender: TObject);
var
  i: integer;
begin
  InitializeSettings;
  //setup BG img
  bgImage.Picture.PNG.LoadFromFile(getSSetting('imgrootpath') + 'bg-lcd-off.png');

  //setup default room
  ScreensImage.Picture.PNG.LoadFromFile(getSSetting('imgrootpath') + 'screens' + PathDelim + 'home.png');

  //Load Pictograms to menu items
  for i := 0 to PictoMenuPanel.ControlCount - 1 do
  begin
    (PictoMenuPanel.Controls[i] as TImage).Picture.PNG.LoadFromFile(getSSetting('imgrootpath') + 'pictograms' +
      PathDelim + menuItems[StrToInt(Copy(PictoMenuPanel.Controls[i].GetNamePath, Length('pictoHome') + 1, 2)) - 1] + '.png');
  end;
end;

//Mask On bitmap to make rest of the form transparent
procedure TtamegatchiForm.FormPaint(Sender: TObject);
var
  maskpicture: TPicture;
begin
  maskpicture := TPicture.Create;
  maskpicture.PNG.LoadFromFile(getSSetting('imgrootpath') + 'bg-lcd-off.png');
  SetShape(maskpicture.Bitmap);
end;

function AnimateObject(objectName: string; index: integer): string;
var
  imagefilename: array of string = ('default', 'skewl1', 'skewr1', 'move1', 'move2', 'move1', 'default', 'skewl1', 'skewr1');
begin
  if StrToInt(settingList.Values['Frame']) < Length(imagefilename) then
  begin
    Result := getSSetting('imgrootpath') + objectName + PathDelim + imagefilename[index];
  end
  else
  begin
    settingList.Values['Frame'] := IntToStr(0);
    Result := getSSetting('imgrootpath') + objectName + PathDelim + imagefilename[0];
  end;
end;

procedure TtamegatchiForm.PlayAnimation(objectName: string);
begin
  SpriteImage.Picture.png.LoadFromFile(AnimateObject(objectName, getISetting('Frame')) + '.png');
  ShadowImage.Picture.png.LoadFromFile(AnimateObject(objectName, getISetting('Frame')) + '-shadow' + '.png');
end;

procedure TtamegatchiForm.MasterTimerTimer(Sender: TObject);
begin
  PlayAnimation('cat\0\0\');

  settingList.Values['Frame'] := IntToStr(StrToInt(settingList.Values['Frame']) + 1);
  settingList.Values['timeunits'] := IntToStr(StrToInt(settingList.Values['timeunits']) + 1);

  updateStats;
end;

procedure TtamegatchiForm.pictoHomeClick(Sender: TObject);
var
  roomFromMenu: string;
begin
  roomFromMenu := menuItems[StrToInt(Copy((Sender as TImage).GetNamePath, Length('pictoHome') + 1, 2)) - 1];

  case roomFromMenu of
    'exit':
      Application.Terminate;
    'health':
    begin
      HealthMarkerImage.Picture.PNG.LoadFromFile(getSSetting('imgrootpath') + 'marker.png');
      HealthMarkerImage.Left := 128 + 67;
      HealthMarkerImage.Top := 128 + 59;
      writeln(settingList.Values['health']);
      HealthMarkerImage.Width := (StrToInt(settingList.Values['health']) * 18);
    end;
  end;

  if roomFromMenu <> 'exit' then
    ScreensImage.Picture.PNG.LoadFromFile(getSSetting('imgrootpath') + 'screens' + PathDelim +
      menuItems[StrToInt(Copy((Sender as TImage).GetNamePath, Length('pictoHome') + 1, 2)) - 1] + '.png');

  settingList.Values['Room'] := roomFromMenu;
  //end;

  settingList.Values['timeunits'];
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
