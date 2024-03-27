import XCTest
@testable import DiscoverKit

final class DiscoverKitTests: XCTestCase {
    let browser = DKService()
    let resolver = DKResolve()
    let addressor = DKAddress()
    let airplay = "_airplay._tcp"

    func testBrowsing() -> Void {
        let exp = expectation(description: UUID().uuidString)
        browser.browse(type: airplay) { result in
            switch result {
            case .success(let success): print(success)
            case .failure(let failure): print(failure) }
        }
        wait(for: [exp], timeout: 15.0)
    }
    
    func testResolving() -> Void {
        let exp = expectation(description: UUID().uuidString)
        resolver.resolve(name: "MacBook Pro 16", type: airplay) { result in
            switch result {
            case .success(let success): print(success)
            case .failure(let failure): print(failure) }
        }
        wait(for: [exp], timeout: 10.0)
    }
    
    func testAddress() -> Void {
        let exp = expectation(description: UUID().uuidString)
        addressor.address(name: "MacBook-Pro-16.local.", network: .ipv4) { result in
            switch result {
            case .success(let success): print(success)
            case .failure(let failure): print(failure) }
        }
        wait(for: [exp], timeout: 10.0)
    }
}
