/*

    Easily Parse URL Arguments as string, integer, float, date, or JSON

    Example:

        URL:  http://localhost/home.php?name=Jim&age=30&hourly=25.99
        
        Script:
            var arg = new Arguments();

            arg.getString('name');      //Returns:  'Jim'
            arg.getString('age');       //Returns:  '30'
            arg.getInt('age');          //Returns:  30
            arg.getInt('hourly');       //Returns:  25
            arg.getFloat('hourly');     //Returns:  25.99
        
*/

class Arguments {
    constructor() {
        this.args = {};
        var argList = location.search.replace(/^\?/,'').split('&').forEach(a =>  {
            var thisArg = a.split('=');
            this.args[thisArg[0]] = decodeURI(thisArg[1]);
        });
    }

    getString(arg) {
        return (this.existArg(arg)) ? this.args[arg].toString() : '';
    }

    getInt(arg) {
        return (this.existArg(arg)) ? parseInt(this.args[arg]) : NaN;
    }

    getFloat(arg) {
        return (this.existArg(arg)) ? parseFloat(this.args[arg]) : NaN;
    }

    getJSON(arg) {
        return (this.existArg(arg)) ? JSON.parse(this.args[arg]) : {};
    }

    getDate(arg) {
        return (this.existArg(arg)) ? new Date(Date.parse(this.args[arg])) : NaN;
    }

    existArg(arg) {
        return (Object.keys(this.args).indexOf(arg) > -1) ? true : false;
    }
}