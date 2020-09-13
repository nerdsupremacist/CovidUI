// swiftlint:disable all
// This file was automatically generated and should not be edited.

import Apollo
import Combine
import Foundation
import SwiftUI

// MARK: Basic API

protocol Target {}

protocol API: Target {
    var client: ApolloClient { get }
}

extension API {
    func fetch<Query: GraphQLQuery>(query: Query, completion: @escaping (Result<Query.Data, GraphQLLoadingError<Self>>) -> Void) {
        client.fetch(query: query) { result in
            switch result {
            case let .success(result):
                guard let data = result.data else {
                    if let errors = result.errors, errors.count > 0 {
                        return completion(.failure(.graphQLErrors(errors)))
                    }
                    return completion(.failure(.emptyData(api: self)))
                }
                completion(.success(data))
            case let .failure(error):
                completion(.failure(.networkError(error)))
            }
        }
    }
}

protocol MutationTarget: Target {}

protocol Connection: Target {
    associatedtype Node
}

protocol Fragment {
    associatedtype UnderlyingType
}

extension Array: Fragment where Element: Fragment {
    typealias UnderlyingType = [Element.UnderlyingType]
}

extension Optional: Fragment where Wrapped: Fragment {
    typealias UnderlyingType = Wrapped.UnderlyingType?
}

protocol Mutation: ObservableObject {
    associatedtype Value

    var isLoading: Bool { get }
}

protocol CurrentValueMutation: ObservableObject {
    associatedtype Value

    var isLoading: Bool { get }
    var value: Value { get }
    var error: Error? { get }
}

// MARK: - Basic API: Paths

struct GraphQLPath<TargetType: Target, Value> {
    fileprivate init() {}
}

struct GraphQLFragmentPath<TargetType: Target, UnderlyingType> {
    fileprivate init() {}
}

extension GraphQLFragmentPath {
    typealias Path<V> = GraphQLPath<TargetType, V>
    typealias FragmentPath<V> = GraphQLFragmentPath<TargetType, V>
}

extension GraphQLFragmentPath {
    var _fragment: FragmentPath<UnderlyingType> {
        return self
    }
}

extension GraphQLFragmentPath {
    func _forEach<Value, Output>(_: KeyPath<GraphQLFragmentPath<TargetType, Value>, GraphQLPath<TargetType, Output>>) -> GraphQLPath<TargetType, [Output]> where UnderlyingType == [Value] {
        return .init()
    }

    func _forEach<Value, Output>(_: KeyPath<GraphQLFragmentPath<TargetType, Value>, GraphQLPath<TargetType, Output>>) -> GraphQLPath<TargetType, [Output]?> where UnderlyingType == [Value]? {
        return .init()
    }
}

extension GraphQLFragmentPath {
    func _forEach<Value, Output>(_: KeyPath<GraphQLFragmentPath<TargetType, Value>, GraphQLFragmentPath<TargetType, Output>>) -> GraphQLFragmentPath<TargetType, [Output]> where UnderlyingType == [Value] {
        return .init()
    }

    func _forEach<Value, Output>(_: KeyPath<GraphQLFragmentPath<TargetType, Value>, GraphQLFragmentPath<TargetType, Output>>) -> GraphQLFragmentPath<TargetType, [Output]?> where UnderlyingType == [Value]? {
        return .init()
    }
}

extension GraphQLFragmentPath {
    func _flatten<T>() -> GraphQLFragmentPath<TargetType, [T]> where UnderlyingType == [[T]] {
        return .init()
    }

    func _flatten<T>() -> GraphQLFragmentPath<TargetType, [T]?> where UnderlyingType == [[T]]? {
        return .init()
    }
}

extension GraphQLPath {
    func _flatten<T>() -> GraphQLPath<TargetType, [T]> where Value == [[T]] {
        return .init()
    }

    func _flatten<T>() -> GraphQLPath<TargetType, [T]?> where Value == [[T]]? {
        return .init()
    }
}

extension GraphQLFragmentPath {
    func _compactMap<T>() -> GraphQLFragmentPath<TargetType, [T]> where UnderlyingType == [T?] {
        return .init()
    }

    func _compactMap<T>() -> GraphQLFragmentPath<TargetType, [T]?> where UnderlyingType == [T?]? {
        return .init()
    }
}

extension GraphQLPath {
    func _compactMap<T>() -> GraphQLPath<TargetType, [T]> where Value == [T?] {
        return .init()
    }

    func _compactMap<T>() -> GraphQLPath<TargetType, [T]?> where Value == [T?]? {
        return .init()
    }
}

extension GraphQLFragmentPath {
    func _nonNull<T>() -> GraphQLFragmentPath<TargetType, T> where UnderlyingType == T? {
        return .init()
    }
}

extension GraphQLPath {
    func _nonNull<T>() -> GraphQLPath<TargetType, T> where Value == T? {
        return .init()
    }
}

extension GraphQLFragmentPath {
    func _withDefault<T>(_: @autoclosure () -> T) -> GraphQLFragmentPath<TargetType, T> where UnderlyingType == T? {
        return .init()
    }
}

extension GraphQLPath {
    func _withDefault<T>(_: @autoclosure () -> T) -> GraphQLPath<TargetType, T> where Value == T? {
        return .init()
    }
}

// MARK: - Basic API: Arguments

enum GraphQLArgument<Value> {
    enum QueryArgument {
        case withDefault(Value)
        case forced
    }

    case value(Value)
    case argument(QueryArgument)
}

extension GraphQLArgument {
    static var argument: GraphQLArgument<Value> {
        return .argument(.forced)
    }

    static func argument(default value: Value) -> GraphQLArgument<Value> {
        return .argument(.withDefault(value))
    }
}

// MARK: - Basic API: Paging

class Paging<Value: Fragment>: DynamicProperty, ObservableObject {
    fileprivate struct Response {
        let values: [Value]
        let cursor: String?
        let hasMore: Bool

        static var empty: Response {
            Response(values: [], cursor: nil, hasMore: false)
        }
    }

    fileprivate typealias Completion = (Result<Response, Error>) -> Void
    fileprivate typealias Loader = (String, Int?, @escaping Completion) -> Void

    private let loader: Loader

    @Published
    private(set) var isLoading: Bool = false

    @Published
    private(set) var values: [Value] = []

    private var cursor: String?

    @Published
    private(set) var hasMore: Bool = false

    @Published
    private(set) var error: Error? = nil

    fileprivate init(_ response: Response, loader: @escaping Loader) {
        self.loader = loader
        use(response)
    }

    func loadMore(pageSize: Int? = nil) {
        guard let cursor = cursor, !isLoading else { return }
        isLoading = true
        loader(cursor, pageSize) { [weak self] result in
            switch result {
            case let .success(response):
                self?.use(response)
            case let .failure(error):
                self?.handle(error)
            }
        }
    }

    private func use(_ response: Response) {
        isLoading = false
        values += response.values
        cursor = response.cursor
        hasMore = response.hasMore
    }

    private func handle(_ error: Error) {
        isLoading = false
        hasMore = false
        self.error = error
    }
}

// MARK: - Basic API: Error Types

enum GraphQLLoadingError<T: API>: Error {
    case emptyData(api: T)
    case graphQLErrors([GraphQLError])
    case networkError(Error)
}

// MARK: - Basic API: Refresh

protocol QueryRefreshController {
    func refresh()
    func refresh(completion: @escaping (Error?) -> Void)
}

private struct QueryRefreshControllerEnvironmentKey: EnvironmentKey {
    static let defaultValue: QueryRefreshController? = nil
}

extension EnvironmentValues {
    var queryRefreshController: QueryRefreshController? {
        get {
            self[QueryRefreshControllerEnvironmentKey.self]
        } set {
            self[QueryRefreshControllerEnvironmentKey.self] = newValue
        }
    }
}

// MARK: - Error Handling

enum QueryError {
    case network(Error)
    case graphql([GraphQLError])
}

extension QueryError: CustomStringConvertible {
    var description: String {
        switch self {
        case let .network(error):
            return error.localizedDescription
        case let .graphql(errors):
            return errors.map { $0.description }.joined(separator: ", ")
        }
    }
}

extension QueryError {
    var networkError: Error? {
        guard case let .network(error) = self else { return nil }
        return error
    }

    var graphQLErrors: [GraphQLError]? {
        guard case let .graphql(errors) = self else { return nil }
        return errors
    }
}

protocol QueryErrorController {
    var error: QueryError? { get }
    func clear()
}

private struct QueryErrorControllerEnvironmentKey: EnvironmentKey {
    static let defaultValue: QueryErrorController? = nil
}

extension EnvironmentValues {
    var queryErrorController: QueryErrorController? {
        get {
            self[QueryErrorControllerEnvironmentKey.self]
        } set {
            self[QueryErrorControllerEnvironmentKey.self] = newValue
        }
    }
}

// MARK: - Basic API: Views

private struct QueryRenderer<Query: GraphQLQuery, Loading: View, Error: View, Content: View>: View {
    typealias ContentFactory = (Query.Data) -> Content
    typealias ErrorFactory = (QueryError) -> Error

    private final class ViewModel: ObservableObject {
        @Published var isLoading: Bool = false
        @Published var value: Query.Data? = nil
        @Published var error: QueryError? = nil

        private var previous: Query?
        private var cancellable: Apollo.Cancellable?

        deinit {
            cancel()
        }

        func load(client: ApolloClient, query: Query) {
            guard previous !== query || (value == nil && !isLoading) else { return }
            perform(client: client, query: query)
        }

        func refresh(client: ApolloClient, query: Query, completion: ((Swift.Error?) -> Void)? = nil) {
            perform(client: client, query: query, cachePolicy: .fetchIgnoringCacheData, completion: completion)
        }

        private func perform(client: ApolloClient, query: Query, cachePolicy: CachePolicy = .returnCacheDataElseFetch, completion: ((Swift.Error?) -> Void)? = nil) {
            previous = query
            cancellable = client.fetch(query: query, cachePolicy: cachePolicy) { [weak self] result in
                defer {
                    self?.cancellable = nil
                    self?.isLoading = false
                }
                switch result {
                case let .success(result):
                    self?.value = result.data
                    self?.error = result.errors.map { .graphql($0) }
                    completion?(nil)
                case let .failure(error):
                    self?.error = .network(error)
                    completion?(error)
                }
            }
            isLoading = true
        }

        func cancel() {
            cancellable?.cancel()
        }
    }

    private struct RefreshController: QueryRefreshController {
        let client: ApolloClient
        let query: Query
        let viewModel: ViewModel

        func refresh() {
            viewModel.refresh(client: client, query: query)
        }

        func refresh(completion: @escaping (Swift.Error?) -> Void) {
            viewModel.refresh(client: client, query: query, completion: completion)
        }
    }

    private struct ErrorController: QueryErrorController {
        let viewModel: ViewModel

        var error: QueryError? {
            return viewModel.error
        }

        func clear() {
            viewModel.error = nil
        }
    }

    let client: ApolloClient
    let query: Query
    let loading: Loading
    let error: ErrorFactory
    let factory: ContentFactory

    @ObservedObject private var viewModel = ViewModel()
    @State private var hasAppeared = false

    var body: some View {
        if hasAppeared {
            self.viewModel.load(client: self.client, query: self.query)
        }
        return VStack {
            viewModel.isLoading && viewModel.value == nil && viewModel.error == nil ? loading : nil
            viewModel.value == nil ? viewModel.error.map(error) : nil
            viewModel
                .value
                .map(factory)
                .environment(\.queryRefreshController, RefreshController(client: client, query: query, viewModel: viewModel))
                .environment(\.queryErrorController, ErrorController(viewModel: viewModel))
        }
        .onAppear {
            DispatchQueue.main.async {
                self.hasAppeared = true
            }
            self.viewModel.load(client: self.client, query: self.query)
        }
        .onDisappear {
            DispatchQueue.main.async {
                self.hasAppeared = false
            }
            self.viewModel.cancel()
        }
    }
}

private struct BasicErrorView: View {
    let error: QueryError

    var body: some View {
        Text("Error: \(error.description)")
    }
}

private struct BasicLoadingView: View {
    var body: some View {
        Text("Loading")
    }
}

struct PagingView<Value: Fragment>: View {
    enum Mode {
        case list
        case vertical(alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil)
        case horizontal(alignment: VerticalAlignment = .center, spacing: CGFloat? = nil)
    }

    enum Data {
        case item(Value, Int)
        case loading
        case error(Error)

        fileprivate var id: String {
            switch self {
            case let .item(_, int):
                return int.description
            case .error:
                return "error"
            case .loading:
                return "loading"
            }
        }
    }

    @ObservedObject private var paging: Paging<Value>
    private let mode: Mode
    private let pageSize: Int?
    private var loader: (Data) -> AnyView

    @State private var visibleRect: CGRect = .zero

    init(_ paging: Paging<Value>, mode: Mode = .list, pageSize: Int? = nil, loader: @escaping (Data) -> AnyView) {
        self.paging = paging
        self.mode = mode
        self.pageSize = pageSize
        self.loader = loader
    }

    var body: some View {
        let data = self.paging.values.enumerated().map { Data.item($0.element, $0.offset) } +
            [self.paging.isLoading ? Data.loading : nil, self.paging.error.map(Data.error)].compactMap { $0 }

        switch mode {
        case .list:
            return AnyView(
                List(data, id: \.id) { data in
                    self.loader(data).onAppear { self.onAppear(data: data) }
                }
            )
        case let .vertical(alignment, spacing):
            return AnyView(
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(alignment: alignment, spacing: spacing) {
                        ForEach(data, id: \.id) { data in
                            self.loader(data).ifVisible(in: self.visibleRect, in: .named("InfiniteVerticalScroll")) { self.onAppear(data: data) }
                        }
                    }
                }
                .coordinateSpace(name: "InfiniteVerticalScroll")
                .rectReader($visibleRect, in: .named("InfiniteVerticalScroll"))
            )
        case let .horizontal(alignment, spacing):
            return AnyView(
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: alignment, spacing: spacing) {
                        ForEach(data, id: \.id) { data in
                            self.loader(data).ifVisible(in: self.visibleRect, in: .named("InfiniteHorizontalScroll")) { self.onAppear(data: data) }
                        }
                    }
                }
                .coordinateSpace(name: "InfiniteHorizontalScroll")
                .rectReader($visibleRect, in: .named("InfiniteHorizontalScroll"))
            )
        }
    }

    private func onAppear(data: Data) {
        guard !paging.isLoading,
            paging.hasMore,
            case let .item(_, index) = data,
            index > paging.values.count - 2 else { return }

        paging.loadMore(pageSize: pageSize)
    }
}

extension PagingView {
    init<Loading: View, Error: View, Data: View>(_ paging: Paging<Value>,
                                                 mode: Mode = .list,
                                                 pageSize: Int? = nil,
                                                 loading loadingView: @escaping () -> Loading,
                                                 error errorView: @escaping (Swift.Error) -> Error,
                                                 item itemView: @escaping (Value) -> Data) {
        self.init(paging, mode: mode, pageSize: pageSize) { data in
            switch data {
            case let .item(item, _):
                return AnyView(itemView(item))
            case let .error(error):
                return AnyView(errorView(error))
            case .loading:
                return AnyView(loadingView())
            }
        }
    }

    init<Error: View, Data: View>(_ paging: Paging<Value>,
                                  mode: Mode = .list,
                                  pageSize: Int? = nil,
                                  error errorView: @escaping (Swift.Error) -> Error,
                                  item itemView: @escaping (Value) -> Data) {
        self.init(paging,
                  mode: mode,
                  pageSize: pageSize,
                  loading: { Text("Loading") },
                  error: errorView,
                  item: itemView)
    }

    init<Loading: View, Data: View>(_ paging: Paging<Value>,
                                    mode: Mode = .list,
                                    pageSize: Int? = nil,
                                    loading loadingView: @escaping () -> Loading,
                                    item itemView: @escaping (Value) -> Data) {
        self.init(paging,
                  mode: mode,
                  pageSize: pageSize,
                  loading: loadingView,
                  error: { Text("Error: \($0.localizedDescription)") },
                  item: itemView)
    }

    init<Data: View>(_ paging: Paging<Value>,
                     mode: Mode = .list,
                     pageSize: Int? = nil,
                     item itemView: @escaping (Value) -> Data) {
        self.init(paging,
                  mode: mode,
                  pageSize: pageSize,
                  loading: { Text("Loading") },
                  error: { Text("Error: \($0.localizedDescription)") },
                  item: itemView)
    }
}

extension PagingView.Mode {
    static var vertical: PagingView.Mode { .vertical() }

    static var horizontal: PagingView.Mode { .horizontal() }
}

extension View {
    fileprivate func rectReader(_ binding: Binding<CGRect>, in space: CoordinateSpace) -> some View {
        background(GeometryReader { (geometry) -> AnyView in
            let rect = geometry.frame(in: space)
            DispatchQueue.main.async {
                binding.wrappedValue = rect
            }
            return AnyView(Rectangle().fill(Color.clear))
        })
    }
}

extension View {
    fileprivate func ifVisible(in rect: CGRect, in space: CoordinateSpace, execute: @escaping () -> Void) -> some View {
        background(GeometryReader { (geometry) -> AnyView in
            let frame = geometry.frame(in: space)
            if frame.intersects(rect) {
                execute()
            }
            return AnyView(Rectangle().fill(Color.clear))
        })
    }
}

// MARK: - Basic API: Decoders

protocol GraphQLValueDecoder {
    associatedtype Encoded
    associatedtype Decoded

    static func decode(encoded: Encoded) throws -> Decoded
}

enum NoOpDecoder<T>: GraphQLValueDecoder {
    static func decode(encoded: T) throws -> T {
        return encoded
    }
}

// MARK: - Basic API: Scalar Handling

protocol GraphQLScalar {
    associatedtype Scalar
    init(from scalar: Scalar) throws
}

extension Array: GraphQLScalar where Element: GraphQLScalar {
    init(from scalar: [Element.Scalar]) throws {
        self = try scalar.map { try Element(from: $0) }
    }
}

extension Optional: GraphQLScalar where Wrapped: GraphQLScalar {
    init(from scalar: Wrapped.Scalar?) throws {
        guard let scalar = scalar else {
            self = .none
            return
        }
        self = .some(try Wrapped(from: scalar))
    }
}

extension URL: GraphQLScalar {
    typealias Scalar = String

    private struct URLScalarDecodingError: Error {
        let string: String
    }

    init(from string: Scalar) throws {
        guard let url = URL(string: string) else {
            throw URLScalarDecodingError(string: string)
        }
        self = url
    }
}

enum ScalarDecoder<ScalarType: GraphQLScalar>: GraphQLValueDecoder {
    typealias Encoded = ScalarType.Scalar
    typealias Decoded = ScalarType

    static func decode(encoded: ScalarType.Scalar) throws -> ScalarType {
        return try ScalarType(from: encoded)
    }
}

// MARK: - Basic API: HACK - AnyObservableObject

private class AnyObservableObject: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    var cancellable: AnyCancellable?

    func use<O: ObservableObject>(_ object: O) {
        cancellable?.cancel()
        cancellable = object.objectWillChange.sink { [unowned self] _ in self.objectWillChange.send() }
    }
}

// MARK: - Basic API: Graph QL Property Wrapper

@propertyWrapper
struct GraphQL<Decoder: GraphQLValueDecoder>: DynamicProperty {
    private let initialValue: Decoder.Decoded

    @State
    private var value: Decoder.Decoded? = nil

    @ObservedObject
    private var observed: AnyObservableObject = AnyObservableObject()
    private let updateObserved: ((Decoder.Decoded) -> Void)?

    var wrappedValue: Decoder.Decoded {
        get {
            return value ?? initialValue
        }
        nonmutating set {
            value = newValue
            updateObserved?(newValue)
        }
    }

    var projectedValue: Binding<Decoder.Decoded> {
        return Binding(get: { self.wrappedValue }, set: { newValue in self.wrappedValue = newValue })
    }

    init<T: Target>(_: @autoclosure () -> GraphQLPath<T, Decoder.Encoded>) {
        fatalError("Initializer with path only should never be used")
    }

    init<T: Target, Value>(_: @autoclosure () -> GraphQLPath<T, Value>) where Decoder == NoOpDecoder<Value> {
        fatalError("Initializer with path only should never be used")
    }

    init<T: Target, Value: GraphQLScalar>(_: @autoclosure () -> GraphQLPath<T, Value.Scalar>) where Decoder == ScalarDecoder<Value> {
        fatalError("Initializer with path only should never be used")
    }

    fileprivate init(_ wrappedValue: Decoder.Encoded) {
        initialValue = try! Decoder.decode(encoded: wrappedValue)
        updateObserved = nil
    }

    mutating func update() {
        _value.update()
        _observed.update()
    }
}

extension GraphQL where Decoder.Decoded: ObservableObject {
    fileprivate init(_ wrappedValue: Decoder.Encoded) {
        let value = try! Decoder.decode(encoded: wrappedValue)
        initialValue = value

        let observed = AnyObservableObject()
        observed.use(value)

        self.observed = observed
        updateObserved = { observed.use($0) }
    }
}

extension GraphQL {
    init<T: Target, Value: Fragment>(_: @autoclosure () -> GraphQLFragmentPath<T, Value.UnderlyingType>) where Decoder == NoOpDecoder<Value> {
        fatalError("Initializer with path only should never be used")
    }
}

extension GraphQL {
    init<T: API, C: Connection, F: Fragment>(_: @autoclosure () -> GraphQLFragmentPath<T, C>) where Decoder == NoOpDecoder<Paging<F>>, C.Node == F.UnderlyingType {
        fatalError("Initializer with path only should never be used")
    }

    init<T: API, C: Connection, F: Fragment>(_: @autoclosure () -> GraphQLFragmentPath<T, C?>) where Decoder == NoOpDecoder<Paging<F>?>, C.Node == F.UnderlyingType {
        fatalError("Initializer with path only should never be used")
    }
}

extension GraphQL {
    init<T: MutationTarget, MutationType: Mutation>(_: @autoclosure () -> GraphQLPath<T, MutationType.Value>) where Decoder == NoOpDecoder<MutationType> {
        fatalError("Initializer with path only should never be used")
    }

    init<T: MutationTarget, MutationType: Mutation>(_: @autoclosure () -> GraphQLFragmentPath<T, MutationType.Value.UnderlyingType>) where Decoder == NoOpDecoder<MutationType>, MutationType.Value: Fragment {
        fatalError("Initializer with path only should never be used")
    }
}

extension GraphQL {
    init<T: Target, M: MutationTarget, MutationType: CurrentValueMutation>(_: @autoclosure () -> GraphQLPath<T, MutationType.Value>, mutation _: @autoclosure () -> GraphQLPath<M, MutationType.Value>) where Decoder == NoOpDecoder<MutationType> {
        fatalError("Initializer with path only should never be used")
    }

    init<T: Target, M: MutationTarget, MutationType: CurrentValueMutation>(_: @autoclosure () -> GraphQLFragmentPath<T, MutationType.Value.UnderlyingType>, mutation _: @autoclosure () -> GraphQLFragmentPath<M, MutationType.Value.UnderlyingType>) where Decoder == NoOpDecoder<MutationType>, MutationType.Value: Fragment {
        fatalError("Initializer with path only should never be used")
    }
}


// MARK: - Covid

#if GRAPHAELLO_COVID_UI__TARGET

    struct Covid: API {
        let client: ApolloClient

        typealias Query = Covid
        typealias Path<V> = GraphQLPath<Covid, V>
        typealias FragmentPath<V> = GraphQLFragmentPath<Covid, V>

        static func continent(identifier _: GraphQLArgument<Covid.ContinentIdentifier> = .argument) -> FragmentPath<Covid.DetailedContinent> {
            return .init()
        }

        static var continent: FragmentPath<Covid.DetailedContinent> { .init() }

        static var continents: FragmentPath<[Covid.Continent]> { .init() }

        static func countries(last _: GraphQLArgument<Int?> = .argument,
                              first _: GraphQLArgument<Int?> = .argument,
                              after _: GraphQLArgument<String?> = .argument,
                              before _: GraphQLArgument<String?> = .argument) -> FragmentPath<Covid.CountryConnection> {
            return .init()
        }

        static var countries: FragmentPath<Covid.CountryConnection> { .init() }

        static func country(identifier _: GraphQLArgument<Covid.CountryIdentifier> = .argument) -> FragmentPath<Covid.Country> {
            return .init()
        }

        static var country: FragmentPath<Covid.Country> { .init() }

        static func historicalData(after _: GraphQLArgument<String?> = .argument,
                                   last _: GraphQLArgument<Int?> = .argument,
                                   before _: GraphQLArgument<String?> = .argument,
                                   first _: GraphQLArgument<Int?> = .argument) -> FragmentPath<Covid.HistoricalDataConnection> {
            return .init()
        }

        static var historicalData: FragmentPath<Covid.HistoricalDataConnection> { .init() }

        static var myCountry: FragmentPath<Covid.Country?> { .init() }

        static var world: FragmentPath<Covid.World> { .init() }

        enum Affected: Target {
            typealias Path<V> = GraphQLPath<Affected, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<Affected, V>

            static var active: Path<Int> { .init() }

            static var cases: Path<Int> { .init() }

            static var critical: Path<Int> { .init() }

            static var deaths: Path<Int> { .init() }

            static var recovered: Path<Int> { .init() }

            static var todayCases: Path<Int> { .init() }

            static var todayDeaths: Path<Int> { .init() }

            static var updated: Path<String> { .init() }

            static var country: FragmentPath<Country?> { .init() }

            static var world: FragmentPath<World?> { .init() }

            static var detailedContinent: FragmentPath<DetailedContinent?> { .init() }

            static var DetailedAffected: FragmentPath<DetailedAffected?> { .init() }

            static var Continent: FragmentPath<Continent?> { .init() }

            static var Affected: FragmentPath<Affected?> { .init() }

            static var _fragment: FragmentPath<Affected> { .init() }
        }

        enum Continent: Target {
            typealias Path<V> = GraphQLPath<Continent, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<Continent, V>

            static var active: Path<Int> { .init() }

            static var cases: Path<Int> { .init() }

            static var critical: Path<Int> { .init() }

            static var deaths: Path<Int> { .init() }

            static var details: FragmentPath<Covid.DetailedContinent> { .init() }

            static var identifier: Path<Covid.ContinentIdentifier> { .init() }

            static var name: Path<String> { .init() }

            static var recovered: Path<Int> { .init() }

            static var todayCases: Path<Int> { .init() }

            static var todayDeaths: Path<Int> { .init() }

            static var updated: Path<String> { .init() }

            static var detailedContinent: FragmentPath<DetailedContinent?> { .init() }

            static var Continent: FragmentPath<Continent?> { .init() }

            static var _fragment: FragmentPath<Continent> { .init() }
        }

        enum ContinentIdentifier: String, Target {
            typealias Path<V> = GraphQLPath<ContinentIdentifier, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<ContinentIdentifier, V>

            case northAmerica = "NorthAmerica"

            case asia = "Asia"

            case europe = "Europe"

            case southAmerica = "SouthAmerica"

            case africa = "Africa"

            case australiaOceania = "AustraliaOceania"

            static var _fragment: FragmentPath<ContinentIdentifier> { .init() }
        }

        enum Country: Target {
            typealias Path<V> = GraphQLPath<Country, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<Country, V>

            static var active: Path<Int> { .init() }

            static var cases: Path<Int> { .init() }

            static var casesPerOneMillion: Path<Double?> { .init() }

            static var continent: FragmentPath<Covid.DetailedContinent> { .init() }

            static var continentIdentifier: Path<Covid.ContinentIdentifier> { .init() }

            static var critical: Path<Int> { .init() }

            static var deaths: Path<Int> { .init() }

            static var deathsPerOneMillion: Path<Double?> { .init() }

            static var identifier: Path<Covid.CountryIdentifier> { .init() }

            static var info: FragmentPath<Covid.Info> { .init() }

            static var name: Path<String> { .init() }

            static var news: FragmentPath<[Covid.NewsStory]> { .init() }

            static var place: Path<Int> { .init() }

            static var recovered: Path<Int> { .init() }

            static var tests: Path<Int> { .init() }

            static var testsPerOneMillion: Path<Double?> { .init() }

            static var timeline: FragmentPath<Covid.Timeline> { .init() }

            static var todayCases: Path<Int> { .init() }

            static var todayDeaths: Path<Int> { .init() }

            static var updated: Path<String> { .init() }

            static var detailedAffected: FragmentPath<DetailedAffected> { .init() }

            static var affected: FragmentPath<Affected> { .init() }

            static var _fragment: FragmentPath<Country> { .init() }
        }

        enum CountryConnection: Target, Connection {
            typealias Node = Covid.Country
            typealias Path<V> = GraphQLPath<CountryConnection, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<CountryConnection, V>

            static var edges: FragmentPath<[Covid.CountryEdge?]?> { .init() }

            static var pageInfo: FragmentPath<Covid.PageInfo> { .init() }

            static var totalCount: Path<Int> { .init() }

            static var _fragment: FragmentPath<CountryConnection> { .init() }
        }

        enum CountryEdge: Target {
            typealias Path<V> = GraphQLPath<CountryEdge, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<CountryEdge, V>

            static var cursor: Path<String> { .init() }

            static var node: FragmentPath<Covid.Country?> { .init() }

            static var _fragment: FragmentPath<CountryEdge> { .init() }
        }

        typealias CountryIdentifier = ApolloCovid.CountryIdentifier

        enum DataPoint: Target {
            typealias Path<V> = GraphQLPath<DataPoint, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<DataPoint, V>

            static var date: Path<String> { .init() }

            static var value: Path<Int> { .init() }

            static var _fragment: FragmentPath<DataPoint> { .init() }
        }

        enum DataPointConnection: Target, Connection {
            typealias Node = Covid.DataPoint
            typealias Path<V> = GraphQLPath<DataPointConnection, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<DataPointConnection, V>

            static var edges: FragmentPath<[Covid.DataPointEdge?]?> { .init() }

            static var pageInfo: FragmentPath<Covid.PageInfo> { .init() }

            static var totalCount: Path<Int> { .init() }

            static var _fragment: FragmentPath<DataPointConnection> { .init() }
        }

        enum DataPointEdge: Target {
            typealias Path<V> = GraphQLPath<DataPointEdge, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<DataPointEdge, V>

            static var cursor: Path<String> { .init() }

            static var node: FragmentPath<Covid.DataPoint?> { .init() }

            static var _fragment: FragmentPath<DataPointEdge> { .init() }
        }

        enum DataPointsCollection: Target {
            typealias Path<V> = GraphQLPath<DataPointsCollection, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<DataPointsCollection, V>

            static func connection(after _: GraphQLArgument<String?> = .argument,
                                   first _: GraphQLArgument<Int?> = .argument,
                                   last _: GraphQLArgument<Int?> = .argument,
                                   before _: GraphQLArgument<String?> = .argument) -> FragmentPath<Covid.DataPointConnection> {
                return .init()
            }

            static var connection: FragmentPath<Covid.DataPointConnection> { .init() }

            static func graph(since _: GraphQLArgument<String> = .argument,
                              numberOfPoints _: GraphQLArgument<Int> = .argument) -> FragmentPath<[Covid.DataPoint]> {
                return .init()
            }

            static var graph: FragmentPath<[Covid.DataPoint]> { .init() }

            static var _fragment: FragmentPath<DataPointsCollection> { .init() }
        }

        enum DetailedAffected: Target {
            typealias Path<V> = GraphQLPath<DetailedAffected, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<DetailedAffected, V>

            static var active: Path<Int> { .init() }

            static var cases: Path<Int> { .init() }

            static var casesPerOneMillion: Path<Double?> { .init() }

            static var critical: Path<Int> { .init() }

            static var deaths: Path<Int> { .init() }

            static var deathsPerOneMillion: Path<Double?> { .init() }

            static var recovered: Path<Int> { .init() }

            static var tests: Path<Int> { .init() }

            static var testsPerOneMillion: Path<Double?> { .init() }

            static var todayCases: Path<Int> { .init() }

            static var todayDeaths: Path<Int> { .init() }

            static var updated: Path<String> { .init() }

            static var country: FragmentPath<Country?> { .init() }

            static var world: FragmentPath<World?> { .init() }

            static var DetailedAffected: FragmentPath<DetailedAffected?> { .init() }

            static var _fragment: FragmentPath<DetailedAffected> { .init() }
        }

        enum DetailedContinent: Target {
            typealias Path<V> = GraphQLPath<DetailedContinent, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<DetailedContinent, V>

            static var active: Path<Int> { .init() }

            static var cases: Path<Int> { .init() }

            static var countries: FragmentPath<[Covid.Country]> { .init() }

            static var countryIdentifiers: Path<[Covid.CountryIdentifier]> { .init() }

            static var critical: Path<Int> { .init() }

            static var deaths: Path<Int> { .init() }

            static var details: FragmentPath<Covid.DetailedContinent> { .init() }

            static var identifier: Path<Covid.ContinentIdentifier> { .init() }

            static var name: Path<String> { .init() }

            static var recovered: Path<Int> { .init() }

            static var todayCases: Path<Int> { .init() }

            static var todayDeaths: Path<Int> { .init() }

            static var updated: Path<String> { .init() }

            static var continent: FragmentPath<Continent> { .init() }

            static var affected: FragmentPath<Affected> { .init() }

            static var _fragment: FragmentPath<DetailedContinent> { .init() }
        }

        enum HistoricalData: Target {
            typealias Path<V> = GraphQLPath<HistoricalData, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<HistoricalData, V>

            static var country: FragmentPath<Covid.Country> { .init() }

            static var countryIdentifier: Path<Covid.CountryIdentifier?> { .init() }

            static var timeline: FragmentPath<Covid.Timeline> { .init() }

            static var _fragment: FragmentPath<HistoricalData> { .init() }
        }

        enum HistoricalDataConnection: Target, Connection {
            typealias Node = Covid.HistoricalData
            typealias Path<V> = GraphQLPath<HistoricalDataConnection, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<HistoricalDataConnection, V>

            static var edges: FragmentPath<[Covid.HistoricalDataEdge?]?> { .init() }

            static var pageInfo: FragmentPath<Covid.PageInfo> { .init() }

            static var totalCount: Path<Int> { .init() }

            static var _fragment: FragmentPath<HistoricalDataConnection> { .init() }
        }

        enum HistoricalDataEdge: Target {
            typealias Path<V> = GraphQLPath<HistoricalDataEdge, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<HistoricalDataEdge, V>

            static var cursor: Path<String> { .init() }

            static var node: FragmentPath<Covid.HistoricalData?> { .init() }

            static var _fragment: FragmentPath<HistoricalDataEdge> { .init() }
        }

        enum Info: Target {
            typealias Path<V> = GraphQLPath<Info, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<Info, V>

            static var emoji: Path<String?> { .init() }

            static var flag: Path<String> { .init() }

            static var iso2: Path<String?> { .init() }

            static var iso3: Path<String?> { .init() }

            static var latitude: Path<Double?> { .init() }

            static var longitude: Path<Double?> { .init() }

            static var _fragment: FragmentPath<Info> { .init() }
        }

        enum NewsStory: Target {
            typealias Path<V> = GraphQLPath<NewsStory, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<NewsStory, V>

            static var author: Path<String?> { .init() }

            static var content: Path<String?> { .init() }

            static var image: Path<String?> { .init() }

            static var overview: Path<String?> { .init() }

            static var source: FragmentPath<Covid.Source> { .init() }

            static var title: Path<String> { .init() }

            static var url: Path<String> { .init() }

            static var _fragment: FragmentPath<NewsStory> { .init() }
        }

        enum PageInfo: Target {
            typealias Path<V> = GraphQLPath<PageInfo, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<PageInfo, V>

            static var endCursor: Path<String?> { .init() }

            static var hasNextPage: Path<Bool> { .init() }

            static var hasPreviousPage: Path<Bool> { .init() }

            static var startCursor: Path<String?> { .init() }

            static var _fragment: FragmentPath<PageInfo> { .init() }
        }

        enum Source: Target {
            typealias Path<V> = GraphQLPath<Source, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<Source, V>

            static var id: Path<String?> { .init() }

            static var name: Path<String> { .init() }

            static var _fragment: FragmentPath<Source> { .init() }
        }

        enum Timeline: Target {
            typealias Path<V> = GraphQLPath<Timeline, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<Timeline, V>

            static var cases: FragmentPath<Covid.DataPointsCollection> { .init() }

            static var deaths: FragmentPath<Covid.DataPointsCollection> { .init() }

            static var recovered: FragmentPath<Covid.DataPointsCollection> { .init() }

            static var _fragment: FragmentPath<Timeline> { .init() }
        }

        enum World: Target {
            typealias Path<V> = GraphQLPath<World, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<World, V>

            static var active: Path<Int> { .init() }

            static var affectedCountries: Path<Int> { .init() }

            static var cases: Path<Int> { .init() }

            static var casesPerOneMillion: Path<Double?> { .init() }

            static var critical: Path<Int> { .init() }

            static var deaths: Path<Int> { .init() }

            static var deathsPerOneMillion: Path<Double?> { .init() }

            static var news: FragmentPath<[Covid.NewsStory]> { .init() }

            static var recovered: Path<Int> { .init() }

            static var tests: Path<Int> { .init() }

            static var testsPerOneMillion: Path<Double?> { .init() }

            static var timeline: FragmentPath<Covid.Timeline> { .init() }

            static var todayCases: Path<Int> { .init() }

            static var todayDeaths: Path<Int> { .init() }

            static var updated: Path<String> { .init() }

            static var detailedAffected: FragmentPath<DetailedAffected> { .init() }

            static var affected: FragmentPath<Affected> { .init() }

            static var _fragment: FragmentPath<World> { .init() }
        }
    }

    extension Covid {
        init(url: URL = URL(string: "https://covidql.apps.quintero.io")!,
             client: URLSessionClient = URLSessionClient(),
             sendOperationIdentifiers: Bool = false,
             useGETForQueries: Bool = false,
             enableAutoPersistedQueries: Bool = false,
             useGETForPersistedQueryRetry: Bool = false,
             requestCreator: RequestCreator = ApolloRequestCreator(),
             delegate: HTTPNetworkTransportDelegate? = nil,
             store: ApolloStore = ApolloStore(cache: InMemoryNormalizedCache())) {
            let networkTransport = HTTPNetworkTransport(url: url,
                                                        client: client,
                                                        sendOperationIdentifiers: sendOperationIdentifiers,
                                                        useGETForQueries: useGETForQueries,
                                                        enableAutoPersistedQueries: enableAutoPersistedQueries,
                                                        useGETForPersistedQueryRetry: useGETForPersistedQueryRetry,
                                                        requestCreator: requestCreator)

            networkTransport.delegate = delegate
            self.init(client: ApolloClient(networkTransport: networkTransport, store: store))
        }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.Affected {
        var active: Path<Int> { .init() }

        var cases: Path<Int> { .init() }

        var critical: Path<Int> { .init() }

        var deaths: Path<Int> { .init() }

        var recovered: Path<Int> { .init() }

        var todayCases: Path<Int> { .init() }

        var todayDeaths: Path<Int> { .init() }

        var updated: Path<String> { .init() }

        var country: FragmentPath<Covid.Country?> { .init() }

        var world: FragmentPath<Covid.World?> { .init() }

        var detailedContinent: FragmentPath<Covid.DetailedContinent?> { .init() }

        var DetailedAffected: FragmentPath<Covid.DetailedAffected?> { .init() }

        var Continent: FragmentPath<Covid.Continent?> { .init() }

        var Affected: FragmentPath<Covid.Affected?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.Affected? {
        var active: Path<Int?> { .init() }

        var cases: Path<Int?> { .init() }

        var critical: Path<Int?> { .init() }

        var deaths: Path<Int?> { .init() }

        var recovered: Path<Int?> { .init() }

        var todayCases: Path<Int?> { .init() }

        var todayDeaths: Path<Int?> { .init() }

        var updated: Path<String?> { .init() }

        var country: FragmentPath<Covid.Country?> { .init() }

        var world: FragmentPath<Covid.World?> { .init() }

        var detailedContinent: FragmentPath<Covid.DetailedContinent?> { .init() }

        var DetailedAffected: FragmentPath<Covid.DetailedAffected?> { .init() }

        var Continent: FragmentPath<Covid.Continent?> { .init() }

        var Affected: FragmentPath<Covid.Affected?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.Continent {
        var active: Path<Int> { .init() }

        var cases: Path<Int> { .init() }

        var critical: Path<Int> { .init() }

        var deaths: Path<Int> { .init() }

        var details: FragmentPath<Covid.DetailedContinent> { .init() }

        var identifier: Path<Covid.ContinentIdentifier> { .init() }

        var name: Path<String> { .init() }

        var recovered: Path<Int> { .init() }

        var todayCases: Path<Int> { .init() }

        var todayDeaths: Path<Int> { .init() }

        var updated: Path<String> { .init() }

        var detailedContinent: FragmentPath<Covid.DetailedContinent?> { .init() }

        var Continent: FragmentPath<Covid.Continent?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.Continent? {
        var active: Path<Int?> { .init() }

        var cases: Path<Int?> { .init() }

        var critical: Path<Int?> { .init() }

        var deaths: Path<Int?> { .init() }

        var details: FragmentPath<Covid.DetailedContinent?> { .init() }

        var identifier: Path<Covid.ContinentIdentifier?> { .init() }

        var name: Path<String?> { .init() }

        var recovered: Path<Int?> { .init() }

        var todayCases: Path<Int?> { .init() }

        var todayDeaths: Path<Int?> { .init() }

        var updated: Path<String?> { .init() }

        var detailedContinent: FragmentPath<Covid.DetailedContinent?> { .init() }

        var Continent: FragmentPath<Covid.Continent?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.ContinentIdentifier {}

    extension GraphQLFragmentPath where UnderlyingType == Covid.ContinentIdentifier? {}

    extension GraphQLFragmentPath where UnderlyingType == Covid.Country {
        var active: Path<Int> { .init() }

        var cases: Path<Int> { .init() }

        var casesPerOneMillion: Path<Double?> { .init() }

        var continent: FragmentPath<Covid.DetailedContinent> { .init() }

        var continentIdentifier: Path<Covid.ContinentIdentifier> { .init() }

        var critical: Path<Int> { .init() }

        var deaths: Path<Int> { .init() }

        var deathsPerOneMillion: Path<Double?> { .init() }

        var identifier: Path<Covid.CountryIdentifier> { .init() }

        var info: FragmentPath<Covid.Info> { .init() }

        var name: Path<String> { .init() }

        var news: FragmentPath<[Covid.NewsStory]> { .init() }

        var place: Path<Int> { .init() }

        var recovered: Path<Int> { .init() }

        var tests: Path<Int> { .init() }

        var testsPerOneMillion: Path<Double?> { .init() }

        var timeline: FragmentPath<Covid.Timeline> { .init() }

        var todayCases: Path<Int> { .init() }

        var todayDeaths: Path<Int> { .init() }

        var updated: Path<String> { .init() }

        var detailedAffected: FragmentPath<Covid.DetailedAffected> { .init() }

        var affected: FragmentPath<Covid.Affected> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.Country? {
        var active: Path<Int?> { .init() }

        var cases: Path<Int?> { .init() }

        var casesPerOneMillion: Path<Double?> { .init() }

        var continent: FragmentPath<Covid.DetailedContinent?> { .init() }

        var continentIdentifier: Path<Covid.ContinentIdentifier?> { .init() }

        var critical: Path<Int?> { .init() }

        var deaths: Path<Int?> { .init() }

        var deathsPerOneMillion: Path<Double?> { .init() }

        var identifier: Path<Covid.CountryIdentifier?> { .init() }

        var info: FragmentPath<Covid.Info?> { .init() }

        var name: Path<String?> { .init() }

        var news: FragmentPath<[Covid.NewsStory]?> { .init() }

        var place: Path<Int?> { .init() }

        var recovered: Path<Int?> { .init() }

        var tests: Path<Int?> { .init() }

        var testsPerOneMillion: Path<Double?> { .init() }

        var timeline: FragmentPath<Covid.Timeline?> { .init() }

        var todayCases: Path<Int?> { .init() }

        var todayDeaths: Path<Int?> { .init() }

        var updated: Path<String?> { .init() }

        var detailedAffected: FragmentPath<Covid.DetailedAffected?> { .init() }

        var affected: FragmentPath<Covid.Affected?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.CountryConnection {
        var edges: FragmentPath<[Covid.CountryEdge?]?> { .init() }

        var pageInfo: FragmentPath<Covid.PageInfo> { .init() }

        var totalCount: Path<Int> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.CountryConnection? {
        var edges: FragmentPath<[Covid.CountryEdge?]?> { .init() }

        var pageInfo: FragmentPath<Covid.PageInfo?> { .init() }

        var totalCount: Path<Int?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.CountryEdge {
        var cursor: Path<String> { .init() }

        var node: FragmentPath<Covid.Country?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.CountryEdge? {
        var cursor: Path<String?> { .init() }

        var node: FragmentPath<Covid.Country?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.CountryIdentifier {}

    extension GraphQLFragmentPath where UnderlyingType == Covid.CountryIdentifier? {}

    extension GraphQLFragmentPath where UnderlyingType == Covid.DataPoint {
        var date: Path<String> { .init() }

        var value: Path<Int> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.DataPoint? {
        var date: Path<String?> { .init() }

        var value: Path<Int?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.DataPointConnection {
        var edges: FragmentPath<[Covid.DataPointEdge?]?> { .init() }

        var pageInfo: FragmentPath<Covid.PageInfo> { .init() }

        var totalCount: Path<Int> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.DataPointConnection? {
        var edges: FragmentPath<[Covid.DataPointEdge?]?> { .init() }

        var pageInfo: FragmentPath<Covid.PageInfo?> { .init() }

        var totalCount: Path<Int?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.DataPointEdge {
        var cursor: Path<String> { .init() }

        var node: FragmentPath<Covid.DataPoint?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.DataPointEdge? {
        var cursor: Path<String?> { .init() }

        var node: FragmentPath<Covid.DataPoint?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.DataPointsCollection {
        func connection(after _: GraphQLArgument<String?> = .argument,
                        first _: GraphQLArgument<Int?> = .argument,
                        last _: GraphQLArgument<Int?> = .argument,
                        before _: GraphQLArgument<String?> = .argument) -> FragmentPath<Covid.DataPointConnection> {
            return .init()
        }

        var connection: FragmentPath<Covid.DataPointConnection> { .init() }

        func graph(since _: GraphQLArgument<String> = .argument,
                   numberOfPoints _: GraphQLArgument<Int> = .argument) -> FragmentPath<[Covid.DataPoint]> {
            return .init()
        }

        var graph: FragmentPath<[Covid.DataPoint]> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.DataPointsCollection? {
        func connection(after _: GraphQLArgument<String?> = .argument,
                        first _: GraphQLArgument<Int?> = .argument,
                        last _: GraphQLArgument<Int?> = .argument,
                        before _: GraphQLArgument<String?> = .argument) -> FragmentPath<Covid.DataPointConnection?> {
            return .init()
        }

        var connection: FragmentPath<Covid.DataPointConnection?> { .init() }

        func graph(since _: GraphQLArgument<String> = .argument,
                   numberOfPoints _: GraphQLArgument<Int> = .argument) -> FragmentPath<[Covid.DataPoint]?> {
            return .init()
        }

        var graph: FragmentPath<[Covid.DataPoint]?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.DetailedAffected {
        var active: Path<Int> { .init() }

        var cases: Path<Int> { .init() }

        var casesPerOneMillion: Path<Double?> { .init() }

        var critical: Path<Int> { .init() }

        var deaths: Path<Int> { .init() }

        var deathsPerOneMillion: Path<Double?> { .init() }

        var recovered: Path<Int> { .init() }

        var tests: Path<Int> { .init() }

        var testsPerOneMillion: Path<Double?> { .init() }

        var todayCases: Path<Int> { .init() }

        var todayDeaths: Path<Int> { .init() }

        var updated: Path<String> { .init() }

        var country: FragmentPath<Covid.Country?> { .init() }

        var world: FragmentPath<Covid.World?> { .init() }

        var DetailedAffected: FragmentPath<Covid.DetailedAffected?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.DetailedAffected? {
        var active: Path<Int?> { .init() }

        var cases: Path<Int?> { .init() }

        var casesPerOneMillion: Path<Double?> { .init() }

        var critical: Path<Int?> { .init() }

        var deaths: Path<Int?> { .init() }

        var deathsPerOneMillion: Path<Double?> { .init() }

        var recovered: Path<Int?> { .init() }

        var tests: Path<Int?> { .init() }

        var testsPerOneMillion: Path<Double?> { .init() }

        var todayCases: Path<Int?> { .init() }

        var todayDeaths: Path<Int?> { .init() }

        var updated: Path<String?> { .init() }

        var country: FragmentPath<Covid.Country?> { .init() }

        var world: FragmentPath<Covid.World?> { .init() }

        var DetailedAffected: FragmentPath<Covid.DetailedAffected?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.DetailedContinent {
        var active: Path<Int> { .init() }

        var cases: Path<Int> { .init() }

        var countries: FragmentPath<[Covid.Country]> { .init() }

        var countryIdentifiers: Path<[Covid.CountryIdentifier]> { .init() }

        var critical: Path<Int> { .init() }

        var deaths: Path<Int> { .init() }

        var details: FragmentPath<Covid.DetailedContinent> { .init() }

        var identifier: Path<Covid.ContinentIdentifier> { .init() }

        var name: Path<String> { .init() }

        var recovered: Path<Int> { .init() }

        var todayCases: Path<Int> { .init() }

        var todayDeaths: Path<Int> { .init() }

        var updated: Path<String> { .init() }

        var continent: FragmentPath<Covid.Continent> { .init() }

        var affected: FragmentPath<Covid.Affected> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.DetailedContinent? {
        var active: Path<Int?> { .init() }

        var cases: Path<Int?> { .init() }

        var countries: FragmentPath<[Covid.Country]?> { .init() }

        var countryIdentifiers: Path<[Covid.CountryIdentifier]?> { .init() }

        var critical: Path<Int?> { .init() }

        var deaths: Path<Int?> { .init() }

        var details: FragmentPath<Covid.DetailedContinent?> { .init() }

        var identifier: Path<Covid.ContinentIdentifier?> { .init() }

        var name: Path<String?> { .init() }

        var recovered: Path<Int?> { .init() }

        var todayCases: Path<Int?> { .init() }

        var todayDeaths: Path<Int?> { .init() }

        var updated: Path<String?> { .init() }

        var continent: FragmentPath<Covid.Continent?> { .init() }

        var affected: FragmentPath<Covid.Affected?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.HistoricalData {
        var country: FragmentPath<Covid.Country> { .init() }

        var countryIdentifier: Path<Covid.CountryIdentifier?> { .init() }

        var timeline: FragmentPath<Covid.Timeline> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.HistoricalData? {
        var country: FragmentPath<Covid.Country?> { .init() }

        var countryIdentifier: Path<Covid.CountryIdentifier?> { .init() }

        var timeline: FragmentPath<Covid.Timeline?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.HistoricalDataConnection {
        var edges: FragmentPath<[Covid.HistoricalDataEdge?]?> { .init() }

        var pageInfo: FragmentPath<Covid.PageInfo> { .init() }

        var totalCount: Path<Int> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.HistoricalDataConnection? {
        var edges: FragmentPath<[Covid.HistoricalDataEdge?]?> { .init() }

        var pageInfo: FragmentPath<Covid.PageInfo?> { .init() }

        var totalCount: Path<Int?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.HistoricalDataEdge {
        var cursor: Path<String> { .init() }

        var node: FragmentPath<Covid.HistoricalData?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.HistoricalDataEdge? {
        var cursor: Path<String?> { .init() }

        var node: FragmentPath<Covid.HistoricalData?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.Info {
        var emoji: Path<String?> { .init() }

        var flag: Path<String> { .init() }

        var iso2: Path<String?> { .init() }

        var iso3: Path<String?> { .init() }

        var latitude: Path<Double?> { .init() }

        var longitude: Path<Double?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.Info? {
        var emoji: Path<String?> { .init() }

        var flag: Path<String?> { .init() }

        var iso2: Path<String?> { .init() }

        var iso3: Path<String?> { .init() }

        var latitude: Path<Double?> { .init() }

        var longitude: Path<Double?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.NewsStory {
        var author: Path<String?> { .init() }

        var content: Path<String?> { .init() }

        var image: Path<String?> { .init() }

        var overview: Path<String?> { .init() }

        var source: FragmentPath<Covid.Source> { .init() }

        var title: Path<String> { .init() }

        var url: Path<String> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.NewsStory? {
        var author: Path<String?> { .init() }

        var content: Path<String?> { .init() }

        var image: Path<String?> { .init() }

        var overview: Path<String?> { .init() }

        var source: FragmentPath<Covid.Source?> { .init() }

        var title: Path<String?> { .init() }

        var url: Path<String?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.PageInfo {
        var endCursor: Path<String?> { .init() }

        var hasNextPage: Path<Bool> { .init() }

        var hasPreviousPage: Path<Bool> { .init() }

        var startCursor: Path<String?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.PageInfo? {
        var endCursor: Path<String?> { .init() }

        var hasNextPage: Path<Bool?> { .init() }

        var hasPreviousPage: Path<Bool?> { .init() }

        var startCursor: Path<String?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.Source {
        var id: Path<String?> { .init() }

        var name: Path<String> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.Source? {
        var id: Path<String?> { .init() }

        var name: Path<String?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.Timeline {
        var cases: FragmentPath<Covid.DataPointsCollection> { .init() }

        var deaths: FragmentPath<Covid.DataPointsCollection> { .init() }

        var recovered: FragmentPath<Covid.DataPointsCollection> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.Timeline? {
        var cases: FragmentPath<Covid.DataPointsCollection?> { .init() }

        var deaths: FragmentPath<Covid.DataPointsCollection?> { .init() }

        var recovered: FragmentPath<Covid.DataPointsCollection?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.World {
        var active: Path<Int> { .init() }

        var affectedCountries: Path<Int> { .init() }

        var cases: Path<Int> { .init() }

        var casesPerOneMillion: Path<Double?> { .init() }

        var critical: Path<Int> { .init() }

        var deaths: Path<Int> { .init() }

        var deathsPerOneMillion: Path<Double?> { .init() }

        var news: FragmentPath<[Covid.NewsStory]> { .init() }

        var recovered: Path<Int> { .init() }

        var tests: Path<Int> { .init() }

        var testsPerOneMillion: Path<Double?> { .init() }

        var timeline: FragmentPath<Covid.Timeline> { .init() }

        var todayCases: Path<Int> { .init() }

        var todayDeaths: Path<Int> { .init() }

        var updated: Path<String> { .init() }

        var detailedAffected: FragmentPath<Covid.DetailedAffected> { .init() }

        var affected: FragmentPath<Covid.Affected> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.World? {
        var active: Path<Int?> { .init() }

        var affectedCountries: Path<Int?> { .init() }

        var cases: Path<Int?> { .init() }

        var casesPerOneMillion: Path<Double?> { .init() }

        var critical: Path<Int?> { .init() }

        var deaths: Path<Int?> { .init() }

        var deathsPerOneMillion: Path<Double?> { .init() }

        var news: FragmentPath<[Covid.NewsStory]?> { .init() }

        var recovered: Path<Int?> { .init() }

        var tests: Path<Int?> { .init() }

        var testsPerOneMillion: Path<Double?> { .init() }

        var timeline: FragmentPath<Covid.Timeline?> { .init() }

        var todayCases: Path<Int?> { .init() }

        var todayDeaths: Path<Int?> { .init() }

        var updated: Path<String?> { .init() }

        var detailedAffected: FragmentPath<Covid.DetailedAffected?> { .init() }

        var affected: FragmentPath<Covid.Affected?> { .init() }
    }

#endif




// MARK: - BasicCountryCell

#if GRAPHAELLO_COVID_UI__TARGET

    extension ApolloCovid.BasicCountryCellCountry: Fragment {
        typealias UnderlyingType = Covid.Country
    }

    extension BasicCountryCell {
        typealias Country = ApolloCovid.BasicCountryCellCountry

        init(api: Covid,
             country: Country) {
            self.init(api: api,
                      name: GraphQL(country.name),
                      identifier: GraphQL(country.identifier),
                      countryCode: GraphQL(country.info.iso2),
                      cases: GraphQL(country.cases))
        }
    }

#endif


// MARK: - CountryMapPin

#if GRAPHAELLO_COVID_UI__TARGET

    extension ApolloCovid.CountryMapPinCountry: Fragment {
        typealias UnderlyingType = Covid.Country
    }

    extension CountryMapPin {
        typealias Country = ApolloCovid.CountryMapPinCountry

        init(country: Country) {
            self.init(cases: GraphQL(country.cases),
                      latitude: GraphQL(country.info.latitude),
                      longitude: GraphQL(country.info.longitude))
        }
    }

    extension CountryMapPin: Fragment {
        typealias UnderlyingType = Covid.Country
    }

    extension ApolloCovid.CountryMapPinCountry {
        func referencedSingleFragmentStruct() -> CountryMapPin {
            return CountryMapPin(country: self)
        }
    }

#endif


// MARK: - NewsStoryCell

#if GRAPHAELLO_COVID_UI__TARGET

    extension ApolloCovid.NewsStoryCellNewsStory: Fragment {
        typealias UnderlyingType = Covid.NewsStory
    }

    extension NewsStoryCell {
        typealias NewsStory = ApolloCovid.NewsStoryCellNewsStory

        init(newsStory: NewsStory) {
            self.init(source: GraphQL(newsStory.source.name),
                      title: GraphQL(newsStory.title),
                      overview: GraphQL(newsStory.overview),
                      image: GraphQL(newsStory.image),
                      url: GraphQL(newsStory.url))
        }
    }

    extension NewsStoryCell: Fragment {
        typealias UnderlyingType = Covid.NewsStory
    }

    extension ApolloCovid.NewsStoryCellNewsStory {
        func referencedSingleFragmentStruct() -> NewsStoryCell {
            return NewsStoryCell(newsStory: self)
        }
    }

#endif


// MARK: - StatsView

#if GRAPHAELLO_COVID_UI__TARGET

    extension ApolloCovid.StatsViewAffected: Fragment {
        typealias UnderlyingType = Covid.Affected
    }

    extension StatsView {
        typealias Affected = ApolloCovid.StatsViewAffected

        init(affected: Affected) {
            self.init(cases: GraphQL(affected.cases),
                      deaths: GraphQL(affected.deaths),
                      recovered: GraphQL(affected.recovered))
        }
    }

    extension StatsView: Fragment {
        typealias UnderlyingType = Covid.Affected
    }

    extension ApolloCovid.StatsViewAffected {
        func referencedSingleFragmentStruct() -> StatsView {
            return StatsView(affected: self)
        }
    }

#endif


// MARK: - CountryDetailView

#if GRAPHAELLO_COVID_UI__TARGET

    extension CountryDetailView {
        typealias Data = ApolloCovid.CountryDetailViewQuery.Data

        init(data: Data) {
            self.init(name: GraphQL(data.country.name),
                      countryCode: GraphQL(data.country.info.iso2),
                      affected: GraphQL(data.country.fragments.statsViewAffected),
                      casesToday: GraphQL(data.country.todayCases),
                      deathsToday: GraphQL(data.country.todayDeaths),
                      casesOverTime: GraphQL(data.country.timeline.cases.graph.map { $0.value }),
                      deathsOverTime: GraphQL(data.country.timeline.deaths.graph.map { $0.value }),
                      recoveredOverTime: GraphQL(data.country.timeline.recovered.graph.map { $0.value }),
                      images: GraphQL(data.country.news.map { $0.image }),
                      news: GraphQL(data.country.news.map { $0.fragments.newsStoryCellNewsStory }))
        }
    }

    extension Covid {
        func countryDetailView<Loading: View, Error: View>(identifier: Covid.CountryIdentifier,
                                                           since: String = "2001-01-01T00:00:00Z",
                                                           numberOfPoints: Int = 30,
                                                           
                                                           @ViewBuilder loading: () -> Loading,
                                                           @ViewBuilder error: @escaping (QueryError) -> Error) -> some View {
            return QueryRenderer(client: client,
                                 query: ApolloCovid.CountryDetailViewQuery(identifier: identifier,
                                                                           since: since,
                                                                           numberOfPoints: numberOfPoints),
                                 loading: loading(),
                                 error: error) { (data: ApolloCovid.CountryDetailViewQuery.Data) -> CountryDetailView in

                CountryDetailView(data: data)
            }
        }

        func countryDetailView<Loading: View>(identifier: Covid.CountryIdentifier,
                                              since: String = "2001-01-01T00:00:00Z",
                                              numberOfPoints: Int = 30,
                                              
                                              @ViewBuilder loading: () -> Loading) -> some View {
            return QueryRenderer(client: client,
                                 query: ApolloCovid.CountryDetailViewQuery(identifier: identifier,
                                                                           since: since,
                                                                           numberOfPoints: numberOfPoints),
                                 loading: loading(),
                                 error: { BasicErrorView(error: $0) }) { (data: ApolloCovid.CountryDetailViewQuery.Data) -> CountryDetailView in

                CountryDetailView(data: data)
            }
        }

        func countryDetailView<Error: View>(identifier: Covid.CountryIdentifier,
                                            since: String = "2001-01-01T00:00:00Z",
                                            numberOfPoints: Int = 30,
                                            
                                            @ViewBuilder error: @escaping (QueryError) -> Error) -> some View {
            return QueryRenderer(client: client,
                                 query: ApolloCovid.CountryDetailViewQuery(identifier: identifier,
                                                                           since: since,
                                                                           numberOfPoints: numberOfPoints),
                                 loading: BasicLoadingView(),
                                 error: error) { (data: ApolloCovid.CountryDetailViewQuery.Data) -> CountryDetailView in

                CountryDetailView(data: data)
            }
        }

        func countryDetailView(identifier: Covid.CountryIdentifier,
                               since: String = "2001-01-01T00:00:00Z",
                               numberOfPoints: Int = 30) -> some View {
            return QueryRenderer(client: client,
                                 query: ApolloCovid.CountryDetailViewQuery(identifier: identifier,
                                                                           since: since,
                                                                           numberOfPoints: numberOfPoints),
                                 loading: BasicLoadingView(),
                                 error: { BasicErrorView(error: $0) }) { (data: ApolloCovid.CountryDetailViewQuery.Data) -> CountryDetailView in

                CountryDetailView(data: data)
            }
        }
    }

#endif


// MARK: - CurrentStateCell

#if GRAPHAELLO_COVID_UI__TARGET

    extension ApolloCovid.CurrentStateCellWorld: Fragment {
        typealias UnderlyingType = Covid.World
    }

    extension CurrentStateCell {
        typealias World = ApolloCovid.CurrentStateCellWorld

        init(world: World) {
            self.init(affected: GraphQL(world.fragments.statsViewAffected))
        }
    }

    extension CurrentStateCell: Fragment {
        typealias UnderlyingType = Covid.World
    }

    extension ApolloCovid.CurrentStateCellWorld {
        func referencedSingleFragmentStruct() -> CurrentStateCell {
            return CurrentStateCell(world: self)
        }
    }

#endif


// MARK: - FeaturedCountryCell

#if GRAPHAELLO_COVID_UI__TARGET

    extension ApolloCovid.FeaturedCountryCellCountry: Fragment {
        typealias UnderlyingType = Covid.Country
    }

    extension FeaturedCountryCell {
        typealias Country = ApolloCovid.FeaturedCountryCellCountry

        init(api: Covid,
             country: Country) {
            self.init(api: api,
                      name: GraphQL(country.name),
                      countryCode: GraphQL(country.info.iso2),
                      affected: GraphQL(country.fragments.statsViewAffected),
                      todayDeaths: GraphQL(country.todayDeaths),
                      casesOverTime: GraphQL(country.timeline.cases.graph.map { $0.value }))
        }
    }

#endif


// MARK: - ContentView

#if GRAPHAELLO_COVID_UI__TARGET

    extension ContentView {
        typealias Data = ApolloCovid.ContentViewQuery.Data

        init(api: Covid,
             countries: Paging<BasicCountryCell.Country>,
             data: Data) {
            self.init(api: api,
                      currentCountry: GraphQL(data.myCountry?.fragments.featuredCountryCellCountry),
                      currentCountryName: GraphQL(data.myCountry?.name),
                      currentCountryNews: GraphQL(data.myCountry?.news.map { $0.fragments.newsStoryCellNewsStory }),
                      world: GraphQL(data.world.fragments.currentStateCellWorld),
                      cases: GraphQL(data.world.timeline.cases.graph.map { $0.value }),
                      deaths: GraphQL(data.world.timeline.deaths.graph.map { $0.value }),
                      recovered: GraphQL(data.world.timeline.recovered.graph.map { $0.value }),
                      news: GraphQL(data.world.news.map { $0.fragments.newsStoryCellNewsStory }),
                      countries: GraphQL(countries),
                      pins: GraphQL(((data.countries.edges?.map { $0?.node })?.compactMap { $0 } ?? []).map { $0.fragments.countryMapPinCountry.referencedSingleFragmentStruct() }))
        }
    }

    extension Covid {
        func contentView<Loading: View, Error: View>(last: Int? = nil,
                                                     first: Int? = nil,
                                                     after: String? = nil,
                                                     before: String? = nil,
                                                     since: String = "2001-01-01T00:00:00Z",
                                                     numberOfPoints: Int = 30,
                                                     
                                                     @ViewBuilder loading: () -> Loading,
                                                     @ViewBuilder error: @escaping (QueryError) -> Error) -> some View {
            return QueryRenderer(client: client,
                                 query: ApolloCovid.ContentViewQuery(last: last,
                                                                     first: first,
                                                                     after: after,
                                                                     before: before,
                                                                     since: since,
                                                                     numberOfPoints: numberOfPoints),
                                 loading: loading(),
                                 error: error) { (data: ApolloCovid.ContentViewQuery.Data) -> ContentView in

                ContentView(api: self,
                            countries: data.countries.fragments.countryConnectionBasicCountryCellCountry.paging { _cursor, _pageSize, _completion in
                                self.client.fetch(query: ApolloCovid.ContentViewCountriesCountryConnectionBasicCountryCellCountryQuery(last: last,
                                                                                                                                       first: _pageSize ?? first,
                                                                                                                                       after: _cursor,
                                                                                                                                       before: before)) { result in
                                    _completion(result.map { $0.data?.countries.fragments.countryConnectionBasicCountryCellCountry })
                                }
                            },
                            
                            data: data)
            }
        }

        func contentView<Loading: View>(last: Int? = nil,
                                        first: Int? = nil,
                                        after: String? = nil,
                                        before: String? = nil,
                                        since: String = "2001-01-01T00:00:00Z",
                                        numberOfPoints: Int = 30,
                                        
                                        @ViewBuilder loading: () -> Loading) -> some View {
            return QueryRenderer(client: client,
                                 query: ApolloCovid.ContentViewQuery(last: last,
                                                                     first: first,
                                                                     after: after,
                                                                     before: before,
                                                                     since: since,
                                                                     numberOfPoints: numberOfPoints),
                                 loading: loading(),
                                 error: { BasicErrorView(error: $0) }) { (data: ApolloCovid.ContentViewQuery.Data) -> ContentView in

                ContentView(api: self,
                            countries: data.countries.fragments.countryConnectionBasicCountryCellCountry.paging { _cursor, _pageSize, _completion in
                                self.client.fetch(query: ApolloCovid.ContentViewCountriesCountryConnectionBasicCountryCellCountryQuery(last: last,
                                                                                                                                       first: _pageSize ?? first,
                                                                                                                                       after: _cursor,
                                                                                                                                       before: before)) { result in
                                    _completion(result.map { $0.data?.countries.fragments.countryConnectionBasicCountryCellCountry })
                                }
                            },
                            
                            data: data)
            }
        }

        func contentView<Error: View>(last: Int? = nil,
                                      first: Int? = nil,
                                      after: String? = nil,
                                      before: String? = nil,
                                      since: String = "2001-01-01T00:00:00Z",
                                      numberOfPoints: Int = 30,
                                      
                                      @ViewBuilder error: @escaping (QueryError) -> Error) -> some View {
            return QueryRenderer(client: client,
                                 query: ApolloCovid.ContentViewQuery(last: last,
                                                                     first: first,
                                                                     after: after,
                                                                     before: before,
                                                                     since: since,
                                                                     numberOfPoints: numberOfPoints),
                                 loading: BasicLoadingView(),
                                 error: error) { (data: ApolloCovid.ContentViewQuery.Data) -> ContentView in

                ContentView(api: self,
                            countries: data.countries.fragments.countryConnectionBasicCountryCellCountry.paging { _cursor, _pageSize, _completion in
                                self.client.fetch(query: ApolloCovid.ContentViewCountriesCountryConnectionBasicCountryCellCountryQuery(last: last,
                                                                                                                                       first: _pageSize ?? first,
                                                                                                                                       after: _cursor,
                                                                                                                                       before: before)) { result in
                                    _completion(result.map { $0.data?.countries.fragments.countryConnectionBasicCountryCellCountry })
                                }
                            },
                            
                            data: data)
            }
        }

        func contentView(last: Int? = nil,
                         first: Int? = nil,
                         after: String? = nil,
                         before: String? = nil,
                         since: String = "2001-01-01T00:00:00Z",
                         numberOfPoints: Int = 30) -> some View {
            return QueryRenderer(client: client,
                                 query: ApolloCovid.ContentViewQuery(last: last,
                                                                     first: first,
                                                                     after: after,
                                                                     before: before,
                                                                     since: since,
                                                                     numberOfPoints: numberOfPoints),
                                 loading: BasicLoadingView(),
                                 error: { BasicErrorView(error: $0) }) { (data: ApolloCovid.ContentViewQuery.Data) -> ContentView in

                ContentView(api: self,
                            countries: data.countries.fragments.countryConnectionBasicCountryCellCountry.paging { _cursor, _pageSize, _completion in
                                self.client.fetch(query: ApolloCovid.ContentViewCountriesCountryConnectionBasicCountryCellCountryQuery(last: last,
                                                                                                                                       first: _pageSize ?? first,
                                                                                                                                       after: _cursor,
                                                                                                                                       before: before)) { result in
                                    _completion(result.map { $0.data?.countries.fragments.countryConnectionBasicCountryCellCountry })
                                }
                            },
                            
                            data: data)
            }
        }
    }

    extension ApolloCovid.ContentViewQuery.Data.MyCountry.Fragments {
        public var featuredCountryCellCountry: ApolloCovid.FeaturedCountryCellCountry {
            get {
                return ApolloCovid.FeaturedCountryCellCountry(unsafeResultMap: resultMap)
            }
            set {
                resultMap += newValue.resultMap
            }
        }
    }

#endif




extension ApolloCovid.CountryConnectionBasicCountryCellCountry {
    typealias Completion = (Result<ApolloCovid.CountryConnectionBasicCountryCellCountry?, Error>) -> Void
    typealias Loader = (String, Int?, @escaping Completion) -> Void

    private var response: Paging<ApolloCovid.BasicCountryCellCountry>.Response {
        return Paging.Response(values: edges?.compactMap { $0?.node?.fragments.basicCountryCellCountry } ?? [],
                               cursor: pageInfo.endCursor,
                               hasMore: pageInfo.hasNextPage)
    }

    fileprivate func paging(loader: @escaping Loader) -> Paging<ApolloCovid.BasicCountryCellCountry> {
        return Paging(response) { cursor, pageSize, completion in
            loader(cursor, pageSize) { result in
                completion(result.map { $0?.response ?? .empty })
            }
        }
    }
}




// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

/// ApolloCovid namespace
public enum ApolloCovid {
  public enum CountryIdentifier: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
    public typealias RawValue = String
    case turksAndCaicosIslands
    case dominicanRepublic
    case greece
    case senegal
    case panama
    case syrianArabRepublic
    case ethiopia
    case fiji
    case kazakhstan
    case brazil
    case libyanArabJamahiriya
    case lithuania
    case andorra
    case trinidadAndTobago
    case saintKittsAndNevis
    case brunei
    case argentina
    case finland
    case costaRica
    case portugal
    case rwanda
    case australia
    case guineaBissau
    case gabon
    case saintLucia
    case sudan
    case yemen
    case barbados
    case guyana
    case ecuador
    case macao
    case colombia
    case poland
    case sanMarino
    case swaziland
    case venezuela
    case cambodia
    case westernSahara
    case kenya
    case turkey
    case malawi
    case tajikistan
    case nicaragua
    case israel
    case bangladesh
    case sKorea
    case chad
    case zimbabwe
    case montserrat
    case comoros
    case uruguay
    case switzerland
    case cuba
    case jordan
    case congo
    case uganda
    case greenland
    case southAfrica
    case elSalvador
    case grenada
    case suriname
    case mauritius
    case malta
    case ghana
    case latvia
    case paraguay
    case niger
    case guinea
    case taiwan
    case papuaNewGuinea
    case togo
    case liechtenstein
    case ukraine
    case equatorialGuinea
    case spain
    case madagascar
    case georgia
    case montenegro
    case belize
    case thailand
    case armenia
    case usa
    case maldives
    case drc
    case gambia
    case kuwait
    case bhutan
    case mongolia
    case liberia
    case nepal
    case msZaandam
    case moldova
    case oman
    case pakistan
    case coteDIvoire
    case monaco
    case curacao
    case bosnia
    case albania
    case saintPierreMiquelon
    case mali
    case netherlands
    case stBarth
    case britishVirginIslands
    case france
    case croatia
    case falklandIslandsMalvinas
    case bolivia
    case bermuda
    case bahrain
    case palestine
    case japan
    case azerbaijan
    case hungary
    case kyrgyzstan
    case cameroon
    case algeria
    case haiti
    case myanmar
    case macedonia
    case malaysia
    case russia
    case sweden
    case eritrea
    case gibraltar
    case lebanon
    case hongKong
    case laoPeopleSDemocraticRepublic
    case morocco
    case tanzania
    case botswana
    case egypt
    case sriLanka
    case czechia
    case caboVerde
    case romania
    case tunisia
    case sintMaarten
    case slovenia
    case singapore
    case namibia
    case estonia
    case mauritania
    case italy
    case iceland
    case afghanistan
    case bulgaria
    case diamondPrincess
    case china
    case belarus
    case frenchPolynesia
    case peru
    case channelIslands
    case bahamas
    case canada
    case honduras
    case newZealand
    case iraq
    case saoTomeAndPrincipe
    case luxembourg
    case dominica
    case frenchGuiana
    case caymanIslands
    case benin
    case caribbeanNetherlands
    case timorLeste
    case guatemala
    case saintMartin
    case vietnam
    case martinique
    case djibouti
    case holySeeVaticanCityState
    case angola
    case qatar
    case reunion
    case saintVincentAndTheGrenadines
    case austria
    case seychelles
    case saudiArabia
    case somalia
    case norway
    case guadeloupe
    case chile
    case mexico
    case india
    case germany
    case burkinaFaso
    case anguilla
    case lesotho
    case denmark
    case southSudan
    case newCaledonia
    case iran
    case mayotte
    case cyprus
    case mozambique
    case nigeria
    case aruba
    case antiguaAndBarbuda
    case zambia
    case serbia
    case uk
    case indonesia
    case isleOfMan
    case uzbekistan
    case faroeIslands
    case ireland
    case jamaica
    case burundi
    case centralAfricanRepublic
    case philippines
    case uae
    case sierraLeone
    case belgium
    case slovakia
    /// Auto generated constant for unknown enum values
    case __unknown(RawValue)

    public init?(rawValue: RawValue) {
      switch rawValue {
        case "TurksAndCaicosIslands": self = .turksAndCaicosIslands
        case "DominicanRepublic": self = .dominicanRepublic
        case "Greece": self = .greece
        case "Senegal": self = .senegal
        case "Panama": self = .panama
        case "SyrianArabRepublic": self = .syrianArabRepublic
        case "Ethiopia": self = .ethiopia
        case "Fiji": self = .fiji
        case "Kazakhstan": self = .kazakhstan
        case "Brazil": self = .brazil
        case "LibyanArabJamahiriya": self = .libyanArabJamahiriya
        case "Lithuania": self = .lithuania
        case "Andorra": self = .andorra
        case "TrinidadAndTobago": self = .trinidadAndTobago
        case "SaintKittsAndNevis": self = .saintKittsAndNevis
        case "Brunei": self = .brunei
        case "Argentina": self = .argentina
        case "Finland": self = .finland
        case "CostaRica": self = .costaRica
        case "Portugal": self = .portugal
        case "Rwanda": self = .rwanda
        case "Australia": self = .australia
        case "GuineaBissau": self = .guineaBissau
        case "Gabon": self = .gabon
        case "SaintLucia": self = .saintLucia
        case "Sudan": self = .sudan
        case "Yemen": self = .yemen
        case "Barbados": self = .barbados
        case "Guyana": self = .guyana
        case "Ecuador": self = .ecuador
        case "Macao": self = .macao
        case "Colombia": self = .colombia
        case "Poland": self = .poland
        case "SanMarino": self = .sanMarino
        case "Swaziland": self = .swaziland
        case "Venezuela": self = .venezuela
        case "Cambodia": self = .cambodia
        case "WesternSahara": self = .westernSahara
        case "Kenya": self = .kenya
        case "Turkey": self = .turkey
        case "Malawi": self = .malawi
        case "Tajikistan": self = .tajikistan
        case "Nicaragua": self = .nicaragua
        case "Israel": self = .israel
        case "Bangladesh": self = .bangladesh
        case "SKorea": self = .sKorea
        case "Chad": self = .chad
        case "Zimbabwe": self = .zimbabwe
        case "Montserrat": self = .montserrat
        case "Comoros": self = .comoros
        case "Uruguay": self = .uruguay
        case "Switzerland": self = .switzerland
        case "Cuba": self = .cuba
        case "Jordan": self = .jordan
        case "Congo": self = .congo
        case "Uganda": self = .uganda
        case "Greenland": self = .greenland
        case "SouthAfrica": self = .southAfrica
        case "ElSalvador": self = .elSalvador
        case "Grenada": self = .grenada
        case "Suriname": self = .suriname
        case "Mauritius": self = .mauritius
        case "Malta": self = .malta
        case "Ghana": self = .ghana
        case "Latvia": self = .latvia
        case "Paraguay": self = .paraguay
        case "Niger": self = .niger
        case "Guinea": self = .guinea
        case "Taiwan": self = .taiwan
        case "PapuaNewGuinea": self = .papuaNewGuinea
        case "Togo": self = .togo
        case "Liechtenstein": self = .liechtenstein
        case "Ukraine": self = .ukraine
        case "EquatorialGuinea": self = .equatorialGuinea
        case "Spain": self = .spain
        case "Madagascar": self = .madagascar
        case "Georgia": self = .georgia
        case "Montenegro": self = .montenegro
        case "Belize": self = .belize
        case "Thailand": self = .thailand
        case "Armenia": self = .armenia
        case "Usa": self = .usa
        case "Maldives": self = .maldives
        case "Drc": self = .drc
        case "Gambia": self = .gambia
        case "Kuwait": self = .kuwait
        case "Bhutan": self = .bhutan
        case "Mongolia": self = .mongolia
        case "Liberia": self = .liberia
        case "Nepal": self = .nepal
        case "MsZaandam": self = .msZaandam
        case "Moldova": self = .moldova
        case "Oman": self = .oman
        case "Pakistan": self = .pakistan
        case "CoteDIvoire": self = .coteDIvoire
        case "Monaco": self = .monaco
        case "Curacao": self = .curacao
        case "Bosnia": self = .bosnia
        case "Albania": self = .albania
        case "SaintPierreMiquelon": self = .saintPierreMiquelon
        case "Mali": self = .mali
        case "Netherlands": self = .netherlands
        case "StBarth": self = .stBarth
        case "BritishVirginIslands": self = .britishVirginIslands
        case "France": self = .france
        case "Croatia": self = .croatia
        case "FalklandIslandsMalvinas": self = .falklandIslandsMalvinas
        case "Bolivia": self = .bolivia
        case "Bermuda": self = .bermuda
        case "Bahrain": self = .bahrain
        case "Palestine": self = .palestine
        case "Japan": self = .japan
        case "Azerbaijan": self = .azerbaijan
        case "Hungary": self = .hungary
        case "Kyrgyzstan": self = .kyrgyzstan
        case "Cameroon": self = .cameroon
        case "Algeria": self = .algeria
        case "Haiti": self = .haiti
        case "Myanmar": self = .myanmar
        case "Macedonia": self = .macedonia
        case "Malaysia": self = .malaysia
        case "Russia": self = .russia
        case "Sweden": self = .sweden
        case "Eritrea": self = .eritrea
        case "Gibraltar": self = .gibraltar
        case "Lebanon": self = .lebanon
        case "HongKong": self = .hongKong
        case "LaoPeopleSDemocraticRepublic": self = .laoPeopleSDemocraticRepublic
        case "Morocco": self = .morocco
        case "Tanzania": self = .tanzania
        case "Botswana": self = .botswana
        case "Egypt": self = .egypt
        case "SriLanka": self = .sriLanka
        case "Czechia": self = .czechia
        case "CaboVerde": self = .caboVerde
        case "Romania": self = .romania
        case "Tunisia": self = .tunisia
        case "SintMaarten": self = .sintMaarten
        case "Slovenia": self = .slovenia
        case "Singapore": self = .singapore
        case "Namibia": self = .namibia
        case "Estonia": self = .estonia
        case "Mauritania": self = .mauritania
        case "Italy": self = .italy
        case "Iceland": self = .iceland
        case "Afghanistan": self = .afghanistan
        case "Bulgaria": self = .bulgaria
        case "DiamondPrincess": self = .diamondPrincess
        case "China": self = .china
        case "Belarus": self = .belarus
        case "FrenchPolynesia": self = .frenchPolynesia
        case "Peru": self = .peru
        case "ChannelIslands": self = .channelIslands
        case "Bahamas": self = .bahamas
        case "Canada": self = .canada
        case "Honduras": self = .honduras
        case "NewZealand": self = .newZealand
        case "Iraq": self = .iraq
        case "SaoTomeAndPrincipe": self = .saoTomeAndPrincipe
        case "Luxembourg": self = .luxembourg
        case "Dominica": self = .dominica
        case "FrenchGuiana": self = .frenchGuiana
        case "CaymanIslands": self = .caymanIslands
        case "Benin": self = .benin
        case "CaribbeanNetherlands": self = .caribbeanNetherlands
        case "TimorLeste": self = .timorLeste
        case "Guatemala": self = .guatemala
        case "SaintMartin": self = .saintMartin
        case "Vietnam": self = .vietnam
        case "Martinique": self = .martinique
        case "Djibouti": self = .djibouti
        case "HolySeeVaticanCityState": self = .holySeeVaticanCityState
        case "Angola": self = .angola
        case "Qatar": self = .qatar
        case "Reunion": self = .reunion
        case "SaintVincentAndTheGrenadines": self = .saintVincentAndTheGrenadines
        case "Austria": self = .austria
        case "Seychelles": self = .seychelles
        case "SaudiArabia": self = .saudiArabia
        case "Somalia": self = .somalia
        case "Norway": self = .norway
        case "Guadeloupe": self = .guadeloupe
        case "Chile": self = .chile
        case "Mexico": self = .mexico
        case "India": self = .india
        case "Germany": self = .germany
        case "BurkinaFaso": self = .burkinaFaso
        case "Anguilla": self = .anguilla
        case "Lesotho": self = .lesotho
        case "Denmark": self = .denmark
        case "SouthSudan": self = .southSudan
        case "NewCaledonia": self = .newCaledonia
        case "Iran": self = .iran
        case "Mayotte": self = .mayotte
        case "Cyprus": self = .cyprus
        case "Mozambique": self = .mozambique
        case "Nigeria": self = .nigeria
        case "Aruba": self = .aruba
        case "AntiguaAndBarbuda": self = .antiguaAndBarbuda
        case "Zambia": self = .zambia
        case "Serbia": self = .serbia
        case "Uk": self = .uk
        case "Indonesia": self = .indonesia
        case "IsleOfMan": self = .isleOfMan
        case "Uzbekistan": self = .uzbekistan
        case "FaroeIslands": self = .faroeIslands
        case "Ireland": self = .ireland
        case "Jamaica": self = .jamaica
        case "Burundi": self = .burundi
        case "CentralAfricanRepublic": self = .centralAfricanRepublic
        case "Philippines": self = .philippines
        case "Uae": self = .uae
        case "SierraLeone": self = .sierraLeone
        case "Belgium": self = .belgium
        case "Slovakia": self = .slovakia
        default: self = .__unknown(rawValue)
      }
    }

    public var rawValue: RawValue {
      switch self {
        case .turksAndCaicosIslands: return "TurksAndCaicosIslands"
        case .dominicanRepublic: return "DominicanRepublic"
        case .greece: return "Greece"
        case .senegal: return "Senegal"
        case .panama: return "Panama"
        case .syrianArabRepublic: return "SyrianArabRepublic"
        case .ethiopia: return "Ethiopia"
        case .fiji: return "Fiji"
        case .kazakhstan: return "Kazakhstan"
        case .brazil: return "Brazil"
        case .libyanArabJamahiriya: return "LibyanArabJamahiriya"
        case .lithuania: return "Lithuania"
        case .andorra: return "Andorra"
        case .trinidadAndTobago: return "TrinidadAndTobago"
        case .saintKittsAndNevis: return "SaintKittsAndNevis"
        case .brunei: return "Brunei"
        case .argentina: return "Argentina"
        case .finland: return "Finland"
        case .costaRica: return "CostaRica"
        case .portugal: return "Portugal"
        case .rwanda: return "Rwanda"
        case .australia: return "Australia"
        case .guineaBissau: return "GuineaBissau"
        case .gabon: return "Gabon"
        case .saintLucia: return "SaintLucia"
        case .sudan: return "Sudan"
        case .yemen: return "Yemen"
        case .barbados: return "Barbados"
        case .guyana: return "Guyana"
        case .ecuador: return "Ecuador"
        case .macao: return "Macao"
        case .colombia: return "Colombia"
        case .poland: return "Poland"
        case .sanMarino: return "SanMarino"
        case .swaziland: return "Swaziland"
        case .venezuela: return "Venezuela"
        case .cambodia: return "Cambodia"
        case .westernSahara: return "WesternSahara"
        case .kenya: return "Kenya"
        case .turkey: return "Turkey"
        case .malawi: return "Malawi"
        case .tajikistan: return "Tajikistan"
        case .nicaragua: return "Nicaragua"
        case .israel: return "Israel"
        case .bangladesh: return "Bangladesh"
        case .sKorea: return "SKorea"
        case .chad: return "Chad"
        case .zimbabwe: return "Zimbabwe"
        case .montserrat: return "Montserrat"
        case .comoros: return "Comoros"
        case .uruguay: return "Uruguay"
        case .switzerland: return "Switzerland"
        case .cuba: return "Cuba"
        case .jordan: return "Jordan"
        case .congo: return "Congo"
        case .uganda: return "Uganda"
        case .greenland: return "Greenland"
        case .southAfrica: return "SouthAfrica"
        case .elSalvador: return "ElSalvador"
        case .grenada: return "Grenada"
        case .suriname: return "Suriname"
        case .mauritius: return "Mauritius"
        case .malta: return "Malta"
        case .ghana: return "Ghana"
        case .latvia: return "Latvia"
        case .paraguay: return "Paraguay"
        case .niger: return "Niger"
        case .guinea: return "Guinea"
        case .taiwan: return "Taiwan"
        case .papuaNewGuinea: return "PapuaNewGuinea"
        case .togo: return "Togo"
        case .liechtenstein: return "Liechtenstein"
        case .ukraine: return "Ukraine"
        case .equatorialGuinea: return "EquatorialGuinea"
        case .spain: return "Spain"
        case .madagascar: return "Madagascar"
        case .georgia: return "Georgia"
        case .montenegro: return "Montenegro"
        case .belize: return "Belize"
        case .thailand: return "Thailand"
        case .armenia: return "Armenia"
        case .usa: return "Usa"
        case .maldives: return "Maldives"
        case .drc: return "Drc"
        case .gambia: return "Gambia"
        case .kuwait: return "Kuwait"
        case .bhutan: return "Bhutan"
        case .mongolia: return "Mongolia"
        case .liberia: return "Liberia"
        case .nepal: return "Nepal"
        case .msZaandam: return "MsZaandam"
        case .moldova: return "Moldova"
        case .oman: return "Oman"
        case .pakistan: return "Pakistan"
        case .coteDIvoire: return "CoteDIvoire"
        case .monaco: return "Monaco"
        case .curacao: return "Curacao"
        case .bosnia: return "Bosnia"
        case .albania: return "Albania"
        case .saintPierreMiquelon: return "SaintPierreMiquelon"
        case .mali: return "Mali"
        case .netherlands: return "Netherlands"
        case .stBarth: return "StBarth"
        case .britishVirginIslands: return "BritishVirginIslands"
        case .france: return "France"
        case .croatia: return "Croatia"
        case .falklandIslandsMalvinas: return "FalklandIslandsMalvinas"
        case .bolivia: return "Bolivia"
        case .bermuda: return "Bermuda"
        case .bahrain: return "Bahrain"
        case .palestine: return "Palestine"
        case .japan: return "Japan"
        case .azerbaijan: return "Azerbaijan"
        case .hungary: return "Hungary"
        case .kyrgyzstan: return "Kyrgyzstan"
        case .cameroon: return "Cameroon"
        case .algeria: return "Algeria"
        case .haiti: return "Haiti"
        case .myanmar: return "Myanmar"
        case .macedonia: return "Macedonia"
        case .malaysia: return "Malaysia"
        case .russia: return "Russia"
        case .sweden: return "Sweden"
        case .eritrea: return "Eritrea"
        case .gibraltar: return "Gibraltar"
        case .lebanon: return "Lebanon"
        case .hongKong: return "HongKong"
        case .laoPeopleSDemocraticRepublic: return "LaoPeopleSDemocraticRepublic"
        case .morocco: return "Morocco"
        case .tanzania: return "Tanzania"
        case .botswana: return "Botswana"
        case .egypt: return "Egypt"
        case .sriLanka: return "SriLanka"
        case .czechia: return "Czechia"
        case .caboVerde: return "CaboVerde"
        case .romania: return "Romania"
        case .tunisia: return "Tunisia"
        case .sintMaarten: return "SintMaarten"
        case .slovenia: return "Slovenia"
        case .singapore: return "Singapore"
        case .namibia: return "Namibia"
        case .estonia: return "Estonia"
        case .mauritania: return "Mauritania"
        case .italy: return "Italy"
        case .iceland: return "Iceland"
        case .afghanistan: return "Afghanistan"
        case .bulgaria: return "Bulgaria"
        case .diamondPrincess: return "DiamondPrincess"
        case .china: return "China"
        case .belarus: return "Belarus"
        case .frenchPolynesia: return "FrenchPolynesia"
        case .peru: return "Peru"
        case .channelIslands: return "ChannelIslands"
        case .bahamas: return "Bahamas"
        case .canada: return "Canada"
        case .honduras: return "Honduras"
        case .newZealand: return "NewZealand"
        case .iraq: return "Iraq"
        case .saoTomeAndPrincipe: return "SaoTomeAndPrincipe"
        case .luxembourg: return "Luxembourg"
        case .dominica: return "Dominica"
        case .frenchGuiana: return "FrenchGuiana"
        case .caymanIslands: return "CaymanIslands"
        case .benin: return "Benin"
        case .caribbeanNetherlands: return "CaribbeanNetherlands"
        case .timorLeste: return "TimorLeste"
        case .guatemala: return "Guatemala"
        case .saintMartin: return "SaintMartin"
        case .vietnam: return "Vietnam"
        case .martinique: return "Martinique"
        case .djibouti: return "Djibouti"
        case .holySeeVaticanCityState: return "HolySeeVaticanCityState"
        case .angola: return "Angola"
        case .qatar: return "Qatar"
        case .reunion: return "Reunion"
        case .saintVincentAndTheGrenadines: return "SaintVincentAndTheGrenadines"
        case .austria: return "Austria"
        case .seychelles: return "Seychelles"
        case .saudiArabia: return "SaudiArabia"
        case .somalia: return "Somalia"
        case .norway: return "Norway"
        case .guadeloupe: return "Guadeloupe"
        case .chile: return "Chile"
        case .mexico: return "Mexico"
        case .india: return "India"
        case .germany: return "Germany"
        case .burkinaFaso: return "BurkinaFaso"
        case .anguilla: return "Anguilla"
        case .lesotho: return "Lesotho"
        case .denmark: return "Denmark"
        case .southSudan: return "SouthSudan"
        case .newCaledonia: return "NewCaledonia"
        case .iran: return "Iran"
        case .mayotte: return "Mayotte"
        case .cyprus: return "Cyprus"
        case .mozambique: return "Mozambique"
        case .nigeria: return "Nigeria"
        case .aruba: return "Aruba"
        case .antiguaAndBarbuda: return "AntiguaAndBarbuda"
        case .zambia: return "Zambia"
        case .serbia: return "Serbia"
        case .uk: return "Uk"
        case .indonesia: return "Indonesia"
        case .isleOfMan: return "IsleOfMan"
        case .uzbekistan: return "Uzbekistan"
        case .faroeIslands: return "FaroeIslands"
        case .ireland: return "Ireland"
        case .jamaica: return "Jamaica"
        case .burundi: return "Burundi"
        case .centralAfricanRepublic: return "CentralAfricanRepublic"
        case .philippines: return "Philippines"
        case .uae: return "Uae"
        case .sierraLeone: return "SierraLeone"
        case .belgium: return "Belgium"
        case .slovakia: return "Slovakia"
        case .__unknown(let value): return value
      }
    }

    public static func == (lhs: CountryIdentifier, rhs: CountryIdentifier) -> Bool {
      switch (lhs, rhs) {
        case (.turksAndCaicosIslands, .turksAndCaicosIslands): return true
        case (.dominicanRepublic, .dominicanRepublic): return true
        case (.greece, .greece): return true
        case (.senegal, .senegal): return true
        case (.panama, .panama): return true
        case (.syrianArabRepublic, .syrianArabRepublic): return true
        case (.ethiopia, .ethiopia): return true
        case (.fiji, .fiji): return true
        case (.kazakhstan, .kazakhstan): return true
        case (.brazil, .brazil): return true
        case (.libyanArabJamahiriya, .libyanArabJamahiriya): return true
        case (.lithuania, .lithuania): return true
        case (.andorra, .andorra): return true
        case (.trinidadAndTobago, .trinidadAndTobago): return true
        case (.saintKittsAndNevis, .saintKittsAndNevis): return true
        case (.brunei, .brunei): return true
        case (.argentina, .argentina): return true
        case (.finland, .finland): return true
        case (.costaRica, .costaRica): return true
        case (.portugal, .portugal): return true
        case (.rwanda, .rwanda): return true
        case (.australia, .australia): return true
        case (.guineaBissau, .guineaBissau): return true
        case (.gabon, .gabon): return true
        case (.saintLucia, .saintLucia): return true
        case (.sudan, .sudan): return true
        case (.yemen, .yemen): return true
        case (.barbados, .barbados): return true
        case (.guyana, .guyana): return true
        case (.ecuador, .ecuador): return true
        case (.macao, .macao): return true
        case (.colombia, .colombia): return true
        case (.poland, .poland): return true
        case (.sanMarino, .sanMarino): return true
        case (.swaziland, .swaziland): return true
        case (.venezuela, .venezuela): return true
        case (.cambodia, .cambodia): return true
        case (.westernSahara, .westernSahara): return true
        case (.kenya, .kenya): return true
        case (.turkey, .turkey): return true
        case (.malawi, .malawi): return true
        case (.tajikistan, .tajikistan): return true
        case (.nicaragua, .nicaragua): return true
        case (.israel, .israel): return true
        case (.bangladesh, .bangladesh): return true
        case (.sKorea, .sKorea): return true
        case (.chad, .chad): return true
        case (.zimbabwe, .zimbabwe): return true
        case (.montserrat, .montserrat): return true
        case (.comoros, .comoros): return true
        case (.uruguay, .uruguay): return true
        case (.switzerland, .switzerland): return true
        case (.cuba, .cuba): return true
        case (.jordan, .jordan): return true
        case (.congo, .congo): return true
        case (.uganda, .uganda): return true
        case (.greenland, .greenland): return true
        case (.southAfrica, .southAfrica): return true
        case (.elSalvador, .elSalvador): return true
        case (.grenada, .grenada): return true
        case (.suriname, .suriname): return true
        case (.mauritius, .mauritius): return true
        case (.malta, .malta): return true
        case (.ghana, .ghana): return true
        case (.latvia, .latvia): return true
        case (.paraguay, .paraguay): return true
        case (.niger, .niger): return true
        case (.guinea, .guinea): return true
        case (.taiwan, .taiwan): return true
        case (.papuaNewGuinea, .papuaNewGuinea): return true
        case (.togo, .togo): return true
        case (.liechtenstein, .liechtenstein): return true
        case (.ukraine, .ukraine): return true
        case (.equatorialGuinea, .equatorialGuinea): return true
        case (.spain, .spain): return true
        case (.madagascar, .madagascar): return true
        case (.georgia, .georgia): return true
        case (.montenegro, .montenegro): return true
        case (.belize, .belize): return true
        case (.thailand, .thailand): return true
        case (.armenia, .armenia): return true
        case (.usa, .usa): return true
        case (.maldives, .maldives): return true
        case (.drc, .drc): return true
        case (.gambia, .gambia): return true
        case (.kuwait, .kuwait): return true
        case (.bhutan, .bhutan): return true
        case (.mongolia, .mongolia): return true
        case (.liberia, .liberia): return true
        case (.nepal, .nepal): return true
        case (.msZaandam, .msZaandam): return true
        case (.moldova, .moldova): return true
        case (.oman, .oman): return true
        case (.pakistan, .pakistan): return true
        case (.coteDIvoire, .coteDIvoire): return true
        case (.monaco, .monaco): return true
        case (.curacao, .curacao): return true
        case (.bosnia, .bosnia): return true
        case (.albania, .albania): return true
        case (.saintPierreMiquelon, .saintPierreMiquelon): return true
        case (.mali, .mali): return true
        case (.netherlands, .netherlands): return true
        case (.stBarth, .stBarth): return true
        case (.britishVirginIslands, .britishVirginIslands): return true
        case (.france, .france): return true
        case (.croatia, .croatia): return true
        case (.falklandIslandsMalvinas, .falklandIslandsMalvinas): return true
        case (.bolivia, .bolivia): return true
        case (.bermuda, .bermuda): return true
        case (.bahrain, .bahrain): return true
        case (.palestine, .palestine): return true
        case (.japan, .japan): return true
        case (.azerbaijan, .azerbaijan): return true
        case (.hungary, .hungary): return true
        case (.kyrgyzstan, .kyrgyzstan): return true
        case (.cameroon, .cameroon): return true
        case (.algeria, .algeria): return true
        case (.haiti, .haiti): return true
        case (.myanmar, .myanmar): return true
        case (.macedonia, .macedonia): return true
        case (.malaysia, .malaysia): return true
        case (.russia, .russia): return true
        case (.sweden, .sweden): return true
        case (.eritrea, .eritrea): return true
        case (.gibraltar, .gibraltar): return true
        case (.lebanon, .lebanon): return true
        case (.hongKong, .hongKong): return true
        case (.laoPeopleSDemocraticRepublic, .laoPeopleSDemocraticRepublic): return true
        case (.morocco, .morocco): return true
        case (.tanzania, .tanzania): return true
        case (.botswana, .botswana): return true
        case (.egypt, .egypt): return true
        case (.sriLanka, .sriLanka): return true
        case (.czechia, .czechia): return true
        case (.caboVerde, .caboVerde): return true
        case (.romania, .romania): return true
        case (.tunisia, .tunisia): return true
        case (.sintMaarten, .sintMaarten): return true
        case (.slovenia, .slovenia): return true
        case (.singapore, .singapore): return true
        case (.namibia, .namibia): return true
        case (.estonia, .estonia): return true
        case (.mauritania, .mauritania): return true
        case (.italy, .italy): return true
        case (.iceland, .iceland): return true
        case (.afghanistan, .afghanistan): return true
        case (.bulgaria, .bulgaria): return true
        case (.diamondPrincess, .diamondPrincess): return true
        case (.china, .china): return true
        case (.belarus, .belarus): return true
        case (.frenchPolynesia, .frenchPolynesia): return true
        case (.peru, .peru): return true
        case (.channelIslands, .channelIslands): return true
        case (.bahamas, .bahamas): return true
        case (.canada, .canada): return true
        case (.honduras, .honduras): return true
        case (.newZealand, .newZealand): return true
        case (.iraq, .iraq): return true
        case (.saoTomeAndPrincipe, .saoTomeAndPrincipe): return true
        case (.luxembourg, .luxembourg): return true
        case (.dominica, .dominica): return true
        case (.frenchGuiana, .frenchGuiana): return true
        case (.caymanIslands, .caymanIslands): return true
        case (.benin, .benin): return true
        case (.caribbeanNetherlands, .caribbeanNetherlands): return true
        case (.timorLeste, .timorLeste): return true
        case (.guatemala, .guatemala): return true
        case (.saintMartin, .saintMartin): return true
        case (.vietnam, .vietnam): return true
        case (.martinique, .martinique): return true
        case (.djibouti, .djibouti): return true
        case (.holySeeVaticanCityState, .holySeeVaticanCityState): return true
        case (.angola, .angola): return true
        case (.qatar, .qatar): return true
        case (.reunion, .reunion): return true
        case (.saintVincentAndTheGrenadines, .saintVincentAndTheGrenadines): return true
        case (.austria, .austria): return true
        case (.seychelles, .seychelles): return true
        case (.saudiArabia, .saudiArabia): return true
        case (.somalia, .somalia): return true
        case (.norway, .norway): return true
        case (.guadeloupe, .guadeloupe): return true
        case (.chile, .chile): return true
        case (.mexico, .mexico): return true
        case (.india, .india): return true
        case (.germany, .germany): return true
        case (.burkinaFaso, .burkinaFaso): return true
        case (.anguilla, .anguilla): return true
        case (.lesotho, .lesotho): return true
        case (.denmark, .denmark): return true
        case (.southSudan, .southSudan): return true
        case (.newCaledonia, .newCaledonia): return true
        case (.iran, .iran): return true
        case (.mayotte, .mayotte): return true
        case (.cyprus, .cyprus): return true
        case (.mozambique, .mozambique): return true
        case (.nigeria, .nigeria): return true
        case (.aruba, .aruba): return true
        case (.antiguaAndBarbuda, .antiguaAndBarbuda): return true
        case (.zambia, .zambia): return true
        case (.serbia, .serbia): return true
        case (.uk, .uk): return true
        case (.indonesia, .indonesia): return true
        case (.isleOfMan, .isleOfMan): return true
        case (.uzbekistan, .uzbekistan): return true
        case (.faroeIslands, .faroeIslands): return true
        case (.ireland, .ireland): return true
        case (.jamaica, .jamaica): return true
        case (.burundi, .burundi): return true
        case (.centralAfricanRepublic, .centralAfricanRepublic): return true
        case (.philippines, .philippines): return true
        case (.uae, .uae): return true
        case (.sierraLeone, .sierraLeone): return true
        case (.belgium, .belgium): return true
        case (.slovakia, .slovakia): return true
        case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
        default: return false
      }
    }

    public static var allCases: [CountryIdentifier] {
      return [
        .turksAndCaicosIslands,
        .dominicanRepublic,
        .greece,
        .senegal,
        .panama,
        .syrianArabRepublic,
        .ethiopia,
        .fiji,
        .kazakhstan,
        .brazil,
        .libyanArabJamahiriya,
        .lithuania,
        .andorra,
        .trinidadAndTobago,
        .saintKittsAndNevis,
        .brunei,
        .argentina,
        .finland,
        .costaRica,
        .portugal,
        .rwanda,
        .australia,
        .guineaBissau,
        .gabon,
        .saintLucia,
        .sudan,
        .yemen,
        .barbados,
        .guyana,
        .ecuador,
        .macao,
        .colombia,
        .poland,
        .sanMarino,
        .swaziland,
        .venezuela,
        .cambodia,
        .westernSahara,
        .kenya,
        .turkey,
        .malawi,
        .tajikistan,
        .nicaragua,
        .israel,
        .bangladesh,
        .sKorea,
        .chad,
        .zimbabwe,
        .montserrat,
        .comoros,
        .uruguay,
        .switzerland,
        .cuba,
        .jordan,
        .congo,
        .uganda,
        .greenland,
        .southAfrica,
        .elSalvador,
        .grenada,
        .suriname,
        .mauritius,
        .malta,
        .ghana,
        .latvia,
        .paraguay,
        .niger,
        .guinea,
        .taiwan,
        .papuaNewGuinea,
        .togo,
        .liechtenstein,
        .ukraine,
        .equatorialGuinea,
        .spain,
        .madagascar,
        .georgia,
        .montenegro,
        .belize,
        .thailand,
        .armenia,
        .usa,
        .maldives,
        .drc,
        .gambia,
        .kuwait,
        .bhutan,
        .mongolia,
        .liberia,
        .nepal,
        .msZaandam,
        .moldova,
        .oman,
        .pakistan,
        .coteDIvoire,
        .monaco,
        .curacao,
        .bosnia,
        .albania,
        .saintPierreMiquelon,
        .mali,
        .netherlands,
        .stBarth,
        .britishVirginIslands,
        .france,
        .croatia,
        .falklandIslandsMalvinas,
        .bolivia,
        .bermuda,
        .bahrain,
        .palestine,
        .japan,
        .azerbaijan,
        .hungary,
        .kyrgyzstan,
        .cameroon,
        .algeria,
        .haiti,
        .myanmar,
        .macedonia,
        .malaysia,
        .russia,
        .sweden,
        .eritrea,
        .gibraltar,
        .lebanon,
        .hongKong,
        .laoPeopleSDemocraticRepublic,
        .morocco,
        .tanzania,
        .botswana,
        .egypt,
        .sriLanka,
        .czechia,
        .caboVerde,
        .romania,
        .tunisia,
        .sintMaarten,
        .slovenia,
        .singapore,
        .namibia,
        .estonia,
        .mauritania,
        .italy,
        .iceland,
        .afghanistan,
        .bulgaria,
        .diamondPrincess,
        .china,
        .belarus,
        .frenchPolynesia,
        .peru,
        .channelIslands,
        .bahamas,
        .canada,
        .honduras,
        .newZealand,
        .iraq,
        .saoTomeAndPrincipe,
        .luxembourg,
        .dominica,
        .frenchGuiana,
        .caymanIslands,
        .benin,
        .caribbeanNetherlands,
        .timorLeste,
        .guatemala,
        .saintMartin,
        .vietnam,
        .martinique,
        .djibouti,
        .holySeeVaticanCityState,
        .angola,
        .qatar,
        .reunion,
        .saintVincentAndTheGrenadines,
        .austria,
        .seychelles,
        .saudiArabia,
        .somalia,
        .norway,
        .guadeloupe,
        .chile,
        .mexico,
        .india,
        .germany,
        .burkinaFaso,
        .anguilla,
        .lesotho,
        .denmark,
        .southSudan,
        .newCaledonia,
        .iran,
        .mayotte,
        .cyprus,
        .mozambique,
        .nigeria,
        .aruba,
        .antiguaAndBarbuda,
        .zambia,
        .serbia,
        .uk,
        .indonesia,
        .isleOfMan,
        .uzbekistan,
        .faroeIslands,
        .ireland,
        .jamaica,
        .burundi,
        .centralAfricanRepublic,
        .philippines,
        .uae,
        .sierraLeone,
        .belgium,
        .slovakia,
      ]
    }
  }

  public final class ContentViewCountriesCountryConnectionBasicCountryCellCountryQuery: GraphQLQuery {
    /// The raw GraphQL definition of this operation.
    public let operationDefinition: String =
      """
      query ContentViewCountriesCountryConnectionBasicCountryCellCountry($last: Int, $first: Int, $after: String, $before: String) {
        countries(after: $after, before: $before, first: $first, last: $last) {
          __typename
          ...CountryConnectionBasicCountryCellCountry
        }
      }
      """

    public let operationName: String = "ContentViewCountriesCountryConnectionBasicCountryCellCountry"

    public var queryDocument: String { return operationDefinition.appending("\n" + CountryConnectionBasicCountryCellCountry.fragmentDefinition).appending("\n" + BasicCountryCellCountry.fragmentDefinition) }

    public var last: Int?
    public var first: Int?
    public var after: String?
    public var before: String?

    public init(last: Int? = nil, first: Int? = nil, after: String? = nil, before: String? = nil) {
      self.last = last
      self.first = first
      self.after = after
      self.before = before
    }

    public var variables: GraphQLMap? {
      return ["last": last, "first": first, "after": after, "before": before]
    }

    public struct Data: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Query"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("countries", arguments: ["after": GraphQLVariable("after"), "before": GraphQLVariable("before"), "first": GraphQLVariable("first"), "last": GraphQLVariable("last")], type: .nonNull(.object(Country.selections))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(countries: Country) {
        self.init(unsafeResultMap: ["__typename": "Query", "countries": countries.resultMap])
      }

      public var countries: Country {
        get {
          return Country(unsafeResultMap: resultMap["countries"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "countries")
        }
      }

      public struct Country: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["CountryConnection"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLFragmentSpread(CountryConnectionBasicCountryCellCountry.self),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var countryConnectionBasicCountryCellCountry: CountryConnectionBasicCountryCellCountry {
            get {
              return CountryConnectionBasicCountryCellCountry(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }
    }
  }

  public final class CountryDetailViewQuery: GraphQLQuery {
    /// The raw GraphQL definition of this operation.
    public let operationDefinition: String =
      """
      query CountryDetailView($identifier: CountryIdentifier!, $since: Date!, $numberOfPoints: Int!) {
        country(identifier: $identifier) {
          __typename
          ...StatsViewAffected
          info {
            __typename
            iso2
          }
          name
          news {
            __typename
            ...NewsStoryCellNewsStory
            image
          }
          timeline {
            __typename
            cases {
              __typename
              graph(numberOfPoints: $numberOfPoints, since: $since) {
                __typename
                value
              }
            }
            deaths {
              __typename
              graph(numberOfPoints: $numberOfPoints, since: $since) {
                __typename
                value
              }
            }
            recovered {
              __typename
              graph(numberOfPoints: $numberOfPoints, since: $since) {
                __typename
                value
              }
            }
          }
          todayCases
          todayDeaths
        }
      }
      """

    public let operationName: String = "CountryDetailView"

    public var queryDocument: String { return operationDefinition.appending("\n" + StatsViewAffected.fragmentDefinition).appending("\n" + NewsStoryCellNewsStory.fragmentDefinition) }

    public var identifier: CountryIdentifier
    public var since: String
    public var numberOfPoints: Int

    public init(identifier: CountryIdentifier, since: String, numberOfPoints: Int) {
      self.identifier = identifier
      self.since = since
      self.numberOfPoints = numberOfPoints
    }

    public var variables: GraphQLMap? {
      return ["identifier": identifier, "since": since, "numberOfPoints": numberOfPoints]
    }

    public struct Data: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Query"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("country", arguments: ["identifier": GraphQLVariable("identifier")], type: .nonNull(.object(Country.selections))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(country: Country) {
        self.init(unsafeResultMap: ["__typename": "Query", "country": country.resultMap])
      }

      public var country: Country {
        get {
          return Country(unsafeResultMap: resultMap["country"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "country")
        }
      }

      public struct Country: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Country"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLFragmentSpread(StatsViewAffected.self),
            GraphQLField("info", type: .nonNull(.object(Info.selections))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
            GraphQLField("news", type: .nonNull(.list(.nonNull(.object(News.selections))))),
            GraphQLField("timeline", type: .nonNull(.object(Timeline.selections))),
            GraphQLField("todayCases", type: .nonNull(.scalar(Int.self))),
            GraphQLField("todayDeaths", type: .nonNull(.scalar(Int.self))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var info: Info {
          get {
            return Info(unsafeResultMap: resultMap["info"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "info")
          }
        }

        public var name: String {
          get {
            return resultMap["name"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }

        public var news: [News] {
          get {
            return (resultMap["news"] as! [ResultMap]).map { (value: ResultMap) -> News in News(unsafeResultMap: value) }
          }
          set {
            resultMap.updateValue(newValue.map { (value: News) -> ResultMap in value.resultMap }, forKey: "news")
          }
        }

        public var timeline: Timeline {
          get {
            return Timeline(unsafeResultMap: resultMap["timeline"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "timeline")
          }
        }

        public var todayCases: Int {
          get {
            return resultMap["todayCases"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "todayCases")
          }
        }

        public var todayDeaths: Int {
          get {
            return resultMap["todayDeaths"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "todayDeaths")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var statsViewAffected: StatsViewAffected {
            get {
              return StatsViewAffected(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }

        public struct Info: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Info"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("iso2", type: .scalar(String.self)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(iso2: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "Info", "iso2": iso2])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var iso2: String? {
            get {
              return resultMap["iso2"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "iso2")
            }
          }
        }

        public struct News: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["NewsStory"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLFragmentSpread(NewsStoryCellNewsStory.self),
              GraphQLField("image", type: .scalar(String.self)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var image: String? {
            get {
              return resultMap["image"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "image")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var newsStoryCellNewsStory: NewsStoryCellNewsStory {
              get {
                return NewsStoryCellNewsStory(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }
        }

        public struct Timeline: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Timeline"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("cases", type: .nonNull(.object(Case.selections))),
              GraphQLField("deaths", type: .nonNull(.object(Death.selections))),
              GraphQLField("recovered", type: .nonNull(.object(Recovered.selections))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(cases: Case, deaths: Death, recovered: Recovered) {
            self.init(unsafeResultMap: ["__typename": "Timeline", "cases": cases.resultMap, "deaths": deaths.resultMap, "recovered": recovered.resultMap])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var cases: Case {
            get {
              return Case(unsafeResultMap: resultMap["cases"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "cases")
            }
          }

          public var deaths: Death {
            get {
              return Death(unsafeResultMap: resultMap["deaths"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "deaths")
            }
          }

          public var recovered: Recovered {
            get {
              return Recovered(unsafeResultMap: resultMap["recovered"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "recovered")
            }
          }

          public struct Case: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["DataPointsCollection"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("graph", arguments: ["numberOfPoints": GraphQLVariable("numberOfPoints"), "since": GraphQLVariable("since")], type: .nonNull(.list(.nonNull(.object(Graph.selections))))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(graph: [Graph]) {
              self.init(unsafeResultMap: ["__typename": "DataPointsCollection", "graph": graph.map { (value: Graph) -> ResultMap in value.resultMap }])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var graph: [Graph] {
              get {
                return (resultMap["graph"] as! [ResultMap]).map { (value: ResultMap) -> Graph in Graph(unsafeResultMap: value) }
              }
              set {
                resultMap.updateValue(newValue.map { (value: Graph) -> ResultMap in value.resultMap }, forKey: "graph")
              }
            }

            public struct Graph: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["DataPoint"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("value", type: .nonNull(.scalar(Int.self))),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(value: Int) {
                self.init(unsafeResultMap: ["__typename": "DataPoint", "value": value])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var value: Int {
                get {
                  return resultMap["value"]! as! Int
                }
                set {
                  resultMap.updateValue(newValue, forKey: "value")
                }
              }
            }
          }

          public struct Death: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["DataPointsCollection"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("graph", arguments: ["numberOfPoints": GraphQLVariable("numberOfPoints"), "since": GraphQLVariable("since")], type: .nonNull(.list(.nonNull(.object(Graph.selections))))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(graph: [Graph]) {
              self.init(unsafeResultMap: ["__typename": "DataPointsCollection", "graph": graph.map { (value: Graph) -> ResultMap in value.resultMap }])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var graph: [Graph] {
              get {
                return (resultMap["graph"] as! [ResultMap]).map { (value: ResultMap) -> Graph in Graph(unsafeResultMap: value) }
              }
              set {
                resultMap.updateValue(newValue.map { (value: Graph) -> ResultMap in value.resultMap }, forKey: "graph")
              }
            }

            public struct Graph: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["DataPoint"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("value", type: .nonNull(.scalar(Int.self))),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(value: Int) {
                self.init(unsafeResultMap: ["__typename": "DataPoint", "value": value])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var value: Int {
                get {
                  return resultMap["value"]! as! Int
                }
                set {
                  resultMap.updateValue(newValue, forKey: "value")
                }
              }
            }
          }

          public struct Recovered: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["DataPointsCollection"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("graph", arguments: ["numberOfPoints": GraphQLVariable("numberOfPoints"), "since": GraphQLVariable("since")], type: .nonNull(.list(.nonNull(.object(Graph.selections))))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(graph: [Graph]) {
              self.init(unsafeResultMap: ["__typename": "DataPointsCollection", "graph": graph.map { (value: Graph) -> ResultMap in value.resultMap }])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var graph: [Graph] {
              get {
                return (resultMap["graph"] as! [ResultMap]).map { (value: ResultMap) -> Graph in Graph(unsafeResultMap: value) }
              }
              set {
                resultMap.updateValue(newValue.map { (value: Graph) -> ResultMap in value.resultMap }, forKey: "graph")
              }
            }

            public struct Graph: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["DataPoint"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("value", type: .nonNull(.scalar(Int.self))),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(value: Int) {
                self.init(unsafeResultMap: ["__typename": "DataPoint", "value": value])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var value: Int {
                get {
                  return resultMap["value"]! as! Int
                }
                set {
                  resultMap.updateValue(newValue, forKey: "value")
                }
              }
            }
          }
        }
      }
    }
  }

  public final class ContentViewQuery: GraphQLQuery {
    /// The raw GraphQL definition of this operation.
    public let operationDefinition: String =
      """
      query ContentView($last: Int, $first: Int, $after: String, $before: String, $since: Date!, $numberOfPoints: Int!) {
        countries(after: $after, before: $before, first: $first, last: $last) {
          __typename
          ...CountryConnectionBasicCountryCellCountry
          edges {
            __typename
            node {
              __typename
              ...CountryMapPinCountry
            }
          }
        }
        myCountry {
          __typename
          ...StatsViewAffected
          info {
            __typename
            iso2
          }
          name
          timeline {
            __typename
            cases {
              __typename
              graph(numberOfPoints: $numberOfPoints, since: $since) {
                __typename
                value
              }
            }
          }
          todayDeaths
          ...StatsViewAffected
          name
          news {
            __typename
            ...NewsStoryCellNewsStory
          }
        }
        world {
          __typename
          ...CurrentStateCellWorld
          news {
            __typename
            ...NewsStoryCellNewsStory
          }
          timeline {
            __typename
            cases {
              __typename
              graph(numberOfPoints: $numberOfPoints, since: $since) {
                __typename
                value
              }
            }
            deaths {
              __typename
              graph(numberOfPoints: $numberOfPoints, since: $since) {
                __typename
                value
              }
            }
            recovered {
              __typename
              graph(numberOfPoints: $numberOfPoints, since: $since) {
                __typename
                value
              }
            }
          }
        }
      }
      """

    public let operationName: String = "ContentView"

    public var queryDocument: String { return operationDefinition.appending("\n" + CountryConnectionBasicCountryCellCountry.fragmentDefinition).appending("\n" + BasicCountryCellCountry.fragmentDefinition).appending("\n" + CountryMapPinCountry.fragmentDefinition).appending("\n" + StatsViewAffected.fragmentDefinition).appending("\n" + NewsStoryCellNewsStory.fragmentDefinition).appending("\n" + CurrentStateCellWorld.fragmentDefinition) }

    public var last: Int?
    public var first: Int?
    public var after: String?
    public var before: String?
    public var since: String
    public var numberOfPoints: Int

    public init(last: Int? = nil, first: Int? = nil, after: String? = nil, before: String? = nil, since: String, numberOfPoints: Int) {
      self.last = last
      self.first = first
      self.after = after
      self.before = before
      self.since = since
      self.numberOfPoints = numberOfPoints
    }

    public var variables: GraphQLMap? {
      return ["last": last, "first": first, "after": after, "before": before, "since": since, "numberOfPoints": numberOfPoints]
    }

    public struct Data: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Query"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("countries", arguments: ["after": GraphQLVariable("after"), "before": GraphQLVariable("before"), "first": GraphQLVariable("first"), "last": GraphQLVariable("last")], type: .nonNull(.object(Country.selections))),
          GraphQLField("myCountry", type: .object(MyCountry.selections)),
          GraphQLField("world", type: .nonNull(.object(World.selections))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(countries: Country, myCountry: MyCountry? = nil, world: World) {
        self.init(unsafeResultMap: ["__typename": "Query", "countries": countries.resultMap, "myCountry": myCountry.flatMap { (value: MyCountry) -> ResultMap in value.resultMap }, "world": world.resultMap])
      }

      public var countries: Country {
        get {
          return Country(unsafeResultMap: resultMap["countries"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "countries")
        }
      }

      public var myCountry: MyCountry? {
        get {
          return (resultMap["myCountry"] as? ResultMap).flatMap { MyCountry(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "myCountry")
        }
      }

      public var world: World {
        get {
          return World(unsafeResultMap: resultMap["world"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "world")
        }
      }

      public struct Country: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["CountryConnection"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLFragmentSpread(CountryConnectionBasicCountryCellCountry.self),
            GraphQLField("edges", type: .list(.object(Edge.selections))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var edges: [Edge?]? {
          get {
            return (resultMap["edges"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Edge?] in value.map { (value: ResultMap?) -> Edge? in value.flatMap { (value: ResultMap) -> Edge in Edge(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }, forKey: "edges")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var countryConnectionBasicCountryCellCountry: CountryConnectionBasicCountryCellCountry {
            get {
              return CountryConnectionBasicCountryCellCountry(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }

        public struct Edge: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["CountryEdge"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("node", type: .object(Node.selections)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(node: Node? = nil) {
            self.init(unsafeResultMap: ["__typename": "CountryEdge", "node": node.flatMap { (value: Node) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var node: Node? {
            get {
              return (resultMap["node"] as? ResultMap).flatMap { Node(unsafeResultMap: $0) }
            }
            set {
              resultMap.updateValue(newValue?.resultMap, forKey: "node")
            }
          }

          public struct Node: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["Country"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLFragmentSpread(CountryMapPinCountry.self),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var fragments: Fragments {
              get {
                return Fragments(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public struct Fragments {
              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public var countryMapPinCountry: CountryMapPinCountry {
                get {
                  return CountryMapPinCountry(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }
            }
          }
        }
      }

      public struct MyCountry: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Country"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLFragmentSpread(StatsViewAffected.self),
            GraphQLField("info", type: .nonNull(.object(Info.selections))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
            GraphQLField("timeline", type: .nonNull(.object(Timeline.selections))),
            GraphQLField("todayDeaths", type: .nonNull(.scalar(Int.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
            GraphQLField("news", type: .nonNull(.list(.nonNull(.object(News.selections))))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var info: Info {
          get {
            return Info(unsafeResultMap: resultMap["info"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "info")
          }
        }

        public var name: String {
          get {
            return resultMap["name"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }

        public var timeline: Timeline {
          get {
            return Timeline(unsafeResultMap: resultMap["timeline"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "timeline")
          }
        }

        public var todayDeaths: Int {
          get {
            return resultMap["todayDeaths"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "todayDeaths")
          }
        }

        public var news: [News] {
          get {
            return (resultMap["news"] as! [ResultMap]).map { (value: ResultMap) -> News in News(unsafeResultMap: value) }
          }
          set {
            resultMap.updateValue(newValue.map { (value: News) -> ResultMap in value.resultMap }, forKey: "news")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var statsViewAffected: StatsViewAffected {
            get {
              return StatsViewAffected(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }

        public struct Info: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Info"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("iso2", type: .scalar(String.self)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(iso2: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "Info", "iso2": iso2])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var iso2: String? {
            get {
              return resultMap["iso2"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "iso2")
            }
          }
        }

        public struct Timeline: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Timeline"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("cases", type: .nonNull(.object(Case.selections))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(cases: Case) {
            self.init(unsafeResultMap: ["__typename": "Timeline", "cases": cases.resultMap])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var cases: Case {
            get {
              return Case(unsafeResultMap: resultMap["cases"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "cases")
            }
          }

          public struct Case: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["DataPointsCollection"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("graph", arguments: ["numberOfPoints": GraphQLVariable("numberOfPoints"), "since": GraphQLVariable("since")], type: .nonNull(.list(.nonNull(.object(Graph.selections))))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(graph: [Graph]) {
              self.init(unsafeResultMap: ["__typename": "DataPointsCollection", "graph": graph.map { (value: Graph) -> ResultMap in value.resultMap }])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var graph: [Graph] {
              get {
                return (resultMap["graph"] as! [ResultMap]).map { (value: ResultMap) -> Graph in Graph(unsafeResultMap: value) }
              }
              set {
                resultMap.updateValue(newValue.map { (value: Graph) -> ResultMap in value.resultMap }, forKey: "graph")
              }
            }

            public struct Graph: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["DataPoint"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("value", type: .nonNull(.scalar(Int.self))),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(value: Int) {
                self.init(unsafeResultMap: ["__typename": "DataPoint", "value": value])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var value: Int {
                get {
                  return resultMap["value"]! as! Int
                }
                set {
                  resultMap.updateValue(newValue, forKey: "value")
                }
              }
            }
          }
        }

        public struct News: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["NewsStory"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLFragmentSpread(NewsStoryCellNewsStory.self),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var newsStoryCellNewsStory: NewsStoryCellNewsStory {
              get {
                return NewsStoryCellNewsStory(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }
        }
      }

      public struct World: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["World"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLFragmentSpread(CurrentStateCellWorld.self),
            GraphQLField("news", type: .nonNull(.list(.nonNull(.object(News.selections))))),
            GraphQLField("timeline", type: .nonNull(.object(Timeline.selections))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var news: [News] {
          get {
            return (resultMap["news"] as! [ResultMap]).map { (value: ResultMap) -> News in News(unsafeResultMap: value) }
          }
          set {
            resultMap.updateValue(newValue.map { (value: News) -> ResultMap in value.resultMap }, forKey: "news")
          }
        }

        public var timeline: Timeline {
          get {
            return Timeline(unsafeResultMap: resultMap["timeline"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "timeline")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var currentStateCellWorld: CurrentStateCellWorld {
            get {
              return CurrentStateCellWorld(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }

        public struct News: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["NewsStory"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLFragmentSpread(NewsStoryCellNewsStory.self),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var newsStoryCellNewsStory: NewsStoryCellNewsStory {
              get {
                return NewsStoryCellNewsStory(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }
        }

        public struct Timeline: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Timeline"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("cases", type: .nonNull(.object(Case.selections))),
              GraphQLField("deaths", type: .nonNull(.object(Death.selections))),
              GraphQLField("recovered", type: .nonNull(.object(Recovered.selections))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(cases: Case, deaths: Death, recovered: Recovered) {
            self.init(unsafeResultMap: ["__typename": "Timeline", "cases": cases.resultMap, "deaths": deaths.resultMap, "recovered": recovered.resultMap])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var cases: Case {
            get {
              return Case(unsafeResultMap: resultMap["cases"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "cases")
            }
          }

          public var deaths: Death {
            get {
              return Death(unsafeResultMap: resultMap["deaths"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "deaths")
            }
          }

          public var recovered: Recovered {
            get {
              return Recovered(unsafeResultMap: resultMap["recovered"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "recovered")
            }
          }

          public struct Case: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["DataPointsCollection"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("graph", arguments: ["numberOfPoints": GraphQLVariable("numberOfPoints"), "since": GraphQLVariable("since")], type: .nonNull(.list(.nonNull(.object(Graph.selections))))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(graph: [Graph]) {
              self.init(unsafeResultMap: ["__typename": "DataPointsCollection", "graph": graph.map { (value: Graph) -> ResultMap in value.resultMap }])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var graph: [Graph] {
              get {
                return (resultMap["graph"] as! [ResultMap]).map { (value: ResultMap) -> Graph in Graph(unsafeResultMap: value) }
              }
              set {
                resultMap.updateValue(newValue.map { (value: Graph) -> ResultMap in value.resultMap }, forKey: "graph")
              }
            }

            public struct Graph: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["DataPoint"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("value", type: .nonNull(.scalar(Int.self))),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(value: Int) {
                self.init(unsafeResultMap: ["__typename": "DataPoint", "value": value])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var value: Int {
                get {
                  return resultMap["value"]! as! Int
                }
                set {
                  resultMap.updateValue(newValue, forKey: "value")
                }
              }
            }
          }

          public struct Death: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["DataPointsCollection"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("graph", arguments: ["numberOfPoints": GraphQLVariable("numberOfPoints"), "since": GraphQLVariable("since")], type: .nonNull(.list(.nonNull(.object(Graph.selections))))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(graph: [Graph]) {
              self.init(unsafeResultMap: ["__typename": "DataPointsCollection", "graph": graph.map { (value: Graph) -> ResultMap in value.resultMap }])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var graph: [Graph] {
              get {
                return (resultMap["graph"] as! [ResultMap]).map { (value: ResultMap) -> Graph in Graph(unsafeResultMap: value) }
              }
              set {
                resultMap.updateValue(newValue.map { (value: Graph) -> ResultMap in value.resultMap }, forKey: "graph")
              }
            }

            public struct Graph: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["DataPoint"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("value", type: .nonNull(.scalar(Int.self))),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(value: Int) {
                self.init(unsafeResultMap: ["__typename": "DataPoint", "value": value])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var value: Int {
                get {
                  return resultMap["value"]! as! Int
                }
                set {
                  resultMap.updateValue(newValue, forKey: "value")
                }
              }
            }
          }

          public struct Recovered: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["DataPointsCollection"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("graph", arguments: ["numberOfPoints": GraphQLVariable("numberOfPoints"), "since": GraphQLVariable("since")], type: .nonNull(.list(.nonNull(.object(Graph.selections))))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(graph: [Graph]) {
              self.init(unsafeResultMap: ["__typename": "DataPointsCollection", "graph": graph.map { (value: Graph) -> ResultMap in value.resultMap }])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var graph: [Graph] {
              get {
                return (resultMap["graph"] as! [ResultMap]).map { (value: ResultMap) -> Graph in Graph(unsafeResultMap: value) }
              }
              set {
                resultMap.updateValue(newValue.map { (value: Graph) -> ResultMap in value.resultMap }, forKey: "graph")
              }
            }

            public struct Graph: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["DataPoint"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("value", type: .nonNull(.scalar(Int.self))),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(value: Int) {
                self.init(unsafeResultMap: ["__typename": "DataPoint", "value": value])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var value: Int {
                get {
                  return resultMap["value"]! as! Int
                }
                set {
                  resultMap.updateValue(newValue, forKey: "value")
                }
              }
            }
          }
        }
      }
    }
  }

  public struct CountryConnectionBasicCountryCellCountry: GraphQLFragment {
    /// The raw GraphQL definition of this fragment.
    public static let fragmentDefinition: String =
      """
      fragment CountryConnectionBasicCountryCellCountry on CountryConnection {
        __typename
        edges {
          __typename
          node {
            __typename
            ...BasicCountryCellCountry
          }
        }
        pageInfo {
          __typename
          endCursor
          hasNextPage
        }
      }
      """

    public static let possibleTypes: [String] = ["CountryConnection"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("edges", type: .list(.object(Edge.selections))),
        GraphQLField("pageInfo", type: .nonNull(.object(PageInfo.selections))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(edges: [Edge?]? = nil, pageInfo: PageInfo) {
      self.init(unsafeResultMap: ["__typename": "CountryConnection", "edges": edges.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }, "pageInfo": pageInfo.resultMap])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var edges: [Edge?]? {
      get {
        return (resultMap["edges"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Edge?] in value.map { (value: ResultMap?) -> Edge? in value.flatMap { (value: ResultMap) -> Edge in Edge(unsafeResultMap: value) } } }
      }
      set {
        resultMap.updateValue(newValue.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }, forKey: "edges")
      }
    }

    public var pageInfo: PageInfo {
      get {
        return PageInfo(unsafeResultMap: resultMap["pageInfo"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "pageInfo")
      }
    }

    public struct Edge: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["CountryEdge"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("node", type: .object(Node.selections)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(node: Node? = nil) {
        self.init(unsafeResultMap: ["__typename": "CountryEdge", "node": node.flatMap { (value: Node) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var node: Node? {
        get {
          return (resultMap["node"] as? ResultMap).flatMap { Node(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "node")
        }
      }

      public struct Node: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Country"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLFragmentSpread(BasicCountryCellCountry.self),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var basicCountryCellCountry: BasicCountryCellCountry {
            get {
              return BasicCountryCellCountry(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }
    }

    public struct PageInfo: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["PageInfo"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("endCursor", type: .scalar(String.self)),
          GraphQLField("hasNextPage", type: .nonNull(.scalar(Bool.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(endCursor: String? = nil, hasNextPage: Bool) {
        self.init(unsafeResultMap: ["__typename": "PageInfo", "endCursor": endCursor, "hasNextPage": hasNextPage])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var endCursor: String? {
        get {
          return resultMap["endCursor"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "endCursor")
        }
      }

      public var hasNextPage: Bool {
        get {
          return resultMap["hasNextPage"]! as! Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "hasNextPage")
        }
      }
    }
  }

  public struct BasicCountryCellCountry: GraphQLFragment {
    /// The raw GraphQL definition of this fragment.
    public static let fragmentDefinition: String =
      """
      fragment BasicCountryCellCountry on Country {
        __typename
        cases
        identifier
        info {
          __typename
          iso2
        }
        name
      }
      """

    public static let possibleTypes: [String] = ["Country"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("cases", type: .nonNull(.scalar(Int.self))),
        GraphQLField("identifier", type: .nonNull(.scalar(CountryIdentifier.self))),
        GraphQLField("info", type: .nonNull(.object(Info.selections))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(cases: Int, identifier: CountryIdentifier, info: Info, name: String) {
      self.init(unsafeResultMap: ["__typename": "Country", "cases": cases, "identifier": identifier, "info": info.resultMap, "name": name])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var cases: Int {
      get {
        return resultMap["cases"]! as! Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "cases")
      }
    }

    public var identifier: CountryIdentifier {
      get {
        return resultMap["identifier"]! as! CountryIdentifier
      }
      set {
        resultMap.updateValue(newValue, forKey: "identifier")
      }
    }

    public var info: Info {
      get {
        return Info(unsafeResultMap: resultMap["info"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "info")
      }
    }

    public var name: String {
      get {
        return resultMap["name"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "name")
      }
    }

    public struct Info: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Info"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("iso2", type: .scalar(String.self)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(iso2: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "Info", "iso2": iso2])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var iso2: String? {
        get {
          return resultMap["iso2"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "iso2")
        }
      }
    }
  }

  public struct CountryMapPinCountry: GraphQLFragment {
    /// The raw GraphQL definition of this fragment.
    public static let fragmentDefinition: String =
      """
      fragment CountryMapPinCountry on Country {
        __typename
        cases
        info {
          __typename
          latitude
          longitude
        }
      }
      """

    public static let possibleTypes: [String] = ["Country"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("cases", type: .nonNull(.scalar(Int.self))),
        GraphQLField("info", type: .nonNull(.object(Info.selections))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(cases: Int, info: Info) {
      self.init(unsafeResultMap: ["__typename": "Country", "cases": cases, "info": info.resultMap])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var cases: Int {
      get {
        return resultMap["cases"]! as! Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "cases")
      }
    }

    public var info: Info {
      get {
        return Info(unsafeResultMap: resultMap["info"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "info")
      }
    }

    public struct Info: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Info"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("latitude", type: .scalar(Double.self)),
          GraphQLField("longitude", type: .scalar(Double.self)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(latitude: Double? = nil, longitude: Double? = nil) {
        self.init(unsafeResultMap: ["__typename": "Info", "latitude": latitude, "longitude": longitude])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var latitude: Double? {
        get {
          return resultMap["latitude"] as? Double
        }
        set {
          resultMap.updateValue(newValue, forKey: "latitude")
        }
      }

      public var longitude: Double? {
        get {
          return resultMap["longitude"] as? Double
        }
        set {
          resultMap.updateValue(newValue, forKey: "longitude")
        }
      }
    }
  }

  public struct NewsStoryCellNewsStory: GraphQLFragment {
    /// The raw GraphQL definition of this fragment.
    public static let fragmentDefinition: String =
      """
      fragment NewsStoryCellNewsStory on NewsStory {
        __typename
        image
        overview
        source {
          __typename
          name
        }
        title
        url
      }
      """

    public static let possibleTypes: [String] = ["NewsStory"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("image", type: .scalar(String.self)),
        GraphQLField("overview", type: .scalar(String.self)),
        GraphQLField("source", type: .nonNull(.object(Source.selections))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("url", type: .nonNull(.scalar(String.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(image: String? = nil, overview: String? = nil, source: Source, title: String, url: String) {
      self.init(unsafeResultMap: ["__typename": "NewsStory", "image": image, "overview": overview, "source": source.resultMap, "title": title, "url": url])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var image: String? {
      get {
        return resultMap["image"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "image")
      }
    }

    public var overview: String? {
      get {
        return resultMap["overview"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "overview")
      }
    }

    public var source: Source {
      get {
        return Source(unsafeResultMap: resultMap["source"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "source")
      }
    }

    public var title: String {
      get {
        return resultMap["title"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "title")
      }
    }

    public var url: String {
      get {
        return resultMap["url"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "url")
      }
    }

    public struct Source: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Source"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(name: String) {
        self.init(unsafeResultMap: ["__typename": "Source", "name": name])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var name: String {
        get {
          return resultMap["name"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }
    }
  }

  public struct StatsViewAffected: GraphQLFragment {
    /// The raw GraphQL definition of this fragment.
    public static let fragmentDefinition: String =
      """
      fragment StatsViewAffected on Affected {
        __typename
        cases
        deaths
        recovered
      }
      """

    public static let possibleTypes: [String] = ["Country", "DetailedContinent", "World", "__Affected", "__Continent", "__DetailedAffected"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("cases", type: .nonNull(.scalar(Int.self))),
        GraphQLField("deaths", type: .nonNull(.scalar(Int.self))),
        GraphQLField("recovered", type: .nonNull(.scalar(Int.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public static func makeCountry(cases: Int, deaths: Int, recovered: Int) -> StatsViewAffected {
      return StatsViewAffected(unsafeResultMap: ["__typename": "Country", "cases": cases, "deaths": deaths, "recovered": recovered])
    }

    public static func makeDetailedContinent(cases: Int, deaths: Int, recovered: Int) -> StatsViewAffected {
      return StatsViewAffected(unsafeResultMap: ["__typename": "DetailedContinent", "cases": cases, "deaths": deaths, "recovered": recovered])
    }

    public static func makeWorld(cases: Int, deaths: Int, recovered: Int) -> StatsViewAffected {
      return StatsViewAffected(unsafeResultMap: ["__typename": "World", "cases": cases, "deaths": deaths, "recovered": recovered])
    }

    public static func make__Affected(cases: Int, deaths: Int, recovered: Int) -> StatsViewAffected {
      return StatsViewAffected(unsafeResultMap: ["__typename": "__Affected", "cases": cases, "deaths": deaths, "recovered": recovered])
    }

    public static func make__Continent(cases: Int, deaths: Int, recovered: Int) -> StatsViewAffected {
      return StatsViewAffected(unsafeResultMap: ["__typename": "__Continent", "cases": cases, "deaths": deaths, "recovered": recovered])
    }

    public static func make__DetailedAffected(cases: Int, deaths: Int, recovered: Int) -> StatsViewAffected {
      return StatsViewAffected(unsafeResultMap: ["__typename": "__DetailedAffected", "cases": cases, "deaths": deaths, "recovered": recovered])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var cases: Int {
      get {
        return resultMap["cases"]! as! Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "cases")
      }
    }

    public var deaths: Int {
      get {
        return resultMap["deaths"]! as! Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "deaths")
      }
    }

    public var recovered: Int {
      get {
        return resultMap["recovered"]! as! Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "recovered")
      }
    }
  }

  public struct CurrentStateCellWorld: GraphQLFragment {
    /// The raw GraphQL definition of this fragment.
    public static let fragmentDefinition: String =
      """
      fragment CurrentStateCellWorld on World {
        __typename
        ...StatsViewAffected
      }
      """

    public static let possibleTypes: [String] = ["World"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLFragmentSpread(StatsViewAffected.self),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(cases: Int, deaths: Int, recovered: Int) {
      self.init(unsafeResultMap: ["__typename": "World", "cases": cases, "deaths": deaths, "recovered": recovered])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var fragments: Fragments {
      get {
        return Fragments(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }

    public struct Fragments {
      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var statsViewAffected: StatsViewAffected {
        get {
          return StatsViewAffected(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }
    }
  }

  public struct FeaturedCountryCellCountry: GraphQLFragment {
    /// The raw GraphQL definition of this fragment.
    public static let fragmentDefinition: String =
      """
      fragment FeaturedCountryCellCountry on Country {
        __typename
        ...StatsViewAffected
        info {
          __typename
          iso2
        }
        name
        timeline {
          __typename
          cases {
            __typename
            graph {
              __typename
              value
            }
          }
        }
        todayDeaths
      }
      """

    public static let possibleTypes: [String] = ["Country"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLFragmentSpread(StatsViewAffected.self),
        GraphQLField("info", type: .nonNull(.object(Info.selections))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("timeline", type: .nonNull(.object(Timeline.selections))),
        GraphQLField("todayDeaths", type: .nonNull(.scalar(Int.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var info: Info {
      get {
        return Info(unsafeResultMap: resultMap["info"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "info")
      }
    }

    public var name: String {
      get {
        return resultMap["name"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "name")
      }
    }

    public var timeline: Timeline {
      get {
        return Timeline(unsafeResultMap: resultMap["timeline"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "timeline")
      }
    }

    public var todayDeaths: Int {
      get {
        return resultMap["todayDeaths"]! as! Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "todayDeaths")
      }
    }

    public var fragments: Fragments {
      get {
        return Fragments(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }

    public struct Fragments {
      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var statsViewAffected: StatsViewAffected {
        get {
          return StatsViewAffected(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }
    }

    public struct Info: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Info"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("iso2", type: .scalar(String.self)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(iso2: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "Info", "iso2": iso2])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var iso2: String? {
        get {
          return resultMap["iso2"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "iso2")
        }
      }
    }

    public struct Timeline: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Timeline"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("cases", type: .nonNull(.object(Case.selections))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(cases: Case) {
        self.init(unsafeResultMap: ["__typename": "Timeline", "cases": cases.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var cases: Case {
        get {
          return Case(unsafeResultMap: resultMap["cases"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "cases")
        }
      }

      public struct Case: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["DataPointsCollection"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("graph", type: .nonNull(.list(.nonNull(.object(Graph.selections))))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(graph: [Graph]) {
          self.init(unsafeResultMap: ["__typename": "DataPointsCollection", "graph": graph.map { (value: Graph) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var graph: [Graph] {
          get {
            return (resultMap["graph"] as! [ResultMap]).map { (value: ResultMap) -> Graph in Graph(unsafeResultMap: value) }
          }
          set {
            resultMap.updateValue(newValue.map { (value: Graph) -> ResultMap in value.resultMap }, forKey: "graph")
          }
        }

        public struct Graph: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["DataPoint"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("value", type: .nonNull(.scalar(Int.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(value: Int) {
            self.init(unsafeResultMap: ["__typename": "DataPoint", "value": value])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var value: Int {
            get {
              return resultMap["value"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "value")
            }
          }
        }
      }
    }
  }
}



