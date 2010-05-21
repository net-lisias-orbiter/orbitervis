{
 Copyright (C) 2003-2007 by Artyom Litvinovich
 AlgorLib: Curve interpolation
}
unit curv;
interface
uses asys,maths;

function l(x:double;xd,yd:adouble):double;
implementation

function f(x:double):double;
begin
 result:=sqr(x-0.5)*sqr(x-0.7);
end;

function n(x:double;xd,yd:adouble):double;
var i,j,k:integer;
n:double;
a:adouble;
begin
 k:=length(xd)-1;
 result:=0;
 setlength(a,k+1);
 a[0]:=yd[0];
 a[1]:=(yd[1]-a[0])/(xd[1]-xd[0]);
 a[2]:=(((yd[2]-yd[1])/(xd[2]-xd[1]))-a[1])/(xd[2]-xd[0]);
 for j:=0 to k do begin
  n:=1; for i:=0 to j-1 do n:=n*(x-xd[i]);
  result:=result+a[j]*n;
 end;
end;

function l(x:double;xd,yd:adouble):double;
var i,j,k:integer;
n:double;
begin
 k:=length(xd)-1;
 result:=0;
 for j:=0 to k do begin
  n:=1; for i:=0 to k do if j<>i then n:=n*((x-xd[i])/(xd[j]-xd[i]));
  result:=result+yd[j]*n;
 end;
end;

begin
end.
