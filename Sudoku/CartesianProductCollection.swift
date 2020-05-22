func product<A, B>(_ a: A, _ b: B) -> CartesianProductCollection<A, B> where A: Collection, B: Collection {
    CartesianProductCollection(a, b)
}

func square<T>(_ collection: T) -> CartesianProductCollection<T, T> where T: Collection {
    product(collection, collection)
}

struct CartesianProductCollection<A: RandomAccessCollection, B: RandomAccessCollection>: RandomAccessCollection {

    typealias Index = Tuple<A.Index, B.Index>
    typealias Element = Tuple<A.Element, B.Element>

    struct Tuple<A1, B1> {
        let a: A1, b: B1
    }

    private var a: A, b: B

    init(_ a: A, _ b: B) {
        self.a = a
        self.b = b
    }

    var startIndex: Index { .init(a: a.startIndex, b: b.startIndex) }
    var endIndex: Index { .init(a: a.endIndex, b: b.startIndex) }

    subscript(position: Index) -> Element {
        .init(a: a[position.a], b: b[position.b])
    }

    func index(after i: Index) -> Index {
        let nextB = b.index(after: i.b)

        if nextB == b.endIndex {
            return .init(a: a.index(after: i.a), b: b.startIndex)
        } else {
            return .init(a: i.a, b: nextB)
        }
    }

    func index(before i: Index) -> Index {
        if i.b == b.startIndex {
            return .init(a: a.index(before: i.a), b: b.index(before: b.endIndex))
        } else {
            return .init(a: i.a, b: b.index(before: i.b))
        }
    }
}

extension CartesianProductCollection.Tuple: Comparable where A1: Comparable, B1: Comparable {
    static func <(lhs: Self, rhs: Self) -> Bool {
        if lhs.a == rhs.a { return lhs.b < rhs.b }
        return lhs.a < rhs.a
    }
}

extension CartesianProductCollection.Tuple: Equatable where A1: Equatable, B1: Equatable {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.a == rhs.a && lhs.b == rhs.b
    }
}
