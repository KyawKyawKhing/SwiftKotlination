import XCTest
@testable import SwiftKotlination

final class TopStoriesTableViewControllerTest: XCTestCase {
    
    var sut: TopStoriesTableViewController!
    
    override func setUp() {
        super.setUp()
        
        guard let viewController = TopStoriesTableViewController.storyBoardInstance else {
            XCTFail("Expected view controller story board instantiation to succeed")
            return
        }
        
        sut = viewController
    }
    
    func testTopStoriesTableViewControllerFetchesTopStoriesSuccessfully() {
        let story = Story(section: "section", subsection: "subsection", title: "title", abstract: "abstract", byline: "byline", url: "url", multimedia: [])
        let topStoriesRepository = TopStoriesRepositoryMock(result: .success([story]))
        let imageRepository = ImageRepositoryMock(result: .failure(NetworkError.invalidResponse))
        sut.viewModel = TopStoriesViewModel(topStoriesRepository: topStoriesRepository, imageRepository: imageRepository)
        
        sut.viewDidLoad()
        sut.viewWillAppear(false)
        
        let tableViewIsNotEmpty = expectation(description: "Expected table view to not be empty")
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else {
                XCTFail("Self should not be nil")
                return
            }
            XCTAssertFalse(self.sut.tableView.visibleCells.isEmpty)
            tableViewIsNotEmpty.fulfill()
        }
        wait(for: [tableViewIsNotEmpty], timeout: 1)
        
        topStoriesRepository.result = .success([])
        sut.refreshControl?.sendActions(for: .valueChanged)
        
        let tableViewIsEmpty = expectation(description: "Expected table view to be empty")
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else {
                XCTFail("Self should not be nil")
                return
            }
            XCTAssertTrue(self.sut.tableView.visibleCells.isEmpty)
            tableViewIsEmpty.fulfill()
        }
        wait(for: [tableViewIsEmpty], timeout: 1)
    }
    
    func testTopStoriesTableViewControllerFetchesTopStoriesUnsuccessfully() {
        let story = Story(section: "section", subsection: "subsection", title: "title", abstract: "abstract", byline: "byline", url: "url", multimedia: [])
        let topStoriesRepository = TopStoriesRepositoryMock(result: .success([story]))
        let imageRepository = ImageRepositoryMock(result: .failure(NetworkError.invalidResponse))
        sut.viewModel = TopStoriesViewModel(topStoriesRepository: topStoriesRepository, imageRepository: imageRepository)
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        window.rootViewController = sut
        
        sut.viewDidLoad()
        sut.viewWillAppear(false)
        
        let tableViewIsNotEmpty = expectation(description: "Expected table view to not be empty")
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else {
                XCTFail("Self should not be nil")
                return
            }
            XCTAssertFalse(self.sut.tableView.visibleCells.isEmpty)
            tableViewIsNotEmpty.fulfill()
        }
        wait(for: [tableViewIsNotEmpty], timeout: 1)
        
        topStoriesRepository.result = .failure(NetworkError.invalidResponse)
        sut.refreshControl?.sendActions(for: .valueChanged)
        
        let alertControllerIsPresented = expectation(description: "Expected alert controller to be presented")
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else {
                XCTFail("Self should not be nil")
                return
            }
            XCTAssertFalse(self.sut.tableView.visibleCells.isEmpty)
            XCTAssertTrue(self.sut.presentedViewController is UIAlertController)
            alertControllerIsPresented.fulfill()
        }
        wait(for: [alertControllerIsPresented], timeout: 1)
    }
    
    func testTopStoriesTableViewControllerFetchesTopStoryImageSuccessfully() {
        guard
            let data = File("28DC-nafta-thumbLarge", .jpg).data,
            let expectedImage = UIImage(data: data) else {
                
                XCTFail("Invalid image")
                return
        }
        
        let imageRepository = ImageRepositoryMock(result: .success(data))
        let story = Story(section: "section", subsection: "subsection", title: "title", abstract: "abstract", byline: "byline", url: "url", multimedia: [Multimedia(url: "url", format: .small)])
        let topStoriesRepository = TopStoriesRepositoryMock(result: .success([story]))
        sut.viewModel = TopStoriesViewModel(topStoriesRepository: topStoriesRepository, imageRepository: imageRepository)
        
        sut.viewDidLoad()
        sut.viewWillAppear(false)
        
        let tableViewIsNotEmpty = expectation(description: "Expected table view to not be empty")
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else {
                XCTFail("Self should not be nil")
                return
            }
            XCTAssertFalse(self.sut.tableView.visibleCells.isEmpty)
            tableViewIsNotEmpty.fulfill()
        }
        wait(for: [tableViewIsNotEmpty], timeout: 1)
        
        let imageIsFetched = expectation(description: "Expected image to be fetched")
        DispatchQueue.main.async { [weak self] in
            guard
                let cell = self?.sut.tableView.visibleCells.first as? TopStoriesTableViewCell,
                let image = cell.multimediaImageView.image else {
                    
                    XCTFail("Invalid cell")
                    return
            }
            
            XCTAssertEqual(UIImagePNGRepresentation(expectedImage), UIImagePNGRepresentation(image))
            XCTAssertFalse(cell.multimediaImageView.isHidden)
            imageIsFetched.fulfill()
        }
        wait(for: [imageIsFetched], timeout: 1)
    }
    
    func testTopStoriesTableViewControllerFetchesTopStoryImageUnsuccessfully() {
        let story = Story(section: "section", subsection: "subsection", title: "title", abstract: "abstract", byline: "byline", url: "url", multimedia: [Multimedia(url: "url", format: .small)])
        let topStoriesRepository = TopStoriesRepositoryMock(result: .success([story]))
        let imageRepository = ImageRepositoryMock(result: .failure(NetworkError.invalidResponse))
        sut.viewModel = TopStoriesViewModel(topStoriesRepository: topStoriesRepository, imageRepository: imageRepository)
        
        sut.viewDidLoad()
        sut.viewWillAppear(false)
        
        let tableViewIsNotEmpty = expectation(description: "Expected table view to not be empty")
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else {
                XCTFail("Self should not be nil")
                return
            }
            XCTAssertFalse(self.sut.tableView.visibleCells.isEmpty)
            tableViewIsNotEmpty.fulfill()
        }
        wait(for: [tableViewIsNotEmpty], timeout: 1)
        
        let imageIsFetched = expectation(description: "Expected image to be fetched")
        DispatchQueue.main.async { [weak self] in
            guard let cell = self?.sut.tableView.visibleCells.first as? TopStoriesTableViewCell else {
                    XCTFail("Invalid cell")
                    return
            }
            
            XCTAssertTrue(cell.multimediaImageView.isHidden)
            imageIsFetched.fulfill()
        }
        wait(for: [imageIsFetched], timeout: 1)
    }
    
    func testTopStoriesTableViewControllerOpensStorySuccessfully() {
        let story = Story(section: "section", subsection: "subsection", title: "title", abstract: "abstract", byline: "byline", url: "url", multimedia: [])
        let topStoriesRepository = TopStoriesRepositoryMock(result: .success([story]))
        let imageRepository = ImageRepositoryMock(result: .failure(NetworkError.invalidResponse))
        let coordinator = CoordinatorMock(expectedMethods: [.openStory])
        sut = TopStoriesTableViewController()
        sut.viewModel = TopStoriesViewModel(topStoriesRepository: topStoriesRepository, imageRepository: imageRepository)
        sut.coordinator = coordinator
        
        sut.viewDidLoad()
        
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else {
                XCTFail("Self should not be nil")
                return
            }
            self.sut.tableView(self.sut.tableView, didSelectRowAt: IndexPath(item: 0, section: 0))
        }
        wait(for: [coordinator.expectation], timeout: 1)
    }
}
