# Sim Server

A toy web server written in swift.

## Usage

```swift
let app = Server()
let router = app.router

router.get("/") {
    req in
    let html =
    "<!DOCTYPE html><html><body style='text-align:center;'><h1>Hello from \(req.path) path.</h1></body></html>"
    return Response(body: html, status: .ok)
}

router.get("/[id]") {
    req in
    let id = req.param["id"] ?? ""
    let html =
    "<!DOCTYPE html><html><body style='text-align:center;'><h1>id = \(id)</h1></body></html>"
    return Response(body: html, status: .ok)
}

app.serve()
```
