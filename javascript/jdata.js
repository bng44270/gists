/*

var recipeSchema = new JDataSchema();
recipeSchema.addField('title',{label:'Title'});
recipeSchema.addField('preptime',{label:'Preparation Time'});
recipeSchema.addField('instructions',{label:'Instructions',multiline:true,display:false})
recipeSchema.addField('ingredients',{label:'Ingredients',list:true,display:false});


var recipeData = new JDataSet(recipeSchema);

document.write('<div id="dataview"></div>');

var view = new JDataView('dataview',recipeData);

view.renderListView();

*/
class JDataSchema {
  constructor(schema) {
    this.schema = (schema) ? schema : [];
    this.addField('uid',{
      autonum : true,
      display : false,
      hidden : true
    });
  }
  
  get schema() {
    return this._s;
  }
  
  set schema(s) {
    if (this.validateSchema(s)) {
      this._s = s;
    }
  }
  
  addField(name,options={}) {
    if (name) {
      var ob = {};
      ob.name = name;
      ob.multiline = (Object.keys(options).indexOf('multiline') > -1) ? options.multiline : false;
      ob.display = (Object.keys(options).indexOf('display') > -1) ? options.display : true;
      ob.label = (Object.keys(options).indexOf('label') > -1) ? options.label : name;
      ob.list = (Object.keys(options).indexOf('list') > -1) ? options.list : false;     
      ob.autonum = (Object.keys(options).indexOf('autonum') > -1) ? options.autonum : false; 
      ob.hidden = (Object.keys(options).indexOf('hidden') > -1) ? options.hidden : false;
      this.schema.push(ob);
    }
  }
  
  removeField(name) {
    this.schema = this.schema.filter(f => f.name != name);
  }
  
  getTemplate(autos) {
    var tpl = {};

    this.schema.forEach(f => {
      if (f.list) {
        tpl[f.name] = [];
      }
      else {
        if (autos) {
          if (Object.keys(autos).indexOf(f.name) > -1) {
             tpl[f.name] = autos[f.name];
          }
          else {
            tpl[f.name] = null;
          }
        }
        else {
          tpl[f.name] = null;
        }
      }
    });
    
    return tpl;
  }
  
  validateSchema(sch) {
    var returnValue = true;
    
    for (var i = 0; i < sch.length; i++) {
      if (Object.keys(sch).indexOf('name') == -1) {
        returnValue = false;
        break;
      }
      
      if (Object.keys(sch).indexOf('list') > -1) {
        if (typeof sch['list'] != 'boolean') {
          returnValue = false;
          break;
        }
      }
    }
    
    return returnValue;
  }
}

class JDataSet {
  constructor(schema,data) {
    if (!(schema instanceof JDataSchema)) throw TypeError('Schema is not of type JDataSchema');
    this.schema = (schema) ? schema : null;
    this.data = (data) ? data : [];
  }
  
  get data() {
    return this._d;
  }
  
  set data(d) {
    this._d = d;
  }
  
  get schema() {
    return this._s;
  }
  
  set schema(s) {
    if (s instanceof JDataSchema) {
      this._s = s;
    }
  }
  
  getEmptyRow() {
    var nextUID = 0;
    var sortData = this.data.sort((a,b) => (a['uid']>b['uid']) ? -1 : (a['uid']<b['uid']) ? 1 : 0);
    if (sortData.length > 0) nextUID = sortData[0]['uid'] + 1;
    return this.schema.getTemplate({ uid: nextUID.toString()});
  }
  
  insert(row) {
    if (this.validateRow(row)) this.data.push(row);
  }
  
  query(q) {
    var d = [];
    
    q.split('^').forEach(f => {
      var thisQ = f.replace(/^([^=%]+)([=%])(.*)$/,"$1|$2|$3").split('|');
      
      if (thisQ.length != 3) throw new SyntaxError('Invalid query (<field><=|%><value>)');
      
      if (thisQ[1] == '=') {
        d = d.concat(this.data.filter(r => r[thisQ[0]] == thisQ[2]));
      }
      
      if (thisQ[1] == '%') {
        var pattern = new RegExp(thisQ[2],'i');
				
				if (this.schema.schema.filter(f => f.name == thisQ[0])[0].list)  {
					d = d.concat(this.data.filter(r => r[thisQ[0]].join(',').match(pattern)));
				}
				else {
					d = d.concat(this.data.filter(r => r[thisQ[0]].match(pattern)));
				}
      }
    });
    
    return new JDataSet(this.schema,d);
  }
  
  update(row) {
    var activeUIDs = this.data.map(r => r['uid']);

    if (activeUIDs.indexOf(row['uid']) > -1) {
      var newData = this.data.filter(r => r['uid'] != row['uid']);
      newData.push(row);
      this.data = newData;
    }
    else {
      this.insert(row)
    }
  }
  
  validateRow(row) {
    var rowFields = Object.keys(row);
    var checkFields = this.schema.schema.map(f => f.name);
    
    var returnValue = true;
    
    if (rowFields.length != checkFields.length) returnValue = false;
    else {
      for (var i = 0; i < rowFields.length ; i++) {
        if (rowFields.indexOf(checkFields[i]) == -1) {
          returnValue = false;
          break;
        }
      }
    }
    
    return returnValue;
  }
}

class JDataView {
  constructor(container,data) {
    if (!(data instanceof JDataSet)) throw TypeError('Data is not of type JDataSet');
    this.container = container;
    this.data = (data) ? data : [];
  }
  
  get container() {
    return document.getElementById(this._c);
  }
  
  set container(c) {
    if (Object.keys(this).indexOf('_c') == -1) {
      this._c = c;
    }
    else {
      throw new SyntaxError('Unable to reset container');
    }
  }
  
  get data() {
    return this._d;
  }
  
  set data(d) {
    if (d instanceof JDataSet) {
      this._d = d;
    }
  }
  
  clearView() {
    this.container.innerHTML = '';
  }
  
  renderQueryEditor(query) {
    var table = document.createElement('table');

    var addQuery = document.createElement('button');
    addQuery.innerText = 'Add Query';
    addQuery.id = 'query_add';
    
    addQuery.onclick = () => {
      var queryRow = document.createElement('tr');
      
      var fieldCell = document.createElement('td');
      var fieldList = document.createElement('select');
      fieldList.classList.add('query_field');
      
      this.data.schema.schema.filter(f => f.name != 'uid').forEach(f => {
        var opt = document.createElement('option');
        opt.value = f.name;
        opt.innerText = f.label;
        fieldList.add(opt);
      });
      
      fieldCell.appendChild(fieldList);
      queryRow.appendChild(fieldCell);
      
      var operCell = document.createElement('td');
      var operList = document.createElement('select');
      operList.classList.add('query_operation')
      
      var eqOp = document.createElement('option');
      eqOp.value = '=';
      eqOp.innerText = 'Equals';
      operList.add(eqOp);
      
      var contOp = document.createElement('option');
      contOp.value = '%';
      contOp.innerText = 'Contains';
      operList.add(contOp);
      
      operCell.appendChild(operList);
      queryRow.appendChild(operCell);
      
      var expressionCell = document.createElement('td');
      var queryExpression = document.createElement('input');
      queryExpression.classList.add('query_expression');
      
      expressionCell.appendChild(queryExpression);
      queryRow.appendChild(expressionCell);
      
      var removeQuery = document.createElement('button');
      removeQuery.innerText = 'X';
      removeQuery.onclick = () => {
        table.removeChild(queryRow);
        document.getElementById('run_query').click();
      };
      
      queryRow.appendChild(removeQuery);
      
      table.appendChild(queryRow);
    };
    
    var runQuery = document.createElement('button');
    runQuery.id = 'run_query';
    runQuery.innerText = "Run";
    
    runQuery.onclick = () => {
      var fields = document.getElementsByClassName('query_field');
      var operations = document.getElementsByClassName('query_operation');
      var expressions = document.getElementsByClassName('query_expression');
      
      if (fields.length == operations.length == expressions.length) {
        var newQuery = []
        for (var i = 0; i < fields.length; i++) {
          newQuery.push(fields[i].value + operations[i].value + expressions[i].value);
        }
        
        this.renderListView(newQuery.join('^'));
      }
    };
		
		var resetQuery = document.createElement('button');
		resetQuery.innerHTML = "Reset";
		resetQuery.onclick = () => {
			this.renderListView();
		};
    
    this.container.appendChild(addQuery);
    this.container.appendChild(runQuery);
		this.container.appendChild(resetQuery);
    this.container.appendChild(document.createElement('br'));
    this.container.appendChild(table);
    
    if (query) {
      query.split('^').forEach(q => {
        var thisQ = q.replace(/^([^=%]+)([=%])(.*)$/,"$1|$2|$3").split('|');
        document.getElementById('query_add').click();
        
        var fields = document.getElementsByClassName('query_field');
        var operations = document.getElementsByClassName('query_operation');
        var expressions = document.getElementsByClassName('query_expression');
        
        if (fields.length == operations.length == expressions.length) {
          fields[fields.length - 1].value = thisQ[0];
          operations[operations.length - 1].value = thisQ[1];
          expressions[expressions.length - 1].value = thisQ[2];
        }
      });
    }
  }
  
  renderListView(query) {
    this.clearView();
    
    var thisData = (query) ? this.data.query(query) : this.data;
    
    if (query) this.renderQueryEditor(query);
    else this.renderQueryEditor();
    
    var table = document.createElement('table');
    var headerRow = document.createElement('tr');
    
    thisData.schema.schema.forEach(f => {
      if (f.display) {
        var column = document.createElement('th');
        column.innerText = f.label;
        headerRow.appendChild(column);
      }
    });
    
    var actionColumn = document.createElement('th');
    actionColumn.innerText = "Action";
    
    headerRow.appendChild(actionColumn);
    
    table.appendChild(headerRow);
    
    
    thisData.data.forEach(r => {
      var newRow = document.createElement('tr');
      Object.keys(r).forEach(f => {
        if (thisData.schema.schema.filter(e => e.name == f)[0].display) {
          var field = document.createElement('td');
          field.innerHTML = (r[f] instanceof Array) ? r[f].join('<br/>') : r[f];
          newRow.appendChild(field);
        }
      });
      
      var actionCol = document.createElement('td');
      var editLink = document.createElement('a');
      editLink.innerText = "Edit";
      editLink.href = '#';
      editLink.onclick = () => {
        this.renderFormView(r);
      };
      
      actionCol.appendChild(editLink);
      newRow.appendChild(actionCol);
      table.appendChild(newRow);
    });
    
    this.container.appendChild(table);
    
    if (table.children.length == 1) {
      var emptyTable = document.createElement('div');
      emptyTable.style.textAlign = 'center';
      emptyTable.innerText = 'No records found';
      
      this.container.appendChild(emptyTable);
    }
    
    var newRecord = document.createElement('button');
    newRecord.innerText = 'New Record';
    newRecord.onclick = () => {
      var newRow = this.data.getEmptyRow();
      this.renderFormView(newRow);
    };
    
    this.container.appendChild(newRecord);
  }
  
  renderFormView(row) {
    this.clearView();

    var hiddenFieldContainer = document.createElement('div');

    var formContainer = document.createElement('div');
    formContainer.setAttribute('style','display: grid; grid-template-columns: max-content max-content;padding: 10px;');
    
    this.data.schema.schema.forEach(f => {
      var labelContainer = document.createElement('div');
      labelContainer.classList.add('jd_label_cell')
      labelContainer.setAttribute('style','padding: 20px;width:100px;');
      
      var fieldContainer = document.createElement('div');
      fieldContainer.classList.add('jd_field_cell');
      fieldContainer.setAttribute('style','padding: 20px;');
      
      if (f.list) {
        var collector = document.createElement('input');
        collector.type = 'hidden';
        collector.id = 'jd_' + f.name;
        collector.classList.add('jd_list');
        
        var label = document.createElement('label');
        label.htmlFor = 'jd_' + f.name + '_add';
        label.innerHTML = f.label;
        
        var listContainer = document.createElement('div');
        
        var newItem = document.createElement('button');
        newItem.id = 'jd_' + f.name + '_add';
        newItem.innerHTML = "Add";
        newItem.onclick = function() {
          var newBox = document.createElement('input');
          newBox.classList.add('jd_' + f.name + '_list');
          
          newBox.onkeyup = function(e) {
            var listAr = [];
            
            var listElements = document.getElementsByClassName('jd_' + f.name + '_list');
            
            for (var i = 0; i < listElements.length; i++) {
              listAr.push(listElements[i].value);
            }
            
            document.getElementById('jd_' + f.name).value = listAr.join(',');
          };
          
          listContainer.appendChild(newBox);
          listContainer.appendChild(document.createElement('br'));
          
          newBox.focus();
        };
        
        labelContainer.appendChild(label);
        
        fieldContainer.appendChild(newItem);
        fieldContainer.appendChild(listContainer);
        fieldContainer.appendChild(collector);
        
        formContainer.appendChild(labelContainer);
        formContainer.appendChild(fieldContainer);     
      }
      else {
        var field = null;
        var label = null;
        
        if (f.multiline) {
          field = document.createElement('textarea');
          field.id = 'jd_' + f.name;
          field.classList.add('jd_text');
          
          label = document.createElement('label');
          label.htmlFor = 'jd_' + f.name;
          label.innerHTML = f.label;
          label.style.display = 'inline-block';
          label.style.float = 'left';
        }
        else {
          field = document.createElement('input');
          field.type = (f.hidden) ? 'hidden' : 'text';
          field.id = 'jd_' + f.name;
          field.classList.add('jd_text');
          
          if (!f.hidden) {
            label = document.createElement('label');
            label.htmlFor = 'jd_' + f.name;
            label.innerHTML = f.label;
          }
        }
        
        if (!f.hidden) {
          labelContainer.appendChild(label);
          
          fieldContainer.appendChild(field);
          
          formContainer.appendChild(labelContainer);
          formContainer.appendChild(fieldContainer);
        }
        else {
          hiddenFieldContainer.appendChild(field);
        }
      }
    });
    
    this.container.appendChild(formContainer);
    this.container.appendChild(hiddenFieldContainer);
    
    var saveButton = document.createElement('button');
    saveButton.innerText = 'Save';
    saveButton.onclick = () => {
      var newRowData = {};
      
      var textFields = document.getElementsByClassName('jd_text');
      for (var i = 0; i < textFields.length; i++) {
        var fieldName = textFields[i].id.replace(/^jd_/,'');
        newRowData[fieldName] = textFields[i].value;
      }
      
      var listFields = document.getElementsByClassName('jd_list');
      for (var i = 0; i < listFields.length; i++) {
        var fieldName = listFields[i].id.replace(/^jd_/,'');
        newRowData[fieldName] = listFields[i].value.split(',');
      }
      
      this.data.update(newRowData);
      
      this.renderListView();
    };
    
    this.container.appendChild(saveButton);
    
    var closeButton = document.createElement('button');
    closeButton.innerText = 'Close';
    closeButton.onclick = () => {
      this.renderListView();
    };
    
    this.container.appendChild(closeButton);
    
    if (row) {
      Object.keys(row).forEach(f => {
        if (row[f] instanceof Array) {
          row[f].forEach(e => {
            document.getElementById('jd_' + f + '_add').click();
            var listFields = document.getElementsByClassName('jd_' + f + '_list');
            listFields[listFields.length - 1].value = e;
          });
          
          document.getElementById('jd_' + f).value = row[f].join(',');
        }
        else {
          document.getElementById('jd_' + f).value = row[f];
        }
      });
    }
  }
}