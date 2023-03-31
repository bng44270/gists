/*
Requires NewClass.js

GET Usage:

	var req = HttpRequest.initialize({
		method : 'get',
		url : 'http://my.site/page.html'
	});

POST Usage (data argument can be URL encoded string also):

	var req = HttpRequest.initialize({
		method : 'post',
		url : 'http://my.site/page.html',
		data : JSON.stringify({
			name : 'bob',
			age : 43
		})
	});


Retrieving the response:

	req.response.then(resp => {
		Object.keys(resp.headers).forEach(x =>
			console.log(x + ': ' + resp.headers[x] + '\n');
		});
		console.log(resp.body);
	}).catch(resp => {
		console.log(resp.status + ' - ' + resp.body);
	});
	
Streamlined execution:

	HttpRequest.instance({
		method : 'get',
		url : 'http://my.site/page.html'
	}).response.then(resp =>
		console.log(resp.body);
	});

*/


/*
	Array.combineDictionaries combines an array containing multiple two-entry dictionaries (two entries are "key" and "value") into a single dictionary
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

var HttpRequest = NewClass({
	public: {
		//Request
		xhr : null,
		method : null,
		url : null,
		data : null,
		reqHeaders : null,
		
		//Response Object
		response : null,
		
		//Execute Request
		send : function(args) {
		
			var argNames = Object.keys(args);
			if (argNames.includes('url') && argNames.includes('method')) {
				this.url = args.url;
				this.method = args.method;
				if (argNames.includes('data'))
					this.data = args.data;
				if (argNames.includes('headers')) {
					this.reqHeaders = args.headers;
					Object.keys(this.reqHeaders).forEach(x => {
						this.xhr.setRequestHeader(x,this.reqHeaders[x]);
					});
				}
			
				this.xhr = new XMLHttpRequest();
				this.xhr.open(this.method,this.url);
			
			 	this.response = new Promise((success,error) => {
					this.xhr.onload = () => {
						success({
							'status' : this.xhr.status,
							'headers' : this.xhr.getAllResponseHeaders().split('\n').filter(x => x.length > 0).map(x => {
									return {'key': x.replace(/^([^:]+):.*$/,"$1"), 'value' : x.replace(/^[^:]+:[ \t]*(.*)$/,"$1")};
								}).combineDictionaries(),
							'body' : this.xhr.responseText
						});
					};
					
					this.xhr.onerror = () => {
						error({
								'status' : this.xhr.status,
								'body' : this.xhr.statusText
							});
					};
				});
			
			
				if (this.data)
					this.xhr.send(this.data);
				else
					this.xhr.send();
			}
		}
	},
	constructor : function(args) {
		return this.send(args);
	}
});