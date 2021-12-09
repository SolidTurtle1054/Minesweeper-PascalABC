program DialogTaskMinesweeper;

uses 
   GraphWPF, Timers;

const 
   w = 24;
   h = 3*w+12;

var 
   visible, Field: array[,] of byte;
   n, m, status: byte;
   toOpen, Bomb, nFlag, time: integer;
   LBdown, LBUp, RBdown, RBup, questionM: boolean;
   t: timer;
   (PreviewX, PreviewY) := (-2,-2);
 

procedure DrawXY(i, j: byte); 
const
   fieldSt: array of char = (' ','1','2','3','4','5','6','7','8',#8277, #9873,'?');
   ColorN: array of Color = (Colors.Black, Colors.Blue, Colors.Green, Colors.Red, Colors.DarkBlue,
   Colors.Brown, Colors.DarkCyan, Colors.Black, Colors.DarkGray, Colors.Black, Colors.MediumVioletRed);

begin
   var 
      nonvisible := Procedure(a,b: byte) → 
   begin 
      var (x, y) := (b*w+12, a*w+h);
      FillRectangle(x,y,w-1, 2, Colors.White);
      FillRectangle(x,y,2, w-1, Colors.White);
      FillRectangle(x+1,y+w-2,w-1, 2, Colors.Gray);
      FillRectangle(x+w-2,y+1,2, w-1, Colors.Gray);
      FillRectangle(x+2,y+2,w-4, w-4, Colors.LightGray);
      SetPixel(x,y+w-1,Colors.DarkGray);
      SetPixel(x+1,y+w-2,Colors.DarkGray);
      SetPixel(x+w-2,y+1,Colors.DarkGray);
      SetPixel(x+w-1,y,Colors.DarkGray);
   end;
   var 
      (ii, jj) := (j*w+12, i*w+h);
    
   case visible[i,j] of
      0: nonvisible(i,j); 
      1: begin 
           nonvisible(i,j);
           DrawText(ii, jj, w, w, fieldSt[10], ColorN[10])
         end;
      2: begin 
            nonvisible(i,j);  
            DrawText(ii, jj, w, w, fieldSt[11], Colors.Black) 
         end;
      7: begin 
            FillRectangle(ii,jj,w, w, Colors.Gray);
            FillRectangle(ii+1,jj+1,w-1, w-1, Colors.LightGray);
            DrawText(ii+1, jj+2, w, w, fieldSt[9], Colors.Black);
            Pen.Width := 3;
            line(ii+7,jj+2, ii+w-2,jj+w-2, Colors.MediumVioletRed);
            line(ii+3,jj+w-2, ii+w-2,jj+5, Colors.MediumVioletRed);
         end;
      9: begin
            FillRectangle(ii,jj,w, w, Colors.Gray);
            FillRectangle(ii+1,jj+1,w-1, w-1, Colors.LightGray);
            if field[i,j] <> 9 then begin
               DrawText(ii+1, jj+2, w, w, fieldSt[field[i,j]], ColorN[field[i,j]]);
               dec(toOpen);
            end
            else begin
               if Status < 2 then 
                  FillRectangle(ii+1,jj+1,w-1, w-1, Colors.HotPink);
               DrawText(ii + 1, jj+3, w, w, fieldSt[field[i,j]], ColorN[field[i,j]]);
            end;
         end;       
     10: begin 
            FillRectangle(ii,jj,w, w, Colors.Gray);
            FillRectangle(ii+1,jj+1,w-1, w-1, Colors.LightGray);
         end;      
     12: begin 
            FillRectangle(ii,jj,w, w, Colors.Gray);
            FillRectangle(ii+1,jj+1,w-1, w-1, Colors.LightGray);
            DrawText(ii, jj, w, w, fieldSt[11], Colors.Black);
         end;    
   end;
end;

procedure DrawQuestionMark; 
begin 
   Pen.Color := questionM ? Colors.DarkCyan : Colors.Red;
   Pen.Width := 2;
   Circle(12 + m div 2 * w + w div 2 , h - w - 3, w div 2, Colors.White);
   Font.Size := w + w div 4;
   DrawText(12 + m div 2 * w, h - 3*w div 2-2 , w, w, '?', Colors.Black);      
   Font.Size := w;  
   if not questionM then 
      DrawSector(12 + m div 2 * w + w div 2, h - w - 3, w div 2, -45, 135);
end;

procedure Table(nFlagOrTtime:boolean); 
Const 
   DrawEdge: array of byte = (0,0,w div 2,0,w div 2,2,w div 2,3*w div 4,
   w div 2,3*w div 4,w div 2,3*w div 2-2,0,3*w div 2,w div 2,3*w div 2,
   0,3*w div 4,0,3*w div 2-2, 0,2,0,3*w div 4,2,3*w div 4, w div 2-2,3*w div 4);

   Edge: array of array of byte = (
   {0}(1, 1, 1, 1, 1, 1, 0), {1}(0, 1, 1, 0, 0, 0, 0), {2}(1, 1, 0, 1, 1, 0, 1), 
   {3}(1, 1, 1, 1, 0, 0, 1), {4}(0, 1, 1, 0, 0, 1, 1), {5}(1, 0, 1, 1, 0, 1, 1),
   {6}(1, 0, 1, 1, 1, 1, 1), {7}(1, 1, 1, 0, 0, 0, 0), {8}(1, 1, 1, 1, 1, 1, 1),
   {9}(1, 1, 1, 1, 0, 1, 1), {-}(0, 0, 0, 0, 0, 0, 1)); 

begin
   var 
      cc, y: integer;
   if nFlagOrTtime then 
      (cc, y) := (abs(nFlag), 23)
   else 
      (cc, y) := (Time, window.Width.Trunc - 13 - (w*2+w div 2));
   var c := Arr(cc div 100, cc div 10 mod 10, cc mod 10);
   if nFlagOrTtime and (nFlag<0) then 
      c[0] := 10;
   Pen.Width := w div 5;
   for var j := 0 to 2 do
      for var k := 0 to 6 do
         line(DrawEdge [k*4] + (w-5) * j + y, DrawEdge [k*4 + 1] + 26,
   DrawEdge [k*4 + 2] + (w-5) * j + y, DrawEdge [k*4 + 3] + 26, 
   Edge[c[j], k]=0 ? Colors.Black : Colors.Red);
end;

procedure OnTimer(); 
begin
   Table(false);
   time += 1;
end;

procedure GenField(n1, m1: byte);
begin
   SetLength(Field, n, m);
   var bombSSet := new SortedSet <word>;
   while bombSSet.Count <> bomb do begin 
     var IndexBomb := Random(0, n*m-1); 
     if IndexBomb <> (n1*m+m1) then
        bombSSet.Add(IndexBomb);
   end;  
   for var i := 0 to n-1 do
      for var j := 0 to m-1 do
      if bombSSet.Contains(i*m+j) then begin 
         Field[i,j] := 9; 
         bombSSet.Remove(i*m+j)
      end
      else 
         Field[i,j] := 0;

   for var i := 0 to n-1 do
      for var j := 0 to m-1 do     
         if Field[i, j] = 9 then 
            for var ii := (i-1).ClampBottom(0) to (i+1).ClampTop(n-1) do
               for var jj := (j-1).ClampBottom(0) to (j+1).ClampTop(m-1) do
                  if Field[ii, jj] <> 9 then 
                     Field[ii, jj] += 1;
   t.Start;
end;


Procedure Init(level: byte); 
begin
   case level of
      1: (n, m, Bomb) := ( 9, 9,10);
      2: (n, m, Bomb) := (16,16,40);
      3: (n, m, Bomb) := (16,30,99);
   end;
   status := 0;
   toOpen := n*m - Bomb;
   nFlag := Bomb;
   var LevelOld := false;
   if window.Width <> m * w + 25 then
      window.SetSize(m * w + 25, n * w + h + 11)
   else
      LevelOld := true;
   FillRectangle(3,3,m * w + 17, n * w + h + 5,Colors.LightGray);
   FillRectangle(9,h-3, 3, n*w+5,Colors.Gray); 
   FillRectangle(9,h-3, m*w+5, 3,Colors.Gray);
   FillRectangle(10,h + n * w, m * w+4, 3, Colors.White); 
   FillRectangle(12 + m * w, h-2, 3, n * w+5, Colors.White);
   SetPixel(10, h + n * w, Colors.Gray);
   SetPixel(10, h+1 + n * w, Colors.LightGray);
   SetPixel(11, h + n * w, Colors.LightGray);
   SetPixel(12 + m * w, h-2, Colors.Gray);
   SetPixel(12 + m * w, h-1, Colors.LightGray);
   SetPixel(13 + m * w, h-2, Colors.LightGray);
   FillRectangle(9,9, 3, h - 18,Colors.Gray); 
   FillRectangle(9,9, m*w+5, 3,Colors.Gray);
   FillRectangle(10,h-11 , m * w+5, 3, Colors.White); 
   FillRectangle(12 + m * w, 10, 3, h-19, Colors.White);
   SetPixel(10, h-11, Colors.Gray);
   SetPixel(10, h-10, Colors.LightGray);
   SetPixel(11, h-11, Colors.LightGray);
   SetPixel(12+m*w, 10, Colors.Gray);
   SetPixel(13+m*w, 10,  Colors.LightGray);
   SetPixel(12+m*w, 11,  Colors.LightGray);
   var button := Procedure(a,b: byte) → 
   begin
      var (x, y) := (b*w+12, a*w+15);
      FillRectangle(x,y,w-1, 2, Colors.White);
      FillRectangle(x,y,2, w-1, Colors.White);
      FillRectangle(x+1,y+w-2,w-1, 2, Colors.Gray);
      FillRectangle(x+w-2,y+1,2, w-1, Colors.Gray);
      FillRectangle(x+2,y+2,w-4, w-4, Colors.LightGray);
      SetPixel(x,y+w-1,Colors.DarkGray);
      SetPixel(x+1,y+w-2,Colors.DarkGray);
      SetPixel(x+w-2,y+1,Colors.DarkGray);
      SetPixel(x+w-1,y,Colors.DarkGray);
   end;
   if not LevelOld then
      for var f := 0 to 2 do begin 
         var ColorN := Arr(Colors.Blue, Colors.Green, Colors.Red);
         var yy := m div 2 - 1+ f;
         button(0, yy);
         DrawText(yy*w+12, 16, w, w, (f+1).ToString, ColorN[f]);      
      end; 
   DrawQuestionMark; 
   FillRectangle(16,18, 2, w*2+2, Colors.Gray);
   FillRectangle(16,18, w*2+w div 2+2, 2, Colors.Gray);
   FillRectangle(18,19+w*2+1, w*2+w div 2+2, 2, Colors.White);
   FillRectangle(18+w*2+w div 2, 20, 2, w*2, Colors.White);
   FillRectangle(18,20,w*2+w div 2, w*2, Colors.Black);
   Table(true);
   FillRectangle(Window.Width.Trunc - 18,20, 2, w*2+2, Colors.White);
   FillRectangle(Window.Width.Trunc - 18,18, -(w*2+w div 2+2), 2, Colors.Gray);
   FillRectangle(Window.Width.Trunc - 18,19+w*2+1, -(w*2+w div 2), 2, Colors.White);
   FillRectangle(Window.Width.Trunc - (18+w*2+w div 2), 20, -2, w*2, Colors.Gray);
   //DrawText(window.Width - 18, 20, -(w*2+w div 2), w*2, '0'.toString, Colors.PaleVioletRed);
   FillRectangle(window.Width.Trunc - 18, 20, -(w*2+w div 2), w*2, Colors.Black);
   t.Stop; time:=0; OnTimer;
   SetLength(visible,n,m);
   for var i := 0 to n-1 do
      for var j := 0 to m-1 do
         if LevelOld then  begin
            if visible[i,j] <> 0 then begin
               visible[i,j] := 0;
               DrawXY(i, j)
            end
         end
         else begin 
            visible[i,j] := 0;
            DrawXY(i, j)
         end;
   (LBdown, LBUp, RBdown, RBup):=(false,false,false,false);  
end;

procedure MouseMove(x,y: real; mb: integer);
begin
   if Status <= 1 then begin
      var PreviewClear := Procedure → 
      begin
         (PreviewX, PreviewY) := (-2, -2);
         for var u := 0 to n-1 do 
            for var v:= 0 to m-1 do
               if visible[u,v] > 9 then begin 
                  visible[u,v] -= 10; 
                  DrawXY(u,v) 
               end
      end;
      if ((x.Trunc in [12..11+m*w]) and (y.Trunc in [h..h+n*w-1])) then begin
         var (i,j) := (trunc(y - h) div w, trunc(x - 12) div w);
         if not((PreviewX = i) and (PreviewY = j)) then begin
            if (LBdown or (LBdown and RBdown)) and not (LBup and RBup) then begin
               (PreviewX, PreviewY) := (i, j);
               var d := RBdown ? 1 : 0;
               for var u := 0 to n-1 do 
                  for var v:= 0 to m-1 do
                     if (u in i-d..i+d) and (v in j-d..j+d) then begin 
                        if visible[u,v] in [0,2] then begin 
                           visible[u,v] += 10; 
                           DrawXY(u,v) 
                        end 
                     end
                     else if visible[u,v] > 9 then begin 
                        visible[u,v] -= 10; 
                        DrawXY(u,v); 
                     end
            end
            else begin 
               (PreviewX, PreviewY) := (-2, -2);
               PreviewClear; 
            end;
            
         end;
        
      end
      else 
         PreviewClear;
   end;
end;

procedure theEnd;
begin
   t.Stop;
   for var i := 0 to n-1 do
      for var j := 0 to m-1 do
         if (visible[i,j] =1) and (Status=2) then begin
            visible[i,j] := field[i,j]=9 ? 9 : 7; 
            DrawXY(i,j)
         end 
         else if (visible[i,j] in [0,2]) and (field[i,j] = 9) then begin
            visible[i,j] := status=2 ? 9 : 1; 
            DrawXY(i,j)
         end;
   if status = 3 then begin 
      nFlag := 0; 
      Table(true) 
   end;
end;
//FIX_ME
procedure mbField(i,j:byte);
begin
   if Status <= 1 then begin
      var mbClick:= ord(LBdown)*1000+ord(LBUp)*100+ord(RBdown)*10+ord(RBup);
      case mbClick of 
      0010: if visible[i,j] < 3 then begin     
               if visible[i,j] = 0 then begin
                  dec(nFlag);
                  Table(true)
               end 
               else if visible[i,j] = 1 then begin
                  inc(nFlag); 
                  Table(true)
               end;
               inc(visible[i,j]);
               if visible[i,j] > 1+ord(questionM) then 
                  visible[i,j]:=0;
               DrawXY(i,j);
            end;
      0100: begin
               if Status = 0 then begin 
                  GenField(i,j); 
                  Status := 1 
               end;
               if not(visible[i,j] in [1,9]) then begin
                  visible[i,j] := 9;
                  DrawXY(i,j);
                  var cEmpty: Procedure(ii,jj: byte);
                  cEmpty := (ii,jj) → 
                  for var u := (ii-1).ClampBottom(0) to (ii+1).ClampTop(n-1) do
                     for var v := (jj-1).ClampBottom(0) to (jj+1).ClampTop(m-1) do begin  
                        if not(visible[u,v] in [1,9]) then begin
                            visible[u,v] := 9;
                           DrawXY(u,v);
                           if field[u,v] = 0 then 
                              cEmpty(u,v);
                        end;
                        
                     end;
                  if field[i, j] = 0 then 
                     cEmpty(i,j);
                  
                  if field[i, j] = 9 then begin
                     Status := 2;
                     theEnd;
                  end
                  else if toOpen = 0 then begin
                     Status := 3;
                     theEnd;
                  end;
               end;
            end;
      1001, 0110: begin
                     (LBdown, LBup, RBdown, RBup) := (false, true, false, false);
                     (PreviewX, PreviewY) := (-2, -2); MouseMove(i*n,j*m,0);
                     var c := 0;
                     for var ii := (i-1).ClampBottom(0) to (i+1).ClampTop(n-1) do
                        for var jj := (j-1).ClampBottom(0) to (j+1).ClampTop(m-1) do
                           if visible[ii,jj] = 1 then 
                              inc(c);
                     if (visible[i,j] = 9) and (field[i,j] = c) then
                        for var u := (i-1).ClampBottom(0) to (i+1).ClampTop(n-1) do
                           for var v := (j-1).ClampBottom(0) to (j+1).ClampTop(m-1) do begin
                              if not(visible[u,v] = 9) then
                                 if visible[u,v] <> 1 then
                                    mbField(u,v);
                           end;
                     LBup := false;
                  end;
      end; 
   end;
end;

procedure MouseUp(x,y: real;mb:integer);
begin
   case mb of
      0: if LBdown then 
            (LBdown, LBup, RBup) := (false, true, false)
         else if RBdown then 
            (LBup, RBdown, RBup) := (false, false, true);
      1: (LBdown, RBdown, RBup) := (true, false, true);
      2: (LBdown, LBUp) := (false, true);
   end;
   if (mb > 0) or LBup then
      MouseMove(x,y,0);
   if (x.Trunc in [12..11+m*w]) and (y.Trunc in [h..h+n*w-1]) then 
      mbField(trunc(y - h) div w, trunc(x - 12) div w);
end;
//##FIX_ME
procedure MouseDown(x,y: real;mb:integer);
begin
   case mb of
      1: if LBdown and RBup then 
            (RBdown, RBup) := (true, false) 
         else if LBdown then 
            (LBup, RBdown, RBUp) := (false, true, false) 
         else if LBup then 
            (LBdown, LBup) := (true, false)
         else 
            (LBdown, RBup) := (true, false);   
      2: (LBup, RBdown, RBup) := (false, true, false);
   end; 
   if LBdown then begin 
      if (x.trunc in [(m+2) div 2 * w - (w div 2) .. (m+2) div 2 * w + (w div 2)]) and
      (y.trunc in [ h-27 - w div 2 .. h-27 + w div 2])  then begin 
         questionM := not questionM;
         DrawQuestionMark
      end;
      if not((x.trunc in [m div 2 * w - w div 2.. (m+6) div 2 * w - w div 2]) and
      (y.trunc in [16 .. w+14])) then begin
      end
      else
         Init((x.Trunc - (m div 2 * w - w div 2)) div w + 1);
   end;       
   if LBdown or (LBdown and RBdown) then 
      (PreviewX, PreviewY) := (-2,-2); MouseMove(x,y,0);
   if (x.Trunc in [12..11+m*w]) and (y.Trunc in [h..h+n*w-1]) then
      mbField(trunc(y - h) div w, trunc(x - 12) div w);
end;

begin
  t := new Timer(1000,OnTimer);
  Window.Title := 'Minesweeper';
  window.SetSize(9 * w + 25, 9 * w + h + 11);
  Window.CenterOnScreen; 
  Window.IsFixedSize := True; 
  Font.Name := 'Courier New';
  Font.Style := Bold; 
  Font.Size := w;
  Init(1);
  OnMouseDown += MouseDown;
  OnMouseUp += MouseUp;
  OnMouseMove += MouseMove;
end.