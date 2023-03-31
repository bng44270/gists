/*
  Requires range.js - https://gist.github.com/bng44270/36f42505c98b4277c608694cf0c93245
  
  usage:
  
    > var cron = new JSCron(false,true);
    > cron.addJob(function() {
        console.log("This runs every minute " + new Date().getMinutes());
      },'This is a test job');
    > cron.addJob(function() {
        console.log("This at the top of every 15 minutes " + new Date().getHours() + ":" + new Date().getMinutes());
      },'Another test job',[0,15,30,45]);
    > cron.addJob(function() {
        console.log("This runs at 4pm " + new Date().getHours() + ":" + new Date().getMinutes());
      },'The last test function',[0],[16]);
    > cron.startScheduler();
*/

class JSCron {
  constructor(start,debug,jobs) {
    this.JOBS = (jobs) ? jobs : [];
    this.DEBUG = (debug) ? debug : false;
    this.AUTOSTART = (start) ? start : false;
    this.RUN = true;
    if (this.AUTOSTART) this.initializeScheduler();
  }
  
  
  
  addJob(r,desc,m,h,d,mo) {
    this.JOBS.push({
      'run' : r,
      'description' : (desc) ? desc : 'UNKNOWN',
      'minute' : (m) ? m : new Range(0,59), 
      'hour' : (h) ? h : new Range(0,23),
      'day' : (d) ? d : new Range(1,31),
      'month' : (mo) ? mo : new Range(0,11),
      'log':[]
    });
  }
  
  runJob(job) {
    var jobId = parseInt(Math.random() * 1000000);
    var startMsg = "Started job (" + job.description + ")[" + jobId.toString() + "] at " + (new Date()).toString();
    job.log.push(startMsg);
    if (this.DEBUG) console.log(startMsg);
    return new Promise(resolve => {
      job.run();
      var stopMsg = "Finished job (" + job.description + ")[" + jobId.toString() + "] at " + (new Date()).toString();
      job.log.push(stopMsg);
      if (this.DEBUG) console.log(stopMsg);
    });
  }
  
  startScheduler() {
    this.RUN = true;
    this.initializeScheduler();
  }
  
  stopScheduler() {
    this.RUN = false;
  }
  
  initializeScheduler() {
    if (this.RUN) {
      var toNextMinute = 60 - (new Date().getSeconds());
      if (this.DEBUG) console.log("Waiting " + toNextMinute.toString() + "s to start scheduler");
      setTimeout(() => {
        if (this.DEBUG) console.log("Scheduler started at " + (new Date()).toString());
        this.tickScheduler();
      },(toNextMinute * 1000));
    }
  }
  
  tickScheduler() {
    setTimeout(() => {
      if (this.RUN) {
        var now = new Date();
        
        this.JOBS.forEach(j => {
          if (j.month.indexOf(now.getMonth()) > -1 &&
            j.day.indexOf(now.getDate()) > -1 &&
            j.hour.indexOf(now.getHours()) > -1 &&
            j.minute.indexOf(now.getMinutes()) > -1) {
            this.runJob(j);
          }
        });
      }
      else {
        if (this.DEBUG) console.log("Scheduler stopped at " + (new Date()).toString());
      }
      
      this.tickScheduler()
    },60000);
  }
}