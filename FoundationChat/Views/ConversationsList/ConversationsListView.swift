import SwiftData
import SwiftUI

struct ConversationsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var conversations: [Conversation]
    
    @State private var path: [Conversation] = []
    
    private var sortedConversations: [Conversation] {
        conversations.sorted(by: { $0.lastMessageTimestamp > $1.lastMessageTimestamp })
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(sortedConversations) {
                    conversation in
                    NavigationLink(value: conversation) {
                        ConversationRowView(conversation: conversation)
                            .swipeActions {
                                Button(role: .destructive) {
                                    modelContext.delete(conversation)
                                    try? modelContext.save()
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                Button {
                                    modelContext.delete(conversation)
                                    try? modelContext.save()
                                } label: {
                                    Label("Report", systemImage: "exclamationmark.triangle")
                                }
                                .tint(.yellow.dark)
                            }
                    }
                }
                .listSectionSeparator(.hidden, edges: .top)
            }
            .listStyle(.plain)
            .navigationDestination(for: Conversation.self) { conversation in
                ConversationDetailView(conversation: conversation)
                    .environment(ChatEngine(conversation: conversation))
            }
            .navigationTitle("Conversations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        let newConversation = Conversation(messages: [], summary: "New conversation")
                        modelContext.insert(newConversation)
                        try? modelContext.save()
                        path.append(newConversation)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}
