import * as vscode from 'vscode';
import * as path from 'path';
import { exec } from 'child_process';

function cycle() {
  const activeEditor = vscode.window.activeTextEditor;

  if (!activeEditor) {
    vscode.window.showErrorMessage('No active editor.');
    return;
  }

  const savedCursor = activeEditor.selection.active;
  const currentFile = activeEditor.document.uri.fsPath;
  const basename = path.basename(currentFile, path.extname(currentFile));

  let outputFileName: string;
  let forceFlag: string;

  if (currentFile.toLowerCase().endsWith('.csml')) {
    vscode.workspace.getConfiguration().update('files.exclude', { [basename + '.*']: true }, vscode.ConfigurationTarget.Workspace);

    vscode.workspace.findFiles(`${basename}.*`).then((candidates: vscode.Uri[]) => {
      if (candidates.length > 0) {
        outputFileName = candidates[0].fsPath;
      } else {
        outputFileName = path.join(path.dirname(currentFile), `${basename}.html`);
        vscode.window.showInputBox({ prompt: `Press Enter or override the output name '${outputFileName}':` })
          .then((input) => {
            if (input) {
              outputFileName = path.join(path.dirname(currentFile), input);
            }
          });
      }

      forceFlag = '-c';
      executeCWheel();
    });
  } else {
    outputFileName = path.join(path.dirname(currentFile), `${basename}.csml`);
    forceFlag = '-x';
    executeCWheel();
  }

  function executeCWheel() {
    const cwheelCommand = `cwheel ${forceFlag} -o ${outputFileName} ${currentFile}`;

    exec(cwheelCommand, (error, stdout, stderr) => {
      if (error) {
        vscode.window.showErrorMessage(`Error executing command: ${error.message}`);
        return;
      }

      vscode.workspace.openTextDocument(outputFileName).then(doc => {
        vscode.window.showTextDocument(doc);
      });

      if (savedCursor && activeEditor) {
        activeEditor.selection = new vscode.Selection(savedCursor, savedCursor);
      }
    });
  }
}

export function activate(context: vscode.ExtensionContext) {
  context.subscriptions.push(vscode.commands.registerCommand('cwheel.cycle', cycle));

  context.subscriptions.push(vscode.commands.registerCommand('cwheel.cycleKeybinding', () => {
    cycle();
  }));
}

