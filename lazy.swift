//
//  lazy.swift
//  lazylist
//
//  Created by Dan Kogai on 7/9/14.
//  Copyright (c) 2014 Dan Kogai. All rights reserved.
//
enum LazyListMaker<T> {
    case One(Int->T?)
    case Two((Int, [T])->T?)
    /// one or none
    func getOne()->(Int->T?) {
        switch self{
        case .One(let one): return one
        default: fatalError("Does not contain Int->T?")
        }
    }
    /// two or none
    func getTwo()->((Int, [T])->T?) {
        switch self{
        case .Two(let two): return two
        default: fatalError("Does not contain Int, [T])->T?")
        }
    }
}
class LazyList<T,U> {
    let maker:      LazyListMaker<T>?
    let seed:       [T]?
    let mapper:     T->U?
    let offset:     Int
    let filtered:   Bool
    /// lazy list.  infinite unless maker is nil
    init(maker:LazyListMaker<T>?, seed:[T]?, mapper:T->U?,
        offset:Int = 0, filtered:Bool = false) {
            self.maker      = maker
            self.seed       = seed
            self.mapper     = mapper
            self.offset     = offset
            self.filtered   = filtered
    }
    /// creates new mapper and installs it
    func map<V>(mapper:U->V?)->LazyList<T,V> {
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
            offset:     offset,
            filtered:   filtered
        )
    }
    /// installs filter as a mapper
    /// which returns nil on false
    func filter(judge:U->Bool)->LazyList<T,U> {
        return LazyList<T,U>(
            maker:      maker,
            seed:       seed,
            mapper:     { (t:T)-> U? in
                if let u = self.mapper(t) {
                    return judge(u) ? u : nil
                }
                return nil
            },
            offset:     offset,
            filtered:   true
        )
    }
    /// returns a new lazy list with n elements truncated
    /// -- actually it only sets the offset
    func drop(n:Int) -> LazyList<T,U> {
        return LazyList<T,U> (
            maker:      self.maker,
            seed:       self.seed,
            mapper:     mapper,
            offset:     offset + n,
            filtered:   filtered
        )
    }
    /// returns an array with upto n elements.
    /// this is where laziness ends
    func take(n:Int)->[U] {
        var result:[U] = []
        if self.seed {
            var seed = self.seed!
            let need = n + self.offset
            if let maker = self.maker { // fill the seed
                let makertwo = maker.getTwo()
                for var i = 0; result.count < need; i++ {
                    if i == seed.count {
                        if let m = makertwo(i, seed) {
                            seed.append(m)
                        } else {
                            break
                        }
                    }
                    if let v = mapper(seed[i]) { result.append(v) }
                }
            } else { // finite so break on broke :-)
                for var i = 0; result.count < need; i++ {
                    if i == seed.count { break }
                    if let v = mapper(seed[i]) { result.append(v) }
                }
            }
        } else { // List without array -- always infinite
            if let maker = self.maker {
                let makerone = maker.getOne()
                if self.filtered {
                    // when we have filter,
                    // we have to keep trying till we have
                    // enough elements.
                    var seed = [T]()
                    let need = n + self.offset
                    for var i = 0; result.count < need; i++ {
                        if i == seed.count {
                            if let m = makerone(i) {
                                seed.append(m)
                            } else {
                                break
                            }
                        }
                        if let v = mapper(seed[i]) {
                            result.append(v)
                        }
                    }
                } else {
                    // the optimal case.
                    // no scratch array needed
                    var i = self.offset
                    for ; result.count < n; i++ {
                        if let m = makerone(i) {
                            result.append(mapper(m)!)
                        } else {
                            break
                        }
                    }
                    return result
                }
            } else {
                fatalError("invalid LazyList")
            }
        }
        return self.offset == 0 ? result
            : Array(result[self.offset..<result.count])
    }
    /// just take(i+1) and return the last element
    subscript(i:Int)->U? {
        let a = self.drop(i).take(1)
        return a.isEmpty ? nil : a[0]
    }
    /// b..<e -> drop(b) then take (e-b)
    subscript(r:Range<Int>)->[U] {
        let b = r.startIndex
        let e = r.endIndex
        return self.drop(b).take(e-b)
    }
    func copy()->LazyList<T,U> {
        return LazyList<T,U> (
            maker:      self.maker,
            seed:       self.seed,
            mapper:     self.mapper,
            offset:     self.offset,
            filtered:   self.filtered
        )
    }
}
extension LazyList : Sequence {
    func generate() -> GeneratorOf<U> {
        var idx = 0
        return GeneratorOf<U> {
            return self[idx++]
        }
    }
}
/// placeholder class
class LazyLists {
    class var Ints:LazyList<Int,Int> {
    return LazyList (
        maker:  LazyListMaker.One({ $0 }),
        seed:   nil,
        mapper: { $0 }
        )
    }
    class var UInts:LazyList<UInt,UInt> {
    return LazyList (
        maker:  LazyListMaker.One({ UInt($0) }),
        seed:   nil,
        mapper: { $0 }
        )
    }
}
/// Factory Functions
func lazylist<T>(maker:Int->T?)->LazyList<T,T> {
    return LazyList (
        maker:  LazyListMaker.One(maker),
        seed:   nil,
        mapper: { $0 }
    )
}
func lazylist<T>(seed:[T])->LazyList<T,T> {
    return LazyList (
        maker:  nil,
        seed:   seed,
        mapper: { $0 }
    )
}
func lazylist<T>(seed:[T], maker:(Int,[T])->T?)->LazyList<T,T> {
    return LazyList (
        maker:  LazyListMaker.Two(maker),
        seed:   seed,
        mapper: { $0 }
    )
}
