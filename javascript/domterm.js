/*
	DomTerm (DOM Terminal)
	
	Replaced by ES6 version (https://gist.github.com/bng44270/23460394706763fece3aaa45046dc191)
	
	Create interactive customizable command-line interface in a browser window
	
	Requires:  NewClass.js
	
	Built-in Commands:
	
		clear - clears terminal display
		pipeon - turns on output pipe
		count - counts lines in output pipe (closes pipe after execution)
		grep - search for string int output pipe (closes pipe after execution)
		history - display command history
		info - show information about environment
		echo - display output and turn command echo on/off
		rerun - rerun command from history	
	Usage:
	
		1) Create <div> to populate with terminal
		2) Create a DomTerm instance:
		
			Option 1 (div = id of <div>):  
				var thisTerm = DomTerm.instance({div:'terminal'});
			
			Option 2 (div = id of <div>, autoexec = array of startup commands:
				var thisTerm = DomTerm.instance({div:'terminal', autoexec: [
					'echo **********************',
					'echo * DOM Term Interface *',
					'echo **********************'
				]});
		   
		3) Adding custom command (in this case, a print command):
		
			thisTerm.addCommand('print',function(myterm,input) {
				myterm.showOutput(input.replace(/^print[ \t]+/,''));
			},{
				description : 'Output string to console',
				usage : 'print &lt;string&gt;'
			});
			
		4) Adding a custom keyboard shortcut (in this case "Alt-c" to clear terminal):
		
			thisTerm.addKeyboardShortcut('c',function(myterm) {
				myterm.clearConsole();
			},"Clear console");
		
*/

var DomTerm = NewClass({
	public : {
		settings : {
			consoleSize : [80,20],
			backgroundColor : '#ffffff',
			foregroundColor : '#000000',
			container : '',
			displayId : '',
			inputId : '',
			selectionId : '',
			cmds : [],
			kbs : [],
			keyon : false,
			inputTask : {
				active : false
			},
			consoleEcho : false,
			selection : false,
			history : [],
			currentHistoryItem : -1,
			scripts : [],
			waitLabel : '',
			outputPipe : {
				active : false,
				text : ''
			}
		},
		toggleSelection : function(event) {
			if (this.settings.selection) {
				this.settings.selection = false;
				document.getElementById(this.settings.selectionId).value = 'Turn Selection Mode On';
			}
			else {
				this.settings.selection = true;
				document.getElementById(this.settings.selectionId).value = 'Turn Selection Mode Off';
			}
			document.getElementById(this.settings.inputId).focus();
		},
		resizeEntry : function(event) {
			document.getElementById(this.settings.inputId).style.width = document.getElementById(this.settings.displayId).style.width;
			if (!this.settings.selection) {
				document.getElementById(this.settings.inputId).focus();
			}
		},
		clearConsole : function() {
			document.getElementById(this.settings.displayId).innerHTML = '';
		},
		showOutput : function(outputText) {
			if (typeof outputText != 'string') throw new TypeError;
			
			if (this.settings.outputPipe.active) {
				this.settings.outputPipe.text += outputText + '\n';
			}
			else {
				document.getElementById(this.settings.displayId).innerHTML = document.getElementById(this.settings.displayId).innerHTML + '\n' + outputText;
			}
	
			document.getElementById(this.settings.displayId).scrollTop = document.getElementById(this.settings.displayId).scrollHeight;
		},
		startPipedOutput : function() {
			this.settings.outputPipe.active = true;
		},
		returnPipedOutput : function() {
			var returnData = '';
			if (this.settings.outputPipe.active) {
				returnData = this.settings.outputPipe.text;
				this.settings.outputPipe.active = false;
				this.settings.outputPipe.text = '';
				this.showOutput('Piped output is complete');
			}
			return returnData;
		},
		replaceConosleText : function(origText,replaceWith) {
			if (typeof origText != 'string') throw new TypeError;
			if (typeof replaceWith != 'string') throw new TypeError;
			
			if (this.settings.outputPipe.active) {
				var pipeText = this.settings.outputPipe.text;
				this.settings.outputPipe.text = pipeText.replace(origText,replaceWith);
			}
			else {
				var consoleText = document.getElementById(this.settings.displayId).innerHTML;
				document.getElementById(this.settings.displayId).innerHTML = consoleText.replace(origText,replaceWith);
			}
		},
		setCommandText : function(cmdText) {
			if (typeof cmdText != 'string') throw new TypeError;
			
			document.getElementById(this.settings.inputId).value = cmdText;
		},
		getCommandText : function() {
			return document.getElementById(this.settings.inputId).value;
		},
		addScript : function(scriptName,cmdAr, scriptDescr) {
			if (typeof scriptName != 'string') throw new TypeError;
			if (typeof cmdAr != 'object') throw new TypeError;
			if (typeof scriptDescr != 'string') throw new TypeError;
			
			this.settings.scripts.push({
				name : scriptName,
				description : scriptDescr,
				commands : cmdAr
			});
		},
		runScript : function(scriptName) {
			if (typeof scriptName != 'string') throw new TypeError;
			
			if (this.existScript(scriptName)) {
				var scriptCommands = this.settings.scripts.filter(function(thisScript) {
					return thisScript.name == scriptName;
				})[0].commands;
				
				this.debugMessage('BEGIN ' + scriptName + ' script');
				for (var i = 0; i < scriptCommands.length; i++) {
					this.setCommandText(scriptCommands[i]);
					this.runInput();
				}
				this.debugMessage('END ' + scriptName + ' script');
			}
		},
		existScript : function(scriptName) {
			if (typeof scriptName != 'string') throw new TypeError;
			
			var scriptFoundCount = this.settings.scripts.filter(function(thisScript) {
				return thisScript.name == scriptName;
			});
			return scriptFoundCount;
		},
		beginOutputWait : function(label) {
			if (typeof label != 'string') throw new TypeError;
			
			this.showOutput('WAITING-FOR-' + label);
			this.settings.waitLabel = label;
		},
		endOutputWait : function(outputText) {
			if (typeof outputText != 'string') throw new TypeError;
			
			this.replaceConosleText('WAITING-FOR-' + this.settings.waitLabel,outputText);
			this.settings.waitLabel = '';
		},
		addCommand : function(cmdName,cmdFunction,helpData) {
			if (typeof cmdName != 'string') throw new TypeError;
			if (typeof cmdFunction != 'function') throw new TypeError;
			if (typeof helpData != 'object' && helpData) throw new TypeError;
			
			if (this.existCommand(cmdName).length == 0) {
				this.settings.cmds.push({
					name:cmdName,
					run:cmdFunction,
					help:helpData
				});
			}
		},
		existCommand : function(cmdName) {
			if (typeof cmdName != 'string') throw new TypeError;
			
			return this.settings.cmds.filter(function(command) {
				return command.name == cmdName;
			});
		},
		addInputTask : function(inputFunction) {
			if (typeof inputFunction != 'function') throw new TypeError;
			
			this.settings.inputTask = {
				run : inputFunction,
				active : true
			};
		},
		resetInputTask : function() {
			this.settings.inputTask = {
				active : false
			};
		},
		addKeyboardShortcut : function(keyEntry, runCode, description) {
			if (typeof keyEntry != 'string' && keyEntry.match(/^[a-z0-9]$/)) throw new TypeError;
			if (typeof runCode != 'function') throw new TypeError;
			if (typeof description != 'string') throw new TypeError;

			this.settings.kbs.push({
				key : keyEntry,
				description : description,
				run : runCode
			});
		},
		handleKeyboardInput : function(event) {
			if (event.altKey) {
				var inputKey = event.code.replace(/^[KD][ei][gy][i]*[t]*(.*$)/,'$1').toLowerCase();

				if (inputKey.match(/^[a-z0-9]$/)) {
					var thisKey = this.settings.kbs.filter(function(thisItem) {
						return thisItem.key == inputKey;
					});

					if (thisKey.length == 1) {
						thisKey[0].run(this);
					}
					else {
						this.showOutput('Alt-' + inputKey + ' not defined');
					}
				}
				this.setCommandText('$ ');
			}
		},
		handleInput : function(event) {
			//Set Prompt
			if (this.getCommandText().length < 2) {
				this.setCommandText('$ ');
			}
			//Escape
			if (event.keyCode == 27) {
				this.setCommandText('$ ');
			}
			//Pressed up
			else if (event.keyCode == 38) {
				this.setCommandText('$ ' + this.settings.history[this.settings.currentHistoryItem]);
				if (this.settings.currentHistoryItem > 0) {
					this.settings.currentHistoryItem -= 1;
				}
			}
			//Pressed down
			else if (event.keyCode == 40) {
				if (this.settings.currentHistoryItem < (this.settings.history.length - 1)) {
					this.settings.currentHistoryItem += 1;
				}
				this.setCommandText('$ ' + this.settings.history[this.settings.currentHistoryItem]);
			}
			//Pressed enter
			else if (event.keyCode == 13) {
				this.runInput();
			}
		},
		debugMessage : function(debugText) {
			this.settings.history.push('# ' + debugText);
			this.settings.currentHistoryItem = this.settings.history.length -1;
			if (this.settings.consoleEcho) {
				this.showOutput('> # ' + debugText);
			}
		},
		runInput : function() {
			var inputText = document.getElementById(this.settings.inputId).value.replace(/^\$[ \t]+/,'');
			this.settings.history.push(inputText);
			this.settings.currentHistoryItem = this.settings.history.length -1;
			if (inputText.length > 0) {
				if (inputText.match(/^#/)) {
					if (this.settings.consoleEcho) {
						this.showOutput('$ ' + inputText);
					}
				}
				else if (this.settings.inputTask.active) {
					if (this.settings.consoleEcho) {
						this.showOutput('$ ' + inputText);
					}
					this.settings.inputTask.run(inputText);
				}
				else {
					var rootCmd = inputText.replace(/^([^ \t]+).*$/,"$1");
					if (this.existCommand(rootCmd).length > 0) {
						if (this.settings.consoleEcho)
							this.showOutput('$ ' + inputText);
						this.settings.cmds.filter(function(command) {
							return command.name == rootCmd;
						})[0].run(this,inputText);
					}
					else if (this.existScript(inputText).length > 0) {
						if (this.settings.consoleEcho)
							this.showOutput('$ ' + inputText);
						this.runScript(inputText);
					}
					else {
						if (this.settings.consoleEcho)
							this.showOutput('$ ' + inputText);
						this.showOutput('Command not found (' + rootCmd + ')');
					}
				}
				
				document.getElementById(this.settings.inputId).value = '$ ';
			}
		}
	},
	constructor : function(args) {
		//Define HTML element names for terminal
		this.settings.container = args.div;
		this.settings.displayId = args.div + '_termDisplay';
		this.settings.inputId = args.div + '_termInput';
		this.settings.selectionId = args.div + '_selection';
		
		//Draw Terminal
		var htmlContent = '<pre id="' + this.settings.displayId + '" style="width:520px;overflow-y:scroll;height:400px;outline:none;resize: both;overflow: auto;"></pre><br/>';
		htmlContent += '<input autocomplete="off" style="font-family: monospace;" type="text" id="' + this.settings.inputId + '" value="$ " style="width:520px;border:none;border-width:0px;" /><br/>';
		htmlContent += '<input type="button" id="' + this.settings.selectionId + '" value="Turn Selection Mode On" />';
		document.getElementById(this.settings.container).innerHTML = htmlContent;
		document.getElementById(this.settings.inputId).addEventListener('keyup',this.handleInput.bind(this),false);
		document.getElementById(this.settings.displayId).addEventListener('mouseup',this.resizeEntry.bind(this),false);
		document.getElementById(this.settings.selectionId).addEventListener('click',this.toggleSelection.bind(this),false);
		document.addEventListener('keyup',this.handleKeyboardInput.bind(this),false);
		
		//Resize Terminal
		document.getElementById(this.settings.inputId).style.width = (document.body.scrollWidth - 30).toString() + 'px';
		document.getElementById(this.settings.displayId).style.width = (document.body.scrollWidth - 30).toString() + 'px';
		document.getElementById(this.settings.displayId).style.height = (document.body.scrollHeight - 150).toString() + 'px';
		
		document.getElementById(this.settings.inputId).focus();
	
		this.debugMessage('Configured Interface');
	
		//Define base command set
		this.addCommand('clear',function(thisTerm,command) {
			thisTerm.clearConsole();
		},{
			description : 'Clears contents of console',
			usage : 'clear'
		});
		this.addCommand('info',function(thisTerm,command) {
			thisTerm.showOutput('Configuration Loaded:\n  ' + 
					    thisTerm.settings.cmds.length.toString() + ' commands\n  ' + 
					    thisTerm.settings.scripts.length.toString() + ' scripts\n  ' + 
					   thisTerm.settings.kbs.length.toString() + ' keyboard shortcuts');
		},{
			description : 'Display terminal information',
			usage : 'info'
		});
		this.addCommand('echo',function(thisTerm,command) {
			command = command.replace(/^echo[ \t]*/,'');
			if (command == 'on') {
				thisTerm.settings.consoleEcho = true;
				thisTerm.showOutput('echo is on');
			}
			else if (command == 'off') {
				thisTerm.settings.consoleEcho = false;
				thisTerm.showOutput('echo is off');
			}
			else if (command.length == 0) {
				thisTerm.showOutput('echo is ' + ((thisTerm.settings.consoleEcho) ? 'on' : 'off'));
			}
			else {
				thisTerm.showOutput(command);
			}
		},{
			description : 'Change command echo functionality',
			usage : 'echo &lt;on|off|(string of text)&gt;'
		});
		this.addCommand('grep',function(thisTerm,input) {
			if (thisTerm.settings.outputPipe.active) {
				input = input.replace(/^grep[ \t]+/,"");
				
				thisTerm.showOutput(thisTerm.returnPipedOutput().split('\n').filter(function(thisLine) {
					return thisLine.match(new RegExp(input,'i'));
				}).join('\n'));
			}
			else {
				thisTerm.showOutput('No active pipes (use pipeon)');
			}
		},{
			description : 'Search piped output',
			usage : 'grep &lt;text&gt;'
		});
		this.addCommand('count',function(thisTerm,input) {
			if (thisTerm.settings.outputPipe.active) {
				input = input.replace(/^count[ \t]*/,"");
				switch(input) {
					case "line" : thisTerm.showOutput("Lines:  " + thisTerm.returnPipedOutput().split('\n').length.toString()); break;
					case "char" : thisTerm.showOutput("Characters :  " + thisTerm.returnPipedOutput().length.toString()); break;
					case "" : thisTerm.showOutput('Requires line or char'); break;
					default : thisTerm.showOutput('Invalid argument (' + input + ')'); break;
				}
			}
			else {
				thisTerm.showOutput('No active pipes (use pipeon)');
			}
		},{
			description : 'Return count data from piped output',
			usage : 'count <line|char>'
		});
		this.addCommand('pipeon',function(thisTerm,command) {
			if (thisTerm.settings.outputPipe.active) {
				thisTerm.showOutput('Pipe is already active');
			}
			else {
				thisTerm.showOutput('Piped output is activated');
				thisTerm.settings.outputPipe.active = true;
			}
		},{
			description : 'Turn on piped output functionality',
			usage : 'pipeon'
		});
		this.addCommand('help',function(thisTerm,input) {
			input = input.replace(/^help[ \t]*/,'');
			
			if (input.length > 0) {
				var commandData = thisTerm.settings.cmds.filter(function(thisCmd) {
					return thisCmd.name == input;
				});
				
				var scriptData = thisTerm.settings.scripts.filter(function(thisScr) {
					return thisScr.name == input;
				});

				if (commandData.length == 1) {
					if (commandData[0].help)
						thisTerm.showOutput(commandData[0].help.description + '\nusage: ' + commandData[0].help.usage + '\n');
					else
						thisTerm.showOutput(input + ':  command help not available');
				}
				else if (scriptData.length == 1) {
					thisTerm.showOutput(scriptData[0].description + '\nCommands executed in script:\n' + scriptData[0].commands.map(function(thisCmd) {
						return '    > ' + thisCmd;
					}).join('\n'));
				}
				else {
					thisTerm.showOutput('Command not found (' + input + ')');
				}
			}
			else {
				thisTerm.showOutput('Available commands:\n' + thisTerm.settings.cmds.map(function(itm) {
					return "   " + itm.name;
				}).sort().join('\n') + '\nAvailable Scripts:\n' + thisTerm.settings.scripts.map(function(itm) {
					return "   " + itm.name;
				}).sort().join('\n') + '\nAvailable Keyboard Shortcuts:\n' + thisTerm.settings.kbs.map(function(itm) {
					return "   Alt-" + itm.key + ":  " + itm.description;
				}).sort().join('\n') + '\nCommand-specific information:\n   help &lt;command&gt;');
			}
		},{
			description : 'Show help information',
			usage : 'help [&lt;command&gt;]'
		});
		this.addCommand('history',function(thisTerm,command) {
			if (command.replace(/^history[ \t]+/,'') == 'del') {
				thisTerm.settings.history = [];
				thisTerm.debugMessage('History deleted');
			}
			else {
				for (var i = 0; i < thisTerm.settings.history.length; i++) {
					thisTerm.showOutput((i+1).toString() + ': ' + thisTerm.settings.history[i]);
				}
			}
		},{
			description : 'Show/Delete command history',
			usage : 'history [del]'
		});
		this.addCommand('rerun',function(thisTerm,command) {
			command = command.replace(/^rerun[ \t]*/,"");
			
			var cmdIdx = eval(command) - 1;
			if (cmdIdx <= thisTerm.settings.history.length) {
				thisTerm.setCommandText(thisTerm.settings.history[cmdIdx]);
				thisTerm.debugMessage('BEGIN Re-run ' + (cmdIdx + 1).toString());
				thisTerm.runInput();
				thisTerm.debugMessage('END Re-run ' + (cmdIdx + 1).toString());
			}
		},{
			description : "Rerun command listed in history",
			usage : "rerun &lt;history-id&gt; [command-count]"
		});
	
		this.addKeyboardShortcut('s',function(thisTerm) {
			thisTerm.toggleSelection();
		},'Toggle selection mode on and off');

		this.debugMessage('Base Command Set Loaded');
	
		if (args.autoexec) {
			this.addScript('autoexec',args.autoexec,'Startup Script');
			this.runScript('autoexec');
		}
	}
});

var thisTerm = DomTerm.instance({div:'terminal', autoexec: [
	'echo **********************',
	'echo * DOM Term Interface *',
	'echo **********************'
]});

thisTerm.addCommand('print',function(myterm,input) {
	myterm.showOutput(input.replace(/^print[ \t]+/,''));
},{
	description : 'Output string to console',
	usage : 'print &lt;string&gt;'
});

thisTerm.addScript('show_banner',[
	'print *****************',
	'print * Welcome Buddy *',
	'print *****************'
],'Display Welcome Banner');

thisTerm.addKeyboardShortcut('c',function(myterm) {
	myterm.clearConsole();
},"Clear console");
