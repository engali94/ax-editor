




protocol Parsable {
    func parse(from path: String) throws
}
    

struct Parser: Parsable {
    func parse(from path: String) throws {
        // the name of the file
        let name = path.split(separator: "/").last ?? ""
        guard let data = manager.contents(atPath: path) else {
            manager.createFile(atPath: path, contents: nil, attributes: nil)
            throw Error.anError
        }
    }
}

class Document {
    @discardableResult
    func remove() -> Int? {
        // do some logic here
        fatalError("Unimplemented")
    }
}
