import Foundation

let zero = Int8(0)
let transportLayer = SOCK_STREAM  //TCP
let internetLayerProtocol = AF_INET  // IPV4
let sock = socket(internetLayerProtocol, Int32(transportLayer), 0)
let portNumber = UInt16(4000)
let socklen = UInt8(socklen_t(MemoryLayout<sockaddr_in>.size))  //this specify the length/size of the socket

struct Server {
  let router = Router()
  func serve() {
    var serveraddr = sockaddr_in()
    serveraddr.sin_family = sa_family_t(AF_INET)
    serveraddr.sin_port = in_port_t((portNumber << 8) + (portNumber >> 8))
    serveraddr.sin_addr = in_addr(s_addr: in_addr_t(0))
    serveraddr.sin_zero = (zero, zero, zero, zero, zero, zero, zero, zero)
    withUnsafePointer(to: &serveraddr) { sockaddrInPtr in
      let sockaddrPtr = UnsafeRawPointer(sockaddrInPtr).assumingMemoryBound(to: sockaddr.self)
      bind(sock, sockaddrPtr, socklen_t(socklen))
    }
    listen(sock, 5)
    print("Server listening on port \(portNumber)")
    repeat {
      let client = accept(sock, nil, nil)
      var buffer = [UInt8](repeating: 0, count: 1024)
      let bytesRead = readData(from: client, into: &buffer, maxLength: buffer.count)
      if bytesRead > 0 {
        let receivedData = Data(bytes: buffer, count: bytesRead)
        if let receivedString = String(data: receivedData, encoding: .utf8) {
          let req = parseRequest(receivedString)
          let res = router.handle(req: req)
          let responseString: String = """
            HTTP/1.1 \(res.status.rawValue) \(res.status.description)
            server: simple-swift-server
            content-length: \(res.body.count)

            \(res.body)
            """
          responseString.withCString { bytes in
            send(client, bytes, Int(strlen(bytes)), 0)
            close(client)
          }
        } else {
          print("Received data is not a valid UTF-8 string")
        }
      } else if bytesRead == 0 {
        print("Connection closed by the other end")
      } else {
        print("Error reading Received data")
      }
    } while sock > -1
  }
}

//This is how it works


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
  print(req.param)in
  let html =
    "<!DOCTYPE html><html><body style='text-align:center;'><h1>id = \(id)</h1></body></html>"
  return Response(body: html, status: .ok)
}

app.serve()