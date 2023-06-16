//
//  FeedView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 2/18/23.
//

import Foundation
import SwiftUI

struct FeedView: View{
    @State var addingEvent: Bool = false
    
    init() {
        let newNavBarAppearance = customNavBarAppearance()
                
        let appearance = UINavigationBar.appearance()
        appearance.scrollEdgeAppearance = newNavBarAppearance
        appearance.compactAppearance = newNavBarAppearance
        appearance.standardAppearance = newNavBarAppearance
    }
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                ZStack {
                    Color.primary.ignoresSafeArea()
                    ScrollView(.vertical) {
                        VStack (spacing: 15) {
                            ForEach(Event.preview) { event in
                                EventView(event: event)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    
                    Button () {
                        addingEvent.toggle ()
                    } label: {
                        Image (systemName: "plus.circle.fill")
                            .resizable ()
                            .frame (width: UIScreen.main.bounds.width / 8, height: UIScreen.main.bounds.width / 8)
                            .foregroundColor (Color (red: 0.94, green: 0.73, blue: 0.75))
                    }.popover(isPresented: $addingEvent) {
                        AddEventView()
                    }
                    .position (x: UIScreen.main.bounds.width * 0.9, y: UIScreen.main.bounds.height * 0.73)
                }
                .navigationBarTitle("Stanford").navigationBarHidden(false)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
                .accentColor(CustomColors.primary)
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

func customNavBarAppearance() -> UINavigationBarAppearance {
    let customNavBarAppearance = UINavigationBarAppearance()
    
    // Apply a red background.
    customNavBarAppearance.configureWithOpaqueBackground()
    customNavBarAppearance.backgroundColor = .systemRed
    
    // Apply white colored normal and large titles.
    customNavBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
    customNavBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]


    // Apply white color to all the nav bar buttons.
    let barButtonItemAppearance = UIBarButtonItemAppearance(style: .plain)
    barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
    barButtonItemAppearance.disabled.titleTextAttributes = [.foregroundColor: UIColor.lightText]
    barButtonItemAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.label]
    barButtonItemAppearance.focused.titleTextAttributes = [.foregroundColor: UIColor.white]
    customNavBarAppearance.buttonAppearance = barButtonItemAppearance
    customNavBarAppearance.backButtonAppearance = barButtonItemAppearance
    customNavBarAppearance.doneButtonAppearance = barButtonItemAppearance
    
    return customNavBarAppearance
}

struct FeedViews_Preview: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}
