import SwiftUI

struct ConversationRowView: View {
  let conversation: Conversation

  var body: some View {
      VStack {
          HStack(alignment: .center) {
              VStack(alignment: .leading) {
                  Text(conversation.messages.last?.role.rawValue ?? "Unknown")
                      .font(.headline)
                      .fontWeight(.bold)
                  Text(conversation.summary ?? "No summary")
                      .font(.subheadline)
                      .foregroundStyle(.secondary)
                      .contentTransition(.interpolate)
              }
              .animation(.bouncy, value: conversation.summary)
              Spacer()
              Text(
                Date(
                    timeIntervalSince1970: conversation.messages.last?.timestamp.timeIntervalSince1970 ?? 0
                ).formatted(
                    date: .omitted, time: .shortened)
              )
              .font(.caption)
              .foregroundStyle(.secondary)
          }
//          HStack {
//              Spacer()
//              VStack {
//                  Image(systemName: "chevron.right")
//                  Text(chatEngine.conversationHistory)
//                      .font(.subheadline)
//                      .foregroundStyle(Color.secondary)
//              }
//          }
//          .padding(.top, 16)
      }
  }
}
