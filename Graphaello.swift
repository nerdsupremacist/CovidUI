// swiftlint:disable all
// This file was automatically generated and should not be edited.

import Apollo
import Combine
import Foundation
import SwiftUI

// MARK: Basic API

protocol Target {}

protocol API: Target {}

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

// MARK: - Basic API: Views

private struct QueryRenderer<Query: GraphQLQuery, Content: View>: View {
    typealias ContentFactory = (Query.Data) -> Content

    private final class ViewModel: ObservableObject {
        @Published var isLoading: Bool = false
        @Published var value: Query.Data? = nil
        @Published var error: String? = nil
        private var cancellable: Apollo.Cancellable?

        deinit {
            cancel()
        }

        func load(client: ApolloClient, query: Query) {
            guard value == nil, !isLoading else { return }
            cancellable = client.fetch(query: query) { [weak self] result in
                defer {
                    self?.cancellable = nil
                    self?.isLoading = false
                }
                switch result {
                case let .success(result):
                    self?.value = result.data
                    self?.error = result.errors?.map { $0.description }.joined(separator: ", ")
                case let .failure(error):
                    self?.error = error.localizedDescription
                }
            }
            isLoading = true
        }

        func cancel() {
            cancellable?.cancel()
        }
    }

    let client: ApolloClient
    let query: Query
    let factory: ContentFactory

    @ObservedObject private var viewModel = ViewModel()

    var body: some View {
        return VStack {
            viewModel.error.map { Text("Error: \($0)") }
            viewModel.value.map(factory)
            viewModel.isLoading ? Text("Loading") : nil
        }.onAppear {
            self.viewModel.load(client: self.client, query: self.query)
        }.onDisappear {
            self.viewModel.cancel()
        }
    }
}

struct PagingView<Value: Fragment>: View {
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
    private let pageSize: Int?
    private var loader: (Data) -> AnyView

    init(_ paging: Paging<Value>, pageSize: Int?, loader: @escaping (Data) -> AnyView) {
        self.paging = paging
        self.pageSize = pageSize
        self.loader = loader
    }

    var body: some View {
        ForEach((paging.values.enumerated().map { Data.item($0.element, $0.offset) } +
                    [paging.isLoading ? Data.loading : nil, paging.error.map(Data.error)].compactMap { $0 }),
        id: \.id) { data in

            self.loader(data).onAppear { self.onAppear(data: data) }
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
                                                 pageSize: Int? = nil,
                                                 loading loadingView: @escaping () -> Loading,
                                                 error errorView: @escaping (Swift.Error) -> Error,
                                                 item itemView: @escaping (Value) -> Data) {
        self.init(paging, pageSize: pageSize) { data in
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
                                  pageSize: Int? = nil,
                                  error errorView: @escaping (Swift.Error) -> Error,
                                  item itemView: @escaping (Value) -> Data) {
        self.init(paging,
                  pageSize: pageSize,
                  loading: { Text("Loading") },
                  error: errorView,
                  item: itemView)
    }

    init<Loading: View, Data: View>(_ paging: Paging<Value>,
                                    pageSize: Int? = nil,
                                    loading loadingView: @escaping () -> Loading,
                                    item itemView: @escaping (Value) -> Data) {
        self.init(paging,
                  pageSize: pageSize,
                  loading: loadingView,
                  error: { Text("Error: \($0.localizedDescription)") },
                  item: itemView)
    }

    init<Data: View>(_ paging: Paging<Value>,
                     pageSize: Int? = nil,
                     item itemView: @escaping (Value) -> Data) {
        self.init(paging,
                  pageSize: pageSize,
                  loading: { Text("Loading") },
                  error: { Text("Error: \($0.localizedDescription)") },
                  item: itemView)
    }
}

// MARK: - Basic API: Decoders

protocol GraphQLValueDecoder {
    associatedtype Encoded
    associatedtype Decoded

    static func decode(encoded: Encoded) throws -> Decoded
}

extension Array: GraphQLValueDecoder where Element: GraphQLValueDecoder {
    static func decode(encoded: [Element.Encoded]) throws -> [Element.Decoded] {
        return try encoded.map { try Element.decode(encoded: $0) }
    }
}

extension Optional: GraphQLValueDecoder where Wrapped: GraphQLValueDecoder {
    static func decode(encoded: Wrapped.Encoded?) throws -> Wrapped.Decoded? {
        return try encoded.map { try Wrapped.decode(encoded: $0) }
    }
}

enum NoOpDecoder<T>: GraphQLValueDecoder {
    static func decode(encoded: T) throws -> T {
        return encoded
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
    @State
    private var value: Decoder.Decoded

    @ObservedObject
    private var observed: AnyObservableObject = AnyObservableObject()
    private let updateObserved: ((Decoder.Decoded) -> Void)?

    var wrappedValue: Decoder.Decoded {
        get {
            return value
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

    fileprivate init(_ wrappedValue: Decoder.Encoded) {
        _value = State(initialValue: try! Decoder.decode(encoded: wrappedValue))
        updateObserved = nil
    }
}

extension GraphQL where Decoder.Decoded: ObservableObject {
    fileprivate init(_ wrappedValue: Decoder.Encoded) {
        let value = try! Decoder.decode(encoded: wrappedValue)
        _value = State(initialValue: value)

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

// MARK: - Basic API: Type Conversion

extension RawRepresentable {
    fileprivate init<Other: RawRepresentable>(_ other: Other) where Other.RawValue == RawValue {
        guard let value = Self(rawValue: other.rawValue) else { fatalError() }
        self = value
    }
}

extension Optional where Wrapped: RawRepresentable {
    fileprivate init<Other: RawRepresentable>(_ other: Other?) where Other.RawValue == Wrapped.RawValue {
        self = other.map { .init($0) }
    }
}

extension Array where Element: RawRepresentable {
    fileprivate init<Other: RawRepresentable>(_ other: [Other]) where Other.RawValue == Element.RawValue {
        self = other.map { .init($0) }
    }
}

extension Optional {
    fileprivate init<Raw: RawRepresentable, Other: RawRepresentable>(_ other: [Other]?) where Wrapped == [Raw], Other.RawValue == Raw.RawValue {
        self = other.map { .init($0) }
    }
}

extension Array {
    fileprivate init<Raw: RawRepresentable, Other: RawRepresentable>(_ other: [Other?]) where Element == Raw?, Other.RawValue == Raw.RawValue {
        self = other.map { .init($0) }
    }
}

extension Optional {
    fileprivate init<Raw: RawRepresentable, Other: RawRepresentable>(_ other: [Other?]?) where Wrapped == [Raw?], Other.RawValue == Raw.RawValue {
        self = other.map { .init($0) }
    }
}

// MARK: - Covid

struct Covid: API {
    let client: ApolloClient

    typealias Query = Covid
    typealias Path<V> = GraphQLPath<Covid, V>
    typealias FragmentPath<V> = GraphQLFragmentPath<Covid, V>

    static var countries: FragmentPath<[Covid.Country]> { .init() }

    static func country(name _: GraphQLArgument<String> = .argument) -> FragmentPath<Covid.Country?> {
        return .init()
    }

    static var country: FragmentPath<Covid.Country?> { .init() }

    static var historicalData: FragmentPath<[Covid.HistoricalData]> { .init() }

    static var myCountry: FragmentPath<Covid.Country?> { .init() }

    static var world: FragmentPath<Covid.World> { .init() }

    enum Country: Target {
        typealias Path<V> = GraphQLPath<Country, V>
        typealias FragmentPath<V> = GraphQLFragmentPath<Country, V>

        static var active: Path<Int> { .init() }

        static var cases: Path<Int> { .init() }

        static var casesPerOneMillion: Path<Double?> { .init() }

        static var critical: Path<Int> { .init() }

        static var deaths: Path<Int> { .init() }

        static var deathsPerOneMillion: Path<Double?> { .init() }

        static var info: FragmentPath<Covid.Info> { .init() }

        static var name: Path<String> { .init() }

        static var news: FragmentPath<[Covid.NewsStory]> { .init() }

        static var recovered: Path<Int> { .init() }

        static var timeline: FragmentPath<Covid.Timeline> { .init() }

        static var todayCases: Path<Int> { .init() }

        static var todayDeaths: Path<Int> { .init() }

        static var updated: Path<String> { .init() }

        static var _fragment: FragmentPath<Country> { .init() }
    }

    enum DataPoint: Target {
        typealias Path<V> = GraphQLPath<DataPoint, V>
        typealias FragmentPath<V> = GraphQLFragmentPath<DataPoint, V>

        static var date: Path<String> { .init() }

        static var value: Path<Int> { .init() }

        static var _fragment: FragmentPath<DataPoint> { .init() }
    }

    enum HistoricalData: Target {
        typealias Path<V> = GraphQLPath<HistoricalData, V>
        typealias FragmentPath<V> = GraphQLFragmentPath<HistoricalData, V>

        static var country: Path<String?> { .init() }

        static var timeline: FragmentPath<Covid.Timeline> { .init() }

        static var _fragment: FragmentPath<HistoricalData> { .init() }
    }

    enum Info: Target {
        typealias Path<V> = GraphQLPath<Info, V>
        typealias FragmentPath<V> = GraphQLFragmentPath<Info, V>

        static var flag: Path<String> { .init() }

        static var iso2: Path<String?> { .init() }

        static var iso3: Path<String?> { .init() }

        static var _fragment: FragmentPath<Info> { .init() }
    }

    enum NewsStory: Target {
        typealias Path<V> = GraphQLPath<NewsStory, V>
        typealias FragmentPath<V> = GraphQLFragmentPath<NewsStory, V>

        static var author: Path<String?> { .init() }

        static var content: Path<String?> { .init() }

        static var image: Path<String?> { .init() }

        static var overview: Path<String?> { .init() }

        static var published: Path<String> { .init() }

        static var source: FragmentPath<Covid.Source> { .init() }

        static var title: Path<String> { .init() }

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

        static var deaths: Path<Int> { .init() }

        static var news: FragmentPath<[Covid.NewsStory]> { .init() }

        static var recovered: Path<Int> { .init() }

        static var timeline: FragmentPath<Covid.Timeline> { .init() }

        static var updated: Path<String> { .init() }

        static var _fragment: FragmentPath<World> { .init() }
    }
}

extension GraphQLFragmentPath where UnderlyingType == Covid.Country {
    var active: Path<Int> { .init() }

    var cases: Path<Int> { .init() }

    var casesPerOneMillion: Path<Double?> { .init() }

    var critical: Path<Int> { .init() }

    var deaths: Path<Int> { .init() }

    var deathsPerOneMillion: Path<Double?> { .init() }

    var info: FragmentPath<Covid.Info> { .init() }

    var name: Path<String> { .init() }

    var news: FragmentPath<[Covid.NewsStory]> { .init() }

    var recovered: Path<Int> { .init() }

    var timeline: FragmentPath<Covid.Timeline> { .init() }

    var todayCases: Path<Int> { .init() }

    var todayDeaths: Path<Int> { .init() }

    var updated: Path<String> { .init() }
}

extension GraphQLFragmentPath where UnderlyingType == Covid.Country? {
    var active: Path<Int?> { .init() }

    var cases: Path<Int?> { .init() }

    var casesPerOneMillion: Path<Double?> { .init() }

    var critical: Path<Int?> { .init() }

    var deaths: Path<Int?> { .init() }

    var deathsPerOneMillion: Path<Double?> { .init() }

    var info: FragmentPath<Covid.Info?> { .init() }

    var name: Path<String?> { .init() }

    var news: FragmentPath<[Covid.NewsStory]?> { .init() }

    var recovered: Path<Int?> { .init() }

    var timeline: FragmentPath<Covid.Timeline?> { .init() }

    var todayCases: Path<Int?> { .init() }

    var todayDeaths: Path<Int?> { .init() }

    var updated: Path<String?> { .init() }
}

extension GraphQLFragmentPath where UnderlyingType == Covid.DataPoint {
    var date: Path<String> { .init() }

    var value: Path<Int> { .init() }
}

extension GraphQLFragmentPath where UnderlyingType == Covid.DataPoint? {
    var date: Path<String?> { .init() }

    var value: Path<Int?> { .init() }
}

extension GraphQLFragmentPath where UnderlyingType == Covid.HistoricalData {
    var country: Path<String?> { .init() }

    var timeline: FragmentPath<Covid.Timeline> { .init() }
}

extension GraphQLFragmentPath where UnderlyingType == Covid.HistoricalData? {
    var country: Path<String?> { .init() }

    var timeline: FragmentPath<Covid.Timeline?> { .init() }
}

extension GraphQLFragmentPath where UnderlyingType == Covid.Info {
    var flag: Path<String> { .init() }

    var iso2: Path<String?> { .init() }

    var iso3: Path<String?> { .init() }
}

extension GraphQLFragmentPath where UnderlyingType == Covid.Info? {
    var flag: Path<String?> { .init() }

    var iso2: Path<String?> { .init() }

    var iso3: Path<String?> { .init() }
}

extension GraphQLFragmentPath where UnderlyingType == Covid.NewsStory {
    var author: Path<String?> { .init() }

    var content: Path<String?> { .init() }

    var image: Path<String?> { .init() }

    var overview: Path<String?> { .init() }

    var published: Path<String> { .init() }

    var source: FragmentPath<Covid.Source> { .init() }

    var title: Path<String> { .init() }
}

extension GraphQLFragmentPath where UnderlyingType == Covid.NewsStory? {
    var author: Path<String?> { .init() }

    var content: Path<String?> { .init() }

    var image: Path<String?> { .init() }

    var overview: Path<String?> { .init() }

    var published: Path<String?> { .init() }

    var source: FragmentPath<Covid.Source?> { .init() }

    var title: Path<String?> { .init() }
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

    var deaths: Path<Int> { .init() }

    var news: FragmentPath<[Covid.NewsStory]> { .init() }

    var recovered: Path<Int> { .init() }

    var timeline: FragmentPath<Covid.Timeline> { .init() }

    var updated: Path<String> { .init() }
}

extension GraphQLFragmentPath where UnderlyingType == Covid.World? {
    var active: Path<Int?> { .init() }

    var affectedCountries: Path<Int?> { .init() }

    var cases: Path<Int?> { .init() }

    var deaths: Path<Int?> { .init() }

    var news: FragmentPath<[Covid.NewsStory]?> { .init() }

    var recovered: Path<Int?> { .init() }

    var timeline: FragmentPath<Covid.Timeline?> { .init() }

    var updated: Path<String?> { .init() }
}

// MARK: - BasicCountryCell

extension ApolloCovid.BasicCountryCellCountry: Fragment {
    typealias UnderlyingType = Covid.Country
}

extension BasicCountryCell {
    typealias Country = ApolloCovid.BasicCountryCellCountry

    init(country: Country) {
        self.init(name: GraphQL(country.name),
                  countryCode: GraphQL(country.info.iso2),
                  cases: GraphQL(country.cases))
    }
}

// MARK: - CurrentStateCell

extension ApolloCovid.CurrentStateCellWorld: Fragment {
    typealias UnderlyingType = Covid.World
}

extension CurrentStateCell {
    typealias World = ApolloCovid.CurrentStateCellWorld

    init(world: World) {
        self.init(cases: GraphQL(world.cases),
                  deaths: GraphQL(world.deaths),
                  recovered: GraphQL(world.recovered))
    }
}

// MARK: - FeaturedCountryCell

extension ApolloCovid.FeaturedCountryCellCountry: Fragment {
    typealias UnderlyingType = Covid.Country
}

extension FeaturedCountryCell {
    typealias Country = ApolloCovid.FeaturedCountryCellCountry

    init(country: Country) {
        self.init(name: GraphQL(country.name),
                  countryCode: GraphQL(country.info.iso2),
                  cases: GraphQL(country.cases),
                  deaths: GraphQL(country.deaths),
                  recovered: GraphQL(country.recovered),
                  todayDeaths: GraphQL(country.todayDeaths),
                  casesOverTime: GraphQL(country.timeline.cases.map { $0.value }))
    }
}

// MARK: - NewsStoryCell

extension ApolloCovid.NewsStoryCellNewsStory: Fragment {
    typealias UnderlyingType = Covid.NewsStory
}

extension NewsStoryCell {
    typealias NewsStory = ApolloCovid.NewsStoryCellNewsStory

    init(newsStory: NewsStory) {
        self.init(source: GraphQL(newsStory.source.name),
                  title: GraphQL(newsStory.title),
                  overview: GraphQL(newsStory.overview),
                  image: GraphQL(newsStory.image))
    }
}

// MARK: - ContentView

extension ContentView {
    typealias Data = ApolloCovid.ContentViewQuery.Data

    init(data: Data) {
        self.init(currentCountry: GraphQL(data.myCountry?.fragments.featuredCountryCellCountry),
                  currentCountryName: GraphQL(data.myCountry?.name),
                  currentCountryNews: GraphQL(data.myCountry?.news.map { $0.fragments.newsStoryCellNewsStory }),
                  world: GraphQL(data.world.fragments.currentStateCellWorld),
                  cases: GraphQL(data.world.timeline.cases.map { $0.value }),
                  deaths: GraphQL(data.world.timeline.deaths.map { $0.value }),
                  recovered: GraphQL(data.world.timeline.recovered.map { $0.value }),
                  news: GraphQL(data.world.news.map { $0.fragments.newsStoryCellNewsStory }),
                  countries: GraphQL(data.countries.map { $0.fragments.basicCountryCellCountry }))
    }
}

extension Covid {
    func contentView() -> some View {
        return QueryRenderer(client: client,
                             query: ApolloCovid.ContentViewQuery()) { (data: ApolloCovid.ContentViewQuery.Data) -> ContentView in

            ContentView(data: data)
        }
    }
}

// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

/// ApolloCovid namespace
public enum ApolloCovid {
    public final class ContentViewQuery: GraphQLQuery {
        /// The raw GraphQL definition of this operation.
        public let operationDefinition: String =
            """
            query ContentView {
              countries {
                __typename
                ...BasicCountryCellCountry
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

        public var queryDocument: String { return operationDefinition.appending(BasicCountryCellCountry.fragmentDefinition).appending(FeaturedCountryCellCountry.fragmentDefinition).appending(NewsStoryCellNewsStory.fragmentDefinition).appending(CurrentStateCellWorld.fragmentDefinition) }

        public init() {}

        public struct Data: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["Query"]

            public static let selections: [GraphQLSelection] = [
                GraphQLField("countries", type: .nonNull(.list(.nonNull(.object(Country.selections))))),
                GraphQLField("myCountry", type: .object(MyCountry.selections)),
                GraphQLField("world", type: .nonNull(.object(World.selections))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
                resultMap = unsafeResultMap
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

                public static let selections: [GraphQLSelection] = [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLFragmentSpread(BasicCountryCellCountry.self),
                ]

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                    resultMap = unsafeResultMap
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
                        resultMap = unsafeResultMap
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

            public struct MyCountry: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["Country"]

                public static let selections: [GraphQLSelection] = [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLFragmentSpread(FeaturedCountryCellCountry.self),
                    GraphQLField("name", type: .nonNull(.scalar(String.self))),
                    GraphQLField("news", type: .nonNull(.list(.nonNull(.object(News.selections))))),
                ]

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                    resultMap = unsafeResultMap
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
                        resultMap = unsafeResultMap
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

                    public static let selections: [GraphQLSelection] = [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLFragmentSpread(NewsStoryCellNewsStory.self),
                    ]

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                        resultMap = unsafeResultMap
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
                            resultMap = unsafeResultMap
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

                public static let selections: [GraphQLSelection] = [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLFragmentSpread(CurrentStateCellWorld.self),
                    GraphQLField("news", type: .nonNull(.list(.nonNull(.object(News.selections))))),
                    GraphQLField("timeline", type: .nonNull(.object(Timeline.selections))),
                ]

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                    resultMap = unsafeResultMap
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
                        resultMap = unsafeResultMap
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

                    public static let selections: [GraphQLSelection] = [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLFragmentSpread(NewsStoryCellNewsStory.self),
                    ]

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                        resultMap = unsafeResultMap
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
                            resultMap = unsafeResultMap
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

                    public static let selections: [GraphQLSelection] = [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("cases", type: .nonNull(.list(.nonNull(.object(Case.selections))))),
                        GraphQLField("deaths", type: .nonNull(.list(.nonNull(.object(Death.selections))))),
                        GraphQLField("recovered", type: .nonNull(.list(.nonNull(.object(Recovered.selections))))),
                    ]

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                        resultMap = unsafeResultMap
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

                        public static let selections: [GraphQLSelection] = [
                            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                            GraphQLField("value", type: .nonNull(.scalar(Int.self))),
                        ]

                        public private(set) var resultMap: ResultMap

                        public init(unsafeResultMap: ResultMap) {
                            resultMap = unsafeResultMap
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

                        public static let selections: [GraphQLSelection] = [
                            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                            GraphQLField("value", type: .nonNull(.scalar(Int.self))),
                        ]

                        public private(set) var resultMap: ResultMap

                        public init(unsafeResultMap: ResultMap) {
                            resultMap = unsafeResultMap
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

                        public static let selections: [GraphQLSelection] = [
                            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                            GraphQLField("value", type: .nonNull(.scalar(Int.self))),
                        ]

                        public private(set) var resultMap: ResultMap

                        public init(unsafeResultMap: ResultMap) {
                            resultMap = unsafeResultMap
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
              info {
                __typename
                iso2
              }
              name
            }
            """

        public static let possibleTypes: [String] = ["Country"]

        public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("cases", type: .nonNull(.scalar(Int.self))),
            GraphQLField("info", type: .nonNull(.object(Info.selections))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
            resultMap = unsafeResultMap
        }

        public init(cases: Int, info: Info, name: String) {
            self.init(unsafeResultMap: ["__typename": "Country", "cases": cases, "info": info.resultMap, "name": name])
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

            public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("iso2", type: .scalar(String.self)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
                resultMap = unsafeResultMap
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

    public struct CurrentStateCellWorld: GraphQLFragment {
        /// The raw GraphQL definition of this fragment.
        public static let fragmentDefinition: String =
            """
            fragment CurrentStateCellWorld on World {
              __typename
              cases
              deaths
              recovered
            }
            """

        public static let possibleTypes: [String] = ["World"]

        public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("cases", type: .nonNull(.scalar(Int.self))),
            GraphQLField("deaths", type: .nonNull(.scalar(Int.self))),
            GraphQLField("recovered", type: .nonNull(.scalar(Int.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
            resultMap = unsafeResultMap
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

    public struct FeaturedCountryCellCountry: GraphQLFragment {
        /// The raw GraphQL definition of this fragment.
        public static let fragmentDefinition: String =
            """
            fragment FeaturedCountryCellCountry on Country {
              __typename
              cases
              deaths
              info {
                __typename
                iso2
              }
              name
              recovered
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

        public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("cases", type: .nonNull(.scalar(Int.self))),
            GraphQLField("deaths", type: .nonNull(.scalar(Int.self))),
            GraphQLField("info", type: .nonNull(.object(Info.selections))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
            GraphQLField("recovered", type: .nonNull(.scalar(Int.self))),
            GraphQLField("timeline", type: .nonNull(.object(Timeline.selections))),
            GraphQLField("todayDeaths", type: .nonNull(.scalar(Int.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
            resultMap = unsafeResultMap
        }

        public init(cases: Int, deaths: Int, info: Info, name: String, recovered: Int, timeline: Timeline, todayDeaths: Int) {
            self.init(unsafeResultMap: ["__typename": "Country", "cases": cases, "deaths": deaths, "info": info.resultMap, "name": name, "recovered": recovered, "timeline": timeline.resultMap, "todayDeaths": todayDeaths])
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

        public var recovered: Int {
            get {
                return resultMap["recovered"]! as! Int
            }
            set {
                resultMap.updateValue(newValue, forKey: "recovered")
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

        public struct Info: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["Info"]

            public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("iso2", type: .scalar(String.self)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
                resultMap = unsafeResultMap
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

            public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("cases", type: .nonNull(.list(.nonNull(.object(Case.selections))))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
                resultMap = unsafeResultMap
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

                public static let selections: [GraphQLSelection] = [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("value", type: .nonNull(.scalar(Int.self))),
                ]

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                    resultMap = unsafeResultMap
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
            }
            """

        public static let possibleTypes: [String] = ["NewsStory"]

        public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("image", type: .scalar(String.self)),
            GraphQLField("overview", type: .scalar(String.self)),
            GraphQLField("source", type: .nonNull(.object(Source.selections))),
            GraphQLField("title", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
            resultMap = unsafeResultMap
        }

        public init(image: String? = nil, overview: String? = nil, source: Source, title: String) {
            self.init(unsafeResultMap: ["__typename": "NewsStory", "image": image, "overview": overview, "source": source.resultMap, "title": title])
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

        public struct Source: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["Source"]

            public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("name", type: .nonNull(.scalar(String.self))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
                resultMap = unsafeResultMap
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
}
