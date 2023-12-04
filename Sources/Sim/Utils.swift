import Foundation

func parseRequest(_ input: String) -> Request {
  let parts = input.components(separatedBy: "\n")
  let reqMessage = parts[0].components(separatedBy: ":")[0].components(separatedBy: " ")
  let method = reqMessage[0] == "GET" ? Method.GET : Method.POST
  let path = reqMessage[1]
  return Request(method: method, path: path)
}

func readData(from socket: Int32, into buffer: UnsafeMutableRawPointer, maxLength: Int) -> Int {
  let bytesRead = read(socket, buffer, maxLength)
  if bytesRead < 0 {
    perror("read error")
  }
  return bytesRead
}
