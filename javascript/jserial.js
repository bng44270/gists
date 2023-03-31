/*

    Define/Run serialized functions in JavaScript

    Define serialized function:

        var serialF = SerDef(function(a,b) {
            return {
                sum : a + b,
                avg : (a + b)/2
            };
        });

    Contents of this Serialized function:

        {
            args : ["a","b"],
            code : "return {sum : a + b,avg : (a + b)/2};"
        }

    Running serialized function:

        var serialResult = SerRun(serialF)(10,20);

    Function output:

        { sum : 30, avg : 15 }

*/

var SerDef = function(target) {
    if (typeof target != 'function') throw new TypeError;

    return {
        args : target.toString().replace(/[ \t]*\n[ \t]*/g,'').replace(/^function\(([^)]+)\).*$/,'$1').split(','),
        code : target.toString().replace(/[ \t]*\n[ \t]*/g,'').replace(/^function[ \t]*\([^)]+\)[ \t]*{[ \t]*(.*)[ \t]*}[ \t]*$/,'$1').trim()
    };
};

var SerRun = function(source) {
    if (Object.keys(source).indexOf('args') == -1 || Object.keys(source).indexOf('code') == -1) throw new SyntaxError;
    if (typeof source.args != 'object' || typeof source.code != 'string') throw new TypeError;
    
    eval('function newFunction(' + source.args.join(',') + ') { ' + source.code + '}');
    return newFunction;
};