/*
    Form Auto-Generator (ES6)
    
    Provide an object-oriented framework for building and interacting wtih DOM forms
    
	Usage:
	
		FormAuto('<parent-container-id>',{<form-object>}, [<form-init-function>()])	
    
    HTML:
		
		<div id="myform"></div>
	
	JS:
	
		var formObj = new FormAuto('myform',{
			title : 'Person Entry',
			fields : [{
				type : '<TYPE>',
				label : '<FIELD_LABEL>',
				name : '<FIELD_NAME>'
				options : [{
					value : "<OPTION_VALUE>",
					label : "<OPTION_LABEL>"
				},
				...
				],
				event : [{
					name : "<EVENT>",
					action : <FUNCTION>
				},
				...
				]
			},
			...
			]
		},function(formObj) {
			//run this on form load and use formObj to access current form object
		});
		
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

class FormAuto {
	constructor(div,form,init) {
		this.settings = {
			container : div,
			form : form
		};
        
        this.drawForm();
        this.addListeners();
        if (init)
            if (typeof init == 'function')
                init(this);
    }
	createControl(field) {
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
	}
	
	drawForm() {
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
	}
	
	addListeners() {
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
	}
	
	getFieldJson() {
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
	}
	
	setField(name,value) {
		document.getElementById(name).value = value;
	}
	
	getField(name) {
		return document.getElementById(name).value;
	}
}