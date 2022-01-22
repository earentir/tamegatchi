unit rujamaunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Menus, FileUtil, LCLIntf;

type

  { TtamegatchiForm }

  TtamegatchiForm = class(TForm)
    FoodImage2: TImage;
    bgImage: TImage;
    FoodImage4: TImage;
    FoodImage1: TImage;
    HealthMarkerImage: TImage;
    FoodMarkerImage: TImage;
    BathMarkerImage: TImage;
    BookMarkerImage: TImage;
    MarkerPanel: TPanel;
    FoodPanel: TPanel;
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
    contextMenu: TPopupMenu;
    FoodImage3: TImage;
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
    procedure updateHealthPanel;
    procedure contextMenuClick(Sender: TObject);
    procedure updateFoodPanel;
    procedure FeedClick(Sender: TObject);
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

function getHealth: string;  // If < 4 then - 1/8 on lifetick, > 4 +1 1/8 on lifetick
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

procedure setSSetting(setting, Value: string);
begin
  settingList.Values[setting] := Value;
end;

function getISetting(setting: string): integer;
begin
  Result := StrToInt(settingList.Values[setting]);
end;

procedure setISetting(setting: string; Value: integer);
begin
  settingList.Values[setting] := StrToInt(Value);
end;

procedure TtamegatchiForm.contextMenuClick(Sender: TObject);
begin
  OpenURL((Sender as TMenuItem).Hint);
end;

procedure TtamegatchiForm.FormCreate(Sender: TObject);
var
  i: integer;
  mi: TMenuItem;
  abouttext: array of string = ('Made for RuJAM 2022A', 'Graphics by Evel_Cult_Leader', 'Code by Earentir', '❤❤ Rujum ❤❤');
  aboutlinks: array of string = ('https://rujam.top', 'https://twitch.tv/evel_cult_leader', 'https://twitch.tv/earentir',
    'https://twitch.tv/therujum');
begin

  for i := 0 to Length(abouttext) - 1 do
  begin
    mi := TMenuItem.Create(nil);
    mi.Caption := abouttext[i];
    mi.Hint := aboutlinks[i];
    mi.Tag := i;
    mi.OnClick := @contextMenuClick;
    contextMenu.Items.Add(mi);
  end;

  //setup settings
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


function getFrames(objectName: string): TStringList;
var
  files: TStringList;
  i: integer;
begin
  files := TStringList.Create;

  FindAllFiles(files, getSSetting('imgrootpath') + objectName + PathDelim, '*.png', False);

  for i := files.Count - 1 downto 0 do
  begin
    files.Strings[i] := copy(files.Strings[i], 0, Length(files.Strings[i]) - Length(ExtractFileExt(files.Strings[i])));
    if files.Strings[i].Contains('-shadow') then
      files.Delete(i);
  end;

  Result := files;
end;

function AnimateObject(objectName: string; index: integer): string;
var
  imagefilename: TStringList;
begin
  imagefilename := TStringList.Create;
  imagefilename := getFrames(objectName);

  if getISetting('Frame') < imagefilename.Count - 1 then
  begin
    Result := imagefilename.Strings[index];
  end
  else
  begin
    settingList.Values['Frame'] := IntToStr(0);
    Result := imagefilename.Strings[0];
  end;
end;

procedure TtamegatchiForm.PlayAnimation(objectName: string);
begin
  SpriteImage.Picture.png.LoadFromFile(AnimateObject(objectName, getISetting('Frame')) + '.png');
  ShadowImage.Picture.png.LoadFromFile(AnimateObject(objectName, getISetting('Frame')) + '-shadow.png');
end;

procedure TtamegatchiForm.MasterTimerTimer(Sender: TObject);
begin
  PlayAnimation('cat\0\0\');

  settingList.Values['Frame'] := IntToStr(getISetting('Frame') + 1);
  settingList.Values['timeunits'] := IntToStr(getISetting('timeunits') + 1);

  if getISetting('timeunits') > getISetting('lifeticks') then
  begin
    settingList.Values['health'] := getHealth;
  end;
end;

procedure TtamegatchiForm.updateHealthPanel;
begin
  MarkerPanel.Visible := True;
  MarkerPanel.Width := 256;
  MarkerPanel.Height := 156;
  MarkerPanel.Top := PictoMenuPanel.Top + 50;
  MarkerPanel.Left := PictoMenuPanel.Left;

  HealthMarkerImage.Picture.PNG.LoadFromFile(getSSetting('imgrootpath') + 'marker.png');
  HealthMarkerImage.Left := 66;
  HealthMarkerImage.Top := 17;
  HealthMarkerImage.Width := (getISetting('health') * 18);

  FoodMarkerImage.Picture.PNG.LoadFromFile(getSSetting('imgrootpath') + 'marker.png');
  FoodMarkerImage.Left := 66;
  FoodMarkerImage.Top := 44;
  FoodMarkerImage.Width := (getISetting('food') * 18);

  PlayMarkerImage.Picture.PNG.LoadFromFile(getSSetting('imgrootpath') + 'marker.png');
  PlayMarkerImage.Left := 66;
  PlayMarkerImage.Top := 69;
  PlayMarkerImage.Width := (getISetting('play') * 18);

  BookMarkerImage.Picture.PNG.LoadFromFile(getSSetting('imgrootpath') + 'marker.png');
  BookMarkerImage.Left := 66;
  BookMarkerImage.Top := 94;
  BookMarkerImage.Width := (getISetting('book') * 18);

  BathMarkerImage.Picture.PNG.LoadFromFile(getSSetting('imgrootpath') + 'marker.png');
  BathMarkerImage.Left := 66;
  BathMarkerImage.Top := 121;
  BathMarkerImage.Width := (getISetting('bath') * 18);
end;

procedure TtamegatchiForm.updateFoodPanel;
begin
  FoodPanel.Visible := True;

  FoodPanel.Width := PictoMenuPanel.Width;
  FoodPanel.Height := 156;
  FoodPanel.Top := PictoMenuPanel.Top + 50;
  FoodPanel.Left := PictoMenuPanel.Left;

  FoodImage1.Picture.PNG.LoadFromFile(getSSetting('imgrootpath') + 'marker.png');
  FoodImage1.Left := 10;
  FoodImage1.Top := 10;
  FoodImage1.Height := 48;
  FoodImage1.Width := 48;
  FoodImage1.OnClick := @FeedClick;

  FoodImage2.Picture.PNG.LoadFromFile(getSSetting('imgrootpath') + 'marker.png');
  FoodImage2.Left := 10;
  FoodImage2.Top := 10 + 48 + 10;
  FoodImage2.Height := 48;
  FoodImage2.Width := 48;

  FoodImage3.Picture.PNG.LoadFromFile(getSSetting('imgrootpath') + 'marker.png');
  FoodImage3.Left := FoodPanel.Width - 48 - 10;
  FoodImage3.Top := 10;
  FoodImage3.Height := 48;
  FoodImage3.Width := 48;

  FoodImage4.Picture.PNG.LoadFromFile(getSSetting('imgrootpath') + 'marker.png');
  FoodImage4.Left := FoodPanel.Width - 48 - 10;
  FoodImage4.Top := 10 + 48 + 10;
  FoodImage4.Height := 48;
  FoodImage4.Width := 48;
end;

procedure TtamegatchiForm.FeedClick(Sender: TObject);
begin
  case (Sender as TImage).GetNamePath of
    'FoodImage1':
      ;
    'FoodImage2':
      ;
    'FoodImage3':
      ;
    'FoodImage4':
      ;
  end;
end;

procedure TtamegatchiForm.pictoHomeClick(Sender: TObject);
var
  roomFromMenu: string;
begin
  roomFromMenu := menuItems[StrToInt(Copy((Sender as TImage).GetNamePath, Length('pictoHome') + 1, 2)) - 1];
  settingList.Values['Room'] := roomFromMenu;

  MarkerPanel.Visible := False;

  case roomFromMenu of
    'exit':
      Application.Terminate;
    'health':
      updateHealthPanel;
    'food':
      updateFoodPanel;
  end;

  if roomFromMenu <> 'exit' then
    ScreensImage.Picture.PNG.LoadFromFile(getSSetting('imgrootpath') + 'screens' + PathDelim +
      menuItems[StrToInt(Copy((Sender as TImage).GetNamePath, Length('pictoHome') + 1, 2)) - 1] + '.png');
end;

procedure TtamegatchiForm.SpriteImageMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  if Button = mbRight then
    contextMenu.PopUp(tamegatchiForm.Left + 128 + x, tamegatchiForm.Top + 128 + y);

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
