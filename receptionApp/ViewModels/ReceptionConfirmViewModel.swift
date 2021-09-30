import Foundation
import Combine

class ReceptionConfirmViewModel: ObservableObject, DepecdsOnSlackChatPostMessageRepository {
    @Published var isPushActive: Bool
    @Published var error: Error?
    @Published var user: User?
    @Published var buttonType: ButtonType
    @Published var companyName: String
    @Published var visitorName: String
    @Published var guestCount: Int
    var cancellables = [AnyCancellable]()
    
    init(buttonType: ButtonType, user: User?, companyName: String, visitorName: String, guestCount: Int) {
        isPushActive = false
        self.buttonType = buttonType
        self.user = user
        self.companyName = companyName
        self.visitorName = visitorName
        self.guestCount = guestCount
    }
    
    func postSlack() {
        slackChatPostMessageRepository
            .create(parameter: ["channel": "C026XDHNL7P", "text": text()])
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.error = error
                    }
                }
            }, receiveValue: {
                DispatchQueue.main.async {
                    self.isPushActive = true
                }
            })
            .store(in: &cancellables)
    }
    
    private func text() -> String {
        let mention = user != nil ? "<@\(user?.id ?? "")>" : "<!here>"
        let companyText = !companyName.isEmpty ? " *\(companyName)* の" : ""
        let guestCountText = guestCount != 0 ? " *\(guestCount)* 名で" : ""
        return "\(mention)\n *「\(buttonType.title())」* ボタンから\(companyText) *\(visitorName)様* が\(guestCountText)来社されました"
    }
}
