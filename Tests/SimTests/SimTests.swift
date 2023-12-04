import XCTest

@testable import Sim

final class SimTests: XCTestCase {
  func testExample() throws {
    let s = Server()
    var router = s.router
    router.get("/") {
      req in
      let html =
        "<!DOCTYPE html><html><body style='text-align:center;'><h1>Hello from \(req.path) path.</h1></body></html>"
      return Response(body: html, status: .ok)
    }

    router.get("/[id]") {
      req in
      let id = req.param["id"] ?? ""
      print(req.param)
      let html =
        "<!DOCTYPE html><html><body style='text-align:center;'><h1>id = \(id)</h1></body></html>"
      return Response(body: html, status: .ok)
    }
    s.serve()
  }
}
