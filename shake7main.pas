unit shake7main;

{$mode objfpc}{$H+}

{ Lock/Unlock simatic step7 blocks (Know How Protection)

  Copyright (C) 2008-2011 Luca Olivetti <luca@ventoso.org>

  This source is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 3 of the License, or (at your option)
  any later version.

  This code is distributed in the hope that it will be useful, but WITHOUT ANY
  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.

  A copy of the GNU General Public License is available on the World Wide Web
  at <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing
  to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
  MA 02111-1307, USA.
}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, dbf, db,
  memds, ExtCtrls, Buttons, StdCtrls, DBGrids, Grids, MRUList,
  inifiles, Menus, Spin;

type

   TBlockType = record
     number:integer;
     name:string;
     show:boolean;
   end;

const

   BlockTypes:Array[1..5] of TBlockType =
      (
        (number:1;  name:'UDT'; show:true)
       ,(number:8;  name:'OB';  show:true)
       ,(number:10; name:'DB';  show:true)
       ,(number:12; name:'FC';  show:true)
       ,(number:14; name:'FB';  show:true)
      );

   BlockLanguages:array[1..40] of string =
      (
       {1}    'AWL'
       {2}   ,'KOP'
       {3}   ,'FUP'
       {4}   ,'SCL'
       {5}   ,'DB'
       {6}   ,'GRAPH'
       {7}   ,'SDB'
       {8}   ,'CPU DB'
       {9}   ,'ASSEMBLER'
       {10}  ,'DB (of FB)'
       {11}  ,'DB (of SFB)'
       {12}  ,'DB (of UDT)'
       {13}  ,'GD'
       {14}  ,'PARATOOL'
       {15}  ,'??00015'
       {16}  ,'NCM'
       {17}  ,'CPU SDB'
       {18}  ,'STL S7-200'
       {19}  ,'LAD ST-200'
       {20}  ,'MCU IBN'
       {21}  ,'C for S7'
       {22}  ,'HIGRAPH'
       {23}  ,'CFC'
       {24}  ,'SFC'
       {25}  ,'CFC/SFC'
       {26}  ,'S7-PDIAG'
       {27}  ,'reserve 27'
       {28}  ,'reserve 28'
       {29}  ,'SFM'
       {30}  ,'CHART'
       {31}  ,'AWL F'
       {32}  ,'KOP F'
       {33}  ,'FUP F'
       {34}  ,'DB F'
       {35}  ,'CALL F'
       {36}  ,'D7-SYS'
       {37}  ,'Tech Obj'
       {38}  ,'KOP F (unchecked)'
       {39}  ,'FUP F (unchecked)'
       {40}  ,'SFM'
       );

type

   { Tshake7mainform }

  Tshake7mainform = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    Blocks: TDbf;
    BlocksBLKLANG: TStringField;
    BlocksBLKNUMBER: TStringField;
    BlocksBlock: TStringField;
    BlocksBLOCKFNAME: TStringField;
    BlocksBLOCKNAME: TStringField;
    BlocksBlockProtected: TStringField;
    BlocksLanguage: TStringField;
    BlocksPASSWORD: TLargeintField;
    BlocksSUBBLKTYP: TStringField;
    BlocksUSERNAME: TStringField;
    BlocksVERSION: TSmallintField;
    BlocksVersionDisplay: TStringField;
    ChangeLanguageButton: TButton;
    Label3: TLabel;
    Language: TComboBox;
    MemBlocks: TMemDataset;
    ShowUDT: TCheckBox;
    ShowOB: TCheckBox;
    ShowDB: TCheckBox;
    ShowFC: TCheckBox;
    ShowFB: TCheckBox;
    Folders: TDBF;
    FoldersID: TFloatField;
    FoldersNAME: TStringField;
    FoldersANZFB: TFloatField;
    FoldersANZFC: TFloatField;
    FoldersANZDB: TFloatField;
    FoldersANZOB: TFloatField;
    FolderSource: TDataSource;
    BlocksSource: TDataSource;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    MainMenu1: TMainMenu;
    MenuFile: TMenuItem;
    MenuHelp: TMenuItem;
    MenuAbout: TMenuItem;
    MenuQuit: TMenuItem;
    MenuOpen: TMenuItem;
    MRUManager: TMRUManager;
    OpenDialog: TOpenDialog;
    OpenButton: TSpeedButton;
    Panel1: TPanel;
    RecentFiles: TComboBox;
    Label1: TLabel;
    FoldersGrid: TDBGrid;
    BlocksGrid: TDBGrid;
    LockButton: TButton;
    ForceLang: TSpinEdit;
    UnlockButton: TButton;
    procedure BlocksBeforeClose(DataSet: TDataSet);
    procedure BlocksGridPrepareCanvas(sender: TObject; DataCol: Integer;
      Column: TColumn; AState: TGridDrawState);
    procedure FoldersAfterScroll(DataSet: TDataSet);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MenuAboutClick(Sender: TObject);
    procedure MenuQuitClick(Sender: TObject);
    procedure OpenProject(Filename:string;AddToMRU:boolean);
    procedure BlocksFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure BlocksCalcFields(DataSet: TDataSet);
    procedure LockUnlockClick(Sender: TObject);
    procedure OpenButtonClick(Sender: TObject);
    procedure MRUManagerChange(Sender: TObject);
    procedure RecentFilesChange(Sender: TObject);
    procedure ChangeLanguageClick(Sender: TObject);
    procedure ShowTypeClick(Sender: TObject);
  private
    { Private declarations }
    FBlockList:TStringList;
    procedure ClearBlocks;
    procedure RefreshMemBlocks;
  public
    { Public declarations }
  end;

var
  shake7mainform: Tshake7mainform;

implementation

uses about;

function ShowBlockType(number:integer):boolean;
var
  i: Integer;
begin
  result:=false;
  for i:=low(BlockTypes) to high(BlockTypes) do
    if BlockTypes[i].number=number then
    begin
      Result:=BlockTypes[i].show;
      exit;
    end;
end;

procedure EnableBlockType(name:string; enable:boolean);
var
  i: integer;
begin
  for i:=low(BlockTypes) to high(BlockTypes) do
    if BlockTypes[i].name=name then
    begin
      BlockTypes[i].show:=enable;
      exit;
    end;

end;

procedure Tshake7mainform.OpenProject(Filename:string;AddToMRU:boolean);
begin
  Folders.Active:=false;
  Blocks.Active:=false;
  if FileExists(Filename) then
  begin
    Folders.FilePathFull:=ExtractFilePath(Filename)+'ombstx\offline';
    try
      Folders.Active:=true;
    except
      on Exception do
        begin
          MessageDlg ('Error', 'Error opening project', mtError, [mbOk],0);
          Folders.Active:=false;
          exit;
        end;
    end;
    if AddToMRU then
    begin
      MRUManager.Add(Filename,0);
      RecentFiles.OnChange:=nil;
      RecentFiles.Itemindex:=RecentFiles.Items.Indexof(Filename); 
      RecentFiles.OnChange:=@RecentFilesChange;
    end;  
    OpenDialog.InitialDir:=ExtractFilePath(Filename);
  end else MessageDlg('Error','File doesn''t exist', mtError, [mbOk], 0);

end;

type TMyMemDs = class(TMemDataset); //ugly hack, see fpc bug #13967

procedure Tshake7mainform.FormCreate(Sender: TObject);
var ini:TIniFile;
    i:integer;
begin
  for i:=low(BlockLanguages) to high(BlockLanguages) do
     Language.Items.Add(BlockLanguages[i]);
  Language.ItemIndex:=0;
  ForceLang.Visible:=ParamStr(1)='testlang';
  ini:=TIniFile.Create(GetUserDir+'shake7.ini');
  MRUManager.LoadFromIni(ini,'recent_files');
  ini.free;
  FBlockList:=TStringList.Create;
  TMyMemDs(MemBlocks).BookmarkSize:=sizeof(Longint); //second part of ugly hack
end;

procedure Tshake7mainform.FormDestroy(Sender: TObject);
begin
  ClearBlocks;
  FBlockList.Free;
end;

procedure Tshake7mainform.MenuAboutClick(Sender: TObject);
begin
  AboutForm.ShowModal;
end;

procedure Tshake7mainform.MenuQuitClick(Sender: TObject);
begin
  Close;
end;

procedure Tshake7mainform.BlocksFilterRecord(DataSet: TDataSet;
  var Accept: Boolean);
begin
  Accept:=ShowBlockType(strToIntDef(BlocksSUBBLKTYP.value,0));
end;

procedure Tshake7mainform.BlocksCalcFields(DataSet: TDataSet);
  Var BlockType,BlockNum,BlockLang:integer;
      BlockName:string;
      i: Integer;
begin
  BlockType:=StrToIntDef(BlocksSUBBLKTYP.value,0);
  BlockName:='??';
  for i:=low(BlockTypes) to high(BlockTypes) do
    if BlockTypes[i].number=BlockType then
    begin
      BlockName:=BlockTypes[i].name;
      break;
    end;
  BlockNum:=StrToIntDef(BlocksBLKNumber.value,-1);
  if BlockNum>=0 then BlockName:=BlockName+IntToStr(BlockNum);
  BlocksBlock.Value:=BlockName;
  if BlocksPassword.Value<>0 then BlocksBlockProtected.value:='Yes'
                             else BlocksBlockProtected.value:='No';
  BlocksVersionDisplay.Value:=format('%d.%d',[BlocksVersion.Value div 16, BlocksVersion.Value mod 16]);
  BlockLang:=StrToIntDef(BlocksBLKLANG.Value,0);
  if (BlockLang>=low(BlockLanguages)) and (BlockLang<=high(BlockLanguages)) then
    BlocksLanguage.Value:=BlockLanguages[BlockLang]
  else
    BlocksLanguage.Value:='??'+BlocksBLKLANG.Value;
end;

procedure Tshake7mainform.LockUnlockClick(Sender: TObject);
var i:integer;
   lockvalue:integer;
   bm:TBookmark;
begin
  if Sender=LockButton then lockvalue:=3 else lockvalue:=0;
  Screen.cursor:=crHourGlass;
  bm:=MemBlocks.GetBookmark;
  Blocks.GotoBookmark(FBlockList.Objects[MemBlocks.FieldByName('Number').AsInteger]);
  Blocks.Edit;
  BlocksPASSWORD.Value:=lockvalue;
  Blocks.Post;
  MemBlocks.Edit;
  MemBlocks.FieldByName('BlockProtected').Value:=BlocksBlockProtected.Value;
  MemBlocks.Post;
  for i:=0 to BlocksGrid.SelectedRows.Count-1 do
  begin
    MemBlocks.GotoBookmark(pointer(BlocksGrid.SelectedRows.Items[i]));
    Blocks.GotoBookmark(FBlockList.Objects[MemBlocks.FieldByName('Number').AsInteger]);
    Blocks.Edit;
    BlocksPASSWORD.Value:=lockvalue;
    Blocks.Post;
    MemBlocks.Edit;
    MemBlocks.FieldByName('BlockProtected').Value:=BlocksBlockProtected.Value;
    MemBlocks.Post;
  end;
  MemBlocks.GotoBookmark(bm);
  Screen.cursor:=crDefault;
end;

procedure Tshake7mainform.ChangeLanguageClick(Sender: TObject);
Type
   TSafetyType = (NormalBlock, FBlock);
   TBlockConversion = array[TSafetyType] of integer;
var
   NewLanguage:string;
   bm:TBookmark;
   i:integer;

   procedure DoChangeLanguage;
   var i:integer;
       CurrentBlockType:integer;
       NewBlockType:string;
   begin
     Blocks.Edit;
     BlocksBLKLANG.Value:=NewLanguage;
     Blocks.Post;
     MemBlocks.Edit;
     MemBlocks.FieldByName('Language').Value:=BlocksLanguage.Value;
     MemBlocks.Post;
   end;

begin
  NewLanguage:=format('%.4d',[Language.ItemIndex+1]);
  if ForceLang.Value<>0 then
    NewLanguage:=format('%.4d',[ForceLang.Value]);
  Screen.cursor:=crHourGlass;
  bm:=MemBlocks.GetBookmark;
  Blocks.GotoBookmark(FBlockList.Objects[MemBlocks.FieldByName('Number').AsInteger]);
  DoChangeLanguage;
  for i:=0 to BlocksGrid.SelectedRows.Count-1 do
  begin
    MemBlocks.GotoBookmark(pointer(BlocksGrid.SelectedRows.Items[i]));
    Blocks.GotoBookmark(FBlockList.Objects[MemBlocks.FieldByName('Number').AsInteger]);
    DoChangeLanguage;
  end;
  MemBlocks.GotoBookmark(bm);
  Screen.cursor:=crDefault;
end;

procedure Tshake7mainform.OpenButtonClick(Sender: TObject);
begin
  if OpenDialog.Execute then
  begin
    OpenProject(OpenDialog.Filename,true);
  end;
end;

procedure Tshake7mainform.MRUManagerChange(Sender: TObject);
var ini:TIniFile;
begin
  ini:=TIniFile.Create(GetUserDir+'shake7.ini');
  MRUManager.SaveToIni(ini,'recent_files');
  ini.free;
  RecentFiles.OnChange:=nil;
  RecentFiles.Items.Assign(MruManager.strings);
  RecentFiles.OnChange:=@RecentFilesChange;
end;

procedure Tshake7mainform.RecentFilesChange(Sender: TObject);
begin
  OpenProject(RecentFiles.Text,false);
end;

procedure Tshake7mainform.ShowTypeClick(Sender: TObject);
begin
  EnableBlockType(TCheckBox(sender).caption, TCheckBox(sender).Checked);
  if Blocks.Active then
  begin
    ClearBlocks;
    Blocks.Refresh;
    RefreshMemBlocks;
  end;
end;

procedure Tshake7mainform.ClearBlocks;
var i:integer;
begin
  for i:=0 to FBlockList.Count-1 do
    Blocks.FreeBookmark(FBlockList.Objects[i]);
  FBlockList.Clear;
end;

procedure Tshake7mainform.RefreshMemBlocks;
var
  i: integer;
begin
  BlocksGrid.SelectedRows.Clear;
  BlocksSource.DataSet:=nil;
  Blocks.First;
  MemBlocks.Clear(false);
  //sort blocks
  while not Blocks.Eof do
  begin
     FBlockList.AddObject(BlocksSUBBLKTYP.Value+BlocksBLKNUMBER.Value, TObject(
       Blocks.GetBookmark()));
     Blocks.Next;
  end;
  FBlockList.Sort;
  for i:=0 to FBlockList.Count-1 do
  begin
     Blocks.GotoBookmark(FBlockList.Objects[i]);
     MemBlocks.AppendRecord([
       BlocksBLKLANG.Value,
       BlocksSUBBLKTYP.Value,
       BlocksBLKNUMBER.Value,
       BlocksPASSWORD.Value,
       BlocksBlockProtected.Value,
       BlocksUSERNAME.Value,
       BlocksBLOCKFNAME.Value,
       BlocksBlock.Value,
       BlocksBLOCKNAME.Value,
       BlocksVERSION.Value,
       BlocksVersionDisplay.Value,
       i,
       BlocksLanguage.Value
       ]);
  end;
  MemBlocks.First;
  BlocksGrid.Enabled:=MemBlocks.RecordCount>0;
  LockButton.Enabled:=BlocksGrid.Enabled;
  UnlockButton.Enabled:=BlocksGrid.Enabled;
  ChangeLanguageButton.Enabled:=BlocksGrid.Enabled;
  BlocksSource.DataSet:=MemBlocks;
end;

procedure Tshake7mainform.BlocksGridPrepareCanvas(sender: TObject; DataCol: Integer;
  Column: TColumn; AState: TGridDrawState);
begin
  if MemBlocks.FieldByName('BlockProtected').AsString='Yes' then
    if GdSelected in AState then BlocksGrid.Canvas.Brush.Color:=$000080 {Dark red}
                            else BlocksGrid.Canvas.Brush.Color:=clRed;
  //F-Blocks
  if (DataCol=0) and (StrToIntDef(MemBlocks.FieldByName('BLKLANG').AsString,0)>30) then
    if GdSelected in AState then BlocksGrid.Canvas.Brush.Color:=$129dcb {Dark yellow}
                            else BlocksGrid.Canvas.Brush.Color:=clYellow;
end;

procedure Tshake7mainform.BlocksBeforeClose(DataSet: TDataSet);
begin
  ClearBlocks;
end;

procedure Tshake7mainform.FoldersAfterScroll(DataSet: TDataSet);
begin
  If not Folders.Active then exit;
  Screen.Cursor:=crHourglass;
  try
    Blocks.Active:=false;
    Blocks.FilePathFull:=Folders.FilePathFull+IntToHex(Trunc(FoldersId.Value),8);
    Blocks.Active:=true;
    RefreshMemBlocks;
  finally
    Screen.Cursor:=crDefault;
  end;
end;

initialization
  {$I shake7main.lrs}


end.
