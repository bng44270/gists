/*

JsIFTTT

Call IFTTT Webhooks from JavaScript (for Google Script use https://gist.github.com/bng44270/d282f5a776b59486f98d2de60f2725d4)

Requires webrequest.js (https://gist.github.com/bng44270/61122a1947591d50004fcd9ee72d643d)

Usage:

    var ifttt = new JsIFTTT('key');
    ifttt.setConfig('event-name','value1','value2','value3');   //value2 and value3 are optional
    ifttt.call(function(resp) {
      //Run this code if call is successful
    },function(resp) {
      //Run this code if call fails
    });
    
Note the resp object in lines used in the callbacks of the call function has the following structure:

    {
        status : <HTTP status code>,
        headers : <array of HTTP response headers>,
        body : <HTTP response body text>
    }

*/

class JsIFTTT {
	constructor(key) {
		this.key = key;
		this.config = null;
	}

	setConfig(event,v1,v2,v3) {
		if (event && v1) {
			var payload = {};
			payload['value1'] = v1;
			if (v2) payload['value2'] = v2;
			if (v2) payload['value3'] = v3;
			
			this.config = {
				event : event,
				payload : JSON.stringify(payload)
			};
		}
		else {
			return false;
		}	
	}
	
	call(success,error) {
    		if (this.config) {
			var reqOptions = {
				headers : {
					'Content-Type' : 'application/json'
				},
				data : this.config.payload
			};
			
			
			
			var requestUrl = ('https://maker.ifttt.com/trigger/' + this.config.event + '/with/key/' + this.key).toString();
			
			var req = new WebRequest('POST',requestUrl,reqOptions);
			
			req.response.then(r => {
				if (r.status == 200) {
					if (success) success(r);
				}
				else {
					if (error) error(r);
				}
			}).catch(r => {
				if (error) error(r);
			});
		}
		else {
			return false;
		}
	}
}