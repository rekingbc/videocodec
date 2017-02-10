% calculat the area of trapezoid
function area = trapezoid(x1,x2,y1,y2)
a = abs(x1-x2);
b = abs(y1+y2);
area = (a * b) / 2;
