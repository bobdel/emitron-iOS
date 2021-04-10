// Copyright (c) 2019 Razeware LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
// distribute, sublicense, create a derivative work, and/or sell copies of the
// Software in any work that is designed, intended, or marketed for pedagogical or
// instructional purposes related to programming, coding, application development,
// or information technology.  Permission for such use, copying, modification,
// merger, publication, distribution, sublicensing, creation of derivative works,
// or sale is expressly withheld.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import SwiftUI

struct MainView: View {
  @EnvironmentObject var sessionController: SessionController
  @EnvironmentObject var dataManager: DataManager
  private let tabViewModel = TabViewModel()
  
  var body: some View {
    ZStack {
      contentView
        .background(Color.backgroundColor)
        .overlay(MessageBarView(messageBus: MessageBus.current), alignment: .bottom)
      // swiftlint:disable all
      Color.black
        .edgesIgnoringSafeArea(.all)
        .opacity(0.6)
      VStack {
        HStack {
          Image("razefaceAnnoyed")
          ZStack {
            Rectangle()
              .foregroundColor(.black)
              .frame(height: 5)
            HStack {
              Spacer()
                .frame(width: 50)
              Circle()
                .foregroundColor(.black)
                .frame(height: 10)
            }
          }
          Image("razefaceHappy")
        }
        Text("Congratulations on completing this course!")
          .foregroundColor(.black)
          .font(.headline)
          .multilineTextAlignment(.center)
          .padding(.bottom)

        Text("Next, take a moment and rate your experience with the app.")
          .foregroundColor(.black)
          .fontWeight(.light)
          .multilineTextAlignment(.center)
        Button {
          // Action Goes Here
        } label: {
          HStack {
            Spacer()
            Text("Leave a review")
              .foregroundColor(.white)
              .padding(.top, 5.0)
              .padding(.bottom, 7.0)
            Spacer()
          }
          .background(Color(.accent))
          .cornerRadius(10.0)
          .shadow(radius: 10, x: 5, y: 5)
        }
        Button {
          // Action Goes Here
        } label: {
          HStack {
            Spacer()
            Text("Not now")
              .foregroundColor(.black)
              .padding(.top, 5.0)
              .padding(.bottom, 7.0)
            Spacer()
          }
          .background(Color(.white))
          .cornerRadius(10.0)
          .shadow(radius: 10, x: 5, y: 5)
        }
      }
      .padding()
      .frame(maxWidth: 250)
      .background(Color.white)
      .cornerRadius(21.0)
      .shadow(radius: 10, x: 5, y: 5)

    }
  }
}
// swiftlint:disable all

// MARK: - private
private extension MainView {
  @ViewBuilder var contentView: some View {
    if !sessionController.isLoggedIn {
      LoginView()
    } else if case .loaded = sessionController.permissionState {
      if sessionController.hasPermissionToUseApp {
        tabBarView
      } else {
        LogoutView()
      }
    } else {
      PermissionsLoadingView()
    }
  }
  
  @ViewBuilder var tabBarView: some View {
    let downloadsView = DownloadsView(
      contentScreen: .downloads(permitted: sessionController.user?.canDownload ?? false),
      downloadRepository: dataManager.downloadRepository
    )
    
    let settingsView = SettingsView()

    switch sessionController.sessionState {
    case .online :
      let libraryView = LibraryView(
        filters: dataManager.filters,
        libraryRepository: dataManager.libraryRepository
      )
      
      let myTutorialsView = MyTutorialView(
        state: .inProgress,
        inProgressRepository: dataManager.inProgressRepository,
        completedRepository: dataManager.completedRepository,
        bookmarkRepository: dataManager.bookmarkRepository,
        domainRepository: dataManager.domainRepository
      )

      TabNavView(
        libraryView: libraryView,
        myTutorialsView: myTutorialsView,
        downloadsView: downloadsView,
        settingsView: settingsView
      )
      .environmentObject(tabViewModel)
    case .offline:
      TabNavView(libraryView: OfflineView(),
                 myTutorialsView: OfflineView(),
                 downloadsView: downloadsView,
                 settingsView: settingsView)
        .environmentObject(tabViewModel)
    case .unknown:
      LoadingView()
    }
  }
}
