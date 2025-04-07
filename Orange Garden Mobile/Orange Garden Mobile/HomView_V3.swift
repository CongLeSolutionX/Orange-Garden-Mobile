//
//  HomView_V3.swift
//  Orange Garden Mobile
//
//  Created by Cong Le on 4/6/25.
//

import SwiftUI
import Foundation // Needed for URL, Data, JSONDecoder

// --- Data Model ---

// Enum to represent different sources for the department logo
enum LogoSource: Hashable, Codable {
    case sfSymbol(name: String)
    case localAsset(name: String) // Assumes image is in Asset Catalog
    case remoteURL(url: URL)
    
    // Coding keys for JSON decoding/encoding
    enum CodingKeys: String, CodingKey {
        case type
        case value
    }
    
    // Custom Decodable Initializer
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        let value = try container.decode(String.self, forKey: .value)
        
        switch type {
        case "sfSymbol":
            self = .sfSymbol(name: value)
        case "localAsset":
            self = .localAsset(name: value)
        case "remoteURL":
            guard let url = URL(string: value) else {
                throw DecodingError.dataCorruptedError(forKey: .value, in: container, debugDescription: "Invalid URL string for remoteURL type")
            }
            self = .remoteURL(url: url)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid logo source type '\(type)'")
        }
    }
    
    // Custom Encodable function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .sfSymbol(let name):
            try container.encode("sfSymbol", forKey: .type)
            try container.encode(name, forKey: .value)
        case .localAsset(let name):
            try container.encode("localAsset", forKey: .type)
            try container.encode(name, forKey: .value)
        case .remoteURL(let url):
            try container.encode("remoteURL", forKey: .type)
            try container.encode(url.absoluteString, forKey: .value)
        }
    }
}

// Updated Department struct to use LogoSource
struct Department: Identifiable, Hashable, Codable {
    let id: UUID // Use UUID for Identifiable and Hashable
    let name: String
    let description: String
    let logoSource: LogoSource // Replaces logoSymbolName
    let datasetCount: Int
    
    // Make id non-codable or provide default for decoding if not in JSON
    enum CodingKeys: String, CodingKey {
        case name, description, logoSource, datasetCount
        // Exclude id from JSON, it will be generated on decode or passed if needed elsewhere
    }
    
    // Custom initializer for decoding (generate UUID if not present)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID() // Generate a new ID upon decoding
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.logoSource = try container.decode(LogoSource.self, forKey: .logoSource)
        self.datasetCount = try container.decode(Int.self, forKey: .datasetCount)
    }
    
    // Added explicit init for non-decoding scenarios & previews
    init(id: UUID = UUID(), name: String, description: String, logoSource: LogoSource, datasetCount: Int) {
        self.id = id
        self.name = name
        self.description = description
        self.logoSource = logoSource
        self.datasetCount = datasetCount
    }
    
    // Required for Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    // Required for Hashable conformance (Equatable)
    static func == (lhs: Department, rhs: Department) -> Bool {
        lhs.id == rhs.id
    }
}

// --- Data Service ---
struct DataService {
    private static let departmentDescriptions: [String: String] = [
        // (Dictionary content remains the same - no changes needed here)
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
    
    private static func makeDescriptionKey(from name: String) -> String {
        return name.lowercased().replacingOccurrences(of: "\n", with: " ")
    }
    
    // --- Option 1: Fetch Mock/Generated Data Async (Original approach adapted) ---
    static func fetchGeneratedDepartmentsAsync() async throws -> [Department] {
        print("Starting asynchronous fetch for generated/mock data...")
        try await Task.sleep(for: .seconds(1.0)) // Shorter delay for mock data
        
        // Base list demonstrating different LogoSource types
        // NOTE: Ensure 'california-flag' exists in your Asset Catalog for .localAsset
        // NOTE: Replace the placeholder URL with a real image URL for testing .remoteURL
        let baseDepartmentsRaw: [(name: String, logo: LogoSource, count: Int)] = [
            ("Department\nof State Hospitals", .sfSymbol(name: "cross.case.fill"), 5),
            ("Department\nof Tax & Fee Admin", .sfSymbol(name: "dollarsign.circle.fill"), 38),
            ("Department\nof Technology", .sfSymbol(name: "server.rack"), 15),
            ("Department\nof Toxic Substances", .sfSymbol(name: "testtube.2"), 2),
            ("Department\nof Water Resources", .localAsset(name: "ca-water-drop"), 546), // Example local asset
            ("Emergency Medical\nServices Authority", .sfSymbol(name: "staroflife.fill"), 3),
            ("Employment Development\nDepartment", .remoteURL(url: URL(string: "https://via.placeholder.com/150/0000FF/FFFFFF?Text=EDD")!), 17), // Example Remote URL
            ("Dept of Education", .sfSymbol(name: "book.closed.fill"), 20),
            ("Highway Patrol", .sfSymbol(name: "shield.lefthalf.filled"), 8),
            ("Parks and Recreation", .localAsset(name: "california-flag"), 75) // Example local asset
        ]
        
        var generatedDepartments: [Department] = []
        for deptData in baseDepartmentsRaw {
            let key = makeDescriptionKey(from: deptData.name)
            let lookupKey = key.contains("parks and recreation") ? "california state parks" : key
            let description = departmentDescriptions[lookupKey] ?? "Description not available."
            
            generatedDepartments.append(Department(
                name: deptData.name,
                description: description,
                logoSource: deptData.logo, // Use the LogoSource directly
                datasetCount: deptData.count
            ))
        }
        
        print("Generated/mock data fetch completed successfully.")
        return generatedDepartments // Return only base for simplicity, remove duplication loop
    }
    
    // --- Option 2: Load Departments from Local JSON File ---
    enum JSONLoadError: Error, LocalizedError {
        case fileNotFound(String)
        case dataLoadingError(String)
        case decodingError(String, Error)
        
        var errorDescription: String? {
            switch self {
            case .fileNotFound(let filename): return "JSON file '\(filename)' not found in bundle."
            case .dataLoadingError(let filename): return "Could not load data from JSON file '\(filename)'."
            case .decodingError(let filename, let underlyingError): return "Failed to decode JSON from '\(filename)': \(underlyingError.localizedDescription)"
            }
        }
    }
    
    static func loadDepartmentsFromJSON(filename: String = "departments.json") async throws -> [Department] {
        print("Attempting to load departments from \(filename)...")
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            throw JSONLoadError.fileNotFound(filename)
        }
        
        guard let data = try? Data(contentsOf: url) else {
            throw JSONLoadError.dataLoadingError(filename)
        }
        
        do {
            let decoder = JSONDecoder()
            let departments = try decoder.decode([Department].self, from: data)
            print("Successfully decoded \(departments.count) departments from \(filename).")
            return departments
        } catch {
            print("JSON Decoding Error: \(error)") // Log detailed error
            throw JSONLoadError.decodingError(filename, error)
        }
    }
}

// --- New Logo Image View ---
// Handles displaying the image based on the LogoSource
struct LogoImageView: View {
    let source: LogoSource
    var size: CGFloat = 60 // Default size
    
    var body: some View {
        Group {
            switch source {
            case .sfSymbol(let name):
                Image(systemName: name)
                    .resizable()
                    .scaledToFit()
                    .symbolRenderingMode(.hierarchical) // Or .palette, .multicolor if applicable
            case .localAsset(let name):
                Image(name) // Assumes image exists in Asset Catalog
                    .resizable()
                    .scaledToFit()
            case .remoteURL(let url):
                // Use AsyncImage for remote URLs
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView() // Show progress indicator while loading
                            .frame(width: size, height: size)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    case .failure:
                        Image(systemName: "exclamationmark.triangle") // Show error placeholder
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.red)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
        .frame(height: size) // Apply frame to the Group or specific images
        .foregroundColor(.accentColor) // Default color, can be overridden
    }
}

// --- Card View ---
// Updated to use LogoImageView
struct DepartmentCardView: View {
    let department: Department
    
    var body: some View {
        VStack(spacing: 10) {
            LogoImageView(source: department.logoSource, size: 60) // Use the new view
                .padding(.top)
            
            Text(department.name)
                .font(.headline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("\(department.datasetCount) Dataset\(department.datasetCount == 1 ? "" : "s")")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 180)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// --- Department Detail View ---
// Updated to use LogoImageView
struct DepartmentDetailView: View {
    let department: Department
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 24) {
                LogoImageView(source: department.logoSource, size: 120) // Use the new view with larger size
                    .padding(.top, 30)
                
                Text(department.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                HStack {
                    Image(systemName: "doc.text.fill")
                    Text("\(department.datasetCount) Dataset\(department.datasetCount == 1 ? "" : "s") Available")
                }
                .font(.title3)
                .foregroundColor(.secondary)
                
                Divider()
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Function / Description")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text(department.description)
                        .font(.body)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Additional Information")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("This section could contain more details like key personnel, links to important resources, and access to specific open datasets managed by the \(department.name.replacingOccurrences(of: "\n", with: " ")).") // Cleaned up name here too
                        .font(.body)
                    Button("Visit Department Website (Placeholder)") {
                        print("Attempting to visit website for \(department.name.replacingOccurrences(of: "\n", with: " "))...")
                    }
                    .buttonStyle(.bordered)
                    .padding(.top)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(department.name.replacingOccurrences(of: "\n", with: " "))
        .navigationBarTitleDisplayMode(.inline)
    }
}

// --- Main Content View (Home View) ---
// Added state for controlling load mode
struct HomeView_V1: View {
    enum LoadMode {
        case generatedAsync // Original mock/generated data fetch
        case fromJSON       // Load from local JSON file
    }
    
    let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 150, maximum: 200))
    ]
    
    @State private var departments: [Department] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var currentLoadMode: LoadMode = .generatedAsync // Default load mode
    
    var body: some View {
        NavigationView {
            VStack { // Encapsulate content and potential pickers/buttons
                // Optional: Add a Picker to switch load modes
                Picker("Load Data From", selection: $currentLoadMode) {
                    Text("Generated Async").tag(LoadMode.generatedAsync)
                    Text("Local JSON").tag(LoadMode.fromJSON)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: currentLoadMode) { oldValue, newValue in
                    if newValue != oldValue {
                        Task { await loadDepartments() }
                    }
                }
                if isLoading {
                    ProgressView("Loading Departments...")
                        .scaleEffect(1.5)
                        .padding()
                        .frame(maxHeight: .infinity) // Center ProgressView
                } else if let errorMsg = errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .resizable().scaledToFit().frame(width: 60, height: 60).foregroundColor(.red)
                        Text("Failed to load departments").font(.title2).multilineTextAlignment(.center)
                        Text(errorMsg).font(.body).foregroundColor(.secondary).multilineTextAlignment(.center)
                        Button("Retry") {
                            Task { await loadDepartments() } // Use consistent load method
                        }
                        .buttonStyle(.borderedProminent).padding(.top)
                    }
                    .padding()
                    .frame(maxHeight: .infinity) // Center Error message
                } else if departments.isEmpty {
                    Text("No departments found.")
                        .foregroundColor(.secondary)
                        .frame(maxHeight: .infinity) // Center text
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(departments) { department in
                                NavigationLink(destination: DepartmentDetailView(department: department)) {
                                    DepartmentCardView(department: department)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("CA Departments")
            .task {
                if departments.isEmpty { // Load on initial appearance
                    await loadDepartments()
                }
            }
            .refreshable { // Pull-to-refresh triggers load based on current mode
                await loadDepartments()
            }
        }
    }
    
    // Updated load function to handle different modes
    private func loadDepartments() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedDepartments: [Department]
            switch currentLoadMode {
            case .generatedAsync:
                fetchedDepartments = try await DataService.fetchGeneratedDepartmentsAsync()
            case .fromJSON:
                // Remember to add departments.json to your project and target!
                fetchedDepartments = try await DataService.loadDepartmentsFromJSON(filename: "departments.json")
            }
            
            await MainActor.run {
                self.departments = fetchedDepartments
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                // Use the localized description from our custom error or standard errors
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                self.departments = [] // Clear data on error
            }
            print("Error occurred during fetch (\(currentLoadMode)): \(error)")
        }
    }
}

// --- SwiftUI Previews ---
// Updated Previews to use LogoSource
struct DepartmentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DepartmentDetailView(department: Department(
                name: "Preview Detail Dept",
                description: "This is a sample description.",
                logoSource: .sfSymbol(name: "paintbrush.fill"), // Use SF Symbol for easy preview
                datasetCount: 123
            ))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static let previewDepts: [Department] = [
        Department(name: "Preview SF Symbol", description: "Task A.", logoSource: .sfSymbol(name: "star.fill"), datasetCount: 10),
        Department(name: "Preview Local Asset", description: "Resource B.", logoSource: .localAsset(name: "california-flag"), datasetCount: 5), // Make sure 'california-flag' exists
        Department(name: "Preview Remote URL", description: "Item C.", logoSource: .remoteURL(url: URL(string:"https://via.placeholder.com/100")!), datasetCount: 0),
        Department(name: "Another SF Symbol", description: "Process D.", logoSource: .sfSymbol(name: "car.fill"), datasetCount: 99),
    ]
    
    static var previews: some View {
        // Default Previews (Now uses updated init)
        HomeView_V1(loadMode: .generatedAsync) // Preview async loading
            .previewDisplayName("Default - Async Gen")
        
        HomeView_V1(loadMode: .fromJSON) // Preview JSON loading (will fail if file not present/valid)
            .previewDisplayName("Default - JSON Load")
        
        // Specific State Previews
        HomeView_V1(departments: previewDepts)
            .previewDisplayName("Loaded State (Mixed Logos)")
        
        HomeView_V1(errorMessage: "Network connection lost. Could not fetch remote logo.")
            .previewDisplayName("Error State")
        
        HomeView_V1(isLoading: true)
            .previewDisplayName("Loading State")
        
        HomeView_V1(departments: [])
            .previewDisplayName("Empty State")
    }
}

// Updated Extension with init accepting loadMode for previews
extension HomeView_V1 {
    init(departments: [Department]) {
        _departments = State(initialValue: departments)
        _isLoading = State(initialValue: false)
        _errorMessage = State(initialValue: nil)
        _currentLoadMode = State(initialValue: .generatedAsync) // Default mode for this state
    }
    init(errorMessage: String) {
        _departments = State(initialValue: [])
        _isLoading = State(initialValue: false)
        _errorMessage = State(initialValue: errorMessage)
        _currentLoadMode = State(initialValue: .generatedAsync)
    }
    init(isLoading: Bool) {
        _departments = State(initialValue: [])
        _isLoading = State(initialValue: isLoading)
        _errorMessage = State(initialValue: nil)
        _currentLoadMode = State(initialValue: .generatedAsync)
    }
    // Added init to explicitly set load mode for previewing different load paths
    init(loadMode: LoadMode) {
        _departments = State(initialValue: [])
        _isLoading = State(initialValue: true) // Start in loading for loadMode previews
        _errorMessage = State(initialValue: nil)
        _currentLoadMode = State(initialValue: loadMode)
    }
}

struct DepartmentCardView_Previews: PreviewProvider {
    static var previews: some View {
        let dept1 = Department(name: "Card Preview SF Symbol", description: "Card preview desc.", logoSource: .sfSymbol(name: "paintbrush.pointed.fill"), datasetCount: 25)
        let dept2 = Department(name: "Card Preview Local", description: "Card preview desc.", logoSource: .localAsset(name: "california-flag"), datasetCount: 5) // Ensure asset exists
        let dept3 = Department(name: "Card Preview Remote", description: "Card preview desc.", logoSource: .remoteURL(url:URL(string:"https://via.placeholder.com/100")!), datasetCount: 0)
        
        Group {
            DepartmentCardView(department: dept1)
            DepartmentCardView(department: dept2)
            DepartmentCardView(department: dept3)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
