import Foundation

struct World {
    var uuid: () -> UUID = UUID.init
    var date: () -> Date = Date.init
}

var Current = World()
