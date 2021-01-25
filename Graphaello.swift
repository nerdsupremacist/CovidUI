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
    static var placeholder: Self { get }
}

extension Array: Fragment where Element: Fragment {
    typealias UnderlyingType = [Element.UnderlyingType]

    static var placeholder: [Element] {
        return Array(repeating: Element.placeholder, count: 5)
    }
}

extension Optional: Fragment where Wrapped: Fragment {
    typealias UnderlyingType = Wrapped.UnderlyingType?

    static var placeholder: Wrapped? {
        return Wrapped.placeholder
    }
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
        case vertical(alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil, insets: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        case horizontal(alignment: VerticalAlignment = .center, spacing: CGFloat? = nil, insets: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
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
        case let .vertical(alignment, spacing, insets):
            return AnyView(
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(alignment: alignment, spacing: spacing) {
                        ForEach(data, id: \.id) { data in
                            self.loader(data).ifVisible(in: self.visibleRect, in: .named("InfiniteVerticalScroll")) { self.onAppear(data: data) }
                        }
                    }
                    .padding(insets)
                }
                .coordinateSpace(name: "InfiniteVerticalScroll")
                .rectReader($visibleRect, in: .named("InfiniteVerticalScroll"))
            )
        case let .horizontal(alignment, spacing, insets):
            return AnyView(
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: alignment, spacing: spacing) {
                        ForEach(data, id: \.id) { data in
                            self.loader(data).ifVisible(in: self.visibleRect, in: .named("InfiniteHorizontalScroll")) { self.onAppear(data: data) }
                        }
                    }
                    .padding(insets)
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

        DispatchQueue.main.async {
            paging.loadMore(pageSize: pageSize)
        }
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
                  loading: { PagingBasicLoadingView(content: itemView) },
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
                  loading: { PagingBasicLoadingView(content: itemView) },
                  error: { Text("Error: \($0.localizedDescription)") },
                  item: itemView)
    }
}

private struct PagingBasicLoadingView<Value: Fragment, Content: View>: View {
    let content: (Value) -> Content

    var body: some View {
        if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
            content(.placeholder).disabled(true).redacted(reason: .placeholder)
        } else {
            BasicLoadingView()
        }
    }
}

extension PagingView.Mode {
    static func vertical(alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil, padding edges: Edge.Set, by padding: CGFloat) -> PagingView.Mode {
        return .vertical(alignment: alignment,
                         spacing: spacing,
                         insets: EdgeInsets(top: edges.contains(.top) ? padding : 0,
                                            leading: edges.contains(.leading) ? padding : 0,
                                            bottom: edges.contains(.bottom) ? padding : 0,
                                            trailing: edges.contains(.trailing) ? padding : 0))
    }

    static func vertical(alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil, padding: CGFloat) -> PagingView.Mode {
        return .vertical(alignment: alignment, spacing: spacing, padding: .all, by: padding)
    }

    static var vertical: PagingView.Mode { .vertical() }

    static func horizontal(alignment: VerticalAlignment = .center, spacing: CGFloat? = nil, padding edges: Edge.Set, by padding: CGFloat) -> PagingView.Mode {
        return .horizontal(alignment: alignment,
                           spacing: spacing,
                           insets: EdgeInsets(top: edges.contains(.top) ? padding : 0,
                                              leading: edges.contains(.leading) ? padding : 0,
                                              bottom: edges.contains(.bottom) ? padding : 0,
                                              trailing: edges.contains(.trailing) ? padding : 0))
    }

    static func horizontal(alignment: VerticalAlignment = .center, spacing: CGFloat? = nil, padding: CGFloat) -> PagingView.Mode {
        return .horizontal(alignment: alignment, spacing: spacing, padding: .all, by: padding)
    }

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
    static var placeholder: Self { get }
    init(from scalar: Scalar) throws
}

extension Array: GraphQLScalar where Element: GraphQLScalar {
    static var placeholder: [Element] {
        return Array(repeating: Element.placeholder, count: 5)
    }

    init(from scalar: [Element.Scalar]) throws {
        self = try scalar.map { try Element(from: $0) }
    }
}

extension Optional: GraphQLScalar where Wrapped: GraphQLScalar {
    static var placeholder: Wrapped? {
        return Wrapped.placeholder
    }

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

    static let placeholder: URL = URL(string: "https://graphaello.dev/assets/logo.png")!

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
        if let encoded = encoded as? String, encoded == "__GRAPHAELLO_PLACEHOLDER__" {
            return Decoded.placeholder
        }
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

#if GRAPHAELLO_COVID_UI_TARGET

    struct Covid: API {
        let client: ApolloClient

        typealias Query = Covid
        typealias Path<V> = GraphQLPath<Covid, V>
        typealias FragmentPath<V> = GraphQLFragmentPath<Covid, V>

        static func continent(identifier _: GraphQLArgument<Covid.ContinentIdentifier> = .argument) -> FragmentPath<Covid.DetailedContinent> {
            return .init()
        }

        static var continent: FragmentPath<Covid.DetailedContinent> { .init() }

        static var continents: FragmentPath<[Covid.IContinent]> { .init() }

        static func countries(before _: GraphQLArgument<String?> = .argument,
                              first _: GraphQLArgument<Int?> = .argument,
                              last _: GraphQLArgument<Int?> = .argument,
                              after _: GraphQLArgument<String?> = .argument) -> FragmentPath<Covid.CountryConnection> {
            return .init()
        }

        static var countries: FragmentPath<Covid.CountryConnection> { .init() }

        static func country(identifier _: GraphQLArgument<Covid.CountryIdentifier> = .argument) -> FragmentPath<Covid.Country> {
            return .init()
        }

        static var country: FragmentPath<Covid.Country> { .init() }

        static func historicalData(after _: GraphQLArgument<String?> = .argument,
                                   first _: GraphQLArgument<Int?> = .argument,
                                   last _: GraphQLArgument<Int?> = .argument,
                                   before _: GraphQLArgument<String?> = .argument) -> FragmentPath<Covid.HistoricalDataConnection> {
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

            static var iAffected: FragmentPath<IAffected> { .init() }

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

            static var iAffected: FragmentPath<IAffected> { .init() }

            static var iContinent: FragmentPath<IContinent> { .init() }

            static var _fragment: FragmentPath<Continent> { .init() }
        }

        enum ContinentIdentifier: String, Target {
            typealias Path<V> = GraphQLPath<ContinentIdentifier, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<ContinentIdentifier, V>

            case europe = "Europe"

            case australiaOceania = "AustraliaOceania"

            case africa = "Africa"

            case asia = "Asia"

            case southAmerica = "SouthAmerica"

            case northAmerica = "NorthAmerica"

            static var _fragment: FragmentPath<ContinentIdentifier> { .init() }
        }

        enum Coordinates: Target {
            typealias Path<V> = GraphQLPath<Coordinates, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<Coordinates, V>

            static var latitude: Path<Double> { .init() }

            static var longitude: Path<Double> { .init() }

            static var _fragment: FragmentPath<Coordinates> { .init() }
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

            static var geometry: FragmentPath<Covid.GeographicalGeometry?> { .init() }

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

            static var iDetailedAffected: FragmentPath<IDetailedAffected> { .init() }

            static var iAffected: FragmentPath<IAffected> { .init() }

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

            static var change: Path<Int> { .init() }

            static var date: Path<String> { .init() }

            static var debugDescription: Path<String> { .init() }

            static var description: Path<String> { .init() }

            static var hash: Path<Int> { .init() }

            static var isEqual: Path<Bool> { .init() }

            static var isKind: Path<Bool> { .init() }

            static var isMember: Path<Bool> { .init() }

            static var isProxy: Path<Bool> { .init() }

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

            static func connection(last _: GraphQLArgument<Int?> = .argument,
                                   after _: GraphQLArgument<String?> = .argument,
                                   first _: GraphQLArgument<Int?> = .argument,
                                   before _: GraphQLArgument<String?> = .argument) -> FragmentPath<Covid.DataPointConnection> {
                return .init()
            }

            static var connection: FragmentPath<Covid.DataPointConnection> { .init() }

            static func graph(numberOfPoints _: GraphQLArgument<Int> = .argument) -> FragmentPath<[Covid.DataPoint]> {
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

            static var iAffected: FragmentPath<IAffected> { .init() }

            static var iDetailedAffected: FragmentPath<IDetailedAffected> { .init() }

            static var _fragment: FragmentPath<DetailedAffected> { .init() }
        }

        enum DetailedContinent: Target {
            typealias Path<V> = GraphQLPath<DetailedContinent, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<DetailedContinent, V>

            static var active: Path<Int> { .init() }

            static var cases: Path<Int> { .init() }

            static func countries(after _: GraphQLArgument<String?> = .argument,
                                  first _: GraphQLArgument<Int?> = .argument,
                                  last _: GraphQLArgument<Int?> = .argument,
                                  before _: GraphQLArgument<String?> = .argument) -> FragmentPath<Covid.CountryConnection> {
                return .init()
            }

            static var countries: FragmentPath<Covid.CountryConnection> { .init() }

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

            static var iContinent: FragmentPath<IContinent> { .init() }

            static var iAffected: FragmentPath<IAffected> { .init() }

            static var _fragment: FragmentPath<DetailedContinent> { .init() }
        }

        enum GeographicalGeometry: Target {
            typealias Path<V> = GraphQLPath<GeographicalGeometry, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<GeographicalGeometry, V>

            static var polygon: FragmentPath<Polygon?> { .init() }

            static var multiPolygon: FragmentPath<MultiPolygon?> { .init() }

            static var _fragment: FragmentPath<GeographicalGeometry> { .init() }
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

        enum IAffected: Target {
            typealias Path<V> = GraphQLPath<IAffected, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<IAffected, V>

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

            static var detailedAffected: FragmentPath<DetailedAffected?> { .init() }

            static var continent: FragmentPath<Continent?> { .init() }

            static var affected: FragmentPath<Affected?> { .init() }

            static var _fragment: FragmentPath<IAffected> { .init() }
        }

        enum IContinent: Target {
            typealias Path<V> = GraphQLPath<IContinent, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<IContinent, V>

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

            static var continent: FragmentPath<Continent?> { .init() }

            static var _fragment: FragmentPath<IContinent> { .init() }
        }

        enum IDetailedAffected: Target {
            typealias Path<V> = GraphQLPath<IDetailedAffected, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<IDetailedAffected, V>

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

            static var detailedAffected: FragmentPath<DetailedAffected?> { .init() }

            static var _fragment: FragmentPath<IDetailedAffected> { .init() }
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

        enum MultiPolygon: Target {
            typealias Path<V> = GraphQLPath<MultiPolygon, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<MultiPolygon, V>

            static var polygons: FragmentPath<[Covid.Polygon]> { .init() }

            static var _fragment: FragmentPath<MultiPolygon> { .init() }
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

        enum Polygon: Target {
            typealias Path<V> = GraphQLPath<Polygon, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<Polygon, V>

            static var points: FragmentPath<[Covid.Coordinates]> { .init() }

            static var _fragment: FragmentPath<Polygon> { .init() }
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

            static var iDetailedAffected: FragmentPath<IDetailedAffected> { .init() }

            static var iAffected: FragmentPath<IAffected> { .init() }

            static var _fragment: FragmentPath<World> { .init() }
        }
    }

    extension Covid {
        init(url: URL = URL(string: "https://covidql.apps.quintero.io")!,
             client: URLSessionClient = URLSessionClient(),
             useGETForQueries: Bool = false,
             enableAutoPersistedQueries: Bool = false,
             useGETForPersistedQueryRetry: Bool = false,
             requestBodyCreator: RequestBodyCreator = ApolloRequestBodyCreator(),
             store: ApolloStore = ApolloStore(cache: InMemoryNormalizedCache())) {
            let provider = LegacyInterceptorProvider(client: client, store: store)
            let networkTransport = RequestChainNetworkTransport(interceptorProvider: provider,
                                                                endpointURL: url,
                                                                autoPersistQueries: enableAutoPersistedQueries,
                                                                requestBodyCreator: requestBodyCreator,
                                                                useGETForQueries: useGETForQueries,
                                                                useGETForPersistedQueryRetry: useGETForPersistedQueryRetry)
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

        var iAffected: FragmentPath<Covid.IAffected> { .init() }
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

        var iAffected: FragmentPath<Covid.IAffected?> { .init() }
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

        var iAffected: FragmentPath<Covid.IAffected> { .init() }

        var iContinent: FragmentPath<Covid.IContinent> { .init() }
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

        var iAffected: FragmentPath<Covid.IAffected?> { .init() }

        var iContinent: FragmentPath<Covid.IContinent?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.ContinentIdentifier {}

    extension GraphQLFragmentPath where UnderlyingType == Covid.ContinentIdentifier? {}

    extension GraphQLFragmentPath where UnderlyingType == Covid.Coordinates {
        var latitude: Path<Double> { .init() }

        var longitude: Path<Double> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.Coordinates? {
        var latitude: Path<Double?> { .init() }

        var longitude: Path<Double?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.Country {
        var active: Path<Int> { .init() }

        var cases: Path<Int> { .init() }

        var casesPerOneMillion: Path<Double?> { .init() }

        var continent: FragmentPath<Covid.DetailedContinent> { .init() }

        var continentIdentifier: Path<Covid.ContinentIdentifier> { .init() }

        var critical: Path<Int> { .init() }

        var deaths: Path<Int> { .init() }

        var deathsPerOneMillion: Path<Double?> { .init() }

        var geometry: FragmentPath<Covid.GeographicalGeometry?> { .init() }

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

        var iDetailedAffected: FragmentPath<Covid.IDetailedAffected> { .init() }

        var iAffected: FragmentPath<Covid.IAffected> { .init() }
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

        var geometry: FragmentPath<Covid.GeographicalGeometry?> { .init() }

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

        var iDetailedAffected: FragmentPath<Covid.IDetailedAffected?> { .init() }

        var iAffected: FragmentPath<Covid.IAffected?> { .init() }
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
        var change: Path<Int> { .init() }

        var date: Path<String> { .init() }

        var debugDescription: Path<String> { .init() }

        var description: Path<String> { .init() }

        var hash: Path<Int> { .init() }

        var isEqual: Path<Bool> { .init() }

        var isKind: Path<Bool> { .init() }

        var isMember: Path<Bool> { .init() }

        var isProxy: Path<Bool> { .init() }

        var value: Path<Int> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.DataPoint? {
        var change: Path<Int?> { .init() }

        var date: Path<String?> { .init() }

        var debugDescription: Path<String?> { .init() }

        var description: Path<String?> { .init() }

        var hash: Path<Int?> { .init() }

        var isEqual: Path<Bool?> { .init() }

        var isKind: Path<Bool?> { .init() }

        var isMember: Path<Bool?> { .init() }

        var isProxy: Path<Bool?> { .init() }

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
        func connection(last _: GraphQLArgument<Int?> = .argument,
                        after _: GraphQLArgument<String?> = .argument,
                        first _: GraphQLArgument<Int?> = .argument,
                        before _: GraphQLArgument<String?> = .argument) -> FragmentPath<Covid.DataPointConnection> {
            return .init()
        }

        var connection: FragmentPath<Covid.DataPointConnection> { .init() }

        func graph(numberOfPoints _: GraphQLArgument<Int> = .argument) -> FragmentPath<[Covid.DataPoint]> {
            return .init()
        }

        var graph: FragmentPath<[Covid.DataPoint]> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.DataPointsCollection? {
        func connection(last _: GraphQLArgument<Int?> = .argument,
                        after _: GraphQLArgument<String?> = .argument,
                        first _: GraphQLArgument<Int?> = .argument,
                        before _: GraphQLArgument<String?> = .argument) -> FragmentPath<Covid.DataPointConnection?> {
            return .init()
        }

        var connection: FragmentPath<Covid.DataPointConnection?> { .init() }

        func graph(numberOfPoints _: GraphQLArgument<Int> = .argument) -> FragmentPath<[Covid.DataPoint]?> {
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

        var iAffected: FragmentPath<Covid.IAffected> { .init() }

        var iDetailedAffected: FragmentPath<Covid.IDetailedAffected> { .init() }
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

        var iAffected: FragmentPath<Covid.IAffected?> { .init() }

        var iDetailedAffected: FragmentPath<Covid.IDetailedAffected?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.DetailedContinent {
        var active: Path<Int> { .init() }

        var cases: Path<Int> { .init() }

        func countries(after _: GraphQLArgument<String?> = .argument,
                       first _: GraphQLArgument<Int?> = .argument,
                       last _: GraphQLArgument<Int?> = .argument,
                       before _: GraphQLArgument<String?> = .argument) -> FragmentPath<Covid.CountryConnection> {
            return .init()
        }

        var countries: FragmentPath<Covid.CountryConnection> { .init() }

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

        var iContinent: FragmentPath<Covid.IContinent> { .init() }

        var iAffected: FragmentPath<Covid.IAffected> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.DetailedContinent? {
        var active: Path<Int?> { .init() }

        var cases: Path<Int?> { .init() }

        func countries(after _: GraphQLArgument<String?> = .argument,
                       first _: GraphQLArgument<Int?> = .argument,
                       last _: GraphQLArgument<Int?> = .argument,
                       before _: GraphQLArgument<String?> = .argument) -> FragmentPath<Covid.CountryConnection?> {
            return .init()
        }

        var countries: FragmentPath<Covid.CountryConnection?> { .init() }

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

        var iContinent: FragmentPath<Covid.IContinent?> { .init() }

        var iAffected: FragmentPath<Covid.IAffected?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.GeographicalGeometry {
        var polygon: FragmentPath<Covid.Polygon?> { .init() }

        var multiPolygon: FragmentPath<Covid.MultiPolygon?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.GeographicalGeometry? {
        var polygon: FragmentPath<Covid.Polygon?> { .init() }

        var multiPolygon: FragmentPath<Covid.MultiPolygon?> { .init() }
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

    extension GraphQLFragmentPath where UnderlyingType == Covid.IAffected {
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

        var detailedAffected: FragmentPath<Covid.DetailedAffected?> { .init() }

        var continent: FragmentPath<Covid.Continent?> { .init() }

        var affected: FragmentPath<Covid.Affected?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.IAffected? {
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

        var detailedAffected: FragmentPath<Covid.DetailedAffected?> { .init() }

        var continent: FragmentPath<Covid.Continent?> { .init() }

        var affected: FragmentPath<Covid.Affected?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.IContinent {
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

        var continent: FragmentPath<Covid.Continent?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.IContinent? {
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

        var continent: FragmentPath<Covid.Continent?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.IDetailedAffected {
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

        var detailedAffected: FragmentPath<Covid.DetailedAffected?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.IDetailedAffected? {
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

        var detailedAffected: FragmentPath<Covid.DetailedAffected?> { .init() }
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

    extension GraphQLFragmentPath where UnderlyingType == Covid.MultiPolygon {
        var polygons: FragmentPath<[Covid.Polygon]> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.MultiPolygon? {
        var polygons: FragmentPath<[Covid.Polygon]?> { .init() }
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

    extension GraphQLFragmentPath where UnderlyingType == Covid.Polygon {
        var points: FragmentPath<[Covid.Coordinates]> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == Covid.Polygon? {
        var points: FragmentPath<[Covid.Coordinates]?> { .init() }
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

        var iDetailedAffected: FragmentPath<Covid.IDetailedAffected> { .init() }

        var iAffected: FragmentPath<Covid.IAffected> { .init() }
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

        var iDetailedAffected: FragmentPath<Covid.IDetailedAffected?> { .init() }

        var iAffected: FragmentPath<Covid.IAffected?> { .init() }
    }

#endif




// MARK: - BasicCountryCell

#if GRAPHAELLO_COVID_UI_TARGET

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
                      emoji: GraphQL(country.info.emoji),
                      cases: GraphQL(country.cases))
        }

        @ViewBuilder
        static func placeholderView(api: Covid) -> some View {
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                Self(api: api,
                     country: .placeholder).disabled(true).redacted(reason: .placeholder)
            } else {
                BasicLoadingView()
            }
        }
    }

    extension ApolloCovid.BasicCountryCellCountry {
        private static let placeholderMap: ResultMap = ["__typename": "Country", "cases": 42, "identifier": Covid.CountryIdentifier(rawValue: "Haiti")!, "info": ["__typename": "Info", "emoji": "__GRAPHAELLO_PLACEHOLDER__"], "name": "__GRAPHAELLO_PLACEHOLDER__"]

        static let placeholder = ApolloCovid.BasicCountryCellCountry(
            unsafeResultMap: ApolloCovid.BasicCountryCellCountry.placeholderMap
        )
    }

#endif


// MARK: - Coordinates

#if GRAPHAELLO_COVID_UI_TARGET

    extension ApolloCovid.CoordinatesCoordinates: Fragment {
        typealias UnderlyingType = Covid.Coordinates
    }

    extension Coordinates {
        typealias Coordinates = ApolloCovid.CoordinatesCoordinates

        init(coordinates: Coordinates) {
            self.init(latitude: GraphQL(coordinates.latitude),
                      longitude: GraphQL(coordinates.longitude))
        }
    }

    extension Coordinates: Fragment {
        typealias UnderlyingType = Covid.Coordinates

        static let placeholder = Self(coordinates: .placeholder)
    }

    extension ApolloCovid.CoordinatesCoordinates {
        func referencedSingleFragmentStruct() -> Coordinates {
            return Coordinates(coordinates: self)
        }
    }

    extension ApolloCovid.CoordinatesCoordinates {
        private static let placeholderMap: ResultMap = ["__typename": "Coordinates", "latitude": 42.0, "longitude": 42.0]

        static let placeholder = ApolloCovid.CoordinatesCoordinates(
            unsafeResultMap: ApolloCovid.CoordinatesCoordinates.placeholderMap
        )
    }

#endif


// MARK: - Polygon

#if GRAPHAELLO_COVID_UI_TARGET

    extension ApolloCovid.PolygonPolygon: Fragment {
        typealias UnderlyingType = Covid.Polygon
    }

    extension Polygon {
        typealias Polygon = ApolloCovid.PolygonPolygon

        init(polygon: Polygon) {
            self.init(points: GraphQL(polygon.points.map { $0.fragments.coordinatesCoordinates.referencedSingleFragmentStruct() }))
        }
    }

    extension Polygon: Fragment {
        typealias UnderlyingType = Covid.Polygon

        static let placeholder = Self(polygon: .placeholder)
    }

    extension ApolloCovid.PolygonPolygon {
        func referencedSingleFragmentStruct() -> Polygon {
            return Polygon(polygon: self)
        }
    }

    extension ApolloCovid.PolygonPolygon {
        private static let placeholderMap: ResultMap = ["__typename": "Polygon", "points": Array(repeating: ["__typename": "Coordinates", "latitude": 42.0, "longitude": 42.0], count: 5) as [ResultMap]]

        static let placeholder = ApolloCovid.PolygonPolygon(
            unsafeResultMap: ApolloCovid.PolygonPolygon.placeholderMap
        )
    }

#endif


// MARK: - MultiPolygon

#if GRAPHAELLO_COVID_UI_TARGET

    extension ApolloCovid.MultiPolygonMultiPolygon: Fragment {
        typealias UnderlyingType = Covid.MultiPolygon
    }

    extension MultiPolygon {
        typealias MultiPolygon = ApolloCovid.MultiPolygonMultiPolygon

        init(multiPolygon: MultiPolygon) {
            self.init(polygons: GraphQL(multiPolygon.polygons.map { $0.fragments.polygonPolygon.referencedSingleFragmentStruct() }))
        }
    }

    extension MultiPolygon: Fragment {
        typealias UnderlyingType = Covid.MultiPolygon

        static let placeholder = Self(multiPolygon: .placeholder)
    }

    extension ApolloCovid.MultiPolygonMultiPolygon {
        func referencedSingleFragmentStruct() -> MultiPolygon {
            return MultiPolygon(multiPolygon: self)
        }
    }

    extension ApolloCovid.MultiPolygonMultiPolygon {
        private static let placeholderMap: ResultMap = ["__typename": "MultiPolygon", "polygons": Array(repeating: ["__typename": "Polygon", "points": Array(repeating: ["__typename": "Coordinates", "latitude": 42.0, "longitude": 42.0], count: 5) as [ResultMap]], count: 5) as [ResultMap]]

        static let placeholder = ApolloCovid.MultiPolygonMultiPolygon(
            unsafeResultMap: ApolloCovid.MultiPolygonMultiPolygon.placeholderMap
        )
    }

#endif


// MARK: - CountryMapPin

#if GRAPHAELLO_COVID_UI_TARGET

    extension ApolloCovid.CountryMapPinCountry: Fragment {
        typealias UnderlyingType = Covid.Country
    }

    extension CountryMapPin {
        typealias Country = ApolloCovid.CountryMapPinCountry

        init(country: Country) {
            self.init(active: GraphQL(country.active),
                      polygon: GraphQL(country.geometry?.asPolygon?.fragments.polygonPolygon.referencedSingleFragmentStruct()),
                      multiPolygon: GraphQL(country.geometry?.asMultiPolygon?.fragments.multiPolygonMultiPolygon.referencedSingleFragmentStruct()),
                      latitude: GraphQL(country.info.latitude),
                      longitude: GraphQL(country.info.longitude))
        }
    }

    extension CountryMapPin: Fragment {
        typealias UnderlyingType = Covid.Country

        static let placeholder = Self(country: .placeholder)
    }

    extension ApolloCovid.CountryMapPinCountry {
        func referencedSingleFragmentStruct() -> CountryMapPin {
            return CountryMapPin(country: self)
        }
    }

    extension ApolloCovid.CountryMapPinCountry {
        private static let placeholderMap: ResultMap = ["__typename": "Country", "active": 42, "geometry": ["__typename": "GeographicalGeometry"], "info": ["__typename": "Info", "latitude": 42.0, "longitude": 42.0]]

        static let placeholder = ApolloCovid.CountryMapPinCountry(
            unsafeResultMap: ApolloCovid.CountryMapPinCountry.placeholderMap
        )
    }

#endif


// MARK: - NewsStoryCell

#if GRAPHAELLO_COVID_UI_TARGET

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

        @ViewBuilder
        static func placeholderView() -> some View {
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                Self(newsStory: .placeholder).disabled(true).redacted(reason: .placeholder)
            } else {
                BasicLoadingView()
            }
        }
    }

    extension NewsStoryCell: Fragment {
        typealias UnderlyingType = Covid.NewsStory

        static let placeholder = Self(newsStory: .placeholder)
    }

    extension ApolloCovid.NewsStoryCellNewsStory {
        func referencedSingleFragmentStruct() -> NewsStoryCell {
            return NewsStoryCell(newsStory: self)
        }
    }

    extension ApolloCovid.NewsStoryCellNewsStory {
        private static let placeholderMap: ResultMap = ["__typename": "NewsStory", "image": "__GRAPHAELLO_PLACEHOLDER__", "overview": "__GRAPHAELLO_PLACEHOLDER__", "source": ["__typename": "Source", "name": "__GRAPHAELLO_PLACEHOLDER__"], "title": "__GRAPHAELLO_PLACEHOLDER__", "url": "__GRAPHAELLO_PLACEHOLDER__"]

        static let placeholder = ApolloCovid.NewsStoryCellNewsStory(
            unsafeResultMap: ApolloCovid.NewsStoryCellNewsStory.placeholderMap
        )
    }

#endif


// MARK: - StatsView

#if GRAPHAELLO_COVID_UI_TARGET

    extension ApolloCovid.StatsViewIAffected: Fragment {
        typealias UnderlyingType = Covid.IAffected
    }

    extension StatsView {
        typealias IAffected = ApolloCovid.StatsViewIAffected

        init(iAffected: IAffected) {
            self.init(cases: GraphQL(iAffected.cases),
                      deaths: GraphQL(iAffected.deaths),
                      recovered: GraphQL(iAffected.recovered))
        }

        @ViewBuilder
        static func placeholderView() -> some View {
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                Self(iAffected: .placeholder).disabled(true).redacted(reason: .placeholder)
            } else {
                BasicLoadingView()
            }
        }
    }

    extension StatsView: Fragment {
        typealias UnderlyingType = Covid.IAffected

        static let placeholder = Self(iAffected: .placeholder)
    }

    extension ApolloCovid.StatsViewIAffected {
        func referencedSingleFragmentStruct() -> StatsView {
            return StatsView(iAffected: self)
        }
    }

    extension ApolloCovid.StatsViewIAffected {
        private static let placeholderMap: ResultMap = ["__typename": "IAffected", "cases": 42, "deaths": 42, "recovered": 42]

        static let placeholder = ApolloCovid.StatsViewIAffected(
            unsafeResultMap: ApolloCovid.StatsViewIAffected.placeholderMap
        )
    }

#endif


// MARK: - CountryDetailView

#if GRAPHAELLO_COVID_UI_TARGET

    extension CountryDetailView {
        typealias Data = ApolloCovid.CountryDetailViewQuery.Data

        init(data: Data) {
            self.init(name: GraphQL(data.country.name),
                      emoji: GraphQL(data.country.info.emoji),
                      affected: GraphQL(data.country.fragments.statsViewIAffected),
                      casesToday: GraphQL(data.country.todayCases),
                      deathsToday: GraphQL(data.country.todayDeaths),
                      casesOverTime: GraphQL(data.country.timeline.cases.graph.map { $0.value }),
                      deathsOverTime: GraphQL(data.country.timeline.deaths.graph.map { $0.value }),
                      recoveredOverTime: GraphQL(data.country.timeline.recovered.graph.map { $0.value }),
                      images: GraphQL(data.country.news.map { $0.image }),
                      news: GraphQL(data.country.news.map { $0.fragments.newsStoryCellNewsStory }))
        }

        @ViewBuilder
        static func placeholderView() -> some View {
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                Self(data: .placeholder).disabled(true).redacted(reason: .placeholder)
            } else {
                BasicLoadingView()
            }
        }
    }

    extension Covid {
        func countryDetailView<Loading: View, Error: View>(identifier: Covid.CountryIdentifier,
                                                           numberOfPoints: Int = 30,
                                                           
                                                           @ViewBuilder loading: () -> Loading,
                                                           @ViewBuilder error: @escaping (QueryError) -> Error) -> some View {
            return QueryRenderer(client: client,
                                 query: ApolloCovid.CountryDetailViewQuery(identifier: identifier,
                                                                           numberOfPoints: numberOfPoints),
                                 loading: loading(),
                                 error: error) { (data: ApolloCovid.CountryDetailViewQuery.Data) -> CountryDetailView in

                CountryDetailView(data: data)
            }
        }

        func countryDetailView<Loading: View>(identifier: Covid.CountryIdentifier,
                                              numberOfPoints: Int = 30,
                                              
                                              @ViewBuilder loading: () -> Loading) -> some View {
            return QueryRenderer(client: client,
                                 query: ApolloCovid.CountryDetailViewQuery(identifier: identifier,
                                                                           numberOfPoints: numberOfPoints),
                                 loading: loading(),
                                 error: { BasicErrorView(error: $0) }) { (data: ApolloCovid.CountryDetailViewQuery.Data) -> CountryDetailView in

                CountryDetailView(data: data)
            }
        }

        func countryDetailView<Error: View>(identifier: Covid.CountryIdentifier,
                                            numberOfPoints: Int = 30,
                                            
                                            @ViewBuilder error: @escaping (QueryError) -> Error) -> some View {
            return QueryRenderer(client: client,
                                 query: ApolloCovid.CountryDetailViewQuery(identifier: identifier,
                                                                           numberOfPoints: numberOfPoints),
                                 loading: CountryDetailView.placeholderView(),
                                 error: error) { (data: ApolloCovid.CountryDetailViewQuery.Data) -> CountryDetailView in

                CountryDetailView(data: data)
            }
        }

        func countryDetailView(identifier: Covid.CountryIdentifier,
                               numberOfPoints: Int = 30) -> some View {
            return QueryRenderer(client: client,
                                 query: ApolloCovid.CountryDetailViewQuery(identifier: identifier,
                                                                           numberOfPoints: numberOfPoints),
                                 loading: CountryDetailView.placeholderView(),
                                 error: { BasicErrorView(error: $0) }) { (data: ApolloCovid.CountryDetailViewQuery.Data) -> CountryDetailView in

                CountryDetailView(data: data)
            }
        }
    }

    extension ApolloCovid.CountryDetailViewQuery.Data {
        private static let placeholderMap: ResultMap = ["country": ["__typename": "Country", "cases": 42, "deaths": 42, "info": ["__typename": "Info", "emoji": "__GRAPHAELLO_PLACEHOLDER__"], "name": "__GRAPHAELLO_PLACEHOLDER__", "news": Array(repeating: ["__typename": "NewsStory", "image": "__GRAPHAELLO_PLACEHOLDER__", "overview": "__GRAPHAELLO_PLACEHOLDER__", "source": ["__typename": "Source", "name": "__GRAPHAELLO_PLACEHOLDER__"], "title": "__GRAPHAELLO_PLACEHOLDER__", "url": "__GRAPHAELLO_PLACEHOLDER__"], count: 5) as [ResultMap], "recovered": 42, "timeline": ["__typename": "Timeline", "cases": ["__typename": "DataPointsCollection", "graph": Array(repeating: ["__typename": "DataPoint", "value": 42], count: 5) as [ResultMap]], "deaths": ["__typename": "DataPointsCollection", "graph": Array(repeating: ["__typename": "DataPoint", "value": 42], count: 5) as [ResultMap]], "recovered": ["__typename": "DataPointsCollection", "graph": Array(repeating: ["__typename": "DataPoint", "value": 42], count: 5) as [ResultMap]]], "todayCases": 42, "todayDeaths": 42]]

        static let placeholder = ApolloCovid.CountryDetailViewQuery.Data(
            unsafeResultMap: ApolloCovid.CountryDetailViewQuery.Data.placeholderMap
        )
    }

#endif


// MARK: - CurrentStateCell

#if GRAPHAELLO_COVID_UI_TARGET

    extension ApolloCovid.CurrentStateCellWorld: Fragment {
        typealias UnderlyingType = Covid.World
    }

    extension CurrentStateCell {
        typealias World = ApolloCovid.CurrentStateCellWorld

        init(world: World) {
            self.init(affected: GraphQL(world.fragments.statsViewIAffected))
        }

        @ViewBuilder
        static func placeholderView() -> some View {
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                Self(world: .placeholder).disabled(true).redacted(reason: .placeholder)
            } else {
                BasicLoadingView()
            }
        }
    }

    extension CurrentStateCell: Fragment {
        typealias UnderlyingType = Covid.World

        static let placeholder = Self(world: .placeholder)
    }

    extension ApolloCovid.CurrentStateCellWorld {
        func referencedSingleFragmentStruct() -> CurrentStateCell {
            return CurrentStateCell(world: self)
        }
    }

    extension ApolloCovid.CurrentStateCellWorld {
        private static let placeholderMap: ResultMap = ["__typename": "World", "cases": 42, "deaths": 42, "recovered": 42]

        static let placeholder = ApolloCovid.CurrentStateCellWorld(
            unsafeResultMap: ApolloCovid.CurrentStateCellWorld.placeholderMap
        )
    }

#endif


// MARK: - FeaturedCountryCell

#if GRAPHAELLO_COVID_UI_TARGET

    extension ApolloCovid.FeaturedCountryCellCountry: Fragment {
        typealias UnderlyingType = Covid.Country
    }

    extension FeaturedCountryCell {
        typealias Country = ApolloCovid.FeaturedCountryCellCountry

        init(api: Covid,
             country: Country) {
            self.init(api: api,
                      name: GraphQL(country.name),
                      emoji: GraphQL(country.info.emoji),
                      affected: GraphQL(country.fragments.statsViewIAffected),
                      todayDeaths: GraphQL(country.todayDeaths),
                      casesOverTime: GraphQL(country.timeline.cases.graph.map { $0.value }))
        }

        @ViewBuilder
        static func placeholderView(api: Covid) -> some View {
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                Self(api: api,
                     country: .placeholder).disabled(true).redacted(reason: .placeholder)
            } else {
                BasicLoadingView()
            }
        }
    }

    extension ApolloCovid.FeaturedCountryCellCountry {
        private static let placeholderMap: ResultMap = ["__typename": "Country", "cases": 42, "deaths": 42, "info": ["__typename": "Info", "emoji": "__GRAPHAELLO_PLACEHOLDER__"], "name": "__GRAPHAELLO_PLACEHOLDER__", "recovered": 42, "timeline": ["__typename": "Timeline", "cases": ["__typename": "DataPointsCollection", "graph": Array(repeating: ["__typename": "DataPoint", "value": 42], count: 5) as [ResultMap]]], "todayDeaths": 42]

        static let placeholder = ApolloCovid.FeaturedCountryCellCountry(
            unsafeResultMap: ApolloCovid.FeaturedCountryCellCountry.placeholderMap
        )
    }

#endif


// MARK: - ContentView

#if GRAPHAELLO_COVID_UI_TARGET

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
                      news: GraphQL(data.world.news.map { $0.fragments.newsStoryCellNewsStory }),
                      countries: GraphQL(countries),
                      pins: GraphQL(((data.countries.edges?.map { $0?.node })?.compactMap { $0 } ?? []).map { $0.fragments.countryMapPinCountry.referencedSingleFragmentStruct() }))
        }

        @ViewBuilder
        static func placeholderView(api: Covid,
                                    countries: Paging<BasicCountryCell.Country>) -> some View {
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                Self(api: api,
                     countries: countries,
                     data: .placeholder).disabled(true).redacted(reason: .placeholder)
            } else {
                BasicLoadingView()
            }
        }
    }

    extension Covid {
        func contentView<Loading: View, Error: View>(before: String? = nil,
                                                     first: Int? = nil,
                                                     last: Int? = nil,
                                                     after: String? = nil,
                                                     numberOfPoints: Int = 30,
                                                     
                                                     @ViewBuilder loading: () -> Loading,
                                                     @ViewBuilder error: @escaping (QueryError) -> Error) -> some View {
            return QueryRenderer(client: client,
                                 query: ApolloCovid.ContentViewQuery(before: before,
                                                                     first: first,
                                                                     last: last,
                                                                     after: after,
                                                                     numberOfPoints: numberOfPoints),
                                 loading: loading(),
                                 error: error) { (data: ApolloCovid.ContentViewQuery.Data) -> ContentView in

                ContentView(api: self,
                            countries: data.countries.fragments.countryConnectionBasicCountryCellCountry.paging { _cursor, _pageSize, _completion in
                                self.client.fetch(query: ApolloCovid.ContentViewCountriesCountryConnectionBasicCountryCellCountryQuery(before: before,
                                                                                                                                       first: _pageSize ?? first,
                                                                                                                                       last: last,
                                                                                                                                       after: _cursor)) { result in
                                    _completion(result.map { $0.data?.countries.fragments.countryConnectionBasicCountryCellCountry })
                                }
                            },
                            
                            data: data)
            }
        }

        func contentView<Loading: View>(before: String? = nil,
                                        first: Int? = nil,
                                        last: Int? = nil,
                                        after: String? = nil,
                                        numberOfPoints: Int = 30,
                                        
                                        @ViewBuilder loading: () -> Loading) -> some View {
            return QueryRenderer(client: client,
                                 query: ApolloCovid.ContentViewQuery(before: before,
                                                                     first: first,
                                                                     last: last,
                                                                     after: after,
                                                                     numberOfPoints: numberOfPoints),
                                 loading: loading(),
                                 error: { BasicErrorView(error: $0) }) { (data: ApolloCovid.ContentViewQuery.Data) -> ContentView in

                ContentView(api: self,
                            countries: data.countries.fragments.countryConnectionBasicCountryCellCountry.paging { _cursor, _pageSize, _completion in
                                self.client.fetch(query: ApolloCovid.ContentViewCountriesCountryConnectionBasicCountryCellCountryQuery(before: before,
                                                                                                                                       first: _pageSize ?? first,
                                                                                                                                       last: last,
                                                                                                                                       after: _cursor)) { result in
                                    _completion(result.map { $0.data?.countries.fragments.countryConnectionBasicCountryCellCountry })
                                }
                            },
                            
                            data: data)
            }
        }

        func contentView<Error: View>(before: String? = nil,
                                      first: Int? = nil,
                                      last: Int? = nil,
                                      after: String? = nil,
                                      numberOfPoints: Int = 30,
                                      
                                      @ViewBuilder error: @escaping (QueryError) -> Error) -> some View {
            return QueryRenderer(client: client,
                                 query: ApolloCovid.ContentViewQuery(before: before,
                                                                     first: first,
                                                                     last: last,
                                                                     after: after,
                                                                     numberOfPoints: numberOfPoints),
                                 loading: ContentView.placeholderView(api: self,
                                                                      countries: ApolloCovid.ContentViewQuery.Data.placeholder.countries.fragments.countryConnectionBasicCountryCellCountry.paging { _, _, _ in
                                                                          // no-op
                                 }),
                                 error: error) { (data: ApolloCovid.ContentViewQuery.Data) -> ContentView in

                ContentView(api: self,
                            countries: data.countries.fragments.countryConnectionBasicCountryCellCountry.paging { _cursor, _pageSize, _completion in
                                self.client.fetch(query: ApolloCovid.ContentViewCountriesCountryConnectionBasicCountryCellCountryQuery(before: before,
                                                                                                                                       first: _pageSize ?? first,
                                                                                                                                       last: last,
                                                                                                                                       after: _cursor)) { result in
                                    _completion(result.map { $0.data?.countries.fragments.countryConnectionBasicCountryCellCountry })
                                }
                            },
                            
                            data: data)
            }
        }

        func contentView(before: String? = nil,
                         first: Int? = nil,
                         last: Int? = nil,
                         after: String? = nil,
                         numberOfPoints: Int = 30) -> some View {
            return QueryRenderer(client: client,
                                 query: ApolloCovid.ContentViewQuery(before: before,
                                                                     first: first,
                                                                     last: last,
                                                                     after: after,
                                                                     numberOfPoints: numberOfPoints),
                                 loading: ContentView.placeholderView(api: self,
                                                                      countries: ApolloCovid.ContentViewQuery.Data.placeholder.countries.fragments.countryConnectionBasicCountryCellCountry.paging { _, _, _ in
                                                                          // no-op
                                 }),
                                 error: { BasicErrorView(error: $0) }) { (data: ApolloCovid.ContentViewQuery.Data) -> ContentView in

                ContentView(api: self,
                            countries: data.countries.fragments.countryConnectionBasicCountryCellCountry.paging { _cursor, _pageSize, _completion in
                                self.client.fetch(query: ApolloCovid.ContentViewCountriesCountryConnectionBasicCountryCellCountryQuery(before: before,
                                                                                                                                       first: _pageSize ?? first,
                                                                                                                                       last: last,
                                                                                                                                       after: _cursor)) { result in
                                    _completion(result.map { $0.data?.countries.fragments.countryConnectionBasicCountryCellCountry })
                                }
                            },
                            
                            data: data)
            }
        }
    }

    extension ApolloCovid.ContentViewQuery.Data {
        private static let placeholderMap: ResultMap = ["countries": ["__typename": "CountryConnection", "edges": Array(repeating: ["__typename": "CountryEdge", "node": ["__typename": "Country", "active": 42, "cases": 42, "geometry": ["__typename": "GeographicalGeometry"], "identifier": Covid.CountryIdentifier(rawValue: "Haiti")!, "info": ["__typename": "Info", "emoji": "__GRAPHAELLO_PLACEHOLDER__", "latitude": 42.0, "longitude": 42.0], "name": "__GRAPHAELLO_PLACEHOLDER__"]], count: 5) as [ResultMap], "pageInfo": ["__typename": "PageInfo", "endCursor": "__GRAPHAELLO_PLACEHOLDER__", "hasNextPage": true]], "myCountry": ["__typename": "Country", "cases": 42, "deaths": 42, "info": ["__typename": "Info", "emoji": "__GRAPHAELLO_PLACEHOLDER__"], "name": "__GRAPHAELLO_PLACEHOLDER__", "news": Array(repeating: ["__typename": "NewsStory", "image": "__GRAPHAELLO_PLACEHOLDER__", "overview": "__GRAPHAELLO_PLACEHOLDER__", "source": ["__typename": "Source", "name": "__GRAPHAELLO_PLACEHOLDER__"], "title": "__GRAPHAELLO_PLACEHOLDER__", "url": "__GRAPHAELLO_PLACEHOLDER__"], count: 5) as [ResultMap], "recovered": 42, "timeline": ["__typename": "Timeline", "cases": ["__typename": "DataPointsCollection", "graph": Array(repeating: ["__typename": "DataPoint", "value": 42], count: 5) as [ResultMap]]], "todayDeaths": 42], "world": ["__typename": "World", "cases": 42, "deaths": 42, "news": Array(repeating: ["__typename": "NewsStory", "image": "__GRAPHAELLO_PLACEHOLDER__", "overview": "__GRAPHAELLO_PLACEHOLDER__", "source": ["__typename": "Source", "name": "__GRAPHAELLO_PLACEHOLDER__"], "title": "__GRAPHAELLO_PLACEHOLDER__", "url": "__GRAPHAELLO_PLACEHOLDER__"], count: 5) as [ResultMap], "recovered": 42, "timeline": ["__typename": "Timeline", "cases": ["__typename": "DataPointsCollection", "graph": Array(repeating: ["__typename": "DataPoint", "value": 42], count: 5) as [ResultMap]]]]]

        static let placeholder = ApolloCovid.ContentViewQuery.Data(
            unsafeResultMap: ApolloCovid.ContentViewQuery.Data.placeholderMap
        )
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
    case haiti
    case solomonIslands
    case libyanArabJamahiriya
    case centralAfricanRepublic
    case wallisAndFutuna
    case egypt
    case frenchPolynesia
    case equatorialGuinea
    case curacao
    case samoa
    case honduras
    case mozambique
    case msZaandam
    case slovenia
    case bhutan
    case morocco
    case bulgaria
    case sanMarino
    case guinea
    case iran
    case burundi
    case lesotho
    case mauritius
    case ireland
    case papuaNewGuinea
    case swaziland
    case saintKittsAndNevis
    case seychelles
    case japan
    case vanuatu
    case uk
    case thailand
    case nepal
    case sriLanka
    case barbados
    case syrianArabRepublic
    case nicaragua
    case chile
    case australia
    case andorra
    case bangladesh
    case saoTomeAndPrincipe
    case estonia
    case uae
    case norway
    case philippines
    case macao
    case fiji
    case russia
    case panama
    case myanmar
    case kyrgyzstan
    case singapore
    case malaysia
    case elSalvador
    case iraq
    case anguilla
    case newCaledonia
    case frenchGuiana
    case niger
    case dominica
    case belize
    case georgia
    case bahamas
    case sweden
    case liberia
    case ecuador
    case indonesia
    case saintPierreMiquelon
    case brazil
    case tunisia
    case ghana
    case india
    case gambia
    case qatar
    case trinidadAndTobago
    case djibouti
    case turkey
    case liechtenstein
    case grenada
    case britishVirginIslands
    case comoros
    case cameroon
    case azerbaijan
    case southSudan
    case kazakhstan
    case falklandIslandsMalvinas
    case belarus
    case greenland
    case botswana
    case israel
    case malawi
    case micronesia
    case spain
    case hungary
    case uzbekistan
    case guineaBissau
    case germany
    case guyana
    case bolivia
    case gabon
    case finland
    case canada
    case afghanistan
    case saintMartin
    case sierraLeone
    case slovakia
    case chad
    case turksAndCaicosIslands
    case argentina
    case gibraltar
    case latvia
    case netherlands
    case serbia
    case caribbeanNetherlands
    case coteDIvoire
    case somalia
    case luxembourg
    case holySeeVaticanCityState
    case pakistan
    case cuba
    case vietnam
    case bahrain
    case greece
    case antiguaAndBarbuda
    case paraguay
    case martinique
    case jordan
    case faroeIslands
    case montserrat
    case czechia
    case brunei
    case kuwait
    case zambia
    case montenegro
    case sudan
    case suriname
    case isleOfMan
    case switzerland
    case cambodia
    case france
    case angola
    case sKorea
    case benin
    case portugal
    case oman
    case denmark
    case palestine
    case dominicanRepublic
    case uganda
    case bosnia
    case sintMaarten
    case romania
    case colombia
    case yemen
    case monaco
    case guatemala
    case channelIslands
    case mayotte
    case burkinaFaso
    case aruba
    case taiwan
    case zimbabwe
    case poland
    case westernSahara
    case algeria
    case nigeria
    case malta
    case timorLeste
    case drc
    case lithuania
    case bermuda
    case cyprus
    case jamaica
    case mauritania
    case senegal
    case caboVerde
    case tajikistan
    case usa
    case moldova
    case reunion
    case namibia
    case eritrea
    case saintVincentAndTheGrenadines
    case italy
    case congo
    case china
    case southAfrica
    case iceland
    case lebanon
    case kenya
    case uruguay
    case mongolia
    case tanzania
    case albania
    case austria
    case macedonia
    case guadeloupe
    case costaRica
    case newZealand
    case mexico
    case stBarth
    case saintLucia
    case rwanda
    case venezuela
    case croatia
    case saudiArabia
    case marshallIslands
    case diamondPrincess
    case peru
    case ukraine
    case maldives
    case madagascar
    case laoPeopleSDemocraticRepublic
    case belgium
    case caymanIslands
    case ethiopia
    case mali
    case armenia
    case hongKong
    case togo
    /// Auto generated constant for unknown enum values
    case __unknown(RawValue)

    public init?(rawValue: RawValue) {
      switch rawValue {
        case "Haiti": self = .haiti
        case "SolomonIslands": self = .solomonIslands
        case "LibyanArabJamahiriya": self = .libyanArabJamahiriya
        case "CentralAfricanRepublic": self = .centralAfricanRepublic
        case "WallisAndFutuna": self = .wallisAndFutuna
        case "Egypt": self = .egypt
        case "FrenchPolynesia": self = .frenchPolynesia
        case "EquatorialGuinea": self = .equatorialGuinea
        case "Curacao": self = .curacao
        case "Samoa": self = .samoa
        case "Honduras": self = .honduras
        case "Mozambique": self = .mozambique
        case "MsZaandam": self = .msZaandam
        case "Slovenia": self = .slovenia
        case "Bhutan": self = .bhutan
        case "Morocco": self = .morocco
        case "Bulgaria": self = .bulgaria
        case "SanMarino": self = .sanMarino
        case "Guinea": self = .guinea
        case "Iran": self = .iran
        case "Burundi": self = .burundi
        case "Lesotho": self = .lesotho
        case "Mauritius": self = .mauritius
        case "Ireland": self = .ireland
        case "PapuaNewGuinea": self = .papuaNewGuinea
        case "Swaziland": self = .swaziland
        case "SaintKittsAndNevis": self = .saintKittsAndNevis
        case "Seychelles": self = .seychelles
        case "Japan": self = .japan
        case "Vanuatu": self = .vanuatu
        case "Uk": self = .uk
        case "Thailand": self = .thailand
        case "Nepal": self = .nepal
        case "SriLanka": self = .sriLanka
        case "Barbados": self = .barbados
        case "SyrianArabRepublic": self = .syrianArabRepublic
        case "Nicaragua": self = .nicaragua
        case "Chile": self = .chile
        case "Australia": self = .australia
        case "Andorra": self = .andorra
        case "Bangladesh": self = .bangladesh
        case "SaoTomeAndPrincipe": self = .saoTomeAndPrincipe
        case "Estonia": self = .estonia
        case "Uae": self = .uae
        case "Norway": self = .norway
        case "Philippines": self = .philippines
        case "Macao": self = .macao
        case "Fiji": self = .fiji
        case "Russia": self = .russia
        case "Panama": self = .panama
        case "Myanmar": self = .myanmar
        case "Kyrgyzstan": self = .kyrgyzstan
        case "Singapore": self = .singapore
        case "Malaysia": self = .malaysia
        case "ElSalvador": self = .elSalvador
        case "Iraq": self = .iraq
        case "Anguilla": self = .anguilla
        case "NewCaledonia": self = .newCaledonia
        case "FrenchGuiana": self = .frenchGuiana
        case "Niger": self = .niger
        case "Dominica": self = .dominica
        case "Belize": self = .belize
        case "Georgia": self = .georgia
        case "Bahamas": self = .bahamas
        case "Sweden": self = .sweden
        case "Liberia": self = .liberia
        case "Ecuador": self = .ecuador
        case "Indonesia": self = .indonesia
        case "SaintPierreMiquelon": self = .saintPierreMiquelon
        case "Brazil": self = .brazil
        case "Tunisia": self = .tunisia
        case "Ghana": self = .ghana
        case "India": self = .india
        case "Gambia": self = .gambia
        case "Qatar": self = .qatar
        case "TrinidadAndTobago": self = .trinidadAndTobago
        case "Djibouti": self = .djibouti
        case "Turkey": self = .turkey
        case "Liechtenstein": self = .liechtenstein
        case "Grenada": self = .grenada
        case "BritishVirginIslands": self = .britishVirginIslands
        case "Comoros": self = .comoros
        case "Cameroon": self = .cameroon
        case "Azerbaijan": self = .azerbaijan
        case "SouthSudan": self = .southSudan
        case "Kazakhstan": self = .kazakhstan
        case "FalklandIslandsMalvinas": self = .falklandIslandsMalvinas
        case "Belarus": self = .belarus
        case "Greenland": self = .greenland
        case "Botswana": self = .botswana
        case "Israel": self = .israel
        case "Malawi": self = .malawi
        case "Micronesia": self = .micronesia
        case "Spain": self = .spain
        case "Hungary": self = .hungary
        case "Uzbekistan": self = .uzbekistan
        case "GuineaBissau": self = .guineaBissau
        case "Germany": self = .germany
        case "Guyana": self = .guyana
        case "Bolivia": self = .bolivia
        case "Gabon": self = .gabon
        case "Finland": self = .finland
        case "Canada": self = .canada
        case "Afghanistan": self = .afghanistan
        case "SaintMartin": self = .saintMartin
        case "SierraLeone": self = .sierraLeone
        case "Slovakia": self = .slovakia
        case "Chad": self = .chad
        case "TurksAndCaicosIslands": self = .turksAndCaicosIslands
        case "Argentina": self = .argentina
        case "Gibraltar": self = .gibraltar
        case "Latvia": self = .latvia
        case "Netherlands": self = .netherlands
        case "Serbia": self = .serbia
        case "CaribbeanNetherlands": self = .caribbeanNetherlands
        case "CoteDIvoire": self = .coteDIvoire
        case "Somalia": self = .somalia
        case "Luxembourg": self = .luxembourg
        case "HolySeeVaticanCityState": self = .holySeeVaticanCityState
        case "Pakistan": self = .pakistan
        case "Cuba": self = .cuba
        case "Vietnam": self = .vietnam
        case "Bahrain": self = .bahrain
        case "Greece": self = .greece
        case "AntiguaAndBarbuda": self = .antiguaAndBarbuda
        case "Paraguay": self = .paraguay
        case "Martinique": self = .martinique
        case "Jordan": self = .jordan
        case "FaroeIslands": self = .faroeIslands
        case "Montserrat": self = .montserrat
        case "Czechia": self = .czechia
        case "Brunei": self = .brunei
        case "Kuwait": self = .kuwait
        case "Zambia": self = .zambia
        case "Montenegro": self = .montenegro
        case "Sudan": self = .sudan
        case "Suriname": self = .suriname
        case "IsleOfMan": self = .isleOfMan
        case "Switzerland": self = .switzerland
        case "Cambodia": self = .cambodia
        case "France": self = .france
        case "Angola": self = .angola
        case "SKorea": self = .sKorea
        case "Benin": self = .benin
        case "Portugal": self = .portugal
        case "Oman": self = .oman
        case "Denmark": self = .denmark
        case "Palestine": self = .palestine
        case "DominicanRepublic": self = .dominicanRepublic
        case "Uganda": self = .uganda
        case "Bosnia": self = .bosnia
        case "SintMaarten": self = .sintMaarten
        case "Romania": self = .romania
        case "Colombia": self = .colombia
        case "Yemen": self = .yemen
        case "Monaco": self = .monaco
        case "Guatemala": self = .guatemala
        case "ChannelIslands": self = .channelIslands
        case "Mayotte": self = .mayotte
        case "BurkinaFaso": self = .burkinaFaso
        case "Aruba": self = .aruba
        case "Taiwan": self = .taiwan
        case "Zimbabwe": self = .zimbabwe
        case "Poland": self = .poland
        case "WesternSahara": self = .westernSahara
        case "Algeria": self = .algeria
        case "Nigeria": self = .nigeria
        case "Malta": self = .malta
        case "TimorLeste": self = .timorLeste
        case "Drc": self = .drc
        case "Lithuania": self = .lithuania
        case "Bermuda": self = .bermuda
        case "Cyprus": self = .cyprus
        case "Jamaica": self = .jamaica
        case "Mauritania": self = .mauritania
        case "Senegal": self = .senegal
        case "CaboVerde": self = .caboVerde
        case "Tajikistan": self = .tajikistan
        case "Usa": self = .usa
        case "Moldova": self = .moldova
        case "Reunion": self = .reunion
        case "Namibia": self = .namibia
        case "Eritrea": self = .eritrea
        case "SaintVincentAndTheGrenadines": self = .saintVincentAndTheGrenadines
        case "Italy": self = .italy
        case "Congo": self = .congo
        case "China": self = .china
        case "SouthAfrica": self = .southAfrica
        case "Iceland": self = .iceland
        case "Lebanon": self = .lebanon
        case "Kenya": self = .kenya
        case "Uruguay": self = .uruguay
        case "Mongolia": self = .mongolia
        case "Tanzania": self = .tanzania
        case "Albania": self = .albania
        case "Austria": self = .austria
        case "Macedonia": self = .macedonia
        case "Guadeloupe": self = .guadeloupe
        case "CostaRica": self = .costaRica
        case "NewZealand": self = .newZealand
        case "Mexico": self = .mexico
        case "StBarth": self = .stBarth
        case "SaintLucia": self = .saintLucia
        case "Rwanda": self = .rwanda
        case "Venezuela": self = .venezuela
        case "Croatia": self = .croatia
        case "SaudiArabia": self = .saudiArabia
        case "MarshallIslands": self = .marshallIslands
        case "DiamondPrincess": self = .diamondPrincess
        case "Peru": self = .peru
        case "Ukraine": self = .ukraine
        case "Maldives": self = .maldives
        case "Madagascar": self = .madagascar
        case "LaoPeopleSDemocraticRepublic": self = .laoPeopleSDemocraticRepublic
        case "Belgium": self = .belgium
        case "CaymanIslands": self = .caymanIslands
        case "Ethiopia": self = .ethiopia
        case "Mali": self = .mali
        case "Armenia": self = .armenia
        case "HongKong": self = .hongKong
        case "Togo": self = .togo
        default: self = .__unknown(rawValue)
      }
    }

    public var rawValue: RawValue {
      switch self {
        case .haiti: return "Haiti"
        case .solomonIslands: return "SolomonIslands"
        case .libyanArabJamahiriya: return "LibyanArabJamahiriya"
        case .centralAfricanRepublic: return "CentralAfricanRepublic"
        case .wallisAndFutuna: return "WallisAndFutuna"
        case .egypt: return "Egypt"
        case .frenchPolynesia: return "FrenchPolynesia"
        case .equatorialGuinea: return "EquatorialGuinea"
        case .curacao: return "Curacao"
        case .samoa: return "Samoa"
        case .honduras: return "Honduras"
        case .mozambique: return "Mozambique"
        case .msZaandam: return "MsZaandam"
        case .slovenia: return "Slovenia"
        case .bhutan: return "Bhutan"
        case .morocco: return "Morocco"
        case .bulgaria: return "Bulgaria"
        case .sanMarino: return "SanMarino"
        case .guinea: return "Guinea"
        case .iran: return "Iran"
        case .burundi: return "Burundi"
        case .lesotho: return "Lesotho"
        case .mauritius: return "Mauritius"
        case .ireland: return "Ireland"
        case .papuaNewGuinea: return "PapuaNewGuinea"
        case .swaziland: return "Swaziland"
        case .saintKittsAndNevis: return "SaintKittsAndNevis"
        case .seychelles: return "Seychelles"
        case .japan: return "Japan"
        case .vanuatu: return "Vanuatu"
        case .uk: return "Uk"
        case .thailand: return "Thailand"
        case .nepal: return "Nepal"
        case .sriLanka: return "SriLanka"
        case .barbados: return "Barbados"
        case .syrianArabRepublic: return "SyrianArabRepublic"
        case .nicaragua: return "Nicaragua"
        case .chile: return "Chile"
        case .australia: return "Australia"
        case .andorra: return "Andorra"
        case .bangladesh: return "Bangladesh"
        case .saoTomeAndPrincipe: return "SaoTomeAndPrincipe"
        case .estonia: return "Estonia"
        case .uae: return "Uae"
        case .norway: return "Norway"
        case .philippines: return "Philippines"
        case .macao: return "Macao"
        case .fiji: return "Fiji"
        case .russia: return "Russia"
        case .panama: return "Panama"
        case .myanmar: return "Myanmar"
        case .kyrgyzstan: return "Kyrgyzstan"
        case .singapore: return "Singapore"
        case .malaysia: return "Malaysia"
        case .elSalvador: return "ElSalvador"
        case .iraq: return "Iraq"
        case .anguilla: return "Anguilla"
        case .newCaledonia: return "NewCaledonia"
        case .frenchGuiana: return "FrenchGuiana"
        case .niger: return "Niger"
        case .dominica: return "Dominica"
        case .belize: return "Belize"
        case .georgia: return "Georgia"
        case .bahamas: return "Bahamas"
        case .sweden: return "Sweden"
        case .liberia: return "Liberia"
        case .ecuador: return "Ecuador"
        case .indonesia: return "Indonesia"
        case .saintPierreMiquelon: return "SaintPierreMiquelon"
        case .brazil: return "Brazil"
        case .tunisia: return "Tunisia"
        case .ghana: return "Ghana"
        case .india: return "India"
        case .gambia: return "Gambia"
        case .qatar: return "Qatar"
        case .trinidadAndTobago: return "TrinidadAndTobago"
        case .djibouti: return "Djibouti"
        case .turkey: return "Turkey"
        case .liechtenstein: return "Liechtenstein"
        case .grenada: return "Grenada"
        case .britishVirginIslands: return "BritishVirginIslands"
        case .comoros: return "Comoros"
        case .cameroon: return "Cameroon"
        case .azerbaijan: return "Azerbaijan"
        case .southSudan: return "SouthSudan"
        case .kazakhstan: return "Kazakhstan"
        case .falklandIslandsMalvinas: return "FalklandIslandsMalvinas"
        case .belarus: return "Belarus"
        case .greenland: return "Greenland"
        case .botswana: return "Botswana"
        case .israel: return "Israel"
        case .malawi: return "Malawi"
        case .micronesia: return "Micronesia"
        case .spain: return "Spain"
        case .hungary: return "Hungary"
        case .uzbekistan: return "Uzbekistan"
        case .guineaBissau: return "GuineaBissau"
        case .germany: return "Germany"
        case .guyana: return "Guyana"
        case .bolivia: return "Bolivia"
        case .gabon: return "Gabon"
        case .finland: return "Finland"
        case .canada: return "Canada"
        case .afghanistan: return "Afghanistan"
        case .saintMartin: return "SaintMartin"
        case .sierraLeone: return "SierraLeone"
        case .slovakia: return "Slovakia"
        case .chad: return "Chad"
        case .turksAndCaicosIslands: return "TurksAndCaicosIslands"
        case .argentina: return "Argentina"
        case .gibraltar: return "Gibraltar"
        case .latvia: return "Latvia"
        case .netherlands: return "Netherlands"
        case .serbia: return "Serbia"
        case .caribbeanNetherlands: return "CaribbeanNetherlands"
        case .coteDIvoire: return "CoteDIvoire"
        case .somalia: return "Somalia"
        case .luxembourg: return "Luxembourg"
        case .holySeeVaticanCityState: return "HolySeeVaticanCityState"
        case .pakistan: return "Pakistan"
        case .cuba: return "Cuba"
        case .vietnam: return "Vietnam"
        case .bahrain: return "Bahrain"
        case .greece: return "Greece"
        case .antiguaAndBarbuda: return "AntiguaAndBarbuda"
        case .paraguay: return "Paraguay"
        case .martinique: return "Martinique"
        case .jordan: return "Jordan"
        case .faroeIslands: return "FaroeIslands"
        case .montserrat: return "Montserrat"
        case .czechia: return "Czechia"
        case .brunei: return "Brunei"
        case .kuwait: return "Kuwait"
        case .zambia: return "Zambia"
        case .montenegro: return "Montenegro"
        case .sudan: return "Sudan"
        case .suriname: return "Suriname"
        case .isleOfMan: return "IsleOfMan"
        case .switzerland: return "Switzerland"
        case .cambodia: return "Cambodia"
        case .france: return "France"
        case .angola: return "Angola"
        case .sKorea: return "SKorea"
        case .benin: return "Benin"
        case .portugal: return "Portugal"
        case .oman: return "Oman"
        case .denmark: return "Denmark"
        case .palestine: return "Palestine"
        case .dominicanRepublic: return "DominicanRepublic"
        case .uganda: return "Uganda"
        case .bosnia: return "Bosnia"
        case .sintMaarten: return "SintMaarten"
        case .romania: return "Romania"
        case .colombia: return "Colombia"
        case .yemen: return "Yemen"
        case .monaco: return "Monaco"
        case .guatemala: return "Guatemala"
        case .channelIslands: return "ChannelIslands"
        case .mayotte: return "Mayotte"
        case .burkinaFaso: return "BurkinaFaso"
        case .aruba: return "Aruba"
        case .taiwan: return "Taiwan"
        case .zimbabwe: return "Zimbabwe"
        case .poland: return "Poland"
        case .westernSahara: return "WesternSahara"
        case .algeria: return "Algeria"
        case .nigeria: return "Nigeria"
        case .malta: return "Malta"
        case .timorLeste: return "TimorLeste"
        case .drc: return "Drc"
        case .lithuania: return "Lithuania"
        case .bermuda: return "Bermuda"
        case .cyprus: return "Cyprus"
        case .jamaica: return "Jamaica"
        case .mauritania: return "Mauritania"
        case .senegal: return "Senegal"
        case .caboVerde: return "CaboVerde"
        case .tajikistan: return "Tajikistan"
        case .usa: return "Usa"
        case .moldova: return "Moldova"
        case .reunion: return "Reunion"
        case .namibia: return "Namibia"
        case .eritrea: return "Eritrea"
        case .saintVincentAndTheGrenadines: return "SaintVincentAndTheGrenadines"
        case .italy: return "Italy"
        case .congo: return "Congo"
        case .china: return "China"
        case .southAfrica: return "SouthAfrica"
        case .iceland: return "Iceland"
        case .lebanon: return "Lebanon"
        case .kenya: return "Kenya"
        case .uruguay: return "Uruguay"
        case .mongolia: return "Mongolia"
        case .tanzania: return "Tanzania"
        case .albania: return "Albania"
        case .austria: return "Austria"
        case .macedonia: return "Macedonia"
        case .guadeloupe: return "Guadeloupe"
        case .costaRica: return "CostaRica"
        case .newZealand: return "NewZealand"
        case .mexico: return "Mexico"
        case .stBarth: return "StBarth"
        case .saintLucia: return "SaintLucia"
        case .rwanda: return "Rwanda"
        case .venezuela: return "Venezuela"
        case .croatia: return "Croatia"
        case .saudiArabia: return "SaudiArabia"
        case .marshallIslands: return "MarshallIslands"
        case .diamondPrincess: return "DiamondPrincess"
        case .peru: return "Peru"
        case .ukraine: return "Ukraine"
        case .maldives: return "Maldives"
        case .madagascar: return "Madagascar"
        case .laoPeopleSDemocraticRepublic: return "LaoPeopleSDemocraticRepublic"
        case .belgium: return "Belgium"
        case .caymanIslands: return "CaymanIslands"
        case .ethiopia: return "Ethiopia"
        case .mali: return "Mali"
        case .armenia: return "Armenia"
        case .hongKong: return "HongKong"
        case .togo: return "Togo"
        case .__unknown(let value): return value
      }
    }

    public static func == (lhs: CountryIdentifier, rhs: CountryIdentifier) -> Bool {
      switch (lhs, rhs) {
        case (.haiti, .haiti): return true
        case (.solomonIslands, .solomonIslands): return true
        case (.libyanArabJamahiriya, .libyanArabJamahiriya): return true
        case (.centralAfricanRepublic, .centralAfricanRepublic): return true
        case (.wallisAndFutuna, .wallisAndFutuna): return true
        case (.egypt, .egypt): return true
        case (.frenchPolynesia, .frenchPolynesia): return true
        case (.equatorialGuinea, .equatorialGuinea): return true
        case (.curacao, .curacao): return true
        case (.samoa, .samoa): return true
        case (.honduras, .honduras): return true
        case (.mozambique, .mozambique): return true
        case (.msZaandam, .msZaandam): return true
        case (.slovenia, .slovenia): return true
        case (.bhutan, .bhutan): return true
        case (.morocco, .morocco): return true
        case (.bulgaria, .bulgaria): return true
        case (.sanMarino, .sanMarino): return true
        case (.guinea, .guinea): return true
        case (.iran, .iran): return true
        case (.burundi, .burundi): return true
        case (.lesotho, .lesotho): return true
        case (.mauritius, .mauritius): return true
        case (.ireland, .ireland): return true
        case (.papuaNewGuinea, .papuaNewGuinea): return true
        case (.swaziland, .swaziland): return true
        case (.saintKittsAndNevis, .saintKittsAndNevis): return true
        case (.seychelles, .seychelles): return true
        case (.japan, .japan): return true
        case (.vanuatu, .vanuatu): return true
        case (.uk, .uk): return true
        case (.thailand, .thailand): return true
        case (.nepal, .nepal): return true
        case (.sriLanka, .sriLanka): return true
        case (.barbados, .barbados): return true
        case (.syrianArabRepublic, .syrianArabRepublic): return true
        case (.nicaragua, .nicaragua): return true
        case (.chile, .chile): return true
        case (.australia, .australia): return true
        case (.andorra, .andorra): return true
        case (.bangladesh, .bangladesh): return true
        case (.saoTomeAndPrincipe, .saoTomeAndPrincipe): return true
        case (.estonia, .estonia): return true
        case (.uae, .uae): return true
        case (.norway, .norway): return true
        case (.philippines, .philippines): return true
        case (.macao, .macao): return true
        case (.fiji, .fiji): return true
        case (.russia, .russia): return true
        case (.panama, .panama): return true
        case (.myanmar, .myanmar): return true
        case (.kyrgyzstan, .kyrgyzstan): return true
        case (.singapore, .singapore): return true
        case (.malaysia, .malaysia): return true
        case (.elSalvador, .elSalvador): return true
        case (.iraq, .iraq): return true
        case (.anguilla, .anguilla): return true
        case (.newCaledonia, .newCaledonia): return true
        case (.frenchGuiana, .frenchGuiana): return true
        case (.niger, .niger): return true
        case (.dominica, .dominica): return true
        case (.belize, .belize): return true
        case (.georgia, .georgia): return true
        case (.bahamas, .bahamas): return true
        case (.sweden, .sweden): return true
        case (.liberia, .liberia): return true
        case (.ecuador, .ecuador): return true
        case (.indonesia, .indonesia): return true
        case (.saintPierreMiquelon, .saintPierreMiquelon): return true
        case (.brazil, .brazil): return true
        case (.tunisia, .tunisia): return true
        case (.ghana, .ghana): return true
        case (.india, .india): return true
        case (.gambia, .gambia): return true
        case (.qatar, .qatar): return true
        case (.trinidadAndTobago, .trinidadAndTobago): return true
        case (.djibouti, .djibouti): return true
        case (.turkey, .turkey): return true
        case (.liechtenstein, .liechtenstein): return true
        case (.grenada, .grenada): return true
        case (.britishVirginIslands, .britishVirginIslands): return true
        case (.comoros, .comoros): return true
        case (.cameroon, .cameroon): return true
        case (.azerbaijan, .azerbaijan): return true
        case (.southSudan, .southSudan): return true
        case (.kazakhstan, .kazakhstan): return true
        case (.falklandIslandsMalvinas, .falklandIslandsMalvinas): return true
        case (.belarus, .belarus): return true
        case (.greenland, .greenland): return true
        case (.botswana, .botswana): return true
        case (.israel, .israel): return true
        case (.malawi, .malawi): return true
        case (.micronesia, .micronesia): return true
        case (.spain, .spain): return true
        case (.hungary, .hungary): return true
        case (.uzbekistan, .uzbekistan): return true
        case (.guineaBissau, .guineaBissau): return true
        case (.germany, .germany): return true
        case (.guyana, .guyana): return true
        case (.bolivia, .bolivia): return true
        case (.gabon, .gabon): return true
        case (.finland, .finland): return true
        case (.canada, .canada): return true
        case (.afghanistan, .afghanistan): return true
        case (.saintMartin, .saintMartin): return true
        case (.sierraLeone, .sierraLeone): return true
        case (.slovakia, .slovakia): return true
        case (.chad, .chad): return true
        case (.turksAndCaicosIslands, .turksAndCaicosIslands): return true
        case (.argentina, .argentina): return true
        case (.gibraltar, .gibraltar): return true
        case (.latvia, .latvia): return true
        case (.netherlands, .netherlands): return true
        case (.serbia, .serbia): return true
        case (.caribbeanNetherlands, .caribbeanNetherlands): return true
        case (.coteDIvoire, .coteDIvoire): return true
        case (.somalia, .somalia): return true
        case (.luxembourg, .luxembourg): return true
        case (.holySeeVaticanCityState, .holySeeVaticanCityState): return true
        case (.pakistan, .pakistan): return true
        case (.cuba, .cuba): return true
        case (.vietnam, .vietnam): return true
        case (.bahrain, .bahrain): return true
        case (.greece, .greece): return true
        case (.antiguaAndBarbuda, .antiguaAndBarbuda): return true
        case (.paraguay, .paraguay): return true
        case (.martinique, .martinique): return true
        case (.jordan, .jordan): return true
        case (.faroeIslands, .faroeIslands): return true
        case (.montserrat, .montserrat): return true
        case (.czechia, .czechia): return true
        case (.brunei, .brunei): return true
        case (.kuwait, .kuwait): return true
        case (.zambia, .zambia): return true
        case (.montenegro, .montenegro): return true
        case (.sudan, .sudan): return true
        case (.suriname, .suriname): return true
        case (.isleOfMan, .isleOfMan): return true
        case (.switzerland, .switzerland): return true
        case (.cambodia, .cambodia): return true
        case (.france, .france): return true
        case (.angola, .angola): return true
        case (.sKorea, .sKorea): return true
        case (.benin, .benin): return true
        case (.portugal, .portugal): return true
        case (.oman, .oman): return true
        case (.denmark, .denmark): return true
        case (.palestine, .palestine): return true
        case (.dominicanRepublic, .dominicanRepublic): return true
        case (.uganda, .uganda): return true
        case (.bosnia, .bosnia): return true
        case (.sintMaarten, .sintMaarten): return true
        case (.romania, .romania): return true
        case (.colombia, .colombia): return true
        case (.yemen, .yemen): return true
        case (.monaco, .monaco): return true
        case (.guatemala, .guatemala): return true
        case (.channelIslands, .channelIslands): return true
        case (.mayotte, .mayotte): return true
        case (.burkinaFaso, .burkinaFaso): return true
        case (.aruba, .aruba): return true
        case (.taiwan, .taiwan): return true
        case (.zimbabwe, .zimbabwe): return true
        case (.poland, .poland): return true
        case (.westernSahara, .westernSahara): return true
        case (.algeria, .algeria): return true
        case (.nigeria, .nigeria): return true
        case (.malta, .malta): return true
        case (.timorLeste, .timorLeste): return true
        case (.drc, .drc): return true
        case (.lithuania, .lithuania): return true
        case (.bermuda, .bermuda): return true
        case (.cyprus, .cyprus): return true
        case (.jamaica, .jamaica): return true
        case (.mauritania, .mauritania): return true
        case (.senegal, .senegal): return true
        case (.caboVerde, .caboVerde): return true
        case (.tajikistan, .tajikistan): return true
        case (.usa, .usa): return true
        case (.moldova, .moldova): return true
        case (.reunion, .reunion): return true
        case (.namibia, .namibia): return true
        case (.eritrea, .eritrea): return true
        case (.saintVincentAndTheGrenadines, .saintVincentAndTheGrenadines): return true
        case (.italy, .italy): return true
        case (.congo, .congo): return true
        case (.china, .china): return true
        case (.southAfrica, .southAfrica): return true
        case (.iceland, .iceland): return true
        case (.lebanon, .lebanon): return true
        case (.kenya, .kenya): return true
        case (.uruguay, .uruguay): return true
        case (.mongolia, .mongolia): return true
        case (.tanzania, .tanzania): return true
        case (.albania, .albania): return true
        case (.austria, .austria): return true
        case (.macedonia, .macedonia): return true
        case (.guadeloupe, .guadeloupe): return true
        case (.costaRica, .costaRica): return true
        case (.newZealand, .newZealand): return true
        case (.mexico, .mexico): return true
        case (.stBarth, .stBarth): return true
        case (.saintLucia, .saintLucia): return true
        case (.rwanda, .rwanda): return true
        case (.venezuela, .venezuela): return true
        case (.croatia, .croatia): return true
        case (.saudiArabia, .saudiArabia): return true
        case (.marshallIslands, .marshallIslands): return true
        case (.diamondPrincess, .diamondPrincess): return true
        case (.peru, .peru): return true
        case (.ukraine, .ukraine): return true
        case (.maldives, .maldives): return true
        case (.madagascar, .madagascar): return true
        case (.laoPeopleSDemocraticRepublic, .laoPeopleSDemocraticRepublic): return true
        case (.belgium, .belgium): return true
        case (.caymanIslands, .caymanIslands): return true
        case (.ethiopia, .ethiopia): return true
        case (.mali, .mali): return true
        case (.armenia, .armenia): return true
        case (.hongKong, .hongKong): return true
        case (.togo, .togo): return true
        case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
        default: return false
      }
    }

    public static var allCases: [CountryIdentifier] {
      return [
        .haiti,
        .solomonIslands,
        .libyanArabJamahiriya,
        .centralAfricanRepublic,
        .wallisAndFutuna,
        .egypt,
        .frenchPolynesia,
        .equatorialGuinea,
        .curacao,
        .samoa,
        .honduras,
        .mozambique,
        .msZaandam,
        .slovenia,
        .bhutan,
        .morocco,
        .bulgaria,
        .sanMarino,
        .guinea,
        .iran,
        .burundi,
        .lesotho,
        .mauritius,
        .ireland,
        .papuaNewGuinea,
        .swaziland,
        .saintKittsAndNevis,
        .seychelles,
        .japan,
        .vanuatu,
        .uk,
        .thailand,
        .nepal,
        .sriLanka,
        .barbados,
        .syrianArabRepublic,
        .nicaragua,
        .chile,
        .australia,
        .andorra,
        .bangladesh,
        .saoTomeAndPrincipe,
        .estonia,
        .uae,
        .norway,
        .philippines,
        .macao,
        .fiji,
        .russia,
        .panama,
        .myanmar,
        .kyrgyzstan,
        .singapore,
        .malaysia,
        .elSalvador,
        .iraq,
        .anguilla,
        .newCaledonia,
        .frenchGuiana,
        .niger,
        .dominica,
        .belize,
        .georgia,
        .bahamas,
        .sweden,
        .liberia,
        .ecuador,
        .indonesia,
        .saintPierreMiquelon,
        .brazil,
        .tunisia,
        .ghana,
        .india,
        .gambia,
        .qatar,
        .trinidadAndTobago,
        .djibouti,
        .turkey,
        .liechtenstein,
        .grenada,
        .britishVirginIslands,
        .comoros,
        .cameroon,
        .azerbaijan,
        .southSudan,
        .kazakhstan,
        .falklandIslandsMalvinas,
        .belarus,
        .greenland,
        .botswana,
        .israel,
        .malawi,
        .micronesia,
        .spain,
        .hungary,
        .uzbekistan,
        .guineaBissau,
        .germany,
        .guyana,
        .bolivia,
        .gabon,
        .finland,
        .canada,
        .afghanistan,
        .saintMartin,
        .sierraLeone,
        .slovakia,
        .chad,
        .turksAndCaicosIslands,
        .argentina,
        .gibraltar,
        .latvia,
        .netherlands,
        .serbia,
        .caribbeanNetherlands,
        .coteDIvoire,
        .somalia,
        .luxembourg,
        .holySeeVaticanCityState,
        .pakistan,
        .cuba,
        .vietnam,
        .bahrain,
        .greece,
        .antiguaAndBarbuda,
        .paraguay,
        .martinique,
        .jordan,
        .faroeIslands,
        .montserrat,
        .czechia,
        .brunei,
        .kuwait,
        .zambia,
        .montenegro,
        .sudan,
        .suriname,
        .isleOfMan,
        .switzerland,
        .cambodia,
        .france,
        .angola,
        .sKorea,
        .benin,
        .portugal,
        .oman,
        .denmark,
        .palestine,
        .dominicanRepublic,
        .uganda,
        .bosnia,
        .sintMaarten,
        .romania,
        .colombia,
        .yemen,
        .monaco,
        .guatemala,
        .channelIslands,
        .mayotte,
        .burkinaFaso,
        .aruba,
        .taiwan,
        .zimbabwe,
        .poland,
        .westernSahara,
        .algeria,
        .nigeria,
        .malta,
        .timorLeste,
        .drc,
        .lithuania,
        .bermuda,
        .cyprus,
        .jamaica,
        .mauritania,
        .senegal,
        .caboVerde,
        .tajikistan,
        .usa,
        .moldova,
        .reunion,
        .namibia,
        .eritrea,
        .saintVincentAndTheGrenadines,
        .italy,
        .congo,
        .china,
        .southAfrica,
        .iceland,
        .lebanon,
        .kenya,
        .uruguay,
        .mongolia,
        .tanzania,
        .albania,
        .austria,
        .macedonia,
        .guadeloupe,
        .costaRica,
        .newZealand,
        .mexico,
        .stBarth,
        .saintLucia,
        .rwanda,
        .venezuela,
        .croatia,
        .saudiArabia,
        .marshallIslands,
        .diamondPrincess,
        .peru,
        .ukraine,
        .maldives,
        .madagascar,
        .laoPeopleSDemocraticRepublic,
        .belgium,
        .caymanIslands,
        .ethiopia,
        .mali,
        .armenia,
        .hongKong,
        .togo,
      ]
    }
  }

  public final class ContentViewCountriesCountryConnectionBasicCountryCellCountryQuery: GraphQLQuery {
    /// The raw GraphQL definition of this operation.
    public let operationDefinition: String =
      """
      query ContentViewCountriesCountryConnectionBasicCountryCellCountry($before: String, $first: Int, $last: Int, $after: String) {
        countries(after: $after, before: $before, first: $first, last: $last) {
          __typename
          ...CountryConnectionBasicCountryCellCountry
        }
      }
      """

    public let operationName: String = "ContentViewCountriesCountryConnectionBasicCountryCellCountry"

    public var queryDocument: String {
      var document: String = operationDefinition
      document.append("\n" + CountryConnectionBasicCountryCellCountry.fragmentDefinition)
      document.append("\n" + BasicCountryCellCountry.fragmentDefinition)
      return document
    }

    public var before: String?
    public var first: Int?
    public var last: Int?
    public var after: String?

    public init(before: String? = nil, first: Int? = nil, last: Int? = nil, after: String? = nil) {
      self.before = before
      self.first = first
      self.last = last
      self.after = after
    }

    public var variables: GraphQLMap? {
      return ["before": before, "first": first, "last": last, "after": after]
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
      query CountryDetailView($identifier: CountryIdentifier!, $numberOfPoints: Int!) {
        country(identifier: $identifier) {
          __typename
          ...StatsViewIAffected
          info {
            __typename
            emoji
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
              graph(numberOfPoints: $numberOfPoints) {
                __typename
                value
              }
            }
            deaths {
              __typename
              graph(numberOfPoints: $numberOfPoints) {
                __typename
                value
              }
            }
            recovered {
              __typename
              graph(numberOfPoints: $numberOfPoints) {
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

    public var queryDocument: String {
      var document: String = operationDefinition
      document.append("\n" + StatsViewIAffected.fragmentDefinition)
      document.append("\n" + NewsStoryCellNewsStory.fragmentDefinition)
      return document
    }

    public var identifier: CountryIdentifier
    public var numberOfPoints: Int

    public init(identifier: CountryIdentifier, numberOfPoints: Int) {
      self.identifier = identifier
      self.numberOfPoints = numberOfPoints
    }

    public var variables: GraphQLMap? {
      return ["identifier": identifier, "numberOfPoints": numberOfPoints]
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
            GraphQLFragmentSpread(StatsViewIAffected.self),
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

          public var statsViewIAffected: StatsViewIAffected {
            get {
              return StatsViewIAffected(unsafeResultMap: resultMap)
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
              GraphQLField("emoji", type: .scalar(String.self)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(emoji: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "Info", "emoji": emoji])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var emoji: String? {
            get {
              return resultMap["emoji"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "emoji")
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
                GraphQLField("graph", arguments: ["numberOfPoints": GraphQLVariable("numberOfPoints")], type: .nonNull(.list(.nonNull(.object(Graph.selections))))),
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
                GraphQLField("graph", arguments: ["numberOfPoints": GraphQLVariable("numberOfPoints")], type: .nonNull(.list(.nonNull(.object(Graph.selections))))),
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
                GraphQLField("graph", arguments: ["numberOfPoints": GraphQLVariable("numberOfPoints")], type: .nonNull(.list(.nonNull(.object(Graph.selections))))),
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
      query ContentView($before: String, $first: Int, $last: Int, $after: String, $numberOfPoints: Int!) {
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
          ...StatsViewIAffected
          info {
            __typename
            emoji
          }
          name
          timeline {
            __typename
            cases {
              __typename
              graph(numberOfPoints: $numberOfPoints) {
                __typename
                value
              }
            }
          }
          todayDeaths
          ...StatsViewIAffected
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
              graph(numberOfPoints: $numberOfPoints) {
                __typename
                value
              }
            }
          }
        }
      }
      """

    public let operationName: String = "ContentView"

    public var queryDocument: String {
      var document: String = operationDefinition
      document.append("\n" + CountryConnectionBasicCountryCellCountry.fragmentDefinition)
      document.append("\n" + BasicCountryCellCountry.fragmentDefinition)
      document.append("\n" + CountryMapPinCountry.fragmentDefinition)
      document.append("\n" + MultiPolygonMultiPolygon.fragmentDefinition)
      document.append("\n" + PolygonPolygon.fragmentDefinition)
      document.append("\n" + CoordinatesCoordinates.fragmentDefinition)
      document.append("\n" + StatsViewIAffected.fragmentDefinition)
      document.append("\n" + NewsStoryCellNewsStory.fragmentDefinition)
      document.append("\n" + CurrentStateCellWorld.fragmentDefinition)
      return document
    }

    public var before: String?
    public var first: Int?
    public var last: Int?
    public var after: String?
    public var numberOfPoints: Int

    public init(before: String? = nil, first: Int? = nil, last: Int? = nil, after: String? = nil, numberOfPoints: Int) {
      self.before = before
      self.first = first
      self.last = last
      self.after = after
      self.numberOfPoints = numberOfPoints
    }

    public var variables: GraphQLMap? {
      return ["before": before, "first": first, "last": last, "after": after, "numberOfPoints": numberOfPoints]
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
            GraphQLFragmentSpread(StatsViewIAffected.self),
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

          public var statsViewIAffected: StatsViewIAffected {
            get {
              return StatsViewIAffected(unsafeResultMap: resultMap)
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
              GraphQLField("emoji", type: .scalar(String.self)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(emoji: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "Info", "emoji": emoji])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var emoji: String? {
            get {
              return resultMap["emoji"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "emoji")
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
                GraphQLField("graph", arguments: ["numberOfPoints": GraphQLVariable("numberOfPoints")], type: .nonNull(.list(.nonNull(.object(Graph.selections))))),
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
                GraphQLField("graph", arguments: ["numberOfPoints": GraphQLVariable("numberOfPoints")], type: .nonNull(.list(.nonNull(.object(Graph.selections))))),
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
          emoji
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
          GraphQLField("emoji", type: .scalar(String.self)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(emoji: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "Info", "emoji": emoji])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var emoji: String? {
        get {
          return resultMap["emoji"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "emoji")
        }
      }
    }
  }

  public struct CoordinatesCoordinates: GraphQLFragment {
    /// The raw GraphQL definition of this fragment.
    public static let fragmentDefinition: String =
      """
      fragment CoordinatesCoordinates on Coordinates {
        __typename
        latitude
        longitude
      }
      """

    public static let possibleTypes: [String] = ["Coordinates"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("latitude", type: .nonNull(.scalar(Double.self))),
        GraphQLField("longitude", type: .nonNull(.scalar(Double.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(latitude: Double, longitude: Double) {
      self.init(unsafeResultMap: ["__typename": "Coordinates", "latitude": latitude, "longitude": longitude])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var latitude: Double {
      get {
        return resultMap["latitude"]! as! Double
      }
      set {
        resultMap.updateValue(newValue, forKey: "latitude")
      }
    }

    public var longitude: Double {
      get {
        return resultMap["longitude"]! as! Double
      }
      set {
        resultMap.updateValue(newValue, forKey: "longitude")
      }
    }
  }

  public struct PolygonPolygon: GraphQLFragment {
    /// The raw GraphQL definition of this fragment.
    public static let fragmentDefinition: String =
      """
      fragment PolygonPolygon on Polygon {
        __typename
        points {
          __typename
          ...CoordinatesCoordinates
        }
      }
      """

    public static let possibleTypes: [String] = ["Polygon"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("points", type: .nonNull(.list(.nonNull(.object(Point.selections))))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(points: [Point]) {
      self.init(unsafeResultMap: ["__typename": "Polygon", "points": points.map { (value: Point) -> ResultMap in value.resultMap }])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var points: [Point] {
      get {
        return (resultMap["points"] as! [ResultMap]).map { (value: ResultMap) -> Point in Point(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: Point) -> ResultMap in value.resultMap }, forKey: "points")
      }
    }

    public struct Point: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Coordinates"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(CoordinatesCoordinates.self),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(latitude: Double, longitude: Double) {
        self.init(unsafeResultMap: ["__typename": "Coordinates", "latitude": latitude, "longitude": longitude])
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

        public var coordinatesCoordinates: CoordinatesCoordinates {
          get {
            return CoordinatesCoordinates(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }
  }

  public struct MultiPolygonMultiPolygon: GraphQLFragment {
    /// The raw GraphQL definition of this fragment.
    public static let fragmentDefinition: String =
      """
      fragment MultiPolygonMultiPolygon on MultiPolygon {
        __typename
        polygons {
          __typename
          ...PolygonPolygon
        }
      }
      """

    public static let possibleTypes: [String] = ["MultiPolygon"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("polygons", type: .nonNull(.list(.nonNull(.object(Polygon.selections))))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(polygons: [Polygon]) {
      self.init(unsafeResultMap: ["__typename": "MultiPolygon", "polygons": polygons.map { (value: Polygon) -> ResultMap in value.resultMap }])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var polygons: [Polygon] {
      get {
        return (resultMap["polygons"] as! [ResultMap]).map { (value: ResultMap) -> Polygon in Polygon(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: Polygon) -> ResultMap in value.resultMap }, forKey: "polygons")
      }
    }

    public struct Polygon: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Polygon"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(PolygonPolygon.self),
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

        public var polygonPolygon: PolygonPolygon {
          get {
            return PolygonPolygon(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
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
        active
        geometry {
          __typename
          ... on MultiPolygon {
            ...MultiPolygonMultiPolygon
          }
          ... on Polygon {
            ...PolygonPolygon
          }
        }
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
        GraphQLField("active", type: .nonNull(.scalar(Int.self))),
        GraphQLField("geometry", type: .object(Geometry.selections)),
        GraphQLField("info", type: .nonNull(.object(Info.selections))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(active: Int, geometry: Geometry? = nil, info: Info) {
      self.init(unsafeResultMap: ["__typename": "Country", "active": active, "geometry": geometry.flatMap { (value: Geometry) -> ResultMap in value.resultMap }, "info": info.resultMap])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var active: Int {
      get {
        return resultMap["active"]! as! Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "active")
      }
    }

    public var geometry: Geometry? {
      get {
        return (resultMap["geometry"] as? ResultMap).flatMap { Geometry(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "geometry")
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

    public struct Geometry: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Polygon", "MultiPolygon"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLTypeCase(
            variants: ["MultiPolygon": AsMultiPolygon.selections, "Polygon": AsPolygon.selections],
            default: [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            ]
          )
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

      public var asMultiPolygon: AsMultiPolygon? {
        get {
          if !AsMultiPolygon.possibleTypes.contains(__typename) { return nil }
          return AsMultiPolygon(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsMultiPolygon: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MultiPolygon"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLFragmentSpread(MultiPolygonMultiPolygon.self),
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

          public var multiPolygonMultiPolygon: MultiPolygonMultiPolygon {
            get {
              return MultiPolygonMultiPolygon(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }

      public var asPolygon: AsPolygon? {
        get {
          if !AsPolygon.possibleTypes.contains(__typename) { return nil }
          return AsPolygon(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsPolygon: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Polygon"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLFragmentSpread(PolygonPolygon.self),
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

          public var polygonPolygon: PolygonPolygon {
            get {
              return PolygonPolygon(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
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

  public struct StatsViewIAffected: GraphQLFragment {
    /// The raw GraphQL definition of this fragment.
    public static let fragmentDefinition: String =
      """
      fragment StatsViewIAffected on IAffected {
        __typename
        cases
        deaths
        recovered
      }
      """

    public static let possibleTypes: [String] = ["Affected", "Continent", "Country", "DetailedAffected", "DetailedContinent", "World"]

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

    public static func makeAffected(cases: Int, deaths: Int, recovered: Int) -> StatsViewIAffected {
      return StatsViewIAffected(unsafeResultMap: ["__typename": "Affected", "cases": cases, "deaths": deaths, "recovered": recovered])
    }

    public static func makeContinent(cases: Int, deaths: Int, recovered: Int) -> StatsViewIAffected {
      return StatsViewIAffected(unsafeResultMap: ["__typename": "Continent", "cases": cases, "deaths": deaths, "recovered": recovered])
    }

    public static func makeCountry(cases: Int, deaths: Int, recovered: Int) -> StatsViewIAffected {
      return StatsViewIAffected(unsafeResultMap: ["__typename": "Country", "cases": cases, "deaths": deaths, "recovered": recovered])
    }

    public static func makeDetailedAffected(cases: Int, deaths: Int, recovered: Int) -> StatsViewIAffected {
      return StatsViewIAffected(unsafeResultMap: ["__typename": "DetailedAffected", "cases": cases, "deaths": deaths, "recovered": recovered])
    }

    public static func makeDetailedContinent(cases: Int, deaths: Int, recovered: Int) -> StatsViewIAffected {
      return StatsViewIAffected(unsafeResultMap: ["__typename": "DetailedContinent", "cases": cases, "deaths": deaths, "recovered": recovered])
    }

    public static func makeWorld(cases: Int, deaths: Int, recovered: Int) -> StatsViewIAffected {
      return StatsViewIAffected(unsafeResultMap: ["__typename": "World", "cases": cases, "deaths": deaths, "recovered": recovered])
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
        ...StatsViewIAffected
      }
      """

    public static let possibleTypes: [String] = ["World"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLFragmentSpread(StatsViewIAffected.self),
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

      public var statsViewIAffected: StatsViewIAffected {
        get {
          return StatsViewIAffected(unsafeResultMap: resultMap)
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
        ...StatsViewIAffected
        info {
          __typename
          emoji
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
        GraphQLFragmentSpread(StatsViewIAffected.self),
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

      public var statsViewIAffected: StatsViewIAffected {
        get {
          return StatsViewIAffected(unsafeResultMap: resultMap)
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
          GraphQLField("emoji", type: .scalar(String.self)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(emoji: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "Info", "emoji": emoji])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var emoji: String? {
        get {
          return resultMap["emoji"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "emoji")
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



