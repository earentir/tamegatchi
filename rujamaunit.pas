unit rujamaunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    bgImage: TImage;
    ShadowImage: TImage;
    SpriteImage: TImage;
    MasterTimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure MasterTimerTimer(Sender: TObject);
    procedure SpriteImageMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
    procedure SpriteImageMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
  private

  public

  end;

var
  Form1: TForm1;
  tempvar: integer = 0;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  bgImage.Picture.PNG.LoadFromFile(GetCurrentDir + PathDelim + 'media\img\bg-lcd-off.png');
end;

//Mask On bitmap to make rest of the form transparent
procedure TForm1.FormPaint(Sender: TObject);
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
  if tempvar < Length(imagefilename) then
  begin
    Result := GetCurrentDir + PathDelim + 'media\img\egg\' + objectName + imagefilename[index];
  end
  else
  begin
    tempvar := 0;
    Result := GetCurrentDir + PathDelim + 'media\img\egg\' + objectName + imagefilename[0];
  end;
end;

procedure TForm1.MasterTimerTimer(Sender: TObject);
begin
  SpriteImage.Picture.png.LoadFromFile(AnimateObject('egg', tempvar) + '.png');
  ShadowImage.Picture.png.LoadFromFile(AnimateObject('egg', tempvar) + '-shadow' + '.png');
  tempvar := tempvar + 1;
end;

procedure TForm1.SpriteImageMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin

end;

procedure TForm1.SpriteImageMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
begin

end;

end.
