program shake7;

{$mode objfpc}{$H+}

{ Lock/Unlock simatic step7 blocks (Know How Protection)

  Copyright (C) 2008 Luca Olivetti <luca@ventoso.org>

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

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms
  { you can add units after this }, shake7main, DBFLaz, rx, about, MemDSLaz;

{$IFDEF WINDOWS}{$R shake7.rc}{$ENDIF}

begin
  Application.Initialize;
  Application.CreateForm(Tshake7mainform, shake7mainform);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.Run;
end.

