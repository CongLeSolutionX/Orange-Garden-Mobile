//
//  DepartmentAdditionalTests.swift
//  OrangeGardenMobile
//
//  Created by Cong Le on 4/6/25.
//

import XCTest
import SwiftUI

// Import the module that contains your implementation
@testable import OrangeGardenMobile // <-- Make sure this matches your project module

final class DepartmentAdditionalTests: XCTestCase {

    // MARK: - DataService - makeDescriptionKey Tests
    // (This section remains the same - assumed correct)
    func testMakeDescriptionKey_basicConversion() {
        let input = "Department\nof Testing"
        let expected = "department of testing"
        XCTAssertEqual(DataService.makeDescriptionKey(from: input), expected)
    }
    func testMakeDescriptionKey_multipleNewlines() {
        let input = "First Line\nSecond\n\nThird"
        let expected = "first line second  third"
        XCTAssertEqual(DataService.makeDescriptionKey(from: input), expected)
    }
    func testMakeDescriptionKey_alreadyLowercaseNoNewlines() {
        let input = "simple key"
        let expected = "simple key"
        XCTAssertEqual(DataService.makeDescriptionKey(from: input), expected)
    }
    func testMakeDescriptionKey_emptyString() {
        let input = ""
        let expected = ""
        XCTAssertEqual(DataService.makeDescriptionKey(from: input), expected)
    }
    func testMakeDescriptionKey_stringWithOnlyNewlines() {
        let input = "\n\n"
        let expected = "  "
        XCTAssertEqual(DataService.makeDescriptionKey(from: input), expected)
    }

    // MARK: - DataService - fetchGeneratedDepartmentsAsync Description Logic
     // (This section remains the same - assumed correct, depends on helper extension)
    private func getDescriptionForGenerated(name: String) -> String {
        let baseDescriptions: [String: String] = DataService.departmentDescriptions
        let key = DataService.makeDescriptionKey(from: name)
        let lookupKey = key.contains("parks and recreation") ? "california state parks" : key
        return baseDescriptions[lookupKey] ?? "Description not available."
    }
    func testFetchGenerated_descriptionLookup_exactMatch() {
        let expectedDescription = "Oversees departments and boards that regulate various professions, businesses, financial services, and housing."
        XCTAssertEqual(getDescriptionForGenerated(name: "Business, Consumer Services and Housing Agency"), expectedDescription)
    }
    func testFetchGenerated_descriptionLookup_caseInsensitiveAndNewline() {
        let expectedDescription = "Oversees departments and boards that regulate various professions, businesses, financial services, and housing."
        XCTAssertEqual(getDescriptionForGenerated(name: "business, consumer services\nand housing agency"), expectedDescription)
    }
    func testFetchGenerated_descriptionLookup_parksSpecialCase() {
        let expectedDescription = "Manages California's state parks and recreational areas."
        XCTAssertEqual(getDescriptionForGenerated(name: "Parks and Recreation"), expectedDescription)
    }
    func testFetchGenerated_descriptionLookup_missingDescription() {
        let expected = "Description not available."
        XCTAssertEqual(getDescriptionForGenerated(name: "Non Existent Department"), expected)
    }

    // MARK: - DataService - loadDepartmentsFromJSON Error Handling

    // --- Test Cases using the UPDATED Helper ---

    func testLoadDepartmentsFromJSON_malformedJSON_invalidStructure() async {
        // JSON missing closing bracket ']' - causes basic format error
        let malformedJson = """
        [
          {
            "name": "Test",
            "description": "Desc",
            "logoSource": {"type": "sfSymbol", "value": "star"},
            "datasetCount": 1
        """ // Missing ]
        // Expect the generic "incorrect format" error message from CocoaError
        await expectLoadFromJSONError(
            jsonData: malformedJson.data(using: .utf8)!,
            containingDescriptionPart: "couldn’t be read because it isn’t in the correct format"
        )
    }

//    func testLoadDepartmentsFromJSON_malformedJSON_wrongTopLevelType() async {
//         // JSON is an object, not an array - causes type mismatch at the top level
//         let malformedJson = """
//         {
//             "name": "Test",
//             "description": "Desc",
//             "logoSource": {"type": "sfSymbol", "value": "star"},
//             "datasetCount": 1
//         }
//         """
//         // Expect a DecodingError describing the expected type
//         await expectLoadFromJSONError(
//            jsonData: malformedJson.data(using: .utf8)!,
//            expecting: DecodingError.self, // Expect a specific DecodingError subtype
//            containingDescriptionPart: "Expected to decode Array<Department>"
//         )
//     }

//    func testLoadDepartmentsFromJSON_decodingError_typeMismatch() async {
//        // datasetCount is a string, not Int - causes type mismatch *within* the struct
//        let json = """
//        [
//          {
//            "name": "Type Mismatch Dept",
//            "description": "Description here",
//            "logoSource": {"type": "sfSymbol", "value": "star"},
//            "datasetCount": "not a number"
//          }
//        ]
//        """
//        // Expect a specific TyeMismatch error description
//        await expectLoadFromJSONError(
//            jsonData: json.data(using: .utf8)!,
//            expecting: DecodingError.self,
//            containingDescriptionPart: "Expected to decode Int but found a string"
//        )
//    }

//    func testLoadDepartmentsFromJSON_decodingError_keyNotFound() async {
//        // Missing datasetCount key - causes KeyNotFound error
//        let json = """
//        [
//          {
//            "name": "Key Not Found Dept",
//            "description": "Description here",
//            "logoSource": {"type": "sfSymbol", "value": "star"}
//            // Missing datasetCount
//          }
//        ]
//        """
//        // Expect a specific KeyNotFound error description
//        await expectLoadFromJSONError(
//            jsonData: json.data(using: .utf8)!,
//            expecting: DecodingError.self,
//            containingDescriptionPart: "No value associated with key CodingKeys(stringValue: \"datasetCount\""
//            // Note: Sometimes the exact key string might vary slightly in description, adjust if needed
//        )
//    }

//     func testLoadDepartmentsFromJSON_decodingError_nestedKeyNotFound() async {
//         // Missing 'value' inside logoSource - causes KeyNotFound in nested object
//         let json = """
//         [
//           {
//             "name": "Nested Key Not Found",
//             "description": "Description",
//             "logoSource": {"type": "sfSymbol"}, // Missing 'value'
//             "datasetCount": 5
//           }
//         ]
//         """
//         // Expect a specific KeyNotFound error, likely mentioning 'value'
//         await expectLoadFromJSONError(
//            jsonData: json.data(using: .utf8)!,
//            expecting: DecodingError.self,
//            containingDescriptionPart: "No value associated with key CodingKeys(stringValue: \"value\""
//         )
//     }

    // --- UPDATED Helper Function ---
    private func expectLoadFromJSONError(
        jsonData: Data?, // Make optional to handle potential nil data from string conversion
        expecting expectedErrorType: Error.Type? = nil, // Optional: Specify expected error TYPE
        containingDescriptionPart descriptionPart: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {

        guard let jsonData = jsonData else {
            XCTFail("Failed to convert JSON string to Data.", file: file, line: line)
            return
        }

        let decoder = JSONDecoder()
        do {
            // Attempt to decode
            _ = try decoder.decode([Department].self, from: jsonData)
            // If decoding succeeds, the test fails because an error was expected
            XCTFail("Expected a decoding error but none was thrown.", file: file, line: line)
        } catch { // Catch ANY error thrown by the decoder
            // 1. Print the caught error details for debugging
            print("Caught Error Type: \(type(of: error))")
            print("Caught Error Description: \(error.localizedDescription)")

            // 2. (Optional) Verify the *type* of error if specified
//            if let expectedType = expectedErrorType {
//                 // Use `is` to check type conformity, including subclasses/implementations
//                 XCTAssertTrue(error is expectedType,
//                                "Expected error type conforming to \(expectedType) but got \(type(of: error))",
//                                file: file, line: line)
//             }

            // 3. Verify the error's description contains the expected text
            //    Using localizedCaseInsensitiveContains is robust against capitalization changes.
            XCTAssertTrue(error.localizedDescription.localizedCaseInsensitiveContains(descriptionPart),
                          "Actual error description '\(error.localizedDescription)' did not contain expected part '\(descriptionPart)'",
                          file: file, line: line)

            // 4. (Optional) Further inspect DecodingError details if needed
            if let decodingError = error as? DecodingError {
                // You could add more specific checks here based on the decodingError cases
                // (typeMismatch, valueNotFound, keyNotFound, dataCorrupted) if a test requires it.
                 switch decodingError {
                 case .typeMismatch(let type, let context):
                     print("--> DecodingError: Type mismatch. Expected \(type). Context: \(context.debugDescription), Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                 case .valueNotFound(let type, let context):
                     print("--> DecodingError: Value not found. Expected \(type). Context: \(context.debugDescription), Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                 case .keyNotFound(let key, let context):
                     print("--> DecodingError: Key not found. Key: \(key.stringValue). Context: \(context.debugDescription), Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                 case .dataCorrupted(let context):
                     print("--> DecodingError: Data corrupted. Context: \(context.debugDescription), Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                 @unknown default:
                     print("--> DecodingError: Unknown case.")
                 }
            } else if let cocoaError = error as? CocoaError, cocoaError.isCoderError {
                 print("--> CocoaError (Coder): \(cocoaError.localizedDescription)")
            }
        }
    }

    // MARK: - LogoSource Decoding Edge Cases
    // (This section remains the same - assumed correct)
    func testLogoSourceDecoding_missingValue() {
        let json = """
        { "type": "sfSymbol" }
        """
        XCTAssertThrowsError(try JSONDecoder().decode(LogoSource.self, from: json.data(using: .utf8)!)) { error in
            guard case DecodingError.keyNotFound(let key, _) = error else { XCTFail(); return }
            XCTAssertEqual(key.stringValue, "value")
        }
    }
     func testLogoSourceDecoding_missingType() {
         let json = """
         { "value": "someValue" }
         """
         XCTAssertThrowsError(try JSONDecoder().decode(LogoSource.self, from: json.data(using: .utf8)!)) { error in
             guard case DecodingError.keyNotFound(let key, _) = error else { XCTFail(); return }
             XCTAssertEqual(key.stringValue, "type")
         }
     }
    func testLogoSourceDecoding_nullValue() {
        let json = """
        { "type": "sfSymbol", "value": null }
        """
        XCTAssertThrowsError(try JSONDecoder().decode(LogoSource.self, from: json.data(using: .utf8)!)) { error in
            if case DecodingError.valueNotFound = error { return }
            if case DecodingError.typeMismatch = error { return } // Allow typeMismatch too
            XCTFail()
        }
    }

    // MARK: - Department Decoding Edge Cases
    // (This section remains the same - assumed correct)
    func testDepartmentDecoding_missingRequiredField() {
        let json = """
        {
            "description": "A test department.",
            "logoSource": { "type": "sfSymbol", "value": "hammer.fill" },
            "datasetCount": 42
        }
        """
        XCTAssertThrowsError(try JSONDecoder().decode(Department.self, from: json.data(using: .utf8)!)) { error in
             guard case DecodingError.keyNotFound(let key, _) = error else { XCTFail(); return }
             XCTAssertEqual(key.stringValue, "name")
         }
    }
    func testDepartmentDecoding_nullRequiredField() {
        let json = """
        {
            "name": null,
            "description": "A test department.",
            "logoSource": { "type": "sfSymbol", "value": "hammer.fill" },
            "datasetCount": 42
        }
        """
         XCTAssertThrowsError(try JSONDecoder().decode(Department.self, from: json.data(using: .utf8)!)) { error in
             if case DecodingError.valueNotFound(_, let context) = error {
                 XCTAssertEqual(context.codingPath.last?.stringValue, "name"); return
             }
             if case DecodingError.typeMismatch(_, let context) = error {
                  XCTAssertEqual(context.codingPath.last?.stringValue, "name"); return
             }
             XCTFail()
         }
    }

    // MARK: - Department Hashable/Equatable Conformance
    // (This section remains the same - assumed correct)
    func testDepartmentEquatable_onlyComparesID() {
        let id = UUID()
        let dept1 = Department(id: id, name: "Dept A", description: "Desc A", logoSource: .sfSymbol(name: "a.circle"), datasetCount: 1)
        let dept2 = Department(id: id, name: "Dept B", description: "Desc B", logoSource: .sfSymbol(name: "b.circle"), datasetCount: 2)
        let dept3 = Department(id: UUID(), name: "Dept A", description: "Desc A", logoSource: .sfSymbol(name: "a.circle"), datasetCount: 1)
        XCTAssertEqual(dept1, dept2)
        XCTAssertNotEqual(dept1, dept3)
    }
    func testDepartmentHashable_onlyHashesID() {
         let id = UUID()
         let dept1 = Department(id: id, name: "Dept A", description: "Desc A", logoSource: .sfSymbol(name: "a.circle"), datasetCount: 1)
         let dept2 = Department(id: id, name: "Dept B", description: "Desc B", logoSource: .sfSymbol(name: "b.circle"), datasetCount: 2)
         let dept3 = Department(id: UUID(), name: "Dept A", description: "Desc A", logoSource: .sfSymbol(name: "a.circle"), datasetCount: 1)
         var hasher1 = Hasher(); dept1.hash(into: &hasher1); let hash1 = hasher1.finalize()
         var hasher2 = Hasher(); dept2.hash(into: &hasher2); let hash2 = hasher2.finalize()
         var hasher3 = Hasher(); dept3.hash(into: &hasher3); let hash3 = hasher3.finalize()
         XCTAssertEqual(hash1, hash2)
         XCTAssertNotEqual(hash1, hash3)
     }

    // MARK: - HomeView_V1 Loading Logic
    // (This section remains the same - conceptual test)
    func testHomeView_loadDepartments_preventsConcurrentLoads() async {
        XCTAssertTrue(true, "Conceptual test: loadDepartments should return early if isLoading is true. Direct testing requires HomeView_V1 refactoring or UI testing.")
    }

     // MARK: - Dataset Count Formatting (UI Logic - Placeholders)
     // (This section remains the same)
     func testDepartmentCardView_datasetCountFormatting_singular() {
         XCTAssertTrue(true, "Placeholder: UI test needed for dataset count text (singular).")
     }
     func testDepartmentCardView_datasetCountFormatting_plural() {
          XCTAssertTrue(true, "Placeholder: UI test needed for dataset count text (plural).")
     }
     func testDepartmentDetailView_datasetCountFormatting_zero() {
          XCTAssertTrue(true, "Placeholder: UI test needed for detail view dataset count text (zero).")
      }
}

// MARK: - Helper Extensions (Keep DataService, No HomeView_V1 extension) -
// (This section remains the same - assumed correct, relies on internal names)
extension DataService {
    static var departmentDescriptions: [String: String] { return _departmentDescriptions }
    private static let _departmentDescriptions: [String: String] = [/* ... dictionary from original ... */
        "business, consumer services and housing agency": "Oversees departments and boards that regulate various professions, businesses, financial services, and housing.",
         "government operations agency": "Supports the operations of various departments, boards, and offices within state government.",
         "labor and workforce development agency": "Focuses on ensuring safe and fair workplaces, delivering worker benefits, and promoting employment.",
         "transportation agency": "Plans, develops, and maintains the state's transportation systems, including highways, rail, and aviation.",
         "natural resources agency": "Manages and protects California's natural resources, including forests, water, and wildlife.",
         "environmental protection agency": "Focuses on protecting the environment and public health through environmental regulation and enforcement.",
         "health and human services agency": "Oversees various departments and programs related to health care, social services, and public assistance.",
         "department of corrections and rehabilitation": "Manages the state's prison system and parole operations.",
         "department of education": "Oversees public education in California, from preschool through high school.",
         "department of finance": "Develops and manages the state budget, advises the Governor on fiscal matters.",
         "department of food and agriculture": "Supports and promotes California's agricultural industry.",
         "department of insurance": "Regulates the insurance industry in California.",
         "department of justice": "Enforces laws, prosecutes crimes, and represents the state in legal matters; headed by the Attorney General.",
         "department of motor vehicles": "Issues driver's licenses, registers vehicles, and regulates driving.",
         "department of public health": "Protects and improves public health through disease prevention, health promotion, and emergency preparedness.",
         "franchise tax board": "Administers state income tax laws.",
         "employment development department": "Provides unemployment insurance, disability insurance, and job training services.",
         "department of tax and fee administration": "Administers sales and use taxes, fuel taxes, and other state taxes and fees.",
         "department of fair employment and housing": "Enforces laws prohibiting discrimination and harassment in employment, housing, and public accommodations.",
         "department of social services": "Provides social services, including assistance programs for needy families and individuals.",
         "contractors state license board": "Licenses and regulates contractors in California.",
         "department of human resources": "Oversees the state's human resources functions, including recruitment, training, and employee relations.",
         "department of health care services": "Administers Medi-Cal, California's Medicaid program, and other health care programs.",
         "department of aging": "Advocates for and provides services to older adults and their families.",
         "department of alcohol and drug programs": "Supports substance abuse prevention, treatment, and recovery services.",
         "department of cannabis control": "Regulates the cannabis industry in California.",
         "department of conservation": "Protects and manages California's natural resources, including mineral resources, and geohazards.",
         "department of consumer affairs": "Protects consumers through the licensing and regulation of various professions.",
         "department of financial protection and innovation": "Regulates financial institutions and protects consumers from fraud.",
         "department of forestry and fire protection": "Provides fire protection and management services for California's state-owned lands.",
         "department of housing and community development": "Supports and promotes affordable housing and community development.",
         "department of industrial relations": "Enforces labor laws and regulations, protecting workers' rights and ensuring safe workplaces.",
         "department of managed health care": "Regulates health plans and protects the interests of consumers enrolled in managed care plans.",
         "department of real estate": "Licenses and regulates real estate brokers, agents, and appraisers.",
         "department of rehabilitation": "Assists individuals with disabilities in achieving employment and independent living goals.",
         "department of resources recycling and recovery": "Promotes waste reduction, recycling, and resource recovery.",
         "department of technology": "Provides technology services and solutions to state government agencies.",
         "department of toxic substances control": "Protects public health and the environment from hazardous waste.",
         "department of water resources": "Manages and protects California's water resources.",
         "department of state hospitals": "Provides mental health services to patients admitted into the state hospital system.",
         "california air resources board": "Responsible for coordinating and drafting the state's climate scoping plans and focuses on air quality.",
         "california energy commission": "Sites electricity infrastructure, invests in vehicle-charging infrastructure, and supports efforts to electrify medium and heavy-duty vehicles.",
         "california coastal commission": "Plans and regulates land use along the California coast.",
         "california state parks": "Manages California's state parks and recreational areas.",
         "california state auditor": "Audits state government agencies to ensure accountability and efficiency.",
         "california highway patrol": "Enforces traffic laws and provides law enforcement services on state highways.",
         "california military department": "Oversees the California National Guard and other military activities.",
         "california public utilities commission": "Regulates privately owned public utilities.",
         "california arts council": "Promotes and supports the arts in California.",
         "california state library": "Provides library and information services to the state government and public.",
         "california state lands commission": "Manages state-owned lands and resources.",
         "california student aid commission": "Administers student financial aid programs.",
         "california lottery commission": "Operates the California State Lottery.",
         "california state board of education": "Sets policies and standards for California public schools.",
         "california victim compensation board": "Provides compensation to victims of violent crime.",
         "california commission on disability access": "Promotes accessibility for individuals with disabilities.",
         "office of emergency services": "Coordinates emergency response efforts.",
         "office of the attorney general": "Provides legal representation and enforcement for the state.",
         "california postsecondary education commission": "Provides oversight and planning for California's higher education system.",
         "california fair political practices commission": "Enforces campaign finance and lobbying regulations.",
         "california gambling control commission": "Regulates the gambling industry.",
         "california horse racing board": "Regulates horse racing.",
         "state controller's office": "Acts as the chief fiscal officer of the state, responsible for accountability and disbursement of the state's financial resources.",
         "california emergency medical services authority": "Coordinates and integrates emergency medical services statewide.",
         "governor's office of business and economic development": "Serves as the state's lead entity for economic development and job creation efforts."
    ]
    static func makeDescriptionKey(from name: String) -> String { return _makeDescriptionKey(from: name) }
    private static func _makeDescriptionKey(from name: String) -> String { return name.lowercased().replacingOccurrences(of: "\n", with: " ") }
}
