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
}
class LazyList<T,U> {
    let maker:LazyListMaker<T>?
    let seed:[T]?
    let mapper:T->U?
    let offset:Int
    /// lazy list.  infinite unless maker is nil
    init(maker:LazyListMaker<T>?, seed:[T]?,
        mapper:T->U?, offset:Int = 0) {
        self.maker  = maker
        self.seed   = seed
        self.mapper = mapper
        self.offset = offset
    }
    /// creates new mapper and installs it
    func map<V>(mapper:U->V?)->LazyList<T,V> {
        return LazyList<T,V>(
            maker:maker,
            seed:seed,
            mapper: { (t:T) -> V? in
                if let u = self.mapper(t) { return mapper(u) }
                else { return nil }
            }
        )
    }
    /// installs filter as a mapper
    /// which returns nil on false
    func filter(judge:U->Bool)->LazyList<T,U> {
        return LazyList<T,U>(
            maker:maker,
            seed:seed,
            mapper: { (t:T)-> U? in
                if let u = self.mapper(t) {
                    return judge(u) ? u : nil
                }
                return nil
            }
        )
    }
    /// returns an array with n elements.
    func take(n:Int) -> [U] {
        var result:[U] = []
        if self.seed {
            var seed = self.seed!
            let need = n + self.offset
            // if infinite list, fill the seed
            if let maker = self.maker {
                var makertwo:(Int,[T])->T?
                switch maker {
                case .Two(let two): makertwo = two
                default: fatalError("Invalid Maker")
                }
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
            // finite so break on broke :-)
            } else {
                for var i = 0; result.count < need; i++ {
                    if i == seed.count { break }
                    if let v = mapper(seed[i]) { result.append(v) }
                }
            }
            if self.offset == 0 {
                return result
            } else {
                return Array(result[self.offset..<result.count])
            }
        } else { // List without array -- always infinite
            if let maker = self.maker {
                var makerone:Int->T?
                switch maker {
                case .One(let one): makerone = one
                default: fatalError("Invalid Maker")
                }
                for var i = self.offset; result.count < n; i++ {
                    if let m = makerone(i) {
                        if let v = mapper(m) { result.append(v) }
                    } else {
                        break
                    }
                }
                return result
            } else {
                fatalError("invalid LazyList")
            }
        }
    }
    /// returns a new lazy list with n elements truncated
    /// -- actually it only sets the offset
    func drop(n:Int) -> LazyList<T,U> {
        return LazyList<T,U> (
            maker:  self.maker,
            seed:   self.seed,
            mapper: self.mapper,
            offset: self.offset + n
        )
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
            maker:  self.maker,
            seed:   self.seed,
            mapper: self.mapper,
            offset: self.offset
        )
    }
}
/// placeholder class
class LazyLists {
    class var Ints:LazyList<Int,Int> {
        return LazyList (
            maker: LazyListMaker.One({ $0 }),
            seed:  nil,
            mapper:{ $0 }
        )
    }
    class var UInts:LazyList<UInt,UInt> {
        return LazyList (
            maker: LazyListMaker.One({ UInt($0) }),
            seed:  nil,
            mapper:{ $0 }
        )
    }
}
/// Factory Functions
func lazylist<T>(maker:Int->T?)->LazyList<T,T> {
    return LazyList (
        maker:LazyListMaker.One(maker),
        seed:nil,
        mapper:{ $0 }
    )
}
func lazylist<T>(seed:[T])->LazyList<T,T> {
    return LazyList (
        maker:nil,
        seed:seed,
        mapper:{ $0 }
    )
}
func lazylist<T>(seed:[T], maker:(Int,[T])->T?)->LazyList<T,T> {
    return LazyList (
        maker:LazyListMaker.Two(maker),
        seed:seed,
        mapper:{ $0 }
    )
}
