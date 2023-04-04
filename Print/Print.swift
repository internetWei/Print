//
//  Utils.swift
//  Print
//
//  Created by LL on 2023/4/3.
//


public enum Alignment {
    case center
    case left
    case right
}

/*
 * 制作纯文本表格。
 * 输入：[
 * ["", "total:", "average:", "max:", "min:", "extreme:", "array:"],
 * ["Test1(ms)", "392.1587", "38.7631", "46.2630", "35.7909", "10.4721", "42.8520 40.6669\n46.2630 43.3030\n35.8280 36.7039\n36.3150 38.6240\n35.8119 35.7909"],
 * ["Test2(ms)", "365.0352", "36.1376", "41.6840", "34.2500", "7.4340", "36.7610 41.6840\n35.8940 34.2500\n34.6791 35.1419\n35.0580 35.1590\n35.5470 40.8610"],
 * ]
 * 输出：
  ┌─────────┬───────────────────┬───────────────────┐
  │         │     Test1(ms)     │     Test2(ms)     │
  ├─────────┼───────────────────┼───────────────────┤
  │  total: │     392.1587      │     365.0352      │
  ├─────────┼───────────────────┼───────────────────┤
  │ average:│      38.7631      │      36.1376      │
  ├─────────┼───────────────────┼───────────────────┤
  │   max:  │      46.2630      │      41.6840      │
  ├─────────┼───────────────────┼───────────────────┤
  │   min:  │      35.7909      │      34.2500      │
  ├─────────┼───────────────────┼───────────────────┤
  │ extreme:│      10.4721      │      7.4340       │
  ├─────────┼───────────────────┼───────────────────┤
  │         │  42.8520 40.6669  │  36.7610 41.6840  │
  │         │  46.2630 43.3030  │  35.8940 34.2500  │
  │  array: │  35.8280 36.7039  │  34.6791 35.1419  │
  │         │  36.3150 38.6240  │  35.0580 35.1590  │
  │         │  35.8119 35.7909  │  35.5470 40.8610  │
  └─────────┴───────────────────┴───────────────────┘
 */
public func plainTextTable(columns: [[String]], alignment: Alignment = .center, space: Int = 2) -> String {
    if columns.isEmpty { return "" }
    
    var rows: [[String]] = []
    var widths: [Int] = []
    var heights: [Int] = []
    var caches: [String:[String]] = [:]
    
    // 根据列数据获取行数据、宽度数组、高度数组。
    do {
        for column in columns {
            var maxWidth = 0
            for (index, content) in column.enumerated() {
                // 将content按照换行符分割
                let lines = content.components(separatedBy: .newlines).filter{!$0.isEmpty}
                if lines.count > 1 {
                    caches[content] = lines
                }
                let textWidth = lines.map {$0.count}.max() ?? 0
                maxWidth = max(maxWidth, textWidth)
                
                var textHeight = index < heights.count ? heights[index] : 0
                textHeight = max(textHeight, lines.count)
                if index < heights.count {
                    heights[index] = textHeight
                } else {
                    heights.append(textHeight)
                }
                 
                var row = index < rows.count ? rows[index] : []
                row.append(content)
                if index < rows.count {
                    rows[index] = row
                } else {
                    rows.append(row)
                }
            }
            
            if alignment == .center {
                maxWidth += space * 2
            } else {
                maxWidth += space
            }
            widths.append(maxWidth)
        }
    }
    
    
    var table = ""
    
    // 绘制第1行(类似这样：┌─────────┬───────────────────┬───────────────────┐)。
    do {
        let last = widths.count - 1
        for (index, width) in widths.enumerated() {
            table += ("─" * width)
            if index == last {
                table += "┐"
            } else {
                table += "┬"
            }
        }
        table = "┌" + table + "\n"
    }
    
    // 逐行绘制。
    for (line, row) in rows.enumerated() {
        let maxHeight = heights[line]
        
        for i in 0..<maxHeight {
            var rowString = "│"
            for column in 0..<widths.count {
                let content = column < row.count ? row[column] : ""
                let width = widths[column]
                let lines = caches[content] ?? [content]
                
                // 将文本设置为垂直居中。
                let rowContent: String = {
                    let rowContent: String
                    if lines.count == maxHeight {// 上下没有间距，不需要设置垂直居中
                        rowContent = i < lines.count ? lines[i] : ""
                    } else {
                        let topSpace = (maxHeight - lines.count) / 2
                        if i >= topSpace && i < (topSpace + lines.count) {
                            let t_index = i - topSpace
                            rowContent = t_index < lines.count ? lines[t_index] : ""
                        } else {
                            rowContent = " " * width
                        }
                    }
                    return rowContent
                }()
                
                switch alignment {
                case .center:
                    let space = (width - rowContent.count) / 2
                    rowString += (" " * space) + rowContent + (" " * (width - rowContent.count - space)) + "│"
                case .left:
                    rowString += rowContent + (" " * (width - rowContent.count)) + "│"
                case .right:
                    rowString += (" " * (width - rowContent.count)) + rowContent + "│"
                }
            }
            
            table += rowString + "\n"
        }
        
        // 行内容绘制结束(行与行之间的分割符)。
        if line == rows.count - 1 {
            table += "└"
            for (index, width) in widths.enumerated() {
                table += ("─" * width)
                if index == widths.count - 1 {
                    table += "┘"
                } else {
                    table += "┴"
                }
            }
        } else {
            table += "├"
            for (index, width) in widths.enumerated() {
                table += ("─" * width)
                if index == widths.count - 1 {
                    table += "┤"
                } else {
                    table += "┼"
                }
            }
        }
        
        table += "\n"
    }
        
    return table
}

private extension String {
    static func *(left: String, right: Int) -> String {
        if left.isEmpty || right <= 0 { return "" }
        if right == 1 { return left }
        
        let totalLength = left.count * right
        var newString = left
        
        for _ in 0..<right {
            newString += left
            let currentLength = newString.count
            if currentLength == totalLength { break }
            let nextLength = currentLength * 2
            
            if nextLength > totalLength {
                let endIndex = newString.index(newString.startIndex, offsetBy: totalLength - currentLength)
                let subString = newString[..<endIndex]
                return newString + subString
            }
        }
        
        return newString
    }
    
    static func *=(left: inout String, right: Int) {
        left = left * right
    }
}
