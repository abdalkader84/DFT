unit main_unit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts, FMX.StdCtrls, FMX.Controls.Presentation , math,
  System.Math.Vectors, FMX.Viewport3D, FMX.Controls3D, FMX.Layers3D;

type DFT=record
     X:single;
     Y:Single;
     Q:Single;
     _Q:Single;
     M:Single;
     k:integer;
end;
const pt_dft_clr=TAlphaColors.Red;
const pt_clr=TAlphaColors.Green;
type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Layout1: TLayout;
    Panel2: TPanel;
    Text1: TText;
    Timer1: TTimer;
    Button3: TButton;
    Image1: TImage;
    OpenDialog1: TOpenDialog;
    CheckBox1: TCheckBox;
    TrackBar1: TTrackBar;
    Label1: TLabel;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Layout1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure Layout1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure Timer1Timer(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Layout1Painting(Sender: TObject; Canvas: TCanvas;
      const ARect: TRectF);
    procedure CheckBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);

  private
    { Private declarations }
  public
    procedure draw_center(clr:TAlphaColor);
    function  get_virt_axis(pt:TPointF;pric:Single): TPointF;
    function  get_orig_axis(pt: TPointF;pric:Single): TPointF;
    procedure draw_point(pt:TPointF;clr:TAlphaColor);
    procedure draw_cir_rel1(clr:TAlphaColor;q:single);
    function  draw_lin_rel1(clr:TAlphaColor;q:single):TPointF;
    procedure calc_dft(q:single);
  end;

const pr=10;
const pi=3.141592;
var
    Form1: TForm1;
    pnt,_shp_pnt:array of TPointF;
    dft_pnt,_dft_pnt:array of DFT;
    cler:Boolean;
    qq:Single;
    ms:TPointF;
implementation

{$R *.fmx}
function  TForm1.get_virt_axis(pt: TPointF;pric:Single): TPointF;
var px,py:single;
begin
  px:=pt.X-Layout1.Width/2;
  py:=-(pt.Y-Layout1.Height/2);
  Result.X:=px/pric;Result.Y:=py/pric;
end;
function  TForm1.get_orig_axis(pt: TPointF;pric:Single): TPointF;
var px,py:single;
begin
  px:=pt.X*pric+Layout1.Width/2;
  py:=-(pt.Y*pric-Layout1.Height/2);
  Result.X:=px;Result.Y:=py;
end;
procedure TForm1.draw_center(clr:TAlphaColor);
var v:Single;p1,p2:TPointF;
    s:TStrokeBrush;
begin
  v:=10;

  s:=TStrokeBrush.Create(TBrushKind.Solid,TAlphaColors.White);
  s.Color:=clr;
  s.Thickness:=1;

  p1:=TPointF.Create(Layout1.Width/2-v,Layout1.Height/2 );
  p2:=TPointF.Create(Layout1.Width/2+v,Layout1.Height/2 );
  Layout1.Canvas.DrawLine(p1,p2,1,s);
  p1:=TPointF.Create(Layout1.Width/2,Layout1.Height/2-v );
  p2:=TPointF.Create(Layout1.Width/2,Layout1.Height/2+v );
  Layout1.Canvas.DrawLine(p1,p2,1,s);

end;
procedure TForm1.draw_point(pt:TPointF;clr:TAlphaColor);
var  p1,p2:TPointF;
     V,px,py:Single;
     s:TStrokeBrush;
begin
  v:=1;
  pt:=get_orig_axis(pt,10);
  s:=TStrokeBrush.Create(TBrushKind.Solid,TAlphaColors.White);
  s.Color:=clr;
  s.Thickness:=1;

  Layout1.Canvas.Stroke.Color:=clr;
  p1:=TPointF.Create(pt.X-v,pt.Y-v);
  p2:=TPointF.Create(pt.X+v,pt.Y-v);
  Layout1.Canvas.DrawLine(p1,p2,1,s);
  p1:=TPointF.Create(pt.X+v,pt.Y-v);
  p2:=TPointF.Create(pt.X+v,pt.Y+v);
  Layout1.Canvas.DrawLine(p1,p2,1,s);
  p1:=TPointF.Create(pt.X+v,pt.Y+v);
  p2:=TPointF.Create(pt.X-v,pt.Y+v);
  Layout1.Canvas.DrawLine(p1,p2,1,s);
  p1:=TPointF.Create(pt.X-v,pt.Y+v);
  p2:=TPointF.Create(pt.X-v,pt.Y-v);
  Layout1.Canvas.DrawLine(p1,p2,1,s);
end;
procedure TForm1.FormCreate(Sender: TObject);
begin
  Timer1.Interval:=trunc(TrackBar1.Value);
end;

procedure TForm1.draw_cir_rel1( clr:TAlphaColor;q:single);
var  pt,_pt:TPointF;
     rct:TRectF;
     k:Integer;
     s:TStrokeBrush;
begin
  s:=TStrokeBrush.Create(TBrushKind.Solid,TAlphaColors.White);
  s.Color:=clr;
  s.Thickness:=1;
  Layout1.Canvas.Stroke.Color:=clr;
  pt:=TPointF.Zero;
  for k := 0  to Length(dft_pnt)-1 do
  begin
    dft_pnt[k].Q:=dft_pnt[k].k* q +dft_pnt[k]._Q ;
    dft_pnt[k].X:=dft_pnt[k].M* Cos(dft_pnt[k].Q);
    dft_pnt[k].Y:=dft_pnt[k].M* Sin(dft_pnt[k].Q);

    _pt:=TPointF.Zero;
    pt:=get_orig_axis(pt,pr);
    rct.left:=pt.X-dft_pnt[k].M*pr;
    rct.Top:=pt.Y-dft_pnt[k].M*pr;
    rct.Width:=2*dft_pnt[k].M*pr;
    rct.Height:=2*dft_pnt[k].M*pr;
    Layout1.Canvas.DrawEllipse(rct,1,s);
    _pt.X:= dft_pnt[k].X;
    _pt.Y:= dft_pnt[k].Y;
    pt:=get_virt_axis(pt,pr);
    pt.X:=pt.X+_pt.X;
    pt.Y:=pt.Y+_pt.Y;
  end;
end;
function  TForm1.draw_lin_rel1(clr:TAlphaColor; q:single):TPointF;
var  p1,p2:TPointF;
     V,px,py:Single; k:Integer;
     s:TStrokeBrush;
begin
  s:=TStrokeBrush.Create(TBrushKind.Solid,TAlphaColors.White);
  s.Color:=clr;
  s.Thickness:=1;
  Layout1.Canvas.Stroke.Color:=clr;
  p1:=TPointF.Zero;
  for k := 0  to Length(dft_pnt)-1 do
  begin
    dft_pnt[k].Q:=dft_pnt[k].k* q +dft_pnt[k]._Q ;
    dft_pnt[k].X:=dft_pnt[k].M* Cos(dft_pnt[k].Q);
    dft_pnt[k].Y:=dft_pnt[k].M* Sin(dft_pnt[k].Q);

    p2:=TPointF.Zero;
    p2.X:= dft_pnt[k].X;
    p2.Y:= dft_pnt[k].Y;
    p2.X:=p2.X+p1.X;
    p2.Y:=p2.Y+p1.Y;
    p1:=get_orig_axis(p1,pr);
    p2:=get_orig_axis(p2,pr);
    Layout1.Canvas.DrawLine(p1,p2,clr,s);
    p1:=p2;
    p1:=get_virt_axis(p1,pr);
    p2:=get_virt_axis(p2,pr);
  end;
  Result:=p2;

end;


procedure TForm1.calc_dft(q:single);
var
  I: Integer;
begin
  for I := 0 to length(dft_pnt)-1 do
  begin

    dft_pnt[i].Q:=dft_pnt[i].k* q +dft_pnt[i]._Q ;
    dft_pnt[i].X:=dft_pnt[i].M* Cos(dft_pnt[i].Q);
    dft_pnt[i].Y:=dft_pnt[i].M* Sin(dft_pnt[i].Q);
  end;
end;

procedure TForm1.CheckBox1Change(Sender: TObject);
begin
  Image1.Visible:=CheckBox1.IsChecked;
end;

procedure TForm1.Button1Click(Sender: TObject);
var n,k,i,ridx,idx:Integer;
    Q:Single;
begin
  n:=Length(pnt);
  if n=0  then exit;

  SetLength(dft_pnt,0);
  SetLength(_dft_pnt,0);
  SetLength(_shp_pnt,0);
  SetLength(dft_pnt,n);
  SetLength(_dft_pnt,n);
  for K := 0 to n-1 do
  begin
    for I := 0 to n-1 do
    begin
      Q:=-2*pi*k*i/n;
      dft_pnt[k].X:=dft_pnt[k].X+(pnt[i].X*Cos(Q)+pnt[i].Y*sin(Q));
      dft_pnt[k].Y:=dft_pnt[k].Y+(pnt[i].Y*cos(Q)-pnt[i].X*sin(Q));
    end;
    dft_pnt[k].X:=dft_pnt[k].X/n;
    dft_pnt[k].Y:=dft_pnt[k].Y/n;
    dft_pnt[k].Q:=ArcTan2(dft_pnt[k].Y,dft_pnt[k].X);
    dft_pnt[k]._Q:=ArcTan2(dft_pnt[k].Y,dft_pnt[k].X);
    dft_pnt[k].M:=Sqrt(power(dft_pnt[k].X,2)+Power(dft_pnt[k].Y,2));
    dft_pnt[k].k:=k;

  end;
  //---------------------------------

  qq:=0;
  Timer1.Enabled:=true;
  Layout1.Repaint;


  k:=0;
  idx:=0;ridx:=0;
  SetLength(_dft_pnt,0);
  SetLength(_dft_pnt,length(_dft_pnt)+1);

  ridx:=0;

  _dft_pnt[k]:=dft_pnt[ridx];
  delete(dft_pnt,ridx,1);

  _dft_pnt[k].k:=k;
  inc(k);
  inc(idx);
  while length(dft_pnt)>0 do
  begin
    SetLength(_dft_pnt,length(_dft_pnt)+1);

    ridx:=0;

    _dft_pnt[idx]:=dft_pnt[ridx];
    delete(dft_pnt,ridx,1);

    _dft_pnt[idx].k:=k;
    inc(idx);

    if length(dft_pnt)>0 then
    begin
      SetLength(_dft_pnt,length(_dft_pnt)+1);

      ridx:=length(dft_pnt)-1;
      _dft_pnt[idx]:=dft_pnt[ridx];
      delete(dft_pnt,ridx,1);

      _dft_pnt[idx].k:=-k;
    end;
    inc(idx);
    inc(k);
  end;
  SetLength(dft_pnt,n);
  for K := 0 to n-1 do
  begin
    dft_pnt[k]:=_dft_pnt[k];

  end;

end;
procedure TForm1.Button2Click(Sender: TObject);
begin
  SetLength(pnt,0);
  SetLength(dft_pnt,0);
  SetLength(_dft_pnt,0);
  SetLength(_shp_pnt,0);
  cler:=True;
  Timer1.Enabled:=false;
  qq:=0;
  Layout1.Repaint;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    Image1.MultiResBitmap.Clear;
    Image1.MultiResBitmap.Add.Bitmap.LoadFromFile(OpenDialog1.FileName);
    Image1.WrapMode:=TImageWrapMode.Center;
  end;

end;

procedure TForm1.Layout1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var pt:TPointF;ft:TFloatFormat;
begin
  ft:=ffGeneral ;
  pt:=get_virt_axis(TPointF.Create(X,Y),pr);
  ms:=pt;
  Text1.Text:=' X = '+FloatToStrF( pt.X,ft,5,4)+' , Y = '+FloatToStrF( pt.Y,ft,5,4)+ ' , Q = '+FloatToStrF( qq,ft,5,4);
end;
procedure TForm1.Layout1MouseUp(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Single);
var pt:TPointF;
begin
  pt:=get_virt_axis(TPointF.Create(X,Y),pr);
  SetLength(pnt,length(pnt)+1);
  pnt[length(pnt)-1].X:=pt.X;
  pnt[length(pnt)-1].Y:=pt.Y;
  Layout1.Repaint;

end;


procedure TForm1.Layout1Painting(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
var pt1,pt2,pt:TPointF;
    i,k:integer;
    p1,p2:TPointF;
    rct:TRectF;
    sav:TCanvasSaveState;
    s:TStrokeBrush;
    b:TBrush;
    a:Integer;
    z:Integer;

begin

    sav:=Canvas.SaveState;

    s:=TStrokeBrush.Create(TBrushKind.Solid,TAlphaColors.White);
    b:=TBrush.Create(TBrushKind.Solid,TAlphaColors.Black);
    Canvas.FillRect(ARect,0,0,[],1,s);
    s.Color:=TAlphaColors.Gray;
    s.Thickness:=1;

    a:=trunc(ARect.Width) div 2;
    z:=50;
    while (a<arect.Width) do
    begin
      if a< arect.Width then Canvas.DrawLine(PointF(a,0),PointF(a,ARect.Height),1,s);
      a:=a+z;
    end;
    a:=trunc(ARect.Width) div 2;
    while ( a>arect.Left  ) do
    begin
      if a> arect.Left then Canvas.DrawLine(PointF(a,0),PointF(a,ARect.Height),1,s);
      a:=a-z;
    end;
    a:=trunc(ARect.Height) div 2;
    while (a<arect.Height)  do
    begin
      if a< arect.Height  then Canvas.DrawLine(PointF(0,a),PointF(ARect.Width,a),1,s);
      a:=a+z;
    end;
    a:=trunc(ARect.Height) div 2;
    while (a>arect.top)  do
    begin
      if a> arect.top  then Canvas.DrawLine(PointF(0,a),PointF(ARect.Width,a),1,s);
      a:=a-z;
    end;
    s.Free;
    b.Free;

    for I := 0 to length(pnt)-1 do
    begin
      draw_point(pnt[i],pt_clr);
    end;
    if length(dft_pnt)>0 then
    begin
      //--------------------------------------
      draw_cir_rel1( TAlphaColors.Blue, qq);
      p1:=draw_lin_rel1(TAlphaColors.Blue,qq);
      //--------------------------------------
      SetLength(_shp_pnt,length(_shp_pnt)+1);
      _shp_pnt[length(_shp_pnt)-1]:=p1;
      if length(_shp_pnt)>0 then
      begin
        for I := 0 to length(_shp_pnt)-1 do
        begin
          draw_point(_shp_pnt[i],pt_dft_clr);
        end;
      end;
    end;
    draw_center(TAlphaColors.Black);

    Canvas.RestoreState(sav);

end;


procedure TForm1.Timer1Timer(Sender: TObject);
var i:Integer;
begin
  qq:=qq+0.1;
  //calc_dft(qq);
  if qq>2*pi then
  begin
    //qq:=0;
    //Timer1.Enabled:=false;
  end;
  Text1.Text:=' X = '+FloatToStrF( ms.X,TFloatFormat.ffGeneral,5,4)+' , Y = '+FloatToStrF( ms.Y,TFloatFormat.ffGeneral,5,4)+ ' , Q = '+FloatToStrF( qq,TFloatFormat.ffGeneral,5,4);
  Layout1.Repaint;
end;


procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  Timer1.Interval:=trunc(TrackBar1.Value);
end;

end.
