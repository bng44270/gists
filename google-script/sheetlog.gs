/*

  Logs a row of data point to Google Sheets
  
  Requirements:
  
    The first row of the spreadsjeet is reserved for column headers
    
    Column 1 is a date field
    

  Usage:

    var log = new SheetLog('FILE-ID','SHEET-NAME');
    log.write(['col1','col2','col3','col4']);
    log.write(['new-col1','new-col2','new-col3','new-col4']);
    
    The above code would result in two new rows in spreadsheet (identified by FILE-ID and sheet identified by SHEET-NAME)

*/

class SheetLog {
  constructor(fileId,sheetName) {
    var ss = SpreadsheetApp.openById(fileId);
    this.log = ss.getSheetByName(sheetName);
  }

  write(p) {
    try {
      this.log.insertRowsAfter(1,1);
      this.log.getRange('A2:' + String.fromCharCode(65 + line.length -1) + '2').setValues([
        [this.getNowDate()].concat(p)
      ]);
      return p;
    catch(e) {
      return false;
    }   
  }
  
  getNowDate() {
    var d = new Date();
    return (d.getFullYear().toString() + '-' + (d.getMonth() + 1).toString().padStart(2,'0') + '-' + d.getDate().toString().padStart(2,'0') + 'T' + d.getHours().toString().padStart(2,'0') + ':' + d.getMinutes().toString().padStart(2,'0') + ':' + d.getSeconds().toString().padStart(2,'0') + 'Z');
  } 
}