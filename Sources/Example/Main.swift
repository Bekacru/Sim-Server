import Foundation
import Sim

var app = Server()

app.get("/") {
  req in
  let html =
    "<!DOCTYPE html><html><body style='text-align:center;'><h1>Hello from Sim.</h1></body></html>"
  return Response(body: html, status: .ok)
}

app.get("/[id]") {
  req in
  let id = req.param["id"] ?? ""
  let html =
    "<!DOCTYPE html><html><body style='text-align:center;'><h1>id = \(id)</h1></body></html>"
  return Response(body: html, status: .ok)
}

do {
  try await app.serve()
} catch {
  print("Error serving: \(error)")
}
