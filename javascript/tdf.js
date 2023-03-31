/*
    Tiny Dataset Framework
    
    Replaced by ES6 version (https://gist.github.com/bng44270/61fe2af9313ae750c53c639a178f5e2e)
    
    Provide ablility to define and edit JSON objects
    
    Requires:  NewClass.js
    
    Two Options:
    
        A) Create single use interface (schema editor or data editor)
        
            1) Create a schema editor interface
            
                a) Initialize the interface.  
                
                    var mytdf = TDF.initialize({
                        id: "<DIV-ID>", 
                        allowSchemaUpdate : true, 
                        data : { 
                            fields : [
                                'name',
                                'age'
                            ]
                        }
                    });
                    
                    <DIV-ID> - the DOM ID of the <div> to place the editor.
                    Fields for this JSON schema are 'name' and 'age'
                
                b) Define function to run on commit (optional)
                
                    mytdf.commitSchema = function(data) {
                        //    The Code in this block will run
                        //    when the "Commit" button is clicked.
                        //    
                        //    This could include posting JSON to server.
                        //    
                        //    data argument has the same object layout
                        //    as the data property in the constructor.
                        
                    };
                    
            2) Create a data editor interface
            
                a) Initiailize the interface
                
                    var mytdf = TDF.initialize({
                        id: "<DIV-ID>", 
                        allowDataUpdate : true, 
                        data : { 
                            fields : [
                                'name',
                                'age'
                            ],
                            rows : [
                                {
                                    name : 'Jim',
                                    age : '20'
                                },
                                {
                                    name : 'Bob',
                                    age : '32'
                                }                                
                            ]
                        }
                    });
                    
                    <DIV-ID> - the DOM ID of the <div> to place the editor.
                    <FIELD-X> - fields that make up JSON schema
                
                b) Define function to run on commit (optional)
                
                    mytdf.commitData = function(data) {
                        //    The Code in this block will run
                        //    when the "Commit" button is clicked.
                        //    
                        //    This could include posting JSON to server.
                        //    
                        //    data argument has the same object layout
                        //    as the data property in the constructor.
                        
                    };
            
        B) Create multi-use interface using TDFStudio (edit schema and data)
        
            1) Initialize the interface
            
                var mytdf = TDFStudio.instance({
                    id:'datatarget',
                    data : {
                        fields : [
                            'name',
                            'age'
                        ], 
                        rows : [
                            {
                                name : 'Jim',
                                age : '20'
                            },
                            {
                                name : 'Bob',
                                age : '32'
                            }                                
                        ]
                    }
                });
                
            2) Define function to run on commit (optional)
            
                mytdf.commit = function(data) {
                    //    The Code in this block will run
                    //    when the "Commit" button is clicked.
                    //    
                    //    This could include posting JSON to server.
                    //    
                    //    data argument has the same object layout
                    //    as the data property in the constructor.
                };
                        
            
*/
var TDF = NewClass({
    public : {
        propertyCounter : 3,
        objectCounter : 1200,
        readOnlySchema : true,
        readOnlyData : true,
        initArgs : null,
        loadInterface : function(args) {
            /*
            args.id = HTML container ID
            args.data = data source definition in JSON format
            
            Data Source Definition
            {
                fields : ["field1","field2"],
                rows : [
                    {
                        field1 : 'one',
                        field2 : 'two'
                    }
                ]
            }
            
            reloading = true of calling init to reload data
            */
            
            if (args.allowDataUpdate && args.allowSchemaUpdate) throw new SyntaxError;
            
            this.initArgs = args;
            
            //Add Form Data
            var addPropertyBtn = document.createElement('input');
            addPropertyBtn.type = 'button';
            addPropertyBtn.value = 'Add Property';
            addPropertyBtn.id = 'addproperty';
            addPropertyBtn.tabIndex = '1';
            addPropertyBtn.addEventListener('click',this.newPropertyEvent.bind(this),false);
            
            var objectDefinition = document.createElement('div');
            objectDefinition.id = 'objectdef';
            
            var addObjectBtn = document.createElement('input');
            addObjectBtn.type = 'button';
            addObjectBtn.value = 'Add Row';
            addObjectBtn.id = 'addobject';
            addObjectBtn.tabIndex = '401';
            addObjectBtn.addEventListener('click',this.newObjectEvent.bind(this),false);
            
            var rowDisplay = document.createElement('div');
            rowDisplay.id = 'rowdisplay';
            
            document.getElementById(args.id).appendChild(addPropertyBtn);
            document.getElementById(args.id).appendChild(objectDefinition);
            
            if (args.allowSchemaUpdate) {
                this.readOnlySchema = false;
                
                var commitSchemaBtn = document.createElement('input');
                commitSchemaBtn.type = 'button';
                commitSchemaBtn.value = 'Done';
                commitSchemaBtn.id = 'commitschema';
                commitSchemaBtn.tabIndex = '400';
                commitSchemaBtn.addEventListener('click',this.commitSchemaEvent.bind(this),false);
                
                document.getElementById(args.id).appendChild(commitSchemaBtn);
            }
            
            
            document.getElementById(args.id).appendChild(addObjectBtn);
            document.getElementById(args.id).appendChild(rowDisplay);
            
            if (args.allowDataUpdate) {
                this.readOnlyData = false;
                
                var commitBtn = document.createElement('input');
                commitBtn.type = 'button';
                commitBtn.value = 'Done';
                commitBtn.id = 'commitdata';
                commitBtn.tabIndex = '402';
                commitBtn.addEventListener('click',this.commitDataEvent.bind(this),false);
                
                document.getElementById(args.id).appendChild(commitBtn);
            }
            
            if (args.data) {
                var changeAr = [];
                
                if (args.data.fields) {
                    if (typeof args.data.fields != 'object') throw new TypeError;
                    
                    changeAr.push('schema');
                    
                    //Add Field Entry
                    for(var i = 0; i < args.data.fields.length; i++) {
                        this.addProperty(args.data.fields[i],true);                
                    }
                }
                
                if (args.data.rows) {
                    if (typeof args.data.rows != 'object') throw new TypeError;
                    
                    changeAr.push('data');
                    
                    //Load Data
                    for (var i = 0; i < args.data.rows.length; i++) {
                        //Validate Data against Schema
                        for (var j in args.data.rows[i]) {
                            if (args.data.fields.indexOf(j) == -1) throw new TypeError;
                        }
                    
                        //Render Data
                        this.addObject(JSON.stringify(args.data.rows[i]));
                    }
                                
                    document.getElementById('addproperty').style.display = 'none';
                }
                else {
                    document.getElementById('addobject').style.display = 'none';
                }
                
                if (changeAr)
                    console.log("Loading " + changeAr.filter(function(thisChange) {
                        return (thisChange.length > 0) ? true : false;
                    }).join(' and '));
            }
            
        },
        newObjectEvent : function() {
            var newOb = {};
            var newProps = document.getElementsByClassName('obprop');
            
            for (var i = 0; i < newProps.length; i++) {
                newOb[newProps[i].id.replace(/_txt$/,'')] = newProps[i].value;
            }
            
            if (Object.keys(newOb).filter(function(thisProp) {
                return (newOb[thisProp].length == 0) ? true : false;
            }).length == 0)
                this.addObject(JSON.stringify(newOb));
        },
        commitDataEvent : function() {
            var newData = {
                fields : this.getSchema(),
                rows : this.getData()
            };
            
            if (Object.keys(this).indexOf('commitData') > -1)
                this.commitData(newData);
        },
        commitSchemaEvent : function() {
            var newSchema = {
                fields : this.getSchema()
            };
            
            if (Object.keys(this).indexOf('commitSchema') > -1)
                this.commitSchema();
        },
        newPropertyEvent : function(newSchema) {
            this.addProperty();
        },
        addProperty : function(propName,auto) {
            var newPropEntry = document.createElement('input');
            newPropEntry.type = 'text';
            newPropEntry.value = (propName) ? propName : 'New Property Name';
            newPropEntry.id = 'newprop' + this.propertyCounter;        
            this.propertyCounter++;
            
            newPropEntry.onclick = function() {
                if (this.value == 'New Property Name')
                    this.value = '';
            };
            
            newPropEntry.onkeyup = function(event) {
                if (event.keyCode == 27) {
                    var entryField = document.getElementById(this.id);
                    var br = this.nextSibling;
                    entryField.parentNode.removeChild(br);
                    entryField.parentNode.removeChild(entryField);
                }
                else if (event.keyCode == 13) {
                    var propertyName = this.value;
                    
                    if (propertyName.match(/^[a-zA-Z0-9_-]+$/)) {
                        if (!document.getElementById('commitschema')) {
                            var newProp = document.createElement('input');
                            newProp.type = 'text';
                            newProp.className = 'obprop';
                            newProp.id = propertyName + '_txt';
                            newProp.tabIndex = this.id.replace(/^newprop/,'');
                        }
                        
                        var delProp = document.createElement('input');
                        delProp.type = 'button';
                        delProp.value = 'Delete';
                        delProp.id = propertyName + '_del';
                        delProp.tabIndex = (parseInt(this.id.replace(/^newprop/,''))+500).toString();
                        delProp.onclick = function() {
                            var thisProp = document.getElementById(this.id.replace(/_del$/,''));
                            thisProp.parentNode.removeChild(thisProp);
                        };
                        
                        var propLabel = document.createElement('p');
                        propLabel.id = propertyName;
                        propLabel.className = 'fieldlabel';
                        propLabel.innerText = propertyName + ': ';
                        
                        if (!document.getElementById('commitschema'))
                            propLabel.appendChild(newProp);
                
                        if (!auto || document.getElementById('commitschema'))
                            propLabel.appendChild(delProp);
                    
                        var brtag = this.nextSibling;
                        this.parentNode.removeChild(brtag);
                        this.parentNode.removeChild(this);
                        
                        document.getElementById('objectdef').appendChild(propLabel);
                    }
                }
                else {
                    if (this.value.match(/New Property Name/))
                        this.value = this.value.replace(/New Property Name/,'');
                }
            };
            
            document.getElementById('objectdef').appendChild(newPropEntry);
            document.getElementById('objectdef').appendChild(document.createElement('br'));
            newPropEntry.focus();
            
            if (auto)
                newPropEntry.onkeyup({keyCode:13});
        },
        addObject : function(jsonString) {
            var deleteButton = document.createElement('input');
            deleteButton.type = 'button';
            deleteButton.value = 'Delete';
            deleteButton.id = "row" + (this.objectCounter-1200).toString() + "_del";
            deleteButton.tabIndex = (this.objectCounter-400);
            
            deleteButton.onclick = function() {
                var row = document.getElementById(this.id.replace(/_del$/,""));
                row.parentNode.removeChild(row);
            };
            
            var editButton = document.createElement('input');
            editButton.type = 'button';
            editButton.value = 'Edit';
            editButton.id = "row" + (this.objectCounter-1200).toString() + "_edit";
            editButton.tabIndex = (this.objectCounter-401);
            
            editButton.onclick = function() {
                var thisRecord = JSON.parse(document.getElementById(this.id.replace(/_edit$/,"")).innerText);
                
                for (var key in thisRecord) {
                    document.getElementById(key + '_txt').value = thisRecord[key];
                }
                
                document.getElementById(this.id.replace(/_edit$/,"_del")).click();
            };
            
            var newRow = document.createElement('p');
            newRow.className = 'fieldrow';
            newRow.id = 'row' + (this.objectCounter-1200).toString();
            
            newRow.innerText = jsonString;
            
            newRow.appendChild(editButton);
            newRow.appendChild(deleteButton);
            
            document.getElementById('rowdisplay').appendChild(newRow);
            var properties = document.getElementsByClassName('obprop');
            for (var i = 0; i < properties.length; i++)
                document.getElementById(properties[i].id).value = '';
            
            this.objectCounter += 2;
        },
        getSchema : function() {
            var returnValue = [];
            var fields = document.getElementsByClassName('fieldlabel');
        
            for (var i = 0; i < fields.length; i++) {
                returnValue.push(fields[i].innerText.replace(/:.*$/,''));
            }
            
            return returnValue;
        },
        getData : function() {
            var returnValue = [];
            var rows = document.getElementsByClassName('fieldrow');
            
            for (var i = 0; i < rows.length; i++) {
                returnValue.push(JSON.parse(rows[i].innerText));
            }
            
            return returnValue;
        }
    },
    constructor : function(args) {
        this.loadInterface(args);
    }
});

var TDFStudio = NewClass({
    public : {
        initializeSpace : function() {
            document.getElementById(this.id).innerHTML = '';
        },
        loadSchemaEditor : function() {
            this.initializeSpace();

            this.schemaEditor = SDF.instance({
                id: this.id, 
                allowSchemaUpdate : true, 
                data : { 
                    fields : this.fields
                }
            });

            this.schemaEditor.commitSchema = this.commitSchema.bind(this);
        },
        loadDataEditor : function() {
            if (this.fields.length > 0) {
                this.initializeSpace();

                this.dataEditor = SDF.instance({
                    id : this.id, 
                    allowDataUpdate : true, 
                    data : {
                        fields : this.fields,
                        rows : this.rows
                    }
                });

                this.dataEditor.commitData = this.commitData.bind(this);
            }
        },
        commitData : function() {
            this.rows = this.dataEditor.getData();
            this.dataEditor = null;
            this.loadStudio();
        },
        commitSchema : function() {
            this.fields = this.schemaEditor.getSchema();
            this.schemaEditor = null;
            this.loadStudio();
        },
        loadStudio : function() {
            this.initializeSpace();

            var editSchemaButton = document.createElement('input');
            editSchemaButton.type = 'button';
            editSchemaButton.value = 'Edit Schema';
            editSchemaButton.addEventListener('click',this.loadSchemaEditor.bind(this),false);

            document.getElementById(this.id).appendChild(editSchemaButton);

            document.getElementById(this.id).appendChild(document.createElement('br'));

            var editDataButton = document.createElement('input');
            editDataButton.type = 'button';
            editDataButton.value = 'Edit Data';
            editDataButton.addEventListener('click',this.loadDataEditor.bind(this),false);

            document.getElementById(this.id).appendChild(editDataButton);

            document.getElementById(this.id).appendChild(document.createElement('br'));

            var commitButton = document.createElement('input');
            commitButton.type = 'button';
            commitButton.value = 'Commit';
            commitButton.addEventListener('click',this.commitEvent.bind(this),false);

            document.getElementById(this.id).appendChild(commitButton);
        },
        commitEvent : function() {
            var newData = {
                fields : this.fields,
                rows : this.rows
            };
            
            if (Object.keys(this).indexOf('commit') > -1)
                this.commit(newData);
        }
    },
    constructor : function(args) {
        this.id = args.id;
        this.schemaEditor = null;
        this.dataEditor = null;

        if (Object.keys(args).indexOf('data') > -1) {
            this.fields = (Object.keys(args.data).indexOf('fields') > -1) ? args.data.fields : [];
            this.rows = (Object.keys(args.data).indexOf('rows') > -1) ? args.data.rows : [];
        }
        else {
            this.schema = [];
            this.data = [];
        }
        this.loadStudio();
    }
});
