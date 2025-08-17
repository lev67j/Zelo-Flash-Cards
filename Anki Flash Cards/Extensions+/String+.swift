//
//  String+.swift
//  Zelo AI
//
//  Created by Lev Vlasov on 2025-08-17.
//

import SwiftUI

extension Text {
    init(_ attributedString: NSAttributedString) {
        self.init("")
        var text = self
        attributedString.enumerateAttributes(in: NSRange(location: 0, length: attributedString.length)) { attributes, range, _ in
            let string = attributedString.attributedSubstring(from: range).string
            var modifiedText = Text(string)
            
            // Применяем шрифты
            if let font = attributes[.font] as? UIFont {
                let swiftUIFont: Font
                if font == UIFont.boldSystemFont(ofSize: 16) {
                    swiftUIFont = .system(size: 16, weight: .bold)
                } else if font == UIFont.italicSystemFont(ofSize: 16) {
                    swiftUIFont = .system(size: 16, weight: .regular, design: .default).italic()
                } else if font.fontName.contains("Menlo") {
                    swiftUIFont = .system(size: 14, design: .monospaced)
                } else {
                    swiftUIFont = .system(size: 16)
                }
                modifiedText = modifiedText.font(swiftUIFont)
            }
            
            // Применяем цвет (для кода)
            if let color = attributes[.foregroundColor] as? UIColor {
                modifiedText = modifiedText.foregroundColor(Color(color))
            }
            
            text = text + modifiedText
        }
        self = text
    }
}

extension String {
    private struct Replacement {
        let fullRange: NSRange
        let contentRange: NSRange
        let replacementText: String
        let attributes: [NSAttributedString.Key: Any]
    }
    
    func parseMarkdownToAttributedString() -> NSAttributedString {
        // Если строка пустая, возвращаем пустую строку с дефолтным шрифтом
        if self.isEmpty {
            return NSAttributedString(string: "", attributes: [.font: UIFont.systemFont(ofSize: 16)])
        }
        
        let attributedString = NSMutableAttributedString(string: self)
        
        // Шрифты для стилей
        let boldFont = UIFont.boldSystemFont(ofSize: 16)
        let italicFont = UIFont.italicSystemFont(ofSize: 16)
        let codeFont = UIFont(name: "Menlo-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        let regularFont = UIFont.systemFont(ofSize: 16)
        
        // Регулярные выражения для Markdown
        let patterns = [
            ("\\*\\*([^*]*)\\*\\*", [NSAttributedString.Key.font: boldFont]), // Жирный
            ("\\*([^*]*)\\*", [NSAttributedString.Key.font: italicFont]), // Курсив
            ("`([^`]*)`", [NSAttributedString.Key.font: codeFont, NSAttributedString.Key.foregroundColor: UIColor.systemGray]), // Код
        ]
        
        var replacements: [Replacement] = []
        
        // Собираем все замены и атрибуты
        for (pattern, attributes) in patterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
                let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
                
                for match in matches {
                    let contentRange = match.range(at: 1)
                    let fullRange = match.range
                    
                    // Проверяем валидность диапазонов
                    guard contentRange.location != NSNotFound,
                          fullRange.location != NSNotFound,
                          contentRange.location + contentRange.length <= self.utf16.count,
                          fullRange.location + fullRange.length <= self.utf16.count,
                          let swiftContentRange = Range(contentRange, in: self) else {
                        continue
                    }
                    
                    let replacementText = String(self[swiftContentRange])
                    replacements.append(Replacement(
                        fullRange: fullRange,
                        contentRange: contentRange,
                        replacementText: replacementText,
                        attributes: attributes
                    ))
                }
            } catch {
                print("Regex error: \(error)")
                // В случае ошибки regex возвращаем строку без изменений
                return NSAttributedString(string: self, attributes: [.font: regularFont])
            }
        }
        
        // Сортируем замены по убыванию позиции
        let sortedReplacements = replacements.sorted { $0.fullRange.location > $1.fullRange.location }
        
        // Применяем замены текста с проверкой
        var currentLength = attributedString.length
        for replacement in sortedReplacements {
            guard replacement.fullRange.location >= 0,
                  replacement.fullRange.location + replacement.fullRange.length <= currentLength else {
                print("Skipping invalid replacement range: \(replacement.fullRange) for text: \(attributedString.string)")
                continue
            }
            attributedString.replaceCharacters(in: replacement.fullRange, with: replacement.replacementText)
            currentLength -= (replacement.fullRange.length - replacement.replacementText.utf16.count)
        }
        
        // Применяем атрибуты с проверкой
        currentLength = attributedString.length
        for replacement in sortedReplacements {
            var adjustedRange = replacement.contentRange
            let offset = replacement.fullRange.length - replacement.replacementText.utf16.count
            adjustedRange.location -= sumOfPreviousOffsets(replacements: sortedReplacements, currentLocation: replacement.fullRange.location, offset: offset)
            guard adjustedRange.location >= 0,
                  adjustedRange.location + adjustedRange.length <= currentLength else {
                print("Skipping invalid attribute range: \(adjustedRange) for text: \(attributedString.string)")
                continue
            }
            attributedString.addAttributes(replacement.attributes, range: adjustedRange)
        }
        
        // Устанавливаем шрифт по умолчанию, если строка не пустая
        if attributedString.length > 0 {
            attributedString.addAttributes([.font: regularFont], range: NSRange(location: 0, length: attributedString.length))
        }
        
        return attributedString
    }
    
    private func sumOfPreviousOffsets(replacements: [Replacement], currentLocation: Int, offset: Int) -> Int {
        var totalOffset = 0
        for replacement in replacements {
            if replacement.fullRange.location > currentLocation {
                totalOffset += replacement.fullRange.length - replacement.replacementText.utf16.count
            }
        }
        return totalOffset
    }
}
