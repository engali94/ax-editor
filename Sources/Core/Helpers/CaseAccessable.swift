
import Foundation

protocol CaseAccessible {
    var label: String { get }
    
    func associatedValue<AssociatedValue>() -> AssociatedValue?
    func associatedValue<AssociatedValue>(mathing pattern: (AssociatedValue) -> Self) -> AssociatedValue?
}

extension CaseAccessible {
    var label: String {
        return Mirror(reflecting: self).children.first?.label ?? String(describing: self)
    }
    
    func associatedValue<AssociatedValue>() -> AssociatedValue? {
        return decompose()?.value
    }
    
    func associatedValue<AssociatedValue>(mathing pattern: (AssociatedValue) -> Self) -> AssociatedValue? {
        guard let decomposed: (String, AssociatedValue) = decompose(),
            let patternLabel = Mirror(reflecting: pattern(decomposed.1)).children.first?.label,
            decomposed.0 == patternLabel else { return nil }
        
        return decomposed.1
    }
    
    private func decompose<AssociatedValue>() -> (label: String, value: AssociatedValue)? {
        for case let (label?, value) in Mirror(reflecting: self).children {
            if let result = (value as? AssociatedValue) ?? (Mirror(reflecting: value).children.first?.value as? AssociatedValue) {
                return (label, result)
            }
        }
        return nil
    }
}
