//
//  MemberRequestsViewModel.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 09/30/24.
//

import Foundation

@MainActor
class MemberRequestsViewModel: ObservableObject {
    @Published var requests: [MemberRequest] = []

    // Function to fetch member requests for a given group
    func fetchRequests(groupId: String) async {
        do {
            self.requests = try await GroupService.fetchMemberRequests(groupId: groupId)
        } catch {
            print("Error fetching member requests: \(error)")
        }
    }

    // Function to accept a member request
    func acceptRequest(userId: String, groupId: String) async throws {
        do {
            try await GroupService.joinGroup(uid: userId, groupId: groupId)
        } catch {
            print("Error accepting request: \(error)")
            throw error
        }
    }


    // Function to reject a member request
    func rejectRequest(requestId: String, groupId: String) async throws {
        do {
            print("Rejecting request")
            try await GroupService.rejectMemberRequest(requestId: requestId, groupId: groupId)
        } catch {
            print("Error rejecting request: \(error)")
            throw error
        }
    }
}
