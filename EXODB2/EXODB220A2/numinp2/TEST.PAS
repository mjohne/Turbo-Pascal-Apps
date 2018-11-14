program testje;
uses    app,dialogs,objects,menus,drivers,views,msgbox,numinput;
const   cmabout=201;

type    tmyapp=object(TApplication)
                 procedure initstatusline;virtual;
                 procedure HandleEvent(var e:tevent);virtual;
                 procedure about;
               end;

procedure tmyapp.initstatusline;
var       r:TRect;
begin
  getextent(r);
  r.a.y:=r.b.y-1;
  statusline:=new(PStatusLine,Init(R,NewStatusDef(0,$ffff,
                NewStatusKey('E~x~it',kbAltX,cmQuit,
                 NewStatusKey('~A~bout',kbF1,cmAbout,
                  NewStatusKey('~A~bout',kbAltA,cmAbout,nil))),nil)));
end;



procedure tmyapp.handleevent(var e:tevent);
begin
  inherited HandleEvent(e);
  if e.what=evCommand then
    case e.command of
      cmAbout: begin about;clearevent(e);end;
      else ;
    end;
end;



procedure tmyapp.about;
var       dialog:pdialog;
          r:trect;
          b:Pview;
          st,s1:string;
          s:record
              l:longint;
              i:integer;
              b:byte;
              w:word;
            end;
begin
  r.assign(1,1,40,10);
  dialog:=new(PDialog,Init(R,'About-Dialog'));
  with dialog^ do
  begin
    options:=options or ofCentered;
    r.assign(10,1,30,2);b:=new(PLongintInputLine,init(R));Insert(b);
    r.assign(1,1,10,2);Insert(new(PLabel,init(R,'Long',b)));

    r.assign(10,3,30,4);b:=new(PIntInputLine,init(R));Insert(b);
    r.assign(1,3,10,4);Insert(new(PLabel,init(R,'Int',b)));

    r.assign(10,5,15,6);b:=new(PByteInputLine,init(R));Insert(b);
    r.assign(1,5,10,6);Insert(new(PLabel,init(R,'Byte',b)));

    r.assign(10,7,17,8);b:=new(PWordInputLine,init(R));Insert(b);
    r.assign(1,7,10,8);Insert(new(PLabel,init(R,'Word',b)));

    r.assign(20,6,30,8);Insert(new(PButton,Init(R,'~O~k',cmOk,bfDefault)));
  end;
  s.w:=1025;
  s.b:=12;
  s.l:=6544554;
  s.i:=1024;
  Dialog^.SetData(s);
  desktop^.execview(dialog);
  Dialog^.GetData(s);
  str(s.l,s1);st:=concat(   ^C,'long: ',s1,^M);
  str(s.i,s1);st:=concat(st,^C,'inte: ',s1,^M);
  str(s.b,s1);st:=concat(st,^C,'byte: ',s1,^M);
  str(s.w,s1);st:=concat(st,^C,'word: ',s1,^M);
  messagebox(st,nil,mfOkbutton+mfInformation);
  dispose(dialog,done);
end;



var   a:tmyapp;
begin
  a.init;
  a.about;
  a.run;
  a.done;
end.