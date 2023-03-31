/*
Data type specific memory allocation

Types:
	uInt(unsigned int)
	sInt(signed int)
	uChar(unsigned char)
	sChar(signed char)
	uShort(unsigned short)
	sShort(signed short)
	uLong(unsigned long)
	sLong(signed long)
	
	Type struct template (T=type):  { T *val; int len; }
	
Functions:
	defineSignedInt(int len);
		returns sInt with <len> allocated to value
		
	extendSignedInt(sInt tempar, int addlen);
		return sInt copy of sInt with the value extended by <addlen>*datatype (in this case, int)
		
	freeSignedInt(sInt tempar);
		initialize value of tempar (free memory)
	...
	same functions for other types
*/

#ifndef _STDLIB_H
#include <stdlib.h>
#endif

#ifndef _DEFTYPE_H
#define _DEFTYPE_H

typedef struct { signed int *val; int len; } sInt;
typedef struct { unsigned int *val; int len; } uInt;
typedef struct { signed char *val; int len; } sChar;
typedef struct { unsigned char *val; int len; } uChar;
typedef struct { signed short *val; int len; } sShort;
typedef struct { unsigned short *val; int len; } uShort;
typedef struct { signed long *val; int len; } sLong;
typedef struct { unsigned long *val; int len; } uLong;


sInt defineSignedInt(int len) {
	sInt tempar;
	tempar.val = (signed int*)malloc(sizeof(int)*len);
	tempar.len = len;
	return tempar;
}

sInt extendSignedInt(sInt tempar, int addlen) {
	tempar.val = (signed int*)realloc(tempar.val,tempar.len+(sizeof(int)*addlen));
	tempar.len += sizeof(int) * addlen;
	return tempar;
}

sInt freeSignedInt(sInt tempar) {
	free(tempar.val);
	tempar.len = 0;
	return tempar;
}

uInt defineUnsignedInt(int len) {
	uInt tempar;
        tempar.val = (unsigned int*)malloc(sizeof(int)*len);
	tempar.len = len;
        return tempar;
}

uInt extendUnsignedInt(uInt tempar, int addlen) {
	tempar.val = (unsigned int*)realloc(tempar.val,tempar.len+(sizeof(int)*addlen));
	tempar.len += sizeof(int) * addlen;
	return tempar;
}

uInt freeUnsignedInt(uInt tempar) {
	free(tempar.val);
	tempar.len = 0;
	return tempar;
}

sChar defineSignedChar(int len) {
	sChar tempar;
	tempar.val = (signed char *)malloc(sizeof(char)*len);
	tempar.len = len;
	return tempar;
}

sChar extendSignedChar(sChar tempar, int addlen) {
	tempar.val = (signed char*)realloc(tempar.val,tempar.len+(sizeof(char)*addlen));
	tempar.len += sizeof(char) * addlen;
	return tempar;
}

sChar freeSignedChar(sChar tempar) {
	free(tempar.val);
	tempar.len = 0;
	return tempar;
}

uChar defineUnsignedChar(int len) {
        uChar tempar;
        tempar.val = (unsigned char *)malloc(sizeof(char)*len);
        tempar.len = len;
        return tempar;
}

uChar extendUnsignedChar(uChar tempar, int addlen) {
        tempar.val = (unsigned char*)realloc(tempar.val,tempar.len+(sizeof(char)*addlen));
        tempar.len += sizeof(char) * addlen;
        return tempar;
}

uChar freeUnsignedChar(uChar tempar) {
        free(tempar.val);
        tempar.len = 0;
        return tempar;
}

sShort defineSignedShort(int len) {
        sShort tempar;
        tempar.val = (signed short*)malloc(sizeof(char)*len);
        tempar.len = len;
        return tempar;
}

sShort extendSignedShort(sShort tempar, int addlen) {
        tempar.val = (signed short*)realloc(tempar.val,tempar.len+(sizeof(short)*addlen));
        tempar.len += sizeof(short) * addlen;
        return tempar;
}

sShort freeSignedShort(sShort tempar) {
        free(tempar.val);
        tempar.len = 0;
        return tempar;
}

uShort defineUnsignedShort(int len) {
        uShort tempar;
        tempar.val = (unsigned short*)malloc(sizeof(char)*len);
        tempar.len = len;
        return tempar;
}

uShort extendUnsignedShort(uShort tempar, int addlen) {
        tempar.val = (unsigned short*)realloc(tempar.val,tempar.len+(sizeof(short)*addlen));
        tempar.len += sizeof(short) * addlen;
        return tempar;
}

uShort freeUnsignedShort(uShort tempar) {
        free(tempar.val);
        tempar.len = 0;
        return tempar;
}

sLong defineSignedLong(int len) {
        sLong tempar;
        tempar.val = (signed long*)malloc(sizeof(char)*len);
        tempar.len = len;
        return tempar;
}

sLong extendSignedLong(sLong tempar, int addlen) {
        tempar.val = (signed long*)realloc(tempar.val,tempar.len+(sizeof(long)*addlen));
        tempar.len += sizeof(long) * addlen;
        return tempar;
}

sLong freeSignedLong(sLong tempar) {
        free(tempar.val);
        tempar.len = 0;
        return tempar;
}

uLong defineUnsignedLong(int len) {
        uLong tempar;
        tempar.val = (unsigned long*)malloc(sizeof(char)*len);
        tempar.len = len;
        return tempar;
}

uLong extendUnsignedLong(uLong tempar, int addlen) {
        tempar.val = (unsigned long*)realloc(tempar.val,tempar.len+(sizeof(long)*addlen));
        tempar.len += sizeof(long) * addlen;
        return tempar;
}

uLong freeUnsignedLong(uLong tempar) {
        free(tempar.val);
        tempar.len = 0;
        return tempar;
}

#endif