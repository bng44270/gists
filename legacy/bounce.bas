' Relic from my past that I rewrote for memory :)

SCREEN 7

maxx = 320
maxy = 200

xmod = -1
ymod = -1
rmod = -1
cmod = -1

r = 9
x = 0
y = 0
c = 0

DO
  IF c < 1 OR c > 15 THEN
    cmod = cmod * -1
  END IF
  IF r < 10 OR r > 20 THEN
    rmod = rmod * -1
  END IF
  IF x < 1 OR x > maxx THEN
    xmod = xmod * -1
  END IF
  IF y < 1 OR y > maxy THEN
    ymod = ymod * -1
  END IF
  
  x = x + xmod
  y = y + ymod
  r = r + rmod
  c = c + cmod
   
  CIRCLE (x, y), r, c
  PAINT (x, y), c
LOOP UNTIL INKEY$ = CHR$(27)