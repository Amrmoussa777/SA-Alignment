//
//  SourceEditorCommand.swift
//  SAAlignment
//
//  Created by Amr Moussa on 13/08/2021.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
        guard let firstSelection = invocation.buffer.selections.firstObject as? XCSourceTextRange,
               let lastSelection = invocation.buffer.selections.lastObject as? XCSourceTextRange else {
                   return
           }
        
        
          guard firstSelection.start.line < lastSelection.end.line else {
              return
          }
            
        alignEqualSigns(invocation.buffer.lines, invocation: invocation, in: firstSelection.start.line...lastSelection.end.line)
        
        
        
        completionHandler(nil)
    }
    
    private func alignEqualSigns(_ inputLines: NSMutableArray,invocation: XCSourceEditorCommandInvocation, in range: CountableClosedRange<Int>){
        guard range.upperBound < inputLines.count, range.lowerBound >= 0 else {
               return
           }
        var columnEqualIndexes:[String.Index] = []
        var newLines:[String]  = []
        
        let lines = inputLines.compactMap { $0 as? String }
        let selectedLines = Array(lines[range])
        
        
        
        for line in selectedLines{
            let equalIndex = line.firstIndex(of: "=")
            guard  let index = equalIndex else {
                columnEqualIndexes.append(.init(utf16Offset: 0, in: line))
                continue
            }
            columnEqualIndexes.append(index)
        }
       
        guard let maxIndex = columnEqualIndexes.max()else{return}
        
        selectedLines.forEach { line in
           let newLine =  addSpaces(line: line, max: maxIndex)
            newLines.append(newLine)
        }
        
        for rowIndex in range {
            inputLines[rowIndex] = newLines[rowIndex - range.lowerBound]
        }
        
        
    }
    
    private func addSpaces(line:String,max:String.Index) -> String{
        guard let equalIndex = line.firstIndex(of: "=") , equalIndex < max else{return line}
       
        let spacesIndexes = max.utf16Offset(in: line) - equalIndex.utf16Offset(in: line)
        let spacingString = String(repeating: " ", count: spacesIndexes)
        
        var ln = line
        ln.insert(contentsOf: spacingString, at: equalIndex)
        return ln
    }
    
}


fileprivate extension String {
    func indexOf(char: Character) -> Int? {
        return firstIndex(of: char)?.utf16Offset(in: self)
    }
}
