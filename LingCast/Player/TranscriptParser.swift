
import Foundation
import NaturalLanguage

enum TranscriptParser {

    static func parse(_ script: String) -> [TranscriptSentence] {
        let normalized = script
            .replacingOccurrences(of: "\r\n", with: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalized.isEmpty else {
            return []
        }

        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = normalized

        var sentences: [TranscriptSentence] = []

        tokenizer.enumerateTokens(
            in: normalized.startIndex..<normalized.endIndex
        ) { range, _ in

            let text = String(normalized[range])
                .trimmingCharacters(in: .whitespacesAndNewlines)

            if !text.isEmpty {
                sentences.append(
                    TranscriptSentence(
                        id: sentences.count,
                        english: text,
                        korean: "",
                        vocabulary: [],
                        spokenWord: ""
                    )
                )
            }

            return true
        }

        return sentences
    }
}

