/*
  KBUtil - Create Keyboard shortcut driven events
  
  Usage:
  
    var kb = new KBUtil();
    
    kb.addKey(function() {
      console.log("You pressed a");
    },KBUtil.KEY_A);
    
    kb.addKey(function() {
      console.log("You pressed A");
    },KBUtil.KEY_A,[KBUtil.SHIFT]);
    
    //Key definitions are KBUtil.KEY_A through KBUtil.KEY_Z and KBUtil.KEY_0 - KBUtil.KEY_9
    
    kb.addKey(function() {
      console.log("You typed a dash");
    },173);
*/

class KBUtil {
  static KEY_A = 65;
  static KEY_B = 66;
  static KEY_C = 67;
  static KEY_D = 68;
  static KEY_E = 69;
  static KEY_F = 70;
  static KEY_G = 71;
  static KEY_H = 72;
  static KEY_I = 73;
  static KEY_J = 74;
  static KEY_K = 75;
  static KEY_L = 76;
  static KEY_M = 77;
  static KEY_N = 78;
  static KEY_O = 79;
  static KEY_P = 80;
  static KEY_Q = 81;
  static KEY_R = 82;
  static KEY_S = 83;
  static KEY_T = 84;
  static KEY_U = 85;
  static KEY_V = 86;
  static KEY_W = 87;
  static KEY_X = 88;
  static KEY_Y = 89;
  static KEY_Z = 90;
  
  static KEY_0 = 48;
  static KEY_1 = 49;
  static KEY_2 = 50;
  static KEY_3 = 51;
  static KEY_4 = 52;
  static KEY_5 = 53;
  static KEY_6 = 54;
  static KEY_7 = 55;
  static KEY_8 = 56;
  static KEY_9 = 57;
  
  static SHIFT = 16
  static CTRL = 17
  static ALT = 18
  
  constructor() {
    this.events = [];
    
    document.addEventListener('keyup',this.evaluateKey.bind(this),false);
  }
  
  evaluateKey(e) {
    this.events.filter(r => r.key == e.keyCode).forEach(r => {
      var oktoRun = false;
      
      if (e.shiftKey && r.mods.indexOf(KBUtil.SHIFT) > -1) oktoRun = true;
      
      if (e.ctrlKey && r.mods.indexOf(KBUtil.CTRL) > -1) oktoRun = true;
      
      if (e.altKey && r.mods.indexOf(KBUtil.ALT) > -1) oktoRun = true;
      
      if (!e.shiftKey && !e.ctrlKey && !e.altKey && r.mods.length == 0) oktoRun = true;
      
      if (oktoRun) r.run();
    });
  }
  
  addKey(run,key,mod) {
    if (!mod) mod = []
    this.events.push({
      key: key,
      mods: mod,
      run: run
    });
  }
}