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

        static var countries: FragmentPath<[Covid.Country]> { .init() }

        static func country(identifier _: GraphQLArgument<Covid.CountryIdentifier> = .argument) -> FragmentPath<Covid.Country> {
            return .init()
        }

        static var country: FragmentPath<Covid.Country> { .init() }

        static var historicalData: FragmentPath<[Covid.HistoricalData]> { .init() }

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

            case southAmerica = "SouthAmerica"

            case africa = "Africa"

            case europe = "Europe"

            case northAmerica = "NorthAmerica"

            case asia = "Asia"

            case oceania = "Oceania"

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

        typealias CountryIdentifier = ApolloCovid.CountryIdentifier

        enum DataPoint: Target {
            typealias Path<V> = GraphQLPath<DataPoint, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<DataPoint, V>

            static var date: Path<String> { .init() }

            static var value: Path<Int> { .init() }

            static var _fragment: FragmentPath<DataPoint> { .init() }
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

            static var country: Path<Covid.CountryIdentifier?> { .init() }

            static var timeline: FragmentPath<Covid.Timeline> { .init() }

            static var _fragment: FragmentPath<HistoricalData> { .init() }
        }

        enum Info: Target {
            typealias Path<V> = GraphQLPath<Info, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<Info, V>

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

            static var cases: FragmentPath<[Covid.DataPoint]> { .init() }

            static var deaths: FragmentPath<[Covid.DataPoint]> { .init() }

            static var recovered: FragmentPath<[Covid.DataPoint]> { .init() }

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
        var country: Path<Covid.CountryIdentifier?> { .init() }

        var timeline: FragmentPath<Covid.Timeline> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.HistoricalData? {
        var country: Path<Covid.CountryIdentifier?> { .init() }

        var timeline: FragmentPath<Covid.Timeline?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.Info {
        var flag: Path<String> { .init() }

        var iso2: Path<String?> { .init() }

        var iso3: Path<String?> { .init() }

        var latitude: Path<Double?> { .init() }

        var longitude: Path<Double?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.Info? {
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

    extension GraphQLFragmentPath where UnderlyingType == Covid.Source {
        var id: Path<String?> { .init() }

        var name: Path<String> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.Source? {
        var id: Path<String?> { .init() }

        var name: Path<String?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.Timeline {
        var cases: FragmentPath<[Covid.DataPoint]> { .init() }

        var deaths: FragmentPath<[Covid.DataPoint]> { .init() }

        var recovered: FragmentPath<[Covid.DataPoint]> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.Timeline? {
        var cases: FragmentPath<[Covid.DataPoint]?> { .init() }

        var deaths: FragmentPath<[Covid.DataPoint]?> { .init() }

        var recovered: FragmentPath<[Covid.DataPoint]?> { .init() }
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
                      casesOverTime: GraphQL(data.country.timeline.cases.map { $0.value }),
                      deathsOverTime: GraphQL(data.country.timeline.deaths.map { $0.value }),
                      recoveredOverTime: GraphQL(data.country.timeline.recovered.map { $0.value }),
                      images: GraphQL(data.country.news.map { $0.image }),
                      news: GraphQL(data.country.news.map { $0.fragments.newsStoryCellNewsStory }))
        }
    }

    extension Covid {
        func countryDetailView<Loading: View, Error: View>(identifier: Covid.CountryIdentifier,
                                                           
                                                           @ViewBuilder loading: () -> Loading,
                                                           @ViewBuilder error: @escaping (QueryError) -> Error) -> some View {
            return QueryRenderer(client: client,
                                 query: ApolloCovid.CountryDetailViewQuery(identifier: identifier),
                                 loading: loading(),
                                 error: error) { (data: ApolloCovid.CountryDetailViewQuery.Data) -> CountryDetailView in

                CountryDetailView(data: data)
            }
        }

        func countryDetailView<Loading: View>(identifier: Covid.CountryIdentifier,
                                              
                                              @ViewBuilder loading: () -> Loading) -> some View {
            return QueryRenderer(client: client,
                                 query: ApolloCovid.CountryDetailViewQuery(identifier: identifier),
                                 loading: loading(),
                                 error: { BasicErrorView(error: $0) }) { (data: ApolloCovid.CountryDetailViewQuery.Data) -> CountryDetailView in

                CountryDetailView(data: data)
            }
        }

        func countryDetailView<Error: View>(identifier: Covid.CountryIdentifier,
                                            
                                            @ViewBuilder error: @escaping (QueryError) -> Error) -> some View {
            return QueryRenderer(client: client,
                                 query: ApolloCovid.CountryDetailViewQuery(identifier: identifier),
                                 loading: BasicLoadingView(),
                                 error: error) { (data: ApolloCovid.CountryDetailViewQuery.Data) -> CountryDetailView in

                CountryDetailView(data: data)
            }
        }

        func countryDetailView(identifier: Covid.CountryIdentifier) -> some View {
            return QueryRenderer(client: client,
                                 query: ApolloCovid.CountryDetailViewQuery(identifier: identifier),
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
                      casesOverTime: GraphQL(country.timeline.cases.map { $0.value }))
        }
    }

#endif


// MARK: - ContentView

#if GRAPHAELLO_COVID_UI__TARGET

    extension ContentView {
        typealias Data = ApolloCovid.ContentViewQuery.Data

        init(api: Covid,
             data: Data) {
            self.init(api: api,
                      currentCountry: GraphQL(data.myCountry?.fragments.featuredCountryCellCountry),
                      currentCountryName: GraphQL(data.myCountry?.name),
                      currentCountryNews: GraphQL(data.myCountry?.news.map { $0.fragments.newsStoryCellNewsStory }),
                      world: GraphQL(data.world.fragments.currentStateCellWorld),
                      cases: GraphQL(data.world.timeline.cases.map { $0.value }),
                      deaths: GraphQL(data.world.timeline.deaths.map { $0.value }),
                      recovered: GraphQL(data.world.timeline.recovered.map { $0.value }),
                      news: GraphQL(data.world.news.map { $0.fragments.newsStoryCellNewsStory }),
                      countries: GraphQL(data.countries.map { $0.fragments.basicCountryCellCountry }),
                      pins: GraphQL(data.countries.map { $0.fragments.countryMapPinCountry }))
        }
    }

    extension Covid {
        func contentView<Loading: View, Error: View>(
            @ViewBuilder loading: () -> Loading,
            @ViewBuilder error: @escaping (QueryError) -> Error
        ) -> some View {
            return QueryRenderer(client: client,
                                 query: ApolloCovid.ContentViewQuery(),
                                 loading: loading(),
                                 error: error) { (data: ApolloCovid.ContentViewQuery.Data) -> ContentView in

                ContentView(api: self,
                            data: data)
            }
        }

        func contentView<Loading: View>(
            @ViewBuilder loading: () -> Loading
        ) -> some View {
            return QueryRenderer(client: client,
                                 query: ApolloCovid.ContentViewQuery(),
                                 loading: loading(),
                                 error: { BasicErrorView(error: $0) }) { (data: ApolloCovid.ContentViewQuery.Data) -> ContentView in

                ContentView(api: self,
                            data: data)
            }
        }

        func contentView<Error: View>(
            @ViewBuilder error: @escaping (QueryError) -> Error
        ) -> some View {
            return QueryRenderer(client: client,
                                 query: ApolloCovid.ContentViewQuery(),
                                 loading: BasicLoadingView(),
                                 error: error) { (data: ApolloCovid.ContentViewQuery.Data) -> ContentView in

                ContentView(api: self,
                            data: data)
            }
        }

        func contentView() -> some View {
            return QueryRenderer(client: client,
                                 query: ApolloCovid.ContentViewQuery(),
                                 loading: BasicLoadingView(),
                                 error: { BasicErrorView(error: $0) }) { (data: ApolloCovid.ContentViewQuery.Data) -> ContentView in

                ContentView(api: self,
                            data: data)
            }
        }
    }

#endif






// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

/// ApolloCovid namespace
public enum ApolloCovid {
  public enum CountryIdentifier: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
    public typealias RawValue = String
    case mexico
    case sKorea
    case somalia
    case curacao
    case papuaNewGuinea
    case nicaragua
    case diamondPrincess
    case uk
    case colombia
    case elSalvador
    case norway
    case pakistan
    case philippines
    case afghanistan
    case mozambique
    case burkinaFaso
    case dominica
    case poland
    case macedonia
    case anguilla
    case guatemala
    case kyrgyzstan
    case falklandIslandsMalvinas
    case argentina
    case liberia
    case eritrea
    case gambia
    case oman
    case grenada
    case stBarth
    case costaRica
    case cuba
    case bangladesh
    case sanMarino
    case malawi
    case southAfrica
    case maldives
    case belize
    case cyprus
    case guinea
    case sudan
    case palestine
    case israel
    case antiguaAndBarbuda
    case suriname
    case botswana
    case belarus
    case sweden
    case guyana
    case saudiArabia
    case namibia
    case chad
    case latvia
    case barbados
    case montserrat
    case armenia
    case newZealand
    case saintVincentAndTheGrenadines
    case guineaBissau
    case ecuador
    case congo
    case caboVerde
    case dominicanRepublic
    case centralAfricanRepublic
    case serbia
    case hungary
    case kuwait
    case lebanon
    case nepal
    case mauritius
    case uruguay
    case mali
    case paraguay
    case caymanIslands
    case westernSahara
    case iceland
    case caribbeanNetherlands
    case sriLanka
    case honduras
    case malta
    case saintPierreMiquelon
    case taiwan
    case belgium
    case liechtenstein
    case vietnam
    case venezuela
    case haiti
    case denmark
    case angola
    case togo
    case mongolia
    case brazil
    case libyanArabJamahiriya
    case syrianArabRepublic
    case qatar
    case romania
    case singapore
    case italy
    case southSudan
    case macao
    case usa
    case benin
    case egypt
    case bosnia
    case jamaica
    case ethiopia
    case tunisia
    case thailand
    case saintKittsAndNevis
    case saoTomeAndPrincipe
    case turksAndCaicosIslands
    case seychelles
    case burundi
    case isleOfMan
    case iran
    case indonesia
    case netherlands
    case uzbekistan
    case laoPeopleSDemocraticRepublic
    case russia
    case drc
    case zambia
    case andorra
    case brunei
    case hongKong
    case saintLucia
    case slovakia
    case iraq
    case madagascar
    case montenegro
    case channelIslands
    case timorLeste
    case japan
    case albania
    case ukraine
    case germany
    case britishVirginIslands
    case trinidadAndTobago
    case cambodia
    case ghana
    case jordan
    case newCaledonia
    case gibraltar
    case india
    case bolivia
    case bulgaria
    case finland
    case frenchPolynesia
    case switzerland
    case chile
    case swaziland
    case yemen
    case slovenia
    case bermuda
    case bahamas
    case mauritania
    case bhutan
    case frenchGuiana
    case portugal
    case cameroon
    case guadeloupe
    case senegal
    case uganda
    case lithuania
    case kazakhstan
    case luxembourg
    case moldova
    case azerbaijan
    case myanmar
    case estonia
    case croatia
    case morocco
    case greenland
    case aruba
    case msZaandam
    case sintMaarten
    case martinique
    case ireland
    case holySeeVaticanCityState
    case djibouti
    case zimbabwe
    case fiji
    case spain
    case canada
    case saintMartin
    case gabon
    case reunion
    case austria
    case tanzania
    case nigeria
    case turkey
    case monaco
    case faroeIslands
    case peru
    case georgia
    case niger
    case czechia
    case panama
    case sierraLeone
    case equatorialGuinea
    case china
    case australia
    case malaysia
    case mayotte
    case rwanda
    case france
    case bahrain
    case greece
    case uae
    case algeria
    case coteDIvoire
    case kenya
    /// Auto generated constant for unknown enum values
    case __unknown(RawValue)

    public init?(rawValue: RawValue) {
      switch rawValue {
        case "Mexico": self = .mexico
        case "SKorea": self = .sKorea
        case "Somalia": self = .somalia
        case "Curacao": self = .curacao
        case "PapuaNewGuinea": self = .papuaNewGuinea
        case "Nicaragua": self = .nicaragua
        case "DiamondPrincess": self = .diamondPrincess
        case "Uk": self = .uk
        case "Colombia": self = .colombia
        case "ElSalvador": self = .elSalvador
        case "Norway": self = .norway
        case "Pakistan": self = .pakistan
        case "Philippines": self = .philippines
        case "Afghanistan": self = .afghanistan
        case "Mozambique": self = .mozambique
        case "BurkinaFaso": self = .burkinaFaso
        case "Dominica": self = .dominica
        case "Poland": self = .poland
        case "Macedonia": self = .macedonia
        case "Anguilla": self = .anguilla
        case "Guatemala": self = .guatemala
        case "Kyrgyzstan": self = .kyrgyzstan
        case "FalklandIslandsMalvinas": self = .falklandIslandsMalvinas
        case "Argentina": self = .argentina
        case "Liberia": self = .liberia
        case "Eritrea": self = .eritrea
        case "Gambia": self = .gambia
        case "Oman": self = .oman
        case "Grenada": self = .grenada
        case "StBarth": self = .stBarth
        case "CostaRica": self = .costaRica
        case "Cuba": self = .cuba
        case "Bangladesh": self = .bangladesh
        case "SanMarino": self = .sanMarino
        case "Malawi": self = .malawi
        case "SouthAfrica": self = .southAfrica
        case "Maldives": self = .maldives
        case "Belize": self = .belize
        case "Cyprus": self = .cyprus
        case "Guinea": self = .guinea
        case "Sudan": self = .sudan
        case "Palestine": self = .palestine
        case "Israel": self = .israel
        case "AntiguaAndBarbuda": self = .antiguaAndBarbuda
        case "Suriname": self = .suriname
        case "Botswana": self = .botswana
        case "Belarus": self = .belarus
        case "Sweden": self = .sweden
        case "Guyana": self = .guyana
        case "SaudiArabia": self = .saudiArabia
        case "Namibia": self = .namibia
        case "Chad": self = .chad
        case "Latvia": self = .latvia
        case "Barbados": self = .barbados
        case "Montserrat": self = .montserrat
        case "Armenia": self = .armenia
        case "NewZealand": self = .newZealand
        case "SaintVincentAndTheGrenadines": self = .saintVincentAndTheGrenadines
        case "GuineaBissau": self = .guineaBissau
        case "Ecuador": self = .ecuador
        case "Congo": self = .congo
        case "CaboVerde": self = .caboVerde
        case "DominicanRepublic": self = .dominicanRepublic
        case "CentralAfricanRepublic": self = .centralAfricanRepublic
        case "Serbia": self = .serbia
        case "Hungary": self = .hungary
        case "Kuwait": self = .kuwait
        case "Lebanon": self = .lebanon
        case "Nepal": self = .nepal
        case "Mauritius": self = .mauritius
        case "Uruguay": self = .uruguay
        case "Mali": self = .mali
        case "Paraguay": self = .paraguay
        case "CaymanIslands": self = .caymanIslands
        case "WesternSahara": self = .westernSahara
        case "Iceland": self = .iceland
        case "CaribbeanNetherlands": self = .caribbeanNetherlands
        case "SriLanka": self = .sriLanka
        case "Honduras": self = .honduras
        case "Malta": self = .malta
        case "SaintPierreMiquelon": self = .saintPierreMiquelon
        case "Taiwan": self = .taiwan
        case "Belgium": self = .belgium
        case "Liechtenstein": self = .liechtenstein
        case "Vietnam": self = .vietnam
        case "Venezuela": self = .venezuela
        case "Haiti": self = .haiti
        case "Denmark": self = .denmark
        case "Angola": self = .angola
        case "Togo": self = .togo
        case "Mongolia": self = .mongolia
        case "Brazil": self = .brazil
        case "LibyanArabJamahiriya": self = .libyanArabJamahiriya
        case "SyrianArabRepublic": self = .syrianArabRepublic
        case "Qatar": self = .qatar
        case "Romania": self = .romania
        case "Singapore": self = .singapore
        case "Italy": self = .italy
        case "SouthSudan": self = .southSudan
        case "Macao": self = .macao
        case "Usa": self = .usa
        case "Benin": self = .benin
        case "Egypt": self = .egypt
        case "Bosnia": self = .bosnia
        case "Jamaica": self = .jamaica
        case "Ethiopia": self = .ethiopia
        case "Tunisia": self = .tunisia
        case "Thailand": self = .thailand
        case "SaintKittsAndNevis": self = .saintKittsAndNevis
        case "SaoTomeAndPrincipe": self = .saoTomeAndPrincipe
        case "TurksAndCaicosIslands": self = .turksAndCaicosIslands
        case "Seychelles": self = .seychelles
        case "Burundi": self = .burundi
        case "IsleOfMan": self = .isleOfMan
        case "Iran": self = .iran
        case "Indonesia": self = .indonesia
        case "Netherlands": self = .netherlands
        case "Uzbekistan": self = .uzbekistan
        case "LaoPeopleSDemocraticRepublic": self = .laoPeopleSDemocraticRepublic
        case "Russia": self = .russia
        case "Drc": self = .drc
        case "Zambia": self = .zambia
        case "Andorra": self = .andorra
        case "Brunei": self = .brunei
        case "HongKong": self = .hongKong
        case "SaintLucia": self = .saintLucia
        case "Slovakia": self = .slovakia
        case "Iraq": self = .iraq
        case "Madagascar": self = .madagascar
        case "Montenegro": self = .montenegro
        case "ChannelIslands": self = .channelIslands
        case "TimorLeste": self = .timorLeste
        case "Japan": self = .japan
        case "Albania": self = .albania
        case "Ukraine": self = .ukraine
        case "Germany": self = .germany
        case "BritishVirginIslands": self = .britishVirginIslands
        case "TrinidadAndTobago": self = .trinidadAndTobago
        case "Cambodia": self = .cambodia
        case "Ghana": self = .ghana
        case "Jordan": self = .jordan
        case "NewCaledonia": self = .newCaledonia
        case "Gibraltar": self = .gibraltar
        case "India": self = .india
        case "Bolivia": self = .bolivia
        case "Bulgaria": self = .bulgaria
        case "Finland": self = .finland
        case "FrenchPolynesia": self = .frenchPolynesia
        case "Switzerland": self = .switzerland
        case "Chile": self = .chile
        case "Swaziland": self = .swaziland
        case "Yemen": self = .yemen
        case "Slovenia": self = .slovenia
        case "Bermuda": self = .bermuda
        case "Bahamas": self = .bahamas
        case "Mauritania": self = .mauritania
        case "Bhutan": self = .bhutan
        case "FrenchGuiana": self = .frenchGuiana
        case "Portugal": self = .portugal
        case "Cameroon": self = .cameroon
        case "Guadeloupe": self = .guadeloupe
        case "Senegal": self = .senegal
        case "Uganda": self = .uganda
        case "Lithuania": self = .lithuania
        case "Kazakhstan": self = .kazakhstan
        case "Luxembourg": self = .luxembourg
        case "Moldova": self = .moldova
        case "Azerbaijan": self = .azerbaijan
        case "Myanmar": self = .myanmar
        case "Estonia": self = .estonia
        case "Croatia": self = .croatia
        case "Morocco": self = .morocco
        case "Greenland": self = .greenland
        case "Aruba": self = .aruba
        case "MsZaandam": self = .msZaandam
        case "SintMaarten": self = .sintMaarten
        case "Martinique": self = .martinique
        case "Ireland": self = .ireland
        case "HolySeeVaticanCityState": self = .holySeeVaticanCityState
        case "Djibouti": self = .djibouti
        case "Zimbabwe": self = .zimbabwe
        case "Fiji": self = .fiji
        case "Spain": self = .spain
        case "Canada": self = .canada
        case "SaintMartin": self = .saintMartin
        case "Gabon": self = .gabon
        case "Reunion": self = .reunion
        case "Austria": self = .austria
        case "Tanzania": self = .tanzania
        case "Nigeria": self = .nigeria
        case "Turkey": self = .turkey
        case "Monaco": self = .monaco
        case "FaroeIslands": self = .faroeIslands
        case "Peru": self = .peru
        case "Georgia": self = .georgia
        case "Niger": self = .niger
        case "Czechia": self = .czechia
        case "Panama": self = .panama
        case "SierraLeone": self = .sierraLeone
        case "EquatorialGuinea": self = .equatorialGuinea
        case "China": self = .china
        case "Australia": self = .australia
        case "Malaysia": self = .malaysia
        case "Mayotte": self = .mayotte
        case "Rwanda": self = .rwanda
        case "France": self = .france
        case "Bahrain": self = .bahrain
        case "Greece": self = .greece
        case "Uae": self = .uae
        case "Algeria": self = .algeria
        case "CoteDIvoire": self = .coteDIvoire
        case "Kenya": self = .kenya
        default: self = .__unknown(rawValue)
      }
    }

    public var rawValue: RawValue {
      switch self {
        case .mexico: return "Mexico"
        case .sKorea: return "SKorea"
        case .somalia: return "Somalia"
        case .curacao: return "Curacao"
        case .papuaNewGuinea: return "PapuaNewGuinea"
        case .nicaragua: return "Nicaragua"
        case .diamondPrincess: return "DiamondPrincess"
        case .uk: return "Uk"
        case .colombia: return "Colombia"
        case .elSalvador: return "ElSalvador"
        case .norway: return "Norway"
        case .pakistan: return "Pakistan"
        case .philippines: return "Philippines"
        case .afghanistan: return "Afghanistan"
        case .mozambique: return "Mozambique"
        case .burkinaFaso: return "BurkinaFaso"
        case .dominica: return "Dominica"
        case .poland: return "Poland"
        case .macedonia: return "Macedonia"
        case .anguilla: return "Anguilla"
        case .guatemala: return "Guatemala"
        case .kyrgyzstan: return "Kyrgyzstan"
        case .falklandIslandsMalvinas: return "FalklandIslandsMalvinas"
        case .argentina: return "Argentina"
        case .liberia: return "Liberia"
        case .eritrea: return "Eritrea"
        case .gambia: return "Gambia"
        case .oman: return "Oman"
        case .grenada: return "Grenada"
        case .stBarth: return "StBarth"
        case .costaRica: return "CostaRica"
        case .cuba: return "Cuba"
        case .bangladesh: return "Bangladesh"
        case .sanMarino: return "SanMarino"
        case .malawi: return "Malawi"
        case .southAfrica: return "SouthAfrica"
        case .maldives: return "Maldives"
        case .belize: return "Belize"
        case .cyprus: return "Cyprus"
        case .guinea: return "Guinea"
        case .sudan: return "Sudan"
        case .palestine: return "Palestine"
        case .israel: return "Israel"
        case .antiguaAndBarbuda: return "AntiguaAndBarbuda"
        case .suriname: return "Suriname"
        case .botswana: return "Botswana"
        case .belarus: return "Belarus"
        case .sweden: return "Sweden"
        case .guyana: return "Guyana"
        case .saudiArabia: return "SaudiArabia"
        case .namibia: return "Namibia"
        case .chad: return "Chad"
        case .latvia: return "Latvia"
        case .barbados: return "Barbados"
        case .montserrat: return "Montserrat"
        case .armenia: return "Armenia"
        case .newZealand: return "NewZealand"
        case .saintVincentAndTheGrenadines: return "SaintVincentAndTheGrenadines"
        case .guineaBissau: return "GuineaBissau"
        case .ecuador: return "Ecuador"
        case .congo: return "Congo"
        case .caboVerde: return "CaboVerde"
        case .dominicanRepublic: return "DominicanRepublic"
        case .centralAfricanRepublic: return "CentralAfricanRepublic"
        case .serbia: return "Serbia"
        case .hungary: return "Hungary"
        case .kuwait: return "Kuwait"
        case .lebanon: return "Lebanon"
        case .nepal: return "Nepal"
        case .mauritius: return "Mauritius"
        case .uruguay: return "Uruguay"
        case .mali: return "Mali"
        case .paraguay: return "Paraguay"
        case .caymanIslands: return "CaymanIslands"
        case .westernSahara: return "WesternSahara"
        case .iceland: return "Iceland"
        case .caribbeanNetherlands: return "CaribbeanNetherlands"
        case .sriLanka: return "SriLanka"
        case .honduras: return "Honduras"
        case .malta: return "Malta"
        case .saintPierreMiquelon: return "SaintPierreMiquelon"
        case .taiwan: return "Taiwan"
        case .belgium: return "Belgium"
        case .liechtenstein: return "Liechtenstein"
        case .vietnam: return "Vietnam"
        case .venezuela: return "Venezuela"
        case .haiti: return "Haiti"
        case .denmark: return "Denmark"
        case .angola: return "Angola"
        case .togo: return "Togo"
        case .mongolia: return "Mongolia"
        case .brazil: return "Brazil"
        case .libyanArabJamahiriya: return "LibyanArabJamahiriya"
        case .syrianArabRepublic: return "SyrianArabRepublic"
        case .qatar: return "Qatar"
        case .romania: return "Romania"
        case .singapore: return "Singapore"
        case .italy: return "Italy"
        case .southSudan: return "SouthSudan"
        case .macao: return "Macao"
        case .usa: return "Usa"
        case .benin: return "Benin"
        case .egypt: return "Egypt"
        case .bosnia: return "Bosnia"
        case .jamaica: return "Jamaica"
        case .ethiopia: return "Ethiopia"
        case .tunisia: return "Tunisia"
        case .thailand: return "Thailand"
        case .saintKittsAndNevis: return "SaintKittsAndNevis"
        case .saoTomeAndPrincipe: return "SaoTomeAndPrincipe"
        case .turksAndCaicosIslands: return "TurksAndCaicosIslands"
        case .seychelles: return "Seychelles"
        case .burundi: return "Burundi"
        case .isleOfMan: return "IsleOfMan"
        case .iran: return "Iran"
        case .indonesia: return "Indonesia"
        case .netherlands: return "Netherlands"
        case .uzbekistan: return "Uzbekistan"
        case .laoPeopleSDemocraticRepublic: return "LaoPeopleSDemocraticRepublic"
        case .russia: return "Russia"
        case .drc: return "Drc"
        case .zambia: return "Zambia"
        case .andorra: return "Andorra"
        case .brunei: return "Brunei"
        case .hongKong: return "HongKong"
        case .saintLucia: return "SaintLucia"
        case .slovakia: return "Slovakia"
        case .iraq: return "Iraq"
        case .madagascar: return "Madagascar"
        case .montenegro: return "Montenegro"
        case .channelIslands: return "ChannelIslands"
        case .timorLeste: return "TimorLeste"
        case .japan: return "Japan"
        case .albania: return "Albania"
        case .ukraine: return "Ukraine"
        case .germany: return "Germany"
        case .britishVirginIslands: return "BritishVirginIslands"
        case .trinidadAndTobago: return "TrinidadAndTobago"
        case .cambodia: return "Cambodia"
        case .ghana: return "Ghana"
        case .jordan: return "Jordan"
        case .newCaledonia: return "NewCaledonia"
        case .gibraltar: return "Gibraltar"
        case .india: return "India"
        case .bolivia: return "Bolivia"
        case .bulgaria: return "Bulgaria"
        case .finland: return "Finland"
        case .frenchPolynesia: return "FrenchPolynesia"
        case .switzerland: return "Switzerland"
        case .chile: return "Chile"
        case .swaziland: return "Swaziland"
        case .yemen: return "Yemen"
        case .slovenia: return "Slovenia"
        case .bermuda: return "Bermuda"
        case .bahamas: return "Bahamas"
        case .mauritania: return "Mauritania"
        case .bhutan: return "Bhutan"
        case .frenchGuiana: return "FrenchGuiana"
        case .portugal: return "Portugal"
        case .cameroon: return "Cameroon"
        case .guadeloupe: return "Guadeloupe"
        case .senegal: return "Senegal"
        case .uganda: return "Uganda"
        case .lithuania: return "Lithuania"
        case .kazakhstan: return "Kazakhstan"
        case .luxembourg: return "Luxembourg"
        case .moldova: return "Moldova"
        case .azerbaijan: return "Azerbaijan"
        case .myanmar: return "Myanmar"
        case .estonia: return "Estonia"
        case .croatia: return "Croatia"
        case .morocco: return "Morocco"
        case .greenland: return "Greenland"
        case .aruba: return "Aruba"
        case .msZaandam: return "MsZaandam"
        case .sintMaarten: return "SintMaarten"
        case .martinique: return "Martinique"
        case .ireland: return "Ireland"
        case .holySeeVaticanCityState: return "HolySeeVaticanCityState"
        case .djibouti: return "Djibouti"
        case .zimbabwe: return "Zimbabwe"
        case .fiji: return "Fiji"
        case .spain: return "Spain"
        case .canada: return "Canada"
        case .saintMartin: return "SaintMartin"
        case .gabon: return "Gabon"
        case .reunion: return "Reunion"
        case .austria: return "Austria"
        case .tanzania: return "Tanzania"
        case .nigeria: return "Nigeria"
        case .turkey: return "Turkey"
        case .monaco: return "Monaco"
        case .faroeIslands: return "FaroeIslands"
        case .peru: return "Peru"
        case .georgia: return "Georgia"
        case .niger: return "Niger"
        case .czechia: return "Czechia"
        case .panama: return "Panama"
        case .sierraLeone: return "SierraLeone"
        case .equatorialGuinea: return "EquatorialGuinea"
        case .china: return "China"
        case .australia: return "Australia"
        case .malaysia: return "Malaysia"
        case .mayotte: return "Mayotte"
        case .rwanda: return "Rwanda"
        case .france: return "France"
        case .bahrain: return "Bahrain"
        case .greece: return "Greece"
        case .uae: return "Uae"
        case .algeria: return "Algeria"
        case .coteDIvoire: return "CoteDIvoire"
        case .kenya: return "Kenya"
        case .__unknown(let value): return value
      }
    }

    public static func == (lhs: CountryIdentifier, rhs: CountryIdentifier) -> Bool {
      switch (lhs, rhs) {
        case (.mexico, .mexico): return true
        case (.sKorea, .sKorea): return true
        case (.somalia, .somalia): return true
        case (.curacao, .curacao): return true
        case (.papuaNewGuinea, .papuaNewGuinea): return true
        case (.nicaragua, .nicaragua): return true
        case (.diamondPrincess, .diamondPrincess): return true
        case (.uk, .uk): return true
        case (.colombia, .colombia): return true
        case (.elSalvador, .elSalvador): return true
        case (.norway, .norway): return true
        case (.pakistan, .pakistan): return true
        case (.philippines, .philippines): return true
        case (.afghanistan, .afghanistan): return true
        case (.mozambique, .mozambique): return true
        case (.burkinaFaso, .burkinaFaso): return true
        case (.dominica, .dominica): return true
        case (.poland, .poland): return true
        case (.macedonia, .macedonia): return true
        case (.anguilla, .anguilla): return true
        case (.guatemala, .guatemala): return true
        case (.kyrgyzstan, .kyrgyzstan): return true
        case (.falklandIslandsMalvinas, .falklandIslandsMalvinas): return true
        case (.argentina, .argentina): return true
        case (.liberia, .liberia): return true
        case (.eritrea, .eritrea): return true
        case (.gambia, .gambia): return true
        case (.oman, .oman): return true
        case (.grenada, .grenada): return true
        case (.stBarth, .stBarth): return true
        case (.costaRica, .costaRica): return true
        case (.cuba, .cuba): return true
        case (.bangladesh, .bangladesh): return true
        case (.sanMarino, .sanMarino): return true
        case (.malawi, .malawi): return true
        case (.southAfrica, .southAfrica): return true
        case (.maldives, .maldives): return true
        case (.belize, .belize): return true
        case (.cyprus, .cyprus): return true
        case (.guinea, .guinea): return true
        case (.sudan, .sudan): return true
        case (.palestine, .palestine): return true
        case (.israel, .israel): return true
        case (.antiguaAndBarbuda, .antiguaAndBarbuda): return true
        case (.suriname, .suriname): return true
        case (.botswana, .botswana): return true
        case (.belarus, .belarus): return true
        case (.sweden, .sweden): return true
        case (.guyana, .guyana): return true
        case (.saudiArabia, .saudiArabia): return true
        case (.namibia, .namibia): return true
        case (.chad, .chad): return true
        case (.latvia, .latvia): return true
        case (.barbados, .barbados): return true
        case (.montserrat, .montserrat): return true
        case (.armenia, .armenia): return true
        case (.newZealand, .newZealand): return true
        case (.saintVincentAndTheGrenadines, .saintVincentAndTheGrenadines): return true
        case (.guineaBissau, .guineaBissau): return true
        case (.ecuador, .ecuador): return true
        case (.congo, .congo): return true
        case (.caboVerde, .caboVerde): return true
        case (.dominicanRepublic, .dominicanRepublic): return true
        case (.centralAfricanRepublic, .centralAfricanRepublic): return true
        case (.serbia, .serbia): return true
        case (.hungary, .hungary): return true
        case (.kuwait, .kuwait): return true
        case (.lebanon, .lebanon): return true
        case (.nepal, .nepal): return true
        case (.mauritius, .mauritius): return true
        case (.uruguay, .uruguay): return true
        case (.mali, .mali): return true
        case (.paraguay, .paraguay): return true
        case (.caymanIslands, .caymanIslands): return true
        case (.westernSahara, .westernSahara): return true
        case (.iceland, .iceland): return true
        case (.caribbeanNetherlands, .caribbeanNetherlands): return true
        case (.sriLanka, .sriLanka): return true
        case (.honduras, .honduras): return true
        case (.malta, .malta): return true
        case (.saintPierreMiquelon, .saintPierreMiquelon): return true
        case (.taiwan, .taiwan): return true
        case (.belgium, .belgium): return true
        case (.liechtenstein, .liechtenstein): return true
        case (.vietnam, .vietnam): return true
        case (.venezuela, .venezuela): return true
        case (.haiti, .haiti): return true
        case (.denmark, .denmark): return true
        case (.angola, .angola): return true
        case (.togo, .togo): return true
        case (.mongolia, .mongolia): return true
        case (.brazil, .brazil): return true
        case (.libyanArabJamahiriya, .libyanArabJamahiriya): return true
        case (.syrianArabRepublic, .syrianArabRepublic): return true
        case (.qatar, .qatar): return true
        case (.romania, .romania): return true
        case (.singapore, .singapore): return true
        case (.italy, .italy): return true
        case (.southSudan, .southSudan): return true
        case (.macao, .macao): return true
        case (.usa, .usa): return true
        case (.benin, .benin): return true
        case (.egypt, .egypt): return true
        case (.bosnia, .bosnia): return true
        case (.jamaica, .jamaica): return true
        case (.ethiopia, .ethiopia): return true
        case (.tunisia, .tunisia): return true
        case (.thailand, .thailand): return true
        case (.saintKittsAndNevis, .saintKittsAndNevis): return true
        case (.saoTomeAndPrincipe, .saoTomeAndPrincipe): return true
        case (.turksAndCaicosIslands, .turksAndCaicosIslands): return true
        case (.seychelles, .seychelles): return true
        case (.burundi, .burundi): return true
        case (.isleOfMan, .isleOfMan): return true
        case (.iran, .iran): return true
        case (.indonesia, .indonesia): return true
        case (.netherlands, .netherlands): return true
        case (.uzbekistan, .uzbekistan): return true
        case (.laoPeopleSDemocraticRepublic, .laoPeopleSDemocraticRepublic): return true
        case (.russia, .russia): return true
        case (.drc, .drc): return true
        case (.zambia, .zambia): return true
        case (.andorra, .andorra): return true
        case (.brunei, .brunei): return true
        case (.hongKong, .hongKong): return true
        case (.saintLucia, .saintLucia): return true
        case (.slovakia, .slovakia): return true
        case (.iraq, .iraq): return true
        case (.madagascar, .madagascar): return true
        case (.montenegro, .montenegro): return true
        case (.channelIslands, .channelIslands): return true
        case (.timorLeste, .timorLeste): return true
        case (.japan, .japan): return true
        case (.albania, .albania): return true
        case (.ukraine, .ukraine): return true
        case (.germany, .germany): return true
        case (.britishVirginIslands, .britishVirginIslands): return true
        case (.trinidadAndTobago, .trinidadAndTobago): return true
        case (.cambodia, .cambodia): return true
        case (.ghana, .ghana): return true
        case (.jordan, .jordan): return true
        case (.newCaledonia, .newCaledonia): return true
        case (.gibraltar, .gibraltar): return true
        case (.india, .india): return true
        case (.bolivia, .bolivia): return true
        case (.bulgaria, .bulgaria): return true
        case (.finland, .finland): return true
        case (.frenchPolynesia, .frenchPolynesia): return true
        case (.switzerland, .switzerland): return true
        case (.chile, .chile): return true
        case (.swaziland, .swaziland): return true
        case (.yemen, .yemen): return true
        case (.slovenia, .slovenia): return true
        case (.bermuda, .bermuda): return true
        case (.bahamas, .bahamas): return true
        case (.mauritania, .mauritania): return true
        case (.bhutan, .bhutan): return true
        case (.frenchGuiana, .frenchGuiana): return true
        case (.portugal, .portugal): return true
        case (.cameroon, .cameroon): return true
        case (.guadeloupe, .guadeloupe): return true
        case (.senegal, .senegal): return true
        case (.uganda, .uganda): return true
        case (.lithuania, .lithuania): return true
        case (.kazakhstan, .kazakhstan): return true
        case (.luxembourg, .luxembourg): return true
        case (.moldova, .moldova): return true
        case (.azerbaijan, .azerbaijan): return true
        case (.myanmar, .myanmar): return true
        case (.estonia, .estonia): return true
        case (.croatia, .croatia): return true
        case (.morocco, .morocco): return true
        case (.greenland, .greenland): return true
        case (.aruba, .aruba): return true
        case (.msZaandam, .msZaandam): return true
        case (.sintMaarten, .sintMaarten): return true
        case (.martinique, .martinique): return true
        case (.ireland, .ireland): return true
        case (.holySeeVaticanCityState, .holySeeVaticanCityState): return true
        case (.djibouti, .djibouti): return true
        case (.zimbabwe, .zimbabwe): return true
        case (.fiji, .fiji): return true
        case (.spain, .spain): return true
        case (.canada, .canada): return true
        case (.saintMartin, .saintMartin): return true
        case (.gabon, .gabon): return true
        case (.reunion, .reunion): return true
        case (.austria, .austria): return true
        case (.tanzania, .tanzania): return true
        case (.nigeria, .nigeria): return true
        case (.turkey, .turkey): return true
        case (.monaco, .monaco): return true
        case (.faroeIslands, .faroeIslands): return true
        case (.peru, .peru): return true
        case (.georgia, .georgia): return true
        case (.niger, .niger): return true
        case (.czechia, .czechia): return true
        case (.panama, .panama): return true
        case (.sierraLeone, .sierraLeone): return true
        case (.equatorialGuinea, .equatorialGuinea): return true
        case (.china, .china): return true
        case (.australia, .australia): return true
        case (.malaysia, .malaysia): return true
        case (.mayotte, .mayotte): return true
        case (.rwanda, .rwanda): return true
        case (.france, .france): return true
        case (.bahrain, .bahrain): return true
        case (.greece, .greece): return true
        case (.uae, .uae): return true
        case (.algeria, .algeria): return true
        case (.coteDIvoire, .coteDIvoire): return true
        case (.kenya, .kenya): return true
        case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
        default: return false
      }
    }

    public static var allCases: [CountryIdentifier] {
      return [
        .mexico,
        .sKorea,
        .somalia,
        .curacao,
        .papuaNewGuinea,
        .nicaragua,
        .diamondPrincess,
        .uk,
        .colombia,
        .elSalvador,
        .norway,
        .pakistan,
        .philippines,
        .afghanistan,
        .mozambique,
        .burkinaFaso,
        .dominica,
        .poland,
        .macedonia,
        .anguilla,
        .guatemala,
        .kyrgyzstan,
        .falklandIslandsMalvinas,
        .argentina,
        .liberia,
        .eritrea,
        .gambia,
        .oman,
        .grenada,
        .stBarth,
        .costaRica,
        .cuba,
        .bangladesh,
        .sanMarino,
        .malawi,
        .southAfrica,
        .maldives,
        .belize,
        .cyprus,
        .guinea,
        .sudan,
        .palestine,
        .israel,
        .antiguaAndBarbuda,
        .suriname,
        .botswana,
        .belarus,
        .sweden,
        .guyana,
        .saudiArabia,
        .namibia,
        .chad,
        .latvia,
        .barbados,
        .montserrat,
        .armenia,
        .newZealand,
        .saintVincentAndTheGrenadines,
        .guineaBissau,
        .ecuador,
        .congo,
        .caboVerde,
        .dominicanRepublic,
        .centralAfricanRepublic,
        .serbia,
        .hungary,
        .kuwait,
        .lebanon,
        .nepal,
        .mauritius,
        .uruguay,
        .mali,
        .paraguay,
        .caymanIslands,
        .westernSahara,
        .iceland,
        .caribbeanNetherlands,
        .sriLanka,
        .honduras,
        .malta,
        .saintPierreMiquelon,
        .taiwan,
        .belgium,
        .liechtenstein,
        .vietnam,
        .venezuela,
        .haiti,
        .denmark,
        .angola,
        .togo,
        .mongolia,
        .brazil,
        .libyanArabJamahiriya,
        .syrianArabRepublic,
        .qatar,
        .romania,
        .singapore,
        .italy,
        .southSudan,
        .macao,
        .usa,
        .benin,
        .egypt,
        .bosnia,
        .jamaica,
        .ethiopia,
        .tunisia,
        .thailand,
        .saintKittsAndNevis,
        .saoTomeAndPrincipe,
        .turksAndCaicosIslands,
        .seychelles,
        .burundi,
        .isleOfMan,
        .iran,
        .indonesia,
        .netherlands,
        .uzbekistan,
        .laoPeopleSDemocraticRepublic,
        .russia,
        .drc,
        .zambia,
        .andorra,
        .brunei,
        .hongKong,
        .saintLucia,
        .slovakia,
        .iraq,
        .madagascar,
        .montenegro,
        .channelIslands,
        .timorLeste,
        .japan,
        .albania,
        .ukraine,
        .germany,
        .britishVirginIslands,
        .trinidadAndTobago,
        .cambodia,
        .ghana,
        .jordan,
        .newCaledonia,
        .gibraltar,
        .india,
        .bolivia,
        .bulgaria,
        .finland,
        .frenchPolynesia,
        .switzerland,
        .chile,
        .swaziland,
        .yemen,
        .slovenia,
        .bermuda,
        .bahamas,
        .mauritania,
        .bhutan,
        .frenchGuiana,
        .portugal,
        .cameroon,
        .guadeloupe,
        .senegal,
        .uganda,
        .lithuania,
        .kazakhstan,
        .luxembourg,
        .moldova,
        .azerbaijan,
        .myanmar,
        .estonia,
        .croatia,
        .morocco,
        .greenland,
        .aruba,
        .msZaandam,
        .sintMaarten,
        .martinique,
        .ireland,
        .holySeeVaticanCityState,
        .djibouti,
        .zimbabwe,
        .fiji,
        .spain,
        .canada,
        .saintMartin,
        .gabon,
        .reunion,
        .austria,
        .tanzania,
        .nigeria,
        .turkey,
        .monaco,
        .faroeIslands,
        .peru,
        .georgia,
        .niger,
        .czechia,
        .panama,
        .sierraLeone,
        .equatorialGuinea,
        .china,
        .australia,
        .malaysia,
        .mayotte,
        .rwanda,
        .france,
        .bahrain,
        .greece,
        .uae,
        .algeria,
        .coteDIvoire,
        .kenya,
      ]
    }
  }

  public final class CountryDetailViewQuery: GraphQLQuery {
    /// The raw GraphQL definition of this operation.
    public let operationDefinition: String =
      """
      query CountryDetailView($identifier: CountryIdentifier!) {
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
              value
            }
            deaths {
              __typename
              value
            }
            recovered {
              __typename
              value
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

    public init(identifier: CountryIdentifier) {
      self.identifier = identifier
    }

    public var variables: GraphQLMap? {
      return ["identifier": identifier]
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
              GraphQLField("cases", type: .nonNull(.list(.nonNull(.object(Case.selections))))),
              GraphQLField("deaths", type: .nonNull(.list(.nonNull(.object(Death.selections))))),
              GraphQLField("recovered", type: .nonNull(.list(.nonNull(.object(Recovered.selections))))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(cases: [Case], deaths: [Death], recovered: [Recovered]) {
            self.init(unsafeResultMap: ["__typename": "Timeline", "cases": cases.map { (value: Case) -> ResultMap in value.resultMap }, "deaths": deaths.map { (value: Death) -> ResultMap in value.resultMap }, "recovered": recovered.map { (value: Recovered) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var cases: [Case] {
            get {
              return (resultMap["cases"] as! [ResultMap]).map { (value: ResultMap) -> Case in Case(unsafeResultMap: value) }
            }
            set {
              resultMap.updateValue(newValue.map { (value: Case) -> ResultMap in value.resultMap }, forKey: "cases")
            }
          }

          public var deaths: [Death] {
            get {
              return (resultMap["deaths"] as! [ResultMap]).map { (value: ResultMap) -> Death in Death(unsafeResultMap: value) }
            }
            set {
              resultMap.updateValue(newValue.map { (value: Death) -> ResultMap in value.resultMap }, forKey: "deaths")
            }
          }

          public var recovered: [Recovered] {
            get {
              return (resultMap["recovered"] as! [ResultMap]).map { (value: ResultMap) -> Recovered in Recovered(unsafeResultMap: value) }
            }
            set {
              resultMap.updateValue(newValue.map { (value: Recovered) -> ResultMap in value.resultMap }, forKey: "recovered")
            }
          }

          public struct Case: GraphQLSelectionSet {
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

          public struct Death: GraphQLSelectionSet {
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

          public struct Recovered: GraphQLSelectionSet {
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

  public final class ContentViewQuery: GraphQLQuery {
    /// The raw GraphQL definition of this operation.
    public let operationDefinition: String =
      """
      query ContentView {
        countries {
          __typename
          ...BasicCountryCellCountry
          ...CountryMapPinCountry
        }
        myCountry {
          __typename
          ...FeaturedCountryCellCountry
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
              value
            }
            deaths {
              __typename
              value
            }
            recovered {
              __typename
              value
            }
          }
        }
      }
      """

    public let operationName: String = "ContentView"

    public var queryDocument: String { return operationDefinition.appending("\n" + BasicCountryCellCountry.fragmentDefinition).appending("\n" + CountryMapPinCountry.fragmentDefinition).appending("\n" + FeaturedCountryCellCountry.fragmentDefinition).appending("\n" + StatsViewAffected.fragmentDefinition).appending("\n" + NewsStoryCellNewsStory.fragmentDefinition).appending("\n" + CurrentStateCellWorld.fragmentDefinition) }

    public init() {
    }

    public struct Data: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Query"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("countries", type: .nonNull(.list(.nonNull(.object(Country.selections))))),
          GraphQLField("myCountry", type: .object(MyCountry.selections)),
          GraphQLField("world", type: .nonNull(.object(World.selections))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(countries: [Country], myCountry: MyCountry? = nil, world: World) {
        self.init(unsafeResultMap: ["__typename": "Query", "countries": countries.map { (value: Country) -> ResultMap in value.resultMap }, "myCountry": myCountry.flatMap { (value: MyCountry) -> ResultMap in value.resultMap }, "world": world.resultMap])
      }

      public var countries: [Country] {
        get {
          return (resultMap["countries"] as! [ResultMap]).map { (value: ResultMap) -> Country in Country(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Country) -> ResultMap in value.resultMap }, forKey: "countries")
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
        public static let possibleTypes: [String] = ["Country"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLFragmentSpread(BasicCountryCellCountry.self),
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

          public var basicCountryCellCountry: BasicCountryCellCountry {
            get {
              return BasicCountryCellCountry(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
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

      public struct MyCountry: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Country"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLFragmentSpread(FeaturedCountryCellCountry.self),
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

          public var featuredCountryCellCountry: FeaturedCountryCellCountry {
            get {
              return FeaturedCountryCellCountry(unsafeResultMap: resultMap)
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
              GraphQLField("cases", type: .nonNull(.list(.nonNull(.object(Case.selections))))),
              GraphQLField("deaths", type: .nonNull(.list(.nonNull(.object(Death.selections))))),
              GraphQLField("recovered", type: .nonNull(.list(.nonNull(.object(Recovered.selections))))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(cases: [Case], deaths: [Death], recovered: [Recovered]) {
            self.init(unsafeResultMap: ["__typename": "Timeline", "cases": cases.map { (value: Case) -> ResultMap in value.resultMap }, "deaths": deaths.map { (value: Death) -> ResultMap in value.resultMap }, "recovered": recovered.map { (value: Recovered) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var cases: [Case] {
            get {
              return (resultMap["cases"] as! [ResultMap]).map { (value: ResultMap) -> Case in Case(unsafeResultMap: value) }
            }
            set {
              resultMap.updateValue(newValue.map { (value: Case) -> ResultMap in value.resultMap }, forKey: "cases")
            }
          }

          public var deaths: [Death] {
            get {
              return (resultMap["deaths"] as! [ResultMap]).map { (value: ResultMap) -> Death in Death(unsafeResultMap: value) }
            }
            set {
              resultMap.updateValue(newValue.map { (value: Death) -> ResultMap in value.resultMap }, forKey: "deaths")
            }
          }

          public var recovered: [Recovered] {
            get {
              return (resultMap["recovered"] as! [ResultMap]).map { (value: ResultMap) -> Recovered in Recovered(unsafeResultMap: value) }
            }
            set {
              resultMap.updateValue(newValue.map { (value: Recovered) -> ResultMap in value.resultMap }, forKey: "recovered")
            }
          }

          public struct Case: GraphQLSelectionSet {
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

          public struct Death: GraphQLSelectionSet {
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

          public struct Recovered: GraphQLSelectionSet {
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
            value
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
          GraphQLField("cases", type: .nonNull(.list(.nonNull(.object(Case.selections))))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(cases: [Case]) {
        self.init(unsafeResultMap: ["__typename": "Timeline", "cases": cases.map { (value: Case) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var cases: [Case] {
        get {
          return (resultMap["cases"] as! [ResultMap]).map { (value: ResultMap) -> Case in Case(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Case) -> ResultMap in value.resultMap }, forKey: "cases")
        }
      }

      public struct Case: GraphQLSelectionSet {
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



