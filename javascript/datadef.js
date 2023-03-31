/*

  DataDef - Create a schema-enforced data structure based on the Array object
  
  Usage:
  
    //Available data types:  string, number, boolean
    var people = new DataDef({
      name:'string',
      age:'number',
      town:'string'
    });
    
    people.insert({
      name: "Bob",
      age: 30,
      town: "New York"
    });
    
    people.insert({
      name: "Jim",
      age: 33,
      town: "Chicago"
    });
    
    people.insert({
      name:"Pete",
      age:50,
      town: "Newton"
    });
    
    //Returns Bob and Jim records
    people.filter(r => 10 > r['age'] % 30 >= 1);
    
    //Returns Bob and Pete records
    people.filter(r => r['town'].match(/^New/)) ;
*/

class SchemaError extends Error {
	constructor(msg) {
		super(msg);
		this.name = this.constructor.name;
	}
}

class DataError extends Error {
	constructor(msg) {
		super(msg);
		this.name = this.constructor.name;
	}
}

class DataDef extends Array{
	constructor(fields,data) {
		super();
		
		this.setSchema(fields);
		
		if (data) this.bulkInsert(data);
	}
	
	setSchema(fields) {
		var fieldNames = Object.keys(fields);
		
		this.SCHEMA = {};
		
		fieldNames.forEach(f => {
			this.addField(f,fields[f]);
		});
	}
	
	addField(field,type) {
		var fieldExists = Object.keys(this.SCHEMA).indexOf(field) > -1;
		
		if (fieldExists) {
			throw new SchemaError("Field already exists (" + field + ")");
		}
		else {
			var fieldTypes = ['number','string','boolean'];
			
			if (fieldTypes.indexOf(type) == -1) {
				throw new SchemaError("Unknown data type (" + fields[fieldNames[i]]  + ")");
			}
			
			this.SCHEMA[field] = type;
			
			this.forEach(r => {
				r[field] = null;
			});
		}
	}
	
	deleteField(field) {
		var fieldExists = this.SCHEMA.indexOf(field) > -1;
		
		if (fieldExists) {
			this.forEach(r => {
				delete r[field];
			});
			
			var fIdx = this.SCHEMA.indexOf(field);
			delete this.SCHEMA[fIdx];
		}
		else {
			throw new SchemaError("Field does not exist (" + field + ")");
		}
	}
	
	uidToIndex(uid) {
		return this.map(r => r['uid']).indexOf(uid);
	}
	
 	getNextUid() {
 		
		return (this.length == 0) ? 1 : this.map(r => r['uid']).sort((a,b) => a < b)[0] + 1;
	}
	
	bulkInsert(records) {
		records.forEach(r => {
			this.insert(r);
		});
	}
	
	insert(record) {
		var fields = Object.keys(record);
		
		//Fill empty fields
		Object.keys(this.SCHEMA).filter(f => (fields.indexOf(f) == -1) ? true : false).forEach(f => {
			record[f] = null;
		});
		
		for (var i = 0; i < fields.length; i++) {
			if (Object.keys(this.SCHEMA).indexOf(fields[i]) == -1) {
				throw new SchemaError("Field not present in schema (" + fields[i] +")");
			}
			
			if (typeof(record[fields[i]]) != this.SCHEMA[fields[i]]) {
				throw new SchemaError("Field type mismatch (" + fields[i] + " expected " + this.SCHEMA[fields[i]] + " but got " + typeof(record[fields[i]]) + ")");
			}
		}
		
		if (Object.keys(record).indexOf('uid') == -1) {
			record['uid'] = this.getNextUid();
		}
		
		this.push(record);
	}
	
	bulkDelete(uidAr) {
		uidAr.forEach(u => {
			bulkDelete(u);
		});
	}
	
	delete(uid) {
		var recIdx = this.uidToIndex(uid);
		
		if (recIdx == -1) {
			throw new DataError("Did not find uid (" + uid.toString() + ")");
		}
		else {
			delete this[recIdx];
		}
	}
}