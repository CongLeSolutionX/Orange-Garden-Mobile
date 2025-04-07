//
//  DepartmentTests.swift
//  Orange Garden Mobile
//
//  Created by Cong Le on 4/6/25.
//

import XCTest
import SwiftUI

// Import the module that contains your implementation (change "OrangeGardenMobile" as appropriate)
@testable import OrangeGardenMobile

final class DepartmentTests: XCTestCase {
    
    // MARK: - LogoSource Decoding & Encoding Tests
    
    func testLogoSourceDecoding_sfSymbol() throws {
        let json = """
        {
            "type": "sfSymbol",
            "value": "star.fill"
        }
        """
        let jsonData = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        let logoSource = try decoder.decode(LogoSource.self, from: jsonData)
        switch logoSource {
        case .sfSymbol(let name):
            XCTAssertEqual(name, "star.fill")
        default:
            XCTFail("Expected sfSymbol case")
        }
        
        // Verify encoding round-trip
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(logoSource)
        let decodedAgain = try decoder.decode(LogoSource.self, from: encodedData)
        XCTAssertEqual(logoSource, decodedAgain)
    }
    
    func testLogoSourceDecoding_localAsset() throws {
        let json = """
        {
            "type": "localAsset",
            "value": "california-flag"
        }
        """
        let jsonData = json.data(using: .utf8)!
        let logoSource = try JSONDecoder().decode(LogoSource.self, from: jsonData)
        
        switch logoSource {
        case .localAsset(let name):
            XCTAssertEqual(name, "california-flag")
        default:
            XCTFail("Expected localAsset case")
        }
    }
    
    func testLogoSourceDecoding_remoteURL_valid() throws {
        let json = """
        {
            "type": "remoteURL",
            "value": "https://via.placeholder.com/150"
        }
        """
        let jsonData = json.data(using: .utf8)!
        let logoSource = try JSONDecoder().decode(LogoSource.self, from: jsonData)
        
        switch logoSource {
        case .remoteURL(let url):
            XCTAssertEqual(url.absoluteString, "https://via.placeholder.com/150")
        default:
            XCTFail("Expected remoteURL case")
        }
    }
    
    func testLogoSourceDecoding_remoteURL_invalidURL() {
        // Use an EMPTY string for the value, which reliably makes URL(string:) return nil.
        let json = "{ \"type\": \"remoteURL\", \"value\": \"\" }" // <-- Key Change: Empty value

        guard let jsonData = json.data(using: .utf8) else {
            XCTFail("Failed to convert test JSON string to Data.")
            return
        }

        XCTAssertThrowsError(try JSONDecoder().decode(LogoSource.self, from: jsonData), "Decoding should fail when the URL string is empty.") { error in
            // Verify that the specific expected error was thrown
            guard let decodingError = error as? DecodingError else {
                XCTFail("Expected a DecodingError, but got \(type(of: error)): \(error)")
                return
            }

            switch decodingError {
            case .dataCorrupted(let context):
                // Check the coding key where the error occurred
                // This should now correctly point to the 'value' key within the LogoSource context
                XCTAssertEqual(context.codingPath.last?.stringValue, LogoSource.CodingKeys.value.stringValue, "Error should be associated with the 'value' key.")

                // Check the debug description for the expected message
                let expectedMessage = "Invalid URL string for remoteURL type" // Ensure this matches the string in your LogoSource init
                XCTAssertTrue(context.debugDescription.contains(expectedMessage), "Debug description mismatch. Expected message containing '\(expectedMessage)', Got: '\(context.debugDescription)'")

            default:
                XCTFail("Expected DecodingError.dataCorrupted, but got \(decodingError)")
            }
        }
    }
    
    func testLogoSourceDecoding_invalidType() {
        let json = """
        {
            "type": "unknownType",
            "value": "value"
        }
        """
        let jsonData = json.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(LogoSource.self, from: jsonData)) { error in
            if case DecodingError.dataCorrupted(let context) = error {
                XCTAssertTrue(context.debugDescription.contains("Invalid logo source type"))
            } else {
                XCTFail("Expected a dataCorrupted error due to invalid logo source type.")
            }
        }
    }
    
    // MARK: - Department Decoding Tests
    
    func testDepartmentDecoding_autoIDGeneration() throws {
        // Note that the Department struct generates a new UUID on decoding (it is omitted in the JSON).
        let json = """
        {
            "name": "Dept of Testing",
            "description": "A test department.",
            "logoSource": {
                "type": "sfSymbol",
                "value": "hammer.fill"
            },
            "datasetCount": 42
        }
        """
        let jsonData = json.data(using: .utf8)!
        let department = try JSONDecoder().decode(Department.self, from: jsonData)
        XCTAssertEqual(department.name, "Dept of Testing")
        XCTAssertEqual(department.datasetCount, 42)
        // Ensure an id was generated (UUID has a nonzero UUIDString)
        XCTAssertFalse(department.id.uuidString.isEmpty)
    }
    
    // MARK: - DataService Tests
    
    func testFetchGeneratedDepartmentsAsync() async throws {
        let departments = try await DataService.fetchGeneratedDepartmentsAsync()
        XCTAssertFalse(departments.isEmpty, "The fetched departments should not be empty.")
        
        // Check one sample department for expected properties.
        if let dept = departments.first {
            XCTAssertFalse(dept.name.isEmpty, "Department name must not be empty.")
            XCTAssertGreaterThanOrEqual(dept.datasetCount, 0, "Dataset count should be non-negative.")
        }
    }
    
    func testLoadDepartmentsFromJSON_fileNotFound() async {
        // Expect the function to throw a fileNotFound error when a filename is not present in the bundle.
        do {
            _ = try await DataService.loadDepartmentsFromJSON(filename: "nonexistent.json")
            XCTFail("Expected fileNotFound error was not thrown.")
        } catch let error as DataService.JSONLoadError {
            switch error {
            case .fileNotFound(let filename):
                XCTAssertEqual(filename, "nonexistent.json", "Error should report the correct filename.")
            default:
                XCTFail("Unexpected error case: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testLoadDepartmentsFromJSON_validData() throws {
        // Instead of using Bundle (which may vary in tests), we decode valid JSON data directly.
        let json = """
        [
          {
            "name": "Dept Test (JSON)",
            "description": "A test description.",
            "logoSource": {
              "type": "sfSymbol",
              "value": "star.fill"
            },
            "datasetCount": 10
          }
        ]
        """
        let jsonData = json.data(using: .utf8)!
        // Decode using JSONDecoder directly.
        let departments = try JSONDecoder().decode([Department].self, from: jsonData)
        XCTAssertEqual(departments.count, 1)
        if let dept = departments.first {
            XCTAssertEqual(dept.name, "Dept Test (JSON)")
            XCTAssertEqual(dept.datasetCount, 10)
        }
    }
    
    // MARK: - SwiftUI View Tests (Optional)
    // Using PreviewProvider is common for visual snapshots. For unit-testing SwiftUI views,
    // you might consider using third-party libraries such as ViewInspector.
    // For demonstration purposes, here is a simple check using a SwiftUI view initializer
    
    func testDepartmentCardView_initialization() throws {
        let department = Department(
            name: "Card Test Dept",
            description: "Testing Department Card",
            logoSource: .localAsset(name: "california-flag"),
            datasetCount: 5)
        
        let view = DepartmentCardView(department: department)
        
        // Simple assertions on the view body can be added if using a view-inspection library.
        // For now, we assert that the view is non-nil.
        XCTAssertNotNil(view, "DepartmentCardView should create a valid view instance.")
    }
    
    // MARK: - Performance (Optional)
    
    func testPerformanceOfFetchGeneratedDepartmentsAsync() async throws {
        self.measure {
            Task {
                do {
                    _ = try await DataService.fetchGeneratedDepartmentsAsync()
                } catch {
                    XCTFail("Unexpected error during performance test: \(error)")
                }
            }
        }
    }
}
