////
////  HomeView_V1.swift
////  Orange Garden Mobile
////
////  Created by Cong Le on 4/6/25.
////
////
////  HomeView_Refactored.swift
////  Based on original HomeView_V1 and CaliGovDepartmentCardView_V4 concepts
////  Created by Cong Le on ~4/6/25 (Original Date)
////
//
//import SwiftUI
//import Foundation
//
//// --- Data Model ---
//// Remains unchanged as all properties are used.
//struct Department: Identifiable, Hashable {
//    let id = UUID()
//    let name: String
//    let description: String
//    let logoSymbolName: String
//    let datasetCount: Int
//
//    // Conformance to Hashable
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
//    static func == (lhs: Department, rhs: Department) -> Bool {
//        lhs.id == rhs.id
//    }
//}
//
//// --- Data Service ---
//// Refactored to remove commented-out dead code.
//struct DataService {
//    // Dictionary holding descriptions remains essential.
//    private static let departmentDescriptions: [String: String] = [
//        // (Dictionary content remains exactly the same as original)
//        // Agencies
//        "business, consumer services and housing agency": "Oversees departments and boards that regulate various professions, businesses, financial services, and housing.",
//        "government operations agency": "Supports the operations of various departments, boards, and offices within state government.",
//        "labor and workforce development agency": "Focuses on ensuring safe and fair workplaces, delivering worker benefits, and promoting employment.",
//        "transportation agency": "Plans, develops, and maintains the state's transportation systems, including highways, rail, and aviation.",
//        "natural resources agency": "Manages and protects California's natural resources, including forests, water, and wildlife.",
//        "environmental protection agency": "Focuses on protecting the environment and public health through environmental regulation and enforcement.",
//        "health and human services agency": "Oversees various departments and programs related to health care, social services, and public assistance.",
//        // Departments
//        "department of corrections and rehabilitation": "Manages the state's prison system and parole operations.",
//        "department of education": "Oversees public education in California, from preschool through high school.",
//        "department of finance": "Develops and manages the state budget, advises the Governor on fiscal matters.",
//        "department of food and agriculture": "Supports and promotes California's agricultural industry.",
//        "department of insurance": "Regulates the insurance industry in California.",
//        "department of justice": "Enforces laws, prosecutes crimes, and represents the state in legal matters; headed by the Attorney General.",
//        "department of motor vehicles": "Issues driver's licenses, registers vehicles, and regulates driving.",
//        "department of public health": "Protects and improves public health through disease prevention, health promotion, and emergency preparedness.",
//        "franchise tax board": "Administers state income tax laws.",
//        "employment development department": "Provides unemployment insurance, disability insurance, and job training services.",
//        "department of tax and fee administration": "Administers sales and use taxes, fuel taxes, and other state taxes and fees.",
//        "department of fair employment and housing": "Enforces laws prohibiting discrimination and harassment in employment, housing, and public accommodations.",
//        "department of social services": "Provides social services, including assistance programs for needy families and individuals.",
//        "contractors state license board": "Licenses and regulates contractors in California.",
//        "department of human resources": "Oversees the state's human resources functions, including recruitment, training, and employee relations.",
//        "department of health care services": "Administers Medi-Cal, California's Medicaid program, and other health care programs.",
//        "department of aging": "Advocates for and provides services to older adults and their families.",
//        "department of alcohol and drug programs": "Supports substance abuse prevention, treatment, and recovery services.",
//        "department of cannabis control": "Regulates the cannabis industry in California.",
//        "department of conservation": "Protects and manages California's natural resources, including mineral resources, and geohazards.",
//        "department of consumer affairs": "Protects consumers through the licensing and regulation of various professions.",
//        "department of financial protection and innovation": "Regulates financial institutions and protects consumers from fraud.",
//        "department of forestry and fire protection": "Provides fire protection and management services for California's state-owned lands.",
//        "department of housing and community development": "Supports and promotes affordable housing and community development.",
//        "department of industrial relations": "Enforces labor laws and regulations, protecting workers' rights and ensuring safe workplaces.",
//        "department of managed health care": "Regulates health plans and protects the interests of consumers enrolled in managed care plans.",
//        "department of real estate": "Licenses and regulates real estate brokers, agents, and appraisers.",
//        "department of rehabilitation": "Assists individuals with disabilities in achieving employment and independent living goals.",
//        "department of resources recycling and recovery": "Promotes waste reduction, recycling, and resource recovery.",
//        "department of technology": "Provides technology services and solutions to state government agencies.",
//        "department of toxic substances control": "Protects public health and the environment from hazardous waste.",
//        "department of water resources": "Manages and protects California's water resources.",
//        "department of state hospitals": "Provides mental health services to patients admitted into the state hospital system.",
//        // Other Entities
//        "california air resources board": "Responsible for coordinating and drafting the state's climate scoping plans and focuses on air quality.",
//        "california energy commission": "Sites electricity infrastructure, invests in vehicle-charging infrastructure, and supports efforts to electrify medium and heavy-duty vehicles.",
//        "california coastal commission": "Plans and regulates land use along the California coast.",
//        "california state parks": "Manages California's state parks and recreational areas.",
//        "california state auditor": "Audits state government agencies to ensure accountability and efficiency.",
//        "california highway patrol": "Enforces traffic laws and provides law enforcement services on state highways.",
//        "california military department": "Oversees the California National Guard and other military activities.",
//        "california public utilities commission": "Regulates privately owned public utilities.",
//        "california arts council": "Promotes and supports the arts in California.",
//        "california state library": "Provides library and information services to the state government and public.",
//        "california state lands commission": "Manages state-owned lands and resources.",
//        "california student aid commission": "Administers student financial aid programs.",
//        "california lottery commission": "Operates the California State Lottery.",
//        "california state board of education": "Sets policies and standards for California public schools.",
//        "california victim compensation board": "Provides compensation to victims of violent crime.",
//        "california commission on disability access": "Promotes accessibility for individuals with disabilities.",
//        "office of emergency services": "Coordinates emergency response efforts.",
//        "office of the attorney general": "Provides legal representation and enforcement for the state.",
//        "california postsecondary education commission": "Provides oversight and planning for California's higher education system.",
//        "california fair political practices commission": "Enforces campaign finance and lobbying regulations.",
//        "california gambling control commission": "Regulates the gambling industry.",
//        "california horse racing board": "Regulates horse racing.",
//        "state controller's office": "Acts as the chief fiscal officer of the state, responsible for accountability and disbursement of the state's financial resources.",
//        "california emergency medical services authority": "Coordinates and integrates emergency medical services statewide.",
//        "governor's office of business and economic development": "Serves as the state's lead entity for economic development and job creation efforts."
//    ]
//
//    // Helper function remains essential.
//    private static func makeDescriptionKey(from name: String) -> String {
//        return name.lowercased().replacingOccurrences(of: "\n", with: " ")
//    }
//
//    static func fetchDepartmentsAsync() async throws -> [Department] {
//        print("Starting asynchronous fetch...")
//        try await Task.sleep(for: .seconds(1.5)) // Simulate network delay
//
//        // --- Removed Dead Code ---
//        // enum FetchError: Error { case networkUnavailable } // Removed
//        // if Bool.random() { throw FetchError.networkUnavailable } // Removed
//        // -------------------------
//
//        // Base list of departments remains the same.
//        let baseDepartmentsRaw: [(name: String, logo: String, count: Int)] = [
//             ("California Department\nof State Hospitals", "cross.case.fill", 5),
//             ("California Department\nof Tax and Fee Administration", "dollarsign.circle.fill", 38),
//             ("California Department\nof Technology", "server.rack", 15),
//             ("California Department\nof Toxic Substances Control", "testtube.2", 2),
//             ("California Department\nof Water Resources", "drop.fill", 546),
//             ("California Emergency\nMedical Services Authority", "staroflife.fill", 3),
//             ("California Employment\nDevelopment Department", "briefcase.fill", 17),
// //            ("California Employment\nTraining Panel", "person.2.fill", 1), // Keep commented if description truly unavailable
//             ("California Energy\nCommission", "bolt.fill", 10),
//             ("California Environmental\nProtection Agency", "leaf.fill", 10),
//             ("California Franchise\nTax Board", "banknote.fill", 104),
//             ("California Governor's Office\nof Business and Economic Development", "building.2.fill", 5),
//             ("California Department of Education", "book.closed.fill", 20),
//             ("California Highway Patrol", "shield.lefthalf.filled", 8),
//             ("California Department of Parks and Recreation", "figure.hiking", 75)
//        ]
//
//        var baseDepartments: [Department] = []
//        for deptData in baseDepartmentsRaw {
//             let key = makeDescriptionKey(from: deptData.name)
//             let lookupKey = key.contains("parks and recreation") ? "california state parks" : key
//             let description = departmentDescriptions[lookupKey] ?? "Description not available."
//
//             baseDepartments.append(Department(
//                name: deptData.name,
//                description: description,
//                logoSymbolName: deptData.logo,
//                datasetCount: deptData.count
//             ))
//        }
//
//        // Data generation loop remains - essential for demo scroll functionality.
//        var generatedDepartments: [Department] = []
//        for i in 0..<5 {
//            generatedDepartments.append(contentsOf: baseDepartments.map {
//                 Department(
//                    name: "\($0.name) (\(i+1))", // Unique-ish name
//                    description: $0.description, // Copy description
//                    logoSymbolName: $0.logoSymbolName,
//                    datasetCount: $0.datasetCount + Int.random(in: -2...5*i)
//                 )
//            })
//        }
//
//        print("Asynchronous fetch completed successfully.") // Keep for debug clarity
//        return generatedDepartments
//    }
//}
//
//// --- Card View ---
//// Remains unchanged as it's a simple display component with no dead/duplicate logic.
//struct DepartmentCardView: View {
//    let department: Department
//
//    var body: some View {
//        VStack(spacing: 10) {
//            Image(systemName: department.logoSymbolName)
//                .resizable()
//                .scaledToFit()
//                .frame(height: 60)
//                .foregroundColor(.accentColor)
//                .padding(.top)
//
//            Text(department.name)
//                .font(.headline)
//                .fontWeight(.medium)
//                .multilineTextAlignment(.center)
//                .fixedSize(horizontal: false, vertical: true)
//
//            Text("\(department.datasetCount) Dataset\(department.datasetCount == 1 ? "" : "s")")
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//
//            Spacer()
//        }
//        .padding()
//        .frame(maxWidth: .infinity, minHeight: 180)
//        .background(Color(.systemGray6))
//        .cornerRadius(12)
//        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
//    }
//}
//
//// --- Department Detail View ---
//// Remains unchanged as all parts contribute to the detail display.
//struct DepartmentDetailView: View {
//    let department: Department
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .center, spacing: 24) {
//                Image(systemName: department.logoSymbolName)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(height: 120)
//                    .foregroundColor(.accentColor)
//                    .padding(.top, 30)
//
//                Text(department.name)
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal)
//
//                HStack {
//                    Image(systemName: "doc.text.fill")
//                    Text("\(department.datasetCount) Dataset\(department.datasetCount == 1 ? "" : "s") Available")
//                }
//                .font(.title3)
//                .foregroundColor(.secondary)
//
//                Divider()
//                    .padding(.horizontal)
//
//                 VStack(alignment: .leading, spacing: 10) {
//                   Text("Function / Description")
//                         .font(.title2)
//                         .fontWeight(.semibold)
//                   Text(department.description)
//                         .font(.body)
//                 }
//                 .padding(.horizontal)
//
//                VStack(alignment: .leading, spacing: 10) {
//                   Text("Additional Information")
//                        .font(.title2)
//                        .fontWeight(.semibold)
//                   Text("This section could contain more details like key personnel, links to important resources, and access to specific open datasets managed by the \(department.name).")
//                        .font(.body)
//                    Button("Visit Department Website (Placeholder)") {
//                        print("Attempting to visit website for \(department.name)...")
//                    }
//                    .buttonStyle(.bordered)
//                    .padding(.top)
//                }
//                .padding(.horizontal)
//
//                Spacer()
//            }
//            .frame(maxWidth: .infinity)
//        }
//        .navigationTitle(department.name.replacingOccurrences(of: "\n", with: " "))
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}
//
//// --- Main Content View (Home View) ---
//// Remains structurally unchanged as its logic for state handling and display is unique.
//struct HomeView_V1: View { // Keeping original name for consistency with Previews
//    let columns: [GridItem] = [
//        GridItem(.adaptive(minimum: 150, maximum: 200))
//    ]
//
//    @State private var departments: [Department] = []
//    @State private var isLoading: Bool = false
//    @State private var errorMessage: String? = nil
//
//    var body: some View {
//        NavigationView {
//            Group {
//                if isLoading {
//                    ProgressView("Loading Departments...")
//                        .scaleEffect(1.5)
//                        .padding()
//                } else if let errorMsg = errorMessage {
//                    VStack(spacing: 20) {
//                        Image(systemName: "exclamationmark.triangle.fill")
//                            .resizable().scaledToFit().frame(width: 60, height: 60).foregroundColor(.red)
//                        Text("Failed to load departments").font(.title2)
//                        Text(errorMsg).font(.body).foregroundColor(.secondary).multilineTextAlignment(.center)
//                        Button("Retry") {
//                            errorMessage = nil
//                            Task { await loadDepartments() }
//                        }
//                        .buttonStyle(.borderedProminent).padding(.top)
//                    }
//                    .padding()
//                } else if departments.isEmpty {
//                    Text("No departments found.")
//                        .foregroundColor(.secondary)
//                } else {
//                    ScrollView {
//                        LazyVGrid(columns: columns, spacing: 20) {
//                            ForEach(departments) { department in
//                                NavigationLink(destination: DepartmentDetailView(department: department)) {
//                                    DepartmentCardView(department: department)
//                                }
//                                .buttonStyle(.plain)
//                            }
//                        }
//                        .padding()
//                    }
//                }
//            }
//            .navigationTitle("CA Departments")
//            .task {
//                // Load only if not already loaded/loading and no error
//                if departments.isEmpty && errorMessage == nil && !isLoading {
//                    await loadDepartments()
//                }
//            }
//             .refreshable { // Pull-to-refresh action
//                 await loadDepartments()
//             }
//        }
//        // .navigationViewStyle(.stack) // Consider for iPad optimization
//    }
//
//    // Async data loading function remains essential.
//    private func loadDepartments() async {
//        guard !isLoading else { return } // Prevent concurrent loads
//
//        isLoading = true
//        errorMessage = nil
//
//        do {
//            let fetchedDepartments = try await DataService.fetchDepartmentsAsync()
//            // Update state on the main thread
//            await MainActor.run {
//                self.departments = fetchedDepartments
//                self.isLoading = false
//            }
//        } catch {
//            // Update state on the main thread in case of error
//            await MainActor.run {
//                self.errorMessage = "Error: \(error.localizedDescription)"
//                self.isLoading = false
//                self.departments = [] // Clear potentially stale data
//            }
//            print("Error occurred during fetch: \(error)") // Keep for debug
//        }
//    }
//}
//
//// --- SwiftUI Previews ---
//// Previews remain essential for development and are unchanged.
//
//struct DepartmentDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            DepartmentDetailView(department: Department(
//                name: "Preview Department",
//                description: "This is a sample description for the preview department.",
//                logoSymbolName: "testtube.2",
//                datasetCount: 123
//            ))
//        }
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static let previewDepts: [Department] = [
//        Department(name: "Preview Dept 1", description: "Handles preview task A.", logoSymbolName: "star.fill", datasetCount: 10),
//        Department(name: "Preview Dept 2", description: "Manages preview resource B.", logoSymbolName: "heart.fill", datasetCount: 5),
//        Department(name: "Preview Dept 3", description: "Oversees preview item C.", logoSymbolName: "trash.fill", datasetCount: 0),
//        Department(name: "Preview Dept 4", description: "Regulates preview process D.", logoSymbolName: "car.fill", datasetCount: 99),
//    ]
//
//    static var previews: some View {
//        // Default Load Preview
//        HomeView_V1()
//            .previewDisplayName("Default Initial Load")
//
//        // Loaded State Preview
//        HomeView_V1(departments: previewDepts)
//            .previewDisplayName("Loaded State")
//
//        // Error State Preview
//        HomeView_V1(errorMessage: "Network connection timed out.")
//            .previewDisplayName("Error State")
//
//        // Loading State Preview
//        HomeView_V1(isLoading: true)
//            .previewDisplayName("Loading State")
//
//        // Empty State Preview
//        HomeView_V1(departments: [])
//             .previewDisplayName("Empty State (Loaded)")
//    }
//}
//
//// Extension with initializers for Previews remains necessary for setting up preview states.
//extension HomeView_V1 {
//     init(departments: [Department]) {
//         _departments = State(initialValue: departments)
//         _isLoading = State(initialValue: false)
//         _errorMessage = State(initialValue: nil)
//     }
//     init(errorMessage: String) {
//         _departments = State(initialValue: [])
//         _isLoading = State(initialValue: false)
//         _errorMessage = State(initialValue: errorMessage)
//     }
//     init(isLoading: Bool) {
//         _departments = State(initialValue: [])
//         _isLoading = State(initialValue: isLoading)
//         _errorMessage = State(initialValue: nil)
//     }
// }
//
//struct DepartmentCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        DepartmentCardView(department: Department(
//            name: "Preview Department Card",
//            description: "Card preview description.",
//            // Using a valid SF Symbol for preview robustness
//            logoSymbolName: "paintbrush.pointed.fill",
//            datasetCount: 25)
//        )
//            .padding()
//            .previewLayout(.sizeThatFits)
//    }
//}
