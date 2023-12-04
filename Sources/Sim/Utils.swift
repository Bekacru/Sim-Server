import Foundation

func parseRequest(_ input: String) -> Request {
  let parts = input.components(separatedBy: "\n")
  let reqMessage = parts[0].components(separatedBy: ":")[0].components(separatedBy: " ")
  let method = reqMessage[0] == "GET" ? Method.GET : Method.POST
  let path = reqMessage[1]
  return Request(method: method, path: path)
}

func readData(from socket: Int32, into buffer: UnsafeMutableRawPointer, maxLength: Int) async -> Int
{
  if #available(macOS 10.15, *) {
    return await withUnsafeContinuation { continuation in
      DispatchQueue.global().async {
        let bytesRead = read(socket, buffer, maxLength)
        if bytesRead < 0 {
          perror("read error")
        }
        continuation.resume(returning: bytesRead)
      }
    }
  } else {
    let bytesRead = read(socket, buffer, maxLength)
    if bytesRead < 0 {
      perror("read error")
    }
    return bytesRead
  }
}

typealias SignalHandler = @convention(c) (Int32) -> Void

func handleSignal(sig: Int32) {
  print("Server is shutting down...")

  exit(0)
}
