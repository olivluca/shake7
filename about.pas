unit about;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons;

type

  { TAboutForm }

  TAboutForm = class(TForm)
    BitBtn1: TBitBtn;
    Memo1: TMemo;
    procedure Label1Click(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  AboutForm: TAboutForm;

implementation

{ TAboutForm }

procedure TAboutForm.Label1Click(Sender: TObject);
begin

end;

procedure TAboutForm.Memo1Change(Sender: TObject);
begin

end;

initialization
  {$I about.lrs}

end.

