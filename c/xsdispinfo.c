/*

Show X Windows Display Information

Compiling Note:

  Requires X11 headers
  
  gcc <options> xdispinfo.c -lX11
  
Usage:

  List X Window Displays
  
    xdispinfo -l
  
  Show X Windows screen count and size(s)
  
    xdispinfo -d <display-name> -s -c
  
  Patterned after https://stackoverflow.com/questions/11367354/obtaining-list-of-all-xorg-displays
  
*/

#include <stdio.h>
#include <dirent.h>
#include <string.h>
#include <X11/Xlib.h>

int main(int argc, char *argv[]) {
  char count = 0;
  char scrsize = 0;
  char list = 0;
  char hasdisp = 0;
  char *disp;
  
  
  for (int i = 0; i < argc; i++) {
    if (argv[i][0] == '-' && argv[i][1] == 's') {
      scrsize = 1;
    }
    
    if (argv[i][0] == '-' && argv[i][1] == 'c') {
      count = 1;
    }
    
    if (argv[i][0] == '-' && argv[i][1] == 'd') {
      i++;
      disp = argv[i];
      hasdisp = (strlen(disp) == 0) ? 0 : 1;
    }
    
    if (argv[i][0] == '-' && argv[i][1] == 'l') {
      list = 1;
    }
  }
  
  if (list) {
    DIR* d = opendir("/tmp/.X11-unix");

    if (d != NULL) {
      struct dirent *dr;
      while ((dr = readdir(d)) != NULL) {
        if (dr->d_name[0] != 'X')
          continue;
 
        char display_name[64] = ":";
        strcat(display_name, dr->d_name + 1);
        
        printf("DisplayName\t%s\n",display_name);
      }
    }
  }
  else if (hasdisp) {  
    Display *xDisp = XOpenDisplay(disp);
    
    printf("Display\t%s\n",disp);
    
    int scrCount = XScreenCount(xDisp);
    
    if (count) {    
      printf("ScreenCount\t%d\n",scrCount);
    }
    
    if (scrsize) {
      for (int i = 0; i < scrCount; i++) {
        int xWid = XDisplayWidth(xDisp,i);
        int xHgt = XDisplayHeight(xDisp,i);
        
        printf("Screen%d\t%dx%d\n",i,xWid,xHgt);
      }
    }
    
    XCloseDisplay(xDisp);
    
    return 0;
  }
  else {
    printf("usage: xdisp <options>\n");
    printf("    -d <display-name>\n");
    printf("         must be format :<number>\n");
    printf("    -s\n");
    printf("         show screen size(s)\n");
    printf("    -c\n");
    printf("         show screen count\n");
    
    return 1;
  }
}