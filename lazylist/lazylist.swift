//
//  lazy.swift
//  lazylist
//
//  Created by Dan Kogai on 7/9/14.
//  Copyright (c) 2014 Dan Kogai. All rights reserved.
//
public class LazyList<T,U> {
    private let maker:  ((Int, [T])->T?)?
    private let seed:   [T]?
    private let mapper: T->U?
    private let offset: Int
    /// lazy list.  infinite unless maker is nil
    public init(maker:((Int, [T])->T?)?, seed:[T]?, mapper:T->U?,
        offset:Int = 0, filtered:Bool = false) {
            self.maker  = maker
            self.seed   = seed
            self.mapper = mapper
            self.offset = offset
    }
    /// creates new mapper and installs it
    public func map<V>(mapper:U->V?)->LazyList<T,V> {
        return LazyList<T,V>(
            maker:      maker,
            seed:       seed,
            mapper:     { (t:T) -> V? in
                if let u = self.mapper(t) {
                    return mapper(u)
                } else {
                    return nil
                }
            },
            offset:     offset
        )
    }
    /// installs filter as a mapper
    /// which returns nil on false
    public func filter(judge:U->Bool)->LazyList<T,U> {
        return LazyList<T,U>(
            maker:  self.maker,
            seed:   {
                return self.seed != nil ? self.seed! : [T]()
            }(),
            mapper: { (t:T)-> U? in
                if let u = self.mapper(t) {
                    return judge(u) ? u : nil
                }
                return nil
            },
            offset: offset
        )
    }
    /// returns a new lazy list with n elements truncated
    /// -- actually it only sets the offset
    public func drop(n:Int) -> LazyList<T,U> {
        return LazyList<T,U> (
            maker:      self.maker,
            seed:       self.seed,
            mapper:     mapper,
            offset:     offset + n
        )
    }
    /// returns an array with upto n elements.
    /// this is where laziness ends
    public  func take(n:Int)->[U] {
        var result:[U] = []
        if self.seed != nil {
            var seed = self.seed!
            let need = n + self.offset
            if let maker = self.maker { // fill the seed
                var i = 0
                while result.count < need {
                    if i == seed.count {
                        if let m = maker(i, seed) {
                            seed.append(m)
                        } else {
                            break
                        }
                    }
                    if let v = mapper(seed[i]) { result.append(v) }
                    i += 1
                }
            } else { // finite so break on broke :-)
                var i = 0
                while result.count < need {
                    if i == seed.count { break }
                    if let v = mapper(seed[i]) { result.append(v) }
                    i += 1
                }
            }
        } else {
            // List without array -- always infinite
            // which is the optimal case. no seed required
            var i = self.offset
            while result.count < n {
                if let m = self.maker!(i, [T]()) {
                    result.append(mapper(m)!)
                } else {
                    break
                }
                i += 1
            }
            return result
        }
        return self.offset == 0 ? result
            : Array(result[self.offset..<result.count])
    }
    /// just take(i+1) and return the last element
    public subscript(i:Int)->U? {
        let a = self.drop(i).take(1)
        return a.isEmpty ? nil : a[0]
    }
    /// b..<e -> drop(b) then take (e-b)
    public  subscript(r:Range<Int>)->[U] {
        let b = r.startIndex
        let e = r.endIndex
        return self.drop(b).take(e-b)
    }
    public func copy()->LazyList<T,U> {
        return LazyList<T,U> (
            maker:      self.maker,
            seed:       self.seed,
            mapper:     self.mapper,
            offset:     self.offset
        )
    }
}
extension LazyList : SequenceType {
    public func generate() -> AnyGenerator<U> {
        var idx = 0
        return anyGenerator {
            let result = self[idx]
            idx += 1
            return result
        }
    }
}
/// Factory Functions
public func lazylist<T>(seed:[T], maker:(Int,[T])->T?)->LazyList<T,T> {
    return LazyList (
        maker:  maker,
        seed:   seed,
        mapper: { $0 }
    )
}
public func lazylist<T>(makerone:Int->T?)->LazyList<T,T> {
    return LazyList (
        maker:  { i, _ in makerone(i) },
        seed:   nil,
        mapper: { $0 }
    )
}
public func lazylist<T>(seed:[T])->LazyList<T,T> {
    return LazyList (
        maker:  nil,
        seed:   seed,
        mapper: { $0 }
    )
}
/// placeholder
public class LazyLists {
    public static let ints  = lazylist{ $0 }
    public static let uints = lazylist{ UInt($0) }
}
