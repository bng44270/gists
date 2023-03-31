/*
Recreation of the Python STRING.format() function

Example 1:
	var greetingTemplate = "Hello, {0}.  Good {1}";
	var greeting = greetingTemplate.format("Jimmy","Morning");
	//greeting = 'Hello, Jimmy.  Good Morning';
	
Example 2:
	var greetingTemplate = "Hello, {0}......Bye {0}";
	var greeting = greetingTemplate.format("Jimmy");
	//greeting = 'Hello, Jimmy......Bye Jimmy';
	
*/
String.prototype.format = function(...arg) {
    var str = this;
    arg.forEach((v,i) => {
        var re = new RegExp("\\\{" + i.toString() + "\\\}","g");
        str = str.replace(re,v);
    });
    return str;
};

/*
Base 2, 8, and 16 conversion functions
*/

Number.prototype.toBinary = function() {
    return this.toString(2);
};

Number.prototype.toOctal = function() {
	return this.toString(8);
};

Number.prototype.toHex = function() {
	return this.toString(16);
}

Date.prototype.getUnixTimestamp = function() {
    return parseInt((this - new Date('1970-01-01T00:00:00Z')) / 1000);
};

/*
Wrapper for manipulating string and number values (simiular in nature to Array.prototype.map)

Usage 1:
  "bob was here".wrap(function(myString) {
    return myString.replace(/^bob/,'jim');
  });
  
Output 1:  jim was here

Usage 2:
  var num = 10;
  num.wrap(function(thisNum) {
    var myAr = [];
	while (thisNum > -1) {
      myAr.push(thisNum);
      thisNum--;
    }
    return myAr;
  });

Output 2 : [10,9,8,7,6,5,4,3,2,1,0]

*/
String.prototype.wrap = function(op) {
	if (typeof op != 'function') throw 'InvalidWrapFunctionException';
	return op(this);
};

Number.prototype.wrap = function(op) {
	if (typeof op != 'function') throw 'InvalidWrapFunctionException';
	return op(this);
};

/*
Returns argument count of user-defined function

usage:

  function concat(s1, s2) {
    return s1 + ' ' + s2;
  }
  
  concat.argCount();
  
output:  2

*/
Function.prototype.argCount = function() {
    return this.toString().replace(/\n/g,'').replace(/^function[ \t]+[^(]+\(/,'').replace(/\).*$/,'').split(',').filter(function(thisArg) {
		return (thisArg.length > 0) ? true : false;
    }).length;
};

//Return sum of numbers in array
Array.prototype.sum = function() {
	var total = 0;
	
	this.forEach(function(thisItem) {
		if (typeof thisItem != 'number') throw 'NonNumericArrayElementException';
		total += thisItem;
	});
	
	return total;
};

//Return average of numbers in array
Array.prototype.avg = function() {
	return this.sum() / this.length;
};

//Round numbers in array to nearest whole number
Array.prototype.round = function() {
	return this.map(function(thisItem) {
		if (typeof thisItem != 'number') throw 'NonNumericArrayElementException';
		return (thisItem - parseInt(thisItem) >= 0.5) ? parseInt(thisItem + 1) : parseInt(thisItem);
	});
};

//Return smallest number in array
Array.prototype.min = function() {
    var min = this[0];
    
	this.slice(1).forEach(function(thisElement) {
        if (typeof thisElement != 'number') throw "NonNumericArrayElementException";
		if(thisElement < min) min = thisElement;
    });
	
    return min;
};

//Return largest number in array
Array.prototype.max = function() {
    var max = this[0];
	
    this.slice(1).forEach(function(thisElement) {
        if (typeof thisElement != 'number') throw "NonNumericArrayElementException";
        if (thisElement > max) max = thisElement;
    });
	
    return max;
};

/*
	Array.combineDictionaries combines an array 
	containing multiple two-entry dictionaries 
	(two entries are "key" and "value") 
	into a single dictionary
*/

Array.prototype.combineDictionaries = function() {
	var newDict = {};
	
	for (var i = 0; i < this.length; i++) {
		var tempdict = {}
		tempdict[this[i].key] = this[i].value;
		newDict = Object.assign(newDict,tempdict);
	}
		
	return newDict;
};

/*
ARRAY.matrixOp(expression)

expression = any valid Javascript mathematical expression

use the variable X to represent the martix value

Example:  ARRAY.matrixOp('X*2') => return a matrix with every value multipled by 2
*/
Array.prototype.matrixOp = function(operation) {
    return this.map(function(thisRow) {
		if (typeof thisRow != 'object') throw 'NonObjectTypeException';
		return thisRow.map(function(thisItem) {
			if (typeof thisItem != 'number') throw 'NonNumericArrayElementException';
			return eval(operation.replace(/X/,thisItem.toString()));
		});
    });
};

//Return number for 1-byte hex digit represented as two characters (0-F)
String.prototype.byteHexToInt = function() {
    var chars = ['0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'];
	
	if (this.length > 2 || chars.indexOf(this[0].toUpperCase()) == -1 || chars.indexOf(this[1].toUpperCase()) == -1) throw 'NonSingleByteHexStringException';
	
    return ((chars.indexOf(this[0].toUpperCase()) * 16) + chars.indexOf(this[1].toUpperCase()));
};

//Return character for 1-byte hex digit represented as two characters (0-F)
String.prototype.byteHexToText = function() {
	var chars = ['0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'];
	
	if (this.length > 2 || chars.indexOf(this[0].toUpperCase()) == -1 || chars.indexOf(this[1].toUpperCase()) == -1) throw 'NonSingleByteHexStringException';
	
	return String.fromCharCode(this.byteHexToInt());
};

//Returns 1-byte hex digit represented as two characters (0-F) for number
Number.prototype.byteToHex = function() {
	var chars = ['0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'];
	
	if (this > 255) throw 'NonSingleByteNumberException';
    
    var un = parseInt(this / 16);
    var ln = this % 16;
	
    return chars[un] + chars[ln];
};

//Returns HTML-encoded string using '&' syntax from a string
String.prototype.htmlEncode = function() {
    return this.split('').map(function(thisChar) {
        return "&" + thisChar.charCodeAt(0).byteToHex() + ";";
    }).join('');
};

//Returns URL-encoded string from a string
String.prototype.urlEncode = function() {
	return this.split('').map(function(thisChar) {
        return "%" + thisChar.charCodeAt(0).byteToHex();
    }).join('')
};

//Returns string from HTML-encoded string using '&' syntax
String.prototype.htmlDecode = function() {
	var newStr = '';
	
	for (i = 0; i < this.length; i++) {
		if (this[i] == '&' && this[i+3] == ';') {
			var hexStr = this[i+1] + this[i+2];
			newStr += hexStr.byteHexToText();
			i += 3;
		}
		else {
			newStr += this[i];
		}
	}

	return newStr;
};

//Returns string from URL-encoded string
String.prototype.urlDecode = function() {
	var newStr = '';

	for (i = 0; i < this.length; i++) {
		if (this[i] == '%' ) {
			var hexStr = this[i+1] + this[i+2];
			newStr += hexStr.byteHexToText();
			i += 2;
		}
		else {
			newStr += this[i];
		}
	}

	return newStr;
};