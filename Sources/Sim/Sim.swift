import Foundation

public struct Server {
  public var routes: [Route]
  let zero = Int8(0)
  let transportLayer = SOCK_STREAM
  let internetLayerProtocol = AF_INET
  let sock: Int32
  let socklen = UInt8(socklen_t(MemoryLayout<sockaddr_in>.size))

  public init() {
    self.sock = socket(internetLayerProtocol, Int32(transportLayer), 0)
    self.routes = []
  }

  public func serve(
    port: Int = 3000,
    backlogSize: Int32 = 1000,
    _ onListen: (_ port: Int) async -> Void = { print("Server Listening on port \($0)") }
  ) async throws {
    let portNumber = UInt16(port)
    var serveraddr = sockaddr_in()
    serveraddr.sin_family = sa_family_t(AF_INET)
    serveraddr.sin_port = in_port_t((portNumber << 8) + (portNumber >> 8))
    serveraddr.sin_addr = in_addr(s_addr: in_addr_t(0))
    serveraddr.sin_zero = (zero, zero, zero, zero, zero, zero, zero, zero)
    withUnsafePointer(to: &serveraddr) { sockaddrInPtr in
      let sockaddrPtr = UnsafeRawPointer(sockaddrInPtr).assumingMemoryBound(to: sockaddr.self)
      bind(sock, sockaddrPtr, socklen_t(socklen))
    }

    listen(sock, backlogSize)

    let signalHandler: SignalHandler = handleSignal
    signal(SIGINT, signalHandler)

    await onListen(Int(portNumber))

    while true {
      if #available(macOS 10.15, *) {
        let client = await withUnsafeContinuation { continuation in
          DispatchQueue.global().async {
            let client = accept(sock, nil, nil)
            continuation.resume(returning: client)
          }
        }
        await handleClient(client)
      } else {
        let client = accept(sock, nil, nil)
        await handleClient(client)
      }
    }
  }

  private func handleClient(_ client: Int32) async {
    var buffer = [UInt8](repeating: 0, count: 1024)
    let bytesRead = await readData(from: client, into: &buffer, maxLength: buffer.count)

    if bytesRead > 0 {
      let receivedData = Data(bytes: buffer, count: bytesRead)
      if let receivedString = String(data: receivedData, encoding: .utf8) {
        let req = parseRequest(receivedString)
        let res = await handle(req: req)
        let responseString: String = """
          HTTP/1.1 \(res.status.rawValue) \(res.status.description)
          server: sim-server
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

    if client == -1 && errno == EINTR {
      return
    }
  }
}
