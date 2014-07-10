//
//  cons.swift
//  lazylist
//
//  Created by Dan Kogai on 7/9/14.
//  Copyright (c) 2014 Dan Kogai. All rights reserved.
//

/// like Haskell, this list is immutable
class Cons<T> : Sequence {
    let car:T
    let cdr:Cons<T>?
    init (_ car:T, _ cdr:Cons<T>?) {
        self.car = car
        self.cdr = cdr
    }
    /*
    deinit {
    let addr = reinterpretCast(self) as UInt
    println("deinit:\(addr),\(self.car)")
    }
    */
    var count:Int {
    if cdr { return 1 + cdr!.count }
        return 1
    }
    var length:Int { return count }
    // to conform to Sequence
    typealias GeneratorType = ConsGenerator<T>
    func generate() -> ConsGenerator<T> {
        return ConsGenerator(self)
    }
    // to conform to Collection in the future
    typealias IndexType = Int
    subscript(idx:Int)->T {
        if idx == 0 { return car }
            if cdr { return cdr![idx - 1] }
            fatalError("index too large")
    }
}
class ConsGenerator<T> : Generator {
    typealias Element = T
    var lst:Cons<T>? = nil
    init(_ lst:Cons<T>){ self.lst = lst }
    func next()->T? {
        if lst {
            let elem = lst!.car
            lst = lst!.cdr
            return elem
        }
        return nil
    }
}
extension Cons {
    func append(lst:Cons<T>)->Cons<T> {
        if cdr {
            return Cons(car, cdr!.append(lst))
        } else {
            return Cons(car, lst)
        }
    }
    func map<R>(mapper:T->R)->Cons<R>{
        let mcar = mapper(car)
        if cdr {
            return Cons<R>(mcar, cdr!.map(mapper))
        } else {
            return Cons<R>(mcar, nil)
        }
    }
    func filter(cond:(T)->Bool)->Cons<T>? {
        if cond(car) {
            if cdr { return Cons(car, cdr!.filter(cond)) }
            else   { return Cons(car, nil) }
        } else {
            if cdr { return cdr!.filter(cond) }
        }
        return nil
    }
    func any(cond:(T)->Bool)->Bool {
        if cond(car) {
            return true
        } else {
            if cdr { return cdr!.any(cond) }
        }
        return false
    }
    func all(cond:(T)->Bool)->Bool {
        if cond(car) {
            if cdr { return cdr!.all(cond) }
        } else {
            return false
        }
        return true
    }
    func reduce<R>(seed:R, reducer:(R,T)->R)->R {
        let result = reducer(seed, car)
        if cdr { return cdr!.reduce(result, reducer) }
        else   { return result }
    }
    func copy()->Cons<T> {
        if cdr {
            return Cons(car, cdr!.copy())
        } else {
            return Cons(car, nil)
        }
    }
    func reverse()->Cons<T> {
        let end = Cons(car, nil)
        if cdr {
            return cdr!.reverse().append(end)
        }
        else { return end }
    }
    func foldr<R>(seed:R, reducer:(T,R)->R)->R {
        let result = reducer(car, seed)
        if cdr { return cdr!.foldr(result, reducer) }
        else   { return result }
    }
    func take(n:Int)->Cons<T>? {
        if n == 0 { return nil }
        if cdr    { return Cons(car, cdr!.take(n - 1)) }
        return Cons(car, nil)
    }
    func drop(n:Int)->Cons<T>? {
        if n == 0 { return self }
        if cdr    { return cdr!.drop(n - 1) }
        return nil
    }
    /// naive quicksort
    func nqsort(comp:(T,T)->Bool)->Cons<T> {
        if cdr {
            let p = self.car
            let m = Cons(p, nil)
            let l = cdr!.filter{  comp($0, p) }?.nqsort(comp)
            let r = cdr!.filter{ !comp($0, p) }?.nqsort(comp)
            if l {
                if r { return l!.append(m).append(r!) }
                else { return l!.append(m) }
            } else {
                return m.append(r!)
            }
        }
        return self
    }
}
@infix func +<T>(lhs:Cons<T>, rhs:Cons<T>)->Cons<T> {
    return lhs.append(rhs)
}
@infix func ==<T: Equatable>(lhs:Cons<T>, rhs:Cons<T>)->Bool {
    if lhs.car != rhs.car { return false }
    if lhs.cdr {
        if rhs.cdr { return lhs.cdr! == rhs.cdr! }
        return false
    }
    if rhs.cdr { return false }
    else { return true }
}
@infix func !=<T: Equatable>(lhs:Cons<T>, rhs:Cons<T>)->Bool {
    return !(lhs == rhs)
}
/// stringification
extension Cons: Printable, DebugPrintable {
    var description:String {
    var s = "\(car)"
        var l = cdr
        while l {
            s += ", \(l!.car)"
            l = l!.cdr
        }
        return "list(\(s))"
    }
    var debugDescription:String {
    return description
    }
}
/// list<->array converter
extension Cons {
    class func list(var elems:[T]) -> Cons<T>? {
        if elems.isEmpty { return nil }
        var l = Cons(elems.removeLast(), nil)
        while !elems.isEmpty {
            l = Cons(elems.removeLast(), l)
        }
        return l
    }
    func toArray()->[T] {
        var a = [T]()
        var l:Cons<T>? = self
        while l is Cons<T> {
            a.append(l!.car)
            l = l!.cdr
        }
        return a
    }
    var asArray:[T] { return toArray() }
    /// somewhat cheating sort
    func sort(comp:(T,T)->Bool)->Cons<T> {
        var ary = self.asArray
        ary.sort(comp)
        return Cons.list(ary)!
    }
}
