/*
    Form Auto-Generator
    
    Replaced by ES6-compatible version (https://gist.github.com/bng44270/a18f3b2c9d2435467d38d6bd16d1255b)
    
    Provide an object-oriented framework for building and interacting wtih DOM forms
    
    Requires:  NewClass.js
    
    Initializing:
	
		var formObj = FormAuto.instance(<FORMDEF>);
		
	Form Definition Object (<FORMDEF> in above example):
	
		{
			id:'formhome',
			init : function() {
				
			},
			form : {
				title : 'Person Entry',
				fields : [
					{
						type : '<TYPE>',
						label : '<FIELD_LABEL>',
						name : '<FIELD_NAME>'
						options : [{
							value : "<OPTION_VALUE>",
							label : "<OPTION_LABEL>"
						},
						...
						],
						event : [
							{
								name : "<EVENT>",
								action : <FUNCTION>
							},
							...
						]
					},
					...
				]
            }
		}
		
	Field Descriptions:
		<TYPE> - field type
			"text" - single-line text field
			"mtext" - multi-line text field
			"number" - number field
			"checkbox" - checkbox field
			"button" - form button
			"dropdown" - select box
		<LABEL> - text to display with form field
		<NAME> - DOM name/id of form field
		<OPTION_VALUE> - value of select option (only used if <TYPE> = "dropdown")
		<OPTION_LABEL> - text display for select option (only used if <TYPE> = "dropdown")
		<EVENT> - DOM event (see https://developer.mozilla.org/en-US/docs/Web/Events#Standard_events)
		<FUNCTION> - function to run on <EVENT>
*/

var FormAuto = NewClass({
    public : {
        settings : {
            container : '',
            form : { }
        },
        createControl : function(field) {
            var controlContent = '';

            if (Object.keys(field).indexOf('type') > -1 &&
                    Object.keys(field).indexOf('label') > -1 &&
                    Object.keys(field).indexOf('name') > -1) {
                if (field.type == 'text') {
                    controlContent += '<tr id="' + field.name + '_container"><td>' + field.label + '</td><td style="width:25px;"></td><td><input type="text" id="' + field.name + '" /></td></tr>';
                }
                else if (field.type == 'mtext') {
                    controlContent += '<tr id="' + field.name + '_container"><td style="vertical-align:top">' + field.label + '</td><td style="width:25px;"></td><td><textarea style="resize: both;overflow: auto;" id="' + field.name + '"></textarea></td></tr>';
                }
				else if (field.type == 'number') {
					controlContent += '<tr id="' + field.name + '_container"><td>' + field.label + '</td><td style="width:25px;"></td><td><input type="number" id="' + field.name + '" /></td></tr>';
				}
                else if (field.type == 'checkbox') {
                    controlContent += '<tr id="' + field.name + '_container"><td>' + field.label + '</td><td style="width:25px;"></td><td><input type="checkbox" id="' + field.name + '" /></td></tr>';
                }
                else if (field.type == 'button') {
                    controlContent += '<tr id="' + field.name + '_container"><td><input type="button" id="' + field.name + '" value="' + field.label + '"/></td><td></td><td></td></tr>';
                }
                else if (field.type == 'dropdown') {
                    controlContent += '<tr id="' + field.name + '_container"><td>' + field.label + '</td><td style="width:25px;"></td><td><select id="' + field.name + '">';
                    if (Object.keys(field).indexOf('options') > -1) {
                        if (typeof field.options == 'object') {
                            field.options.forEach(o => {
                                if (Object.keys(o).indexOf('value') > -1 &&
                                        Object.keys(o).indexOf('label') > -1) {
                                            controlContent += '<option value="' + o.value + '">' + o.label + '</option>';
                                }
                                else {
                                    throw new TypeError;
                                }
                            });
                        }
                        else {
                            throw new TypeError;
                        }
                    }
                    else {
                        throw new TypeError;
                    }
                    controlContent += '</select></td></tr>';
                }
                else {
                    throw new TypeError;
                }
            }
            else {
                throw new TypeError;
            }

            return controlContent;
        },
        drawForm : function() {
            var htmlContent = '';
            if (Object.keys(this.settings.form).indexOf('title') > -1) {
                htmlContent += '<h1>' + this.settings.form.title + '</h1>';
            }
            else {
                throw new TypeError;
            }

            if (Object.keys(this.settings.form).indexOf('columns') > -1) {
                htmlContent += '<table>';
                this.settings.form.columns.forEach(c => {
                    htmlContent += '<tr><td>';
                    if (Object.keys(c).indexOf('fields') > -1) {
                        htmlContent += '<table>';
                        c.fields.forEach(f => {
                            htmlContent += this.createControl(f);
                        });
                    
                        htmlContent =+ '</table>';
                    }
                    else {
                        throw new TypeError;
                    }
                    
                    htmlContent += '</td></tr>';
                });

                htmlContent += '</table>';
            }
            else if (Object.keys(this.settings.form).indexOf('fields') > -1) {
                htmlContent += '<table>';
                this.settings.form.fields.forEach(f => {
                    htmlContent += this.createControl(f);
                });

                htmlContent += '</table>';
            }
            else {
                throw new TypeError;
            }

            document.getElementById(this.settings.container).innerHTML = htmlContent;
        },
        addListeners : function() {
            if (Object.keys(this.settings.form).indexOf('columns') > -1) {
                this.settings.form.columns.forEach(c => {
                    if (Object.keys(c).indexOf('fields') > -1) {
                        c.fields.forEach(f => {
                            if (Object.keys(f).indexOf('event') > -1) {
                                fetch.event.forEach(e => {
                                    if (Object.keys(e).indexOf('name') > -1 &&
                                            Object.keys(e).indexOf('action')) {
                                        document.getElementById(f.name).addEventListener(e.name,e.action.bind(this),false);
                                    }
                                });
                            }
                        });
                    }
                });
            }
            else if (Object.keys(this.settings.form).indexOf('fields') > -1) {
                this.settings.form.fields.forEach(f => {
                    if (Object.keys(f).indexOf('event') > -1) {
                        f.event.forEach(e => {
                           if (Object.keys(e).indexOf('name') > -1 &&
                                 Object.keys(e).indexOf('action')) {
                                document.getElementById(f.name).addEventListener(e.name,e.action.bind(this),false);
                            }
                        });
                    }
                });
            }
        },
        getFieldJson : function() {
            var fieldData = {};

            if (Object.keys(this.settings.form).indexOf('columns') > -1) {
                this.settings.form.columns.forEach(c => {
                    if (Object.keys(c).indexOf('fields') > -1) {
                        c.fields.filter(t => {
                            return (t.type != 'button');
                        }).forEach(f => {
                            var fieldName = f.name;
                            var fieldValue = document.getElementById(f.name).value;      
                            
                            fieldData[fieldName] = fieldValue;
                        });
                    }
                    else {
                        throw new TypeError;
                    }
                });
            }
            else if (Object.keys(this.settings.form).indexOf('fields') > -1) {
                this.settings.form.fields.filter(t => {
                    return (t.type != 'button');
                }).forEach(f => {
                    var fieldName = f.name;
                    var fieldValue = document.getElementById(f.name).value;
                    
                    fieldData[fieldName] = fieldValue;
                });
            }
            else {
                throw new TypeError;
            }

            return fieldData;
        },
        setField : function(name,value) {
            document.getElementById(name).value = value;
        },
        getField : function(name) {
            return document.getElementById(name).value;
        }
    },
    constructor : function(args) {
        this.settings.container = args.id;
        this.settings.form = args.form;
        this.drawForm();
        this.addListeners();
        if (Object.keys(args).indexOf('init') > -1)
            if (typeof args.init == 'function')
                args.init();
    }
});