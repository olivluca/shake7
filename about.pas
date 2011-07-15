unit about;

{$mode objfpc}{$H+}

interface

uses
  LResources, Forms, StdCtrls,
  Buttons;

type

  { TAboutForm }

  TAboutForm = class(TForm)
    BitBtn1: TBitBtn;
    Memo1: TMemo;
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  AboutForm: TAboutForm;

implementation

{ TAboutForm }

initialization
  {$I about.lrs}

end.

