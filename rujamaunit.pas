unit rujamaunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Menus, FileUtil, LCLIntf, Math;

type
  numarray = array of integer;

type

  { TtamegatchiForm }

  TtamegatchiForm = class(TForm)
    BathImage1: TImage;
    BathImage2: TImage;
    BathImage3: TImage;
    BathImage4: TImage;
    BathPanel: TPanel;
    FoodImage2: TImage;
    bgImage: TImage;
    FoodImage4: TImage;
    FoodImage1: TImage;
    PlayImage1: TImage;
    PlayImage2: TImage;
    PlayImage3: TImage;
    PlayImage4: TImage;
    BookImage1: TImage;
    BookImage2: TImage;
    BookImage3: TImage;
    BookImage4: TImage;
    PlayPanel: TPanel;
    HealthMarkerImage: TImage;
    FoodMarkerImage: TImage;
    BathMarkerImage: TImage;
    BookMarkerImage: TImage;
    HealthPanel: TPanel;
    FoodPanel: TPanel;
    PlayMarkerImage: TImage;
    pictoHome1: TImage;
    PictoMenuPanel: TPanel;
    pictoHome2: TImage;
    pictoHome3: TImage;
    pictoHome4: TImage;
    pictoHome5: TImage;
    pictoHome6: TImage;
    pictoHome7: TImage;
    pictoHome8: TImage;
    contextMenu: TPopupMenu;
    FoodImage3: TImage;
    BookPanel: TPanel;
    ShadowImage: TImage;
    ScreensImage: TImage;
    SpriteImage: TImage;
    MasterTimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure MasterTimerTimer(Sender: TObject);
    procedure pictoHomeClick(Sender: TObject);
    procedure PictoMenuPanelDblClick(Sender: TObject);
    procedure SpriteImageMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
    procedure SpriteImageMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure SpriteImageMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
  private
    procedure InitializeSettings;
    procedure PlayAnimation(objectName: string);
    procedure updateHealthPanel;
    procedure contextMenuClick(Sender: TObject);
    procedure actionClick(Sender: TObject);
    procedure updateActionPanel(panelname: string);
    procedure DoAnimationPlay(animation: string);
  public

  end;

var
  tamegatchiForm: TtamegatchiForm;
  settingList: TStringList;
  canMoveForm: boolean;
  mouseX, mouseY: integer;
  menuItems: array of string = ('home', 'health', 'food', 'settings', 'bath', 'play', 'book', 'exit');
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
  settingList.Values['Room'] := 'home';

  settingList.Values['Frame'] := IntToStr(0);
  settingList.Values['animation'] := 'home';
  settingList.Values['subanimation'] := '0';
  settingList.Values['subanimationticks'] := '0';
  settingList.Values['specialanimation'] := '';
  settingList.Values['specialanimationticks'] := '0';
  settingList.Values['specialanimationmaxticks'] := '20';

  settingList.Values['timeunits'] := '0';
  settingList.Values['lifeticks'] := IntToStr(5 * 4);
  settingList.Values['healthtogrow'] := '6';
  settingList.Values['growticks'] := '0';
  settingList.Values['growstep'] := '5';  //Reach 5 to get next gen

  settingList.Values['health'] := '8'; // 4.6 (initial)
  settingList.Values['food'] := '1'; //50%  4    //0.5  //   0 = Dead
  settingList.Values['book'] := '1'; //10%  0.4  //0.1  // 1-3 = Bad
  settingList.Values['play'] := '1'; //25%  2    //0.2  // 4-6 = Good
  settingList.Values['bath'] := '1'; //15%  1.2  //0.2  // 6-8 = Excelent

  settingList.Values['gen'] := '0';

  settingList.Values['bg'] := 'bg-lcd-off';
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
  Result :=
    Round(StrToFloat(settingList.Values[setting]));
end;

procedure setISetting(setting: string; Value: integer);
begin
  settingList.Values[setting] := IntToStr(Value);
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
  bgImage.Picture.PNG.LoadFromFile(getSSetting('imgrootpath') + getSSetting('bg') + '.png');

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
  maskpicture.PNG.LoadFromFile(getSSetting('imgrootpath') + getSSetting('bg') + '.png');
  SetShape(maskpicture.Bitmap);
end;


function getFrames(objectName: string): TStringList;
var
  files, newfiles: TStringList;
  i: integer;
  path: string;
begin
  files := TStringList.Create;
  newfiles := TStringList.Create;

  FindAllFiles(files, getSSetting('imgrootpath') + objectName, '*.png', False);
  path := ExtractFilePath(files[0]);

  for i := 0 to files.Count - 1 do
  begin
    newfiles.Add(path + IntToStr(i) + '.png');
  end;

  Result := newfiles;
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
var
  frameFileName: string;
  topPadding: integer;
begin
  frameFileName := AnimateObject(objectName, getISetting('Frame'));

  case getSSetting('gen') of
    '0':
      topPadding := 60;
    '1':
      topPadding := 50;
    '2':
      topPadding := 15;
  end;

  SpriteImage.Top := 120 + topPadding;
  ShadowImage.Top := 120 + topPadding;

  SpriteImage.Picture.png.LoadFromFile(frameFileName);
  ShadowImage.Picture.png.LoadFromFile(ExtractFilePath(frameFileName) + PathDelim + 'shadow' + PathDelim +
    ExtractFileName(frameFileName));
end;

procedure TtamegatchiForm.DoAnimationPlay(animation: string);
var
  randomNum: integer;
begin

  //randomize animation if more than one exists
  if getISetting('subanimation') = 0 then
  begin
    Randomize;
    randomNum := RandomRange(1, 200);
    writeln('gen ran');
  end;

  if getISetting('subanimationticks') = 0 then
  begin
    if getSSetting('animation') = 'home' then
    begin
      writeln('home ', randomNum);
      if (randomNum > 1) and (randomNum < 150) then
      begin
        setSSetting('subanimation', '0');
        setISetting('subanimationticks', 20);
        writeln('l', randomNum);
      end;

      if (randomNum >= 150) and (randomNum < 190) then
      begin
        setSSetting('subanimation', '1');
        setISetting('subanimationticks', 40);
        writeln('m', randomNum);
      end;

      if (randomNum >= 190) and (randomNum <= 200) then
      begin
        setSSetting('subanimation', '2');
        setISetting('subanimationticks', 20);
        writeln('h', randomNum);
      end;
    end;
  end;

  if getISetting('subanimationticks') > 0 then
  begin
    writeln('decr ', getISetting('subanimationticks'));
    setISetting('subanimationticks', getISetting('subanimationticks') - 1);
  end
  else
  begin
    setISetting('subanimation', 0);
    setISetting('subanimationticks', 0);
    writeln('reset ', getISetting('subanimation'), getISetting('subanimationticks'));
  end;

  //Choose What To Play
  if (getSSetting('specialanimation') = '') and (getSSetting('animation') = 'home') then
  begin
    PlayAnimation('cat' + PathDelim + getSSetting('gen') + PathDelim + getSSetting('animation') + PathDelim +
      getSSetting('subanimation') + PathDelim);
  end
  else
  begin
    if getISetting('specialanimationticks') <= getISetting('specialanimationmaxticks') then
    begin
      PlayAnimation('cat' + PathDelim + getSSetting('gen') + PathDelim + getSSetting('specialanimation') +
        PathDelim + getSSetting('subanimation') + PathDelim);
    end
    else
    begin
      setISetting('specialanimationticks', 0);
      setSSetting('specialanimation', '');
    end;
  end;
end;

procedure TtamegatchiForm.MasterTimerTimer(Sender: TObject);
begin

  //Choose Animation
  DoAnimationPlay('cat' + getSSetting('gen'));
  //PlayAnimation('cat\' + getSSetting('gen') + '\default\0\');

  settingList.Values['Frame'] := IntToStr(getISetting('Frame') + 1);
  settingList.Values['timeunits'] := IntToStr(getISetting('timeunits') + 1);

  //Update Health
  if getISetting('timeunits') > getISetting('lifeticks') then
  begin
    settingList.Values['health'] := getHealth;
  end;

  //set GrowTicks
  if (getISetting('health') > getISetting('healthtogrow')) and (getISetting('gen') < 2) then
  begin
    if (getISetting('timeunits') mod 5) = 0 then
    begin
      //writeln('we grew to ', getISetting('growticks'));
      setISetting('growticks', getISetting('growticks') + 1);
    end;
  end;

  //Advance if we have enough growticks
  if (getISetting('gen') < 2) and (getISetting('growticks') >= getISetting('growstep')) then
  begin
    //writeln('advanced to ', getISetting('gen'));
    setISetting('gen', getISetting('gen') + 1);
    setISetting('growticks', 0);
  end;

end;

procedure TtamegatchiForm.updateHealthPanel;
var
  i: integer;
begin
  HealthPanel.Visible := True;
  HealthPanel.Width := PictoMenuPanel.Width;
  HealthPanel.Height := 156;
  HealthPanel.Top := PictoMenuPanel.Top + 50;
  HealthPanel.Left := PictoMenuPanel.Left;

  for i := 0 to HealthPanel.ControlCount - 1 do
  begin
    if (HealthPanel.Controls[i].Name.Contains('MarkerImage')) and (HealthPanel.Controls[i].ClassType.ClassName = 'TImage') then
    begin
      (HealthPanel.Controls[i] as TImage).Picture.PNG.LoadFromFile(getSSetting('imgrootpath') + 'marker.png');
      (HealthPanel.Controls[i] as TImage).Left := 74;
      (HealthPanel.Controls[i] as TImage).Top := 26 + (i * 25);
      (HealthPanel.Controls[i] as TImage).Width := (getISetting(HealthPanel.Controls[i].Name.Replace('MarkerImage', '').ToLower) * 18);
    end;
  end;
end;

procedure TtamegatchiForm.updateActionPanel(panelname: string);
var
  i: integer;
  panel: TPanel;
begin
  panelname := panelname.ToUpper.Substring(0, 1) + panelname.ToLower.Substring(1, Length(panelname));

  for i := 0 to tamegatchiForm.ControlCount - 1 do
  begin
    if (tamegatchiForm.Controls[i].ClassName = 'TPanel') then
    begin
      if (tamegatchiForm.Controls[i].GetNamePath <> 'PictoMenuPanel') then
        (tamegatchiForm.Controls[i] as TPanel).Visible := False;

      if (tamegatchiForm.Controls[i].GetNamePath.Contains(panelname)) then
      begin
        panel := (tamegatchiForm.Controls[i] as TPanel);
      end;
    end;
  end;

  try
    panel.Visible := True;

    panel.Width := PictoMenuPanel.Width;
    panel.Height := 156;
    panel.Top := PictoMenuPanel.Top + 50;
    panel.Left := PictoMenuPanel.Left;

    for i := 0 to panel.ControlCount - 1 do
    begin
      if (panel.Controls[i].ClassType.ClassName = 'TImage') then
      begin
        (panel.Controls[i] as TImage).Picture.PNG.LoadFromFile(getSSetting('imgrootpath') + 'icons/' +
          panelname.ToLower + '/' + IntToStr(i) + '.png');

        if i <= 1 then
          (panel.Controls[i] as TImage).Left := 10
        else
          (panel.Controls[i] as TImage).Left := panel.Width - 48 - 10;

        if i <= 1 then
          (panel.Controls[i] as TImage).Top := 10 + (i * 10) + (i * 48)
        else
          (panel.Controls[i] as TImage).Top := 10 + ((i - 2) * 10) + ((i - 2) * 48);

        (panel.Controls[i] as TImage).Height := 48;
        (panel.Controls[i] as TImage).Width := 48;
        (panel.Controls[i] as TImage).OnClick := @ActionClick;
      end;
    end;
  except
    Writeln('Panel ' + panelname + ' not found.')
  end;
end;

procedure TtamegatchiForm.actionClick(Sender: TObject);
var
  settingname: string;
  settingindex: integer;
begin
  settingindex := StrToInt(copy((Sender as TImage).GetNamePath, Length((Sender as TImage).GetNamePath), 1));
  settingname := copy((Sender as TImage).GetNamePath.Replace('Image', ''), 0, Length(
    (Sender as TImage).GetNamePath.Replace('Image', '')) - 1).ToLower;

  setISetting(settingname, getISetting(settingname) + settingindex);
end;

procedure TtamegatchiForm.pictoHomeClick(Sender: TObject);
var
  roomFromMenu: string;
  i: integer;
begin
  roomFromMenu := menuItems[StrToInt(Copy((Sender as TImage).GetNamePath, Length('pictoHome') + 1, 2)) - 1];
  settingList.Values['Room'] := roomFromMenu;

  for i := 0 to tamegatchiForm.ControlCount - 1 do
  begin
    if (tamegatchiForm.Controls[i].ClassName = 'TPanel') then
    begin
      if (tamegatchiForm.Controls[i].GetNamePath <> 'PictoMenuPanel') then
        (tamegatchiForm.Controls[i] as TPanel).Visible := False;
    end;
  end;

  case roomFromMenu of
    'exit':
      Application.Terminate;
    'health':
      updateHealthPanel;
  end;

  if roomFromMenu <> 'exit' then
    ScreensImage.Picture.PNG.LoadFromFile(getSSetting('imgrootpath') + 'screens' + PathDelim +
      menuItems[StrToInt(Copy((Sender as TImage).GetNamePath, Length('pictoHome') + 1, 2)) - 1] + '.png');

  if (roomFromMenu <> 'exit') and (roomFromMenu <> 'health') then
    updateActionPanel(roomFromMenu);
end;

procedure TtamegatchiForm.PictoMenuPanelDblClick(Sender: TObject);
begin
  if getSSetting('bg') = 'bg-lcd-on' then
    setSSetting('bg', 'bg-lcd-off')
  else
    setSSetting('bg', 'bg-lcd-on');

  bgImage.Picture.PNG.LoadFromFile(getSSetting('imgrootpath') + getSSetting('bg') + '.png');
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
