//
//  GroupSearchView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 11/26/23.
//

import SwiftUI

struct GroupSearchView: View {
    @StateObject var viewModel = GroupSearchViewModel()
    @EnvironmentObject var groupsViewModel: GroupsViewModel
    
    var body: some View {
        VStack {
            TextField("Search for group handle", text: $viewModel.searchText)
                .frame(height: 44)
                .padding(.leading)
                .background(Color(.systemGroupedBackground))
                .onChange(of: viewModel.searchText) { newValue in
                    Task {
                        do {
                            try await viewModel.searchForGroups()
                        } catch {
                            print("Error: \(error)")
                        }
                    }
                }
            
            LazyVStack {
                ForEach(viewModel.groups) { group in
                    VStack {
                        HStack {
                            SquareGroupImageView(group: group, size: .small)

                            VStack(alignment: .leading) {
                                Text(group.name)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.theme.primaryText)
                                
                                Text("@\(group.handle)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.theme.secondaryText)
                            }
                            
                            Spacer()
                            
                            if !groupsViewModel.groups.contains(where: { $0.id == group.id }) {
                                Button("Request to Join") {
                                    
                                }
                                .padding()
                                .foregroundColor(.white) // Text color
                                .background(Color.blue) // System blue background
                                .cornerRadius(10)
                            }
                        }
                        
                        Divider()
                            .padding(.leading, 40)
                    }
                    .padding(.leading)
                }
            }
            
            Spacer()
        }
        .navigationTitle("Search for Groups")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.theme.background)
    }
}

//#Preview {
//    GroupSearchView()
//}
