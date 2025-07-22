import FoundationModels
import Playgrounds
import SwiftUI

@Observable
class ChatEngine {
  private let model = SystemLanguageModel.default
  private let session: LanguageModelSession
  private let conversation: Conversation

  var isAvailable: Bool {
    switch model.availability {
    case .available:
      return true
    default:
      return false
    }
  }

  var conversationHistory: String {
    conversation.sortedMessages.map {
      "Role: \($0.role.rawValue)\nContent: \($0.content)"
    }.joined(separator: "\n\n")
  }

  var conversationHistorySize: Int {
    conversationHistory.components(separatedBy: .whitespacesAndNewlines).count
  }

  private var estimatedTokenCount: Int {
    // Rough estimation: 1 token ≈ 0.75 words for English
    Int(Double(conversationHistorySize) / 0.75)
  }

  private let maxTokens = 4096
  private let safeTokenLimit = 3500

  init(conversation: Conversation) {
    self.conversation = conversation
    session = LanguageModelSession(tools: [WebAnalyserTool()]) {
      """
      You're a helpful chatbot. The user will send you messages, and you'll respond to them.
      Be short, it's a chat application.
      You can also summarize the conversation when asked to.
      Each message will have a role, either user, assistant or system for initial conversation configuration.
      """
    }
  }

  func prewarm() {
    session.prewarm()
  }

  func respondTo() async -> LanguageModelSession.ResponseStream<MessageGenerable>? {
    if estimatedTokenCount < safeTokenLimit {
      return session.streamResponse(generating: MessageGenerable.self) {
        """
        Here is the conversation history:
        \(conversationHistory)
        Respond with the assistant role to the user last message.
        If there is a URL in the user's request, use the WebAnalyserTool to analyse the webpage and add the attachment to the message.
        Don't include any WebPageMetadata property in the response if thre is no URL in the user's message.
        """
      }
    } else {
      return session.streamResponse(generating: MessageGenerable.self) {
        """
        Here is the conversation summary:
        \(conversation.summary ?? "No summary available")
        And the last message from the user:
        \(conversation.messages.last?.content ?? "No message available")
        Respond with the assistant role to the user last message.
        If there is a URL in the user's request, use the WebAnalyserTool to analyse the webpage and add the attachment to the message.
        Don't include any WebPageMetadata property in the response if thre is no URL in the user's message.
        """
      }
    }
  }

  func summarize() async -> LanguageModelSession.ResponseStream<String>? {
    if estimatedTokenCount < safeTokenLimit {
      return session.streamResponse {
        """
        Write a 1-2 sentence summary of what was discussed.
        Start directly with the topic itself.
        Example: "Swift programming techniques and best practices for error handling."
        DO NOT start with phrases like "The conversation is about" or "The discussion covers".

        Conversation to summarize:
        \(conversationHistory)
        """
      }
    } else {
      return session.streamResponse {
        """
        Update the summary to include new information, keeping it to 1-2 sentences.
        Start directly with the topic itself.
        DO NOT start with phrases like "The conversation is about" or "The discussion covers".

        Previous summary:
        \(conversation.summary ?? "No summary available")

        Latest message:
        \(conversation.messages.last?.content ?? "No message available")
        """
      }
    }
  }

  /// Send a message as any Role, optionally with webpage metadata
  /// This demonstrates advanced usage of FoundationModels allowing
  /// creation of messages with dynamic attachments and roles.
  func sendMessage(as role: Role, content: String, metadata: WebPageMetadata? = nil) {
    let message = Message(
      content: content,
      role: role,
      timestamp: Date(),
      attachementTitle: metadata?.title,
      attachementDescription: metadata?.description,
      attachementThumbnail: metadata?.thumbnail
    )
    conversation.messages.append(message)
    // Use your persistence mechanism here, e.g., saving to modelContext if available
  }

  /// Attach dynamic webpage metadata to an assistant message (simulated example)
  /// Illustrates enriching assistant responses with webpage previews using FoundationModels.
  func respondWithWebPageAnalysis(content: String, url: String) {
    let meta = WebPageMetadata(
      title: "Preview of: \(url)",
      thumbnail: "https://example.com/favicon.ico",
      description: "Auto-generated preview for \(url)."
    )
    sendMessage(as: .assistant, content: content, metadata: meta)
  }

  /// Inject a system message into the conversation
  /// Useful for adding system-level instructions or context dynamically.
  func injectSystemMessage(_ content: String) {
    sendMessage(as: .system, content: content)
  }
}
