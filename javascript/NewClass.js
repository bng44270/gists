/*

NewClass Usage

    This was originally an attempt on my part to provide some OOP functionality on platforms that only support ES5.

    Create New Empty Class

        var class1 = NewClass();

    Create New Class w/ elements

        var class1 = NewClass({
            public : {
                method1 : function() {
                    return this.prop1;
                },
                method2 : function() {
                    return this.private()._getprop2();
                },
                prop1 : 100
            },
            private : {
                prop2 : 200,
                _getprop2 : function() {
                    return this.prop2;
                }
            },
            constructor : function() {
                this.prop1 = 300;
            }
        });

    Add/Replace Public Method/Property to existing class

        class1.publicProperty('sum',0);
        class1.publicMethod('add',function(a,b) {
            this.sum = a + b;
            return this.sum;
        });

    Add/Replace Private Method/Property to an existing class

        class1.privateProperty('diff',0);
        class1.privateProperty('_subtr',function(a,b) {
            this.diff = a - b;
            return this.diff;
        });

    Add/Replace Constructor of an existing class

        class1.constructor(function() {
            this.name = 'andy';
        });

    Instantiating an object from a class (with no constructor arguments)

        var object1 = class1.instance();

    Instantiating an object from a class (with constructor arguments)

        class1.constructor(function(args) {
            this.name = args.name;
            this.age = args.age;
        });

        var object1 = class1.instance({
            name : 'andy',
            age : 38
        });

    Creating a copy of an existing class (extending without modifying)

        var class2 = class1.extend();

    Extending a class (retain inherited constructor)

        var class2 = class1.extend({
            public : {
                getName : function() {
                    return this.private()._getname();
                }
            },
            private : {
                _getname : function() {
                    return this.name
                },
                name : 'andy'
            }
        });
		
	Extending a class (with new constructor calling super class constructor)
	
		var class3 = class1.extend({
			public : {
				address : ''
			},
			constructor : function(args) {
				this.super(args);
				this.address = args.address;
			}
		});
		
		var ob3 = class3.instance({
            		name : 'andy',
            		age : 38,
			address '123 Main Street'
        	});
    

*/

var NewClass = function(newObject) {
    var baseObject = function() { };

    var privateObject = function() { };

    if (newObject) {
        if (Object.keys(newObject).indexOf('constructor') > -1)
            baseObject = newObject.constructor;
        
	    baseObject.prototype = (Object.keys(newObject).indexOf('public') > -1) ? newObject.public : { };
        privateObject.prototype = (Object.keys(newObject).indexOf('private') > -1) ? newObject.private : { };
    }

    baseObject.prototype.constructor = baseObject;

	var returnObject = {
		instance : function(jsonArgs) {
			var priv = new privateObject();
			
			baseObject.prototype.private = function() {
				return priv;
			};
			
			return (jsonArgs) ? new baseObject(jsonArgs) : new baseObject();
        },
        publicMethod : function(methodName,newMethod) {
            if (typeof methodName != 'string' || typeof newMethod != 'function') throw new TypeError;
            if (methodName && newMethod) {
                baseObject.prototype[methodName] = newMethod;
            }
        },
        publicProperty : function(propName,propVal) {
            if (typeof propName != 'string') throw new TypeError;
            if (propName && propVal) {
                baseObject.prototype[propName] = propVal;
            }
        },
        privateMethod : function(methodName,newMethod) {
            if (typeof methodName != 'string' || typeof newMethod != 'function') throw new TypeError;
            if (methodName && newMethod) {
                privateCode[methodName] = newMethod;
            }
        },
        privateProperty : function(propName,propVal) {
            if (typeof propName != 'string') throw new TypeError;
            if (propName && propVal) {
                privateCode[propName] = propVal;
            }
        },
        constructor : function(newConstr) {
            if (typeof newConstr != 'function') throw new TypeError;
            if (newConstr) {
                var newob = newConstr;
                newob.prototype = baseObject.prototype;
                newob.prototype.constructor = newob;
                baseObject.prototype.private = getPrivate;
                baseObject = newob;
            }

            return baseObject.prototype.constructor;
        },
        object : function() {
            return {
                public : baseObject.prototype,
                private : privateCode,
                constructor : baseObject.prototype.constructor
            };
        },
		extend : function(extObject) {
            var extPublic = { };
            var extPrivate = { };
            var extConstr = function() { };

			//Add existing object public elements to public object
			for (var prop in baseObject.prototype) {
				extPublic[prop] = baseObject.prototype[prop];
			}

			//Add existing object private elements to private object
			for (var prop in privateObject.prototype) {
				extPrivate[prop] = privateObject.prototype[prop];
			}
			
            //If extended object is provided
            if (extObject) {
                
                //If public elements are provided
                if (Object.keys(extObject).indexOf('public') > -1) {
                    
                    if (typeof extObject.public != 'object') throw new TypeError;
                    
                    //Add public extended elemenets
                    for (var prop in extObject.public) {
                        extPublic[prop] = extObject.public[prop];
                    }
		    		
		    extPublic['super'] = baseObject.prototype.constructor;
                }
            
                //If private elements are provided
                if (Object.keys(extObject).indexOf('private') > -1) {
                    
                    if (typeof extObject.private != 'object') throw new TypeError;

                    //Add private extended elements
                    for (var prop in extObject.private) {
                        extPrivate[prop] = extObject.private[prop];
                    }
                }

                //If constructor is provided
                if (Object.keys(extObject).indexOf('constructor') > -1)

                    if (typeof extObject.constructor != 'function') throw new TypeError;

                    //Use new constructor
                    extConstr = extObject.constructor;
            }
            
            //Return object contains public and private objects and constructor
            return NewClass({
                public: extPublic, 
                private : extPrivate,
                constructor : extConstr
            });
        }
    };

    return returnObject;
};