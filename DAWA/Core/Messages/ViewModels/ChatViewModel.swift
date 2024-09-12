//
//  ChatViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 8/12/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import PhotosUI
import SwiftUI

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages = [Message]()
    @Published var selectedItem: PhotosPickerItem? {
        didSet { Task { try await loadImage() } }
    }
    @Published var messageImage: Image?
    
    private let service: ChatService
    private var uiImage: UIImage?
    
    init(activity: Activity) {
        self.service = ChatService(activity: activity)
        observeChatMessages()
    }
    
    func observeChatMessages() {
        Task {
            for await newMessages in service.messagesStream {
                self.messages.append(contentsOf: newMessages)
            }
        }
    }
    
    func sendMessage(_ messageText: String) async throws {
        if let image = uiImage {
            try await service.sendMessage(type: .image(image))
            messageImage = nil
        } else {
            try await service.sendMessage(type: .text(messageText))
        }
    }
    
    func nextMessage(forIndex index: Int) -> Message? {
        return index != messages.count - 1 ? messages[index + 1] : nil
    }
    
    func prevMessage(forIndex index: Int) -> Message? {
        return index != 0 ? messages[index - 1] : nil
    }
    
    func removeChatListener() {
        service.removeListener()
    }
}

extension ChatViewModel {
    
    func loadImage() async throws {
        guard let uiImage = try await PhotosPickerHelper.loadImage(fromItem: selectedItem) else { return }
        self.uiImage = uiImage
        messageImage = Image(uiImage: uiImage)
    }
}
