import Foundation

public enum Method {
  case GET, POST
}

public enum Status: Equatable {
  case ok
  case badRequest
  case unauthorized
  case notFound
  case methodNotAllowed
  case internalServerError
  case custom(Int)

  var rawValue: Int {
    switch self {
    case .ok: return 200
    case .badRequest: return 400
    case .unauthorized: return 401
    case .notFound: return 404
    case .methodNotAllowed: return 405
    case .internalServerError: return 500
    case .custom(let code): return code
    }
  }
  var description: String {
    switch self {
    case .ok: return "OK"
    case .badRequest: return "Bad Request"
    case .unauthorized: return "Unauthorized"
    case .notFound: return "Not Found"
    case .methodNotAllowed: return "Method Not Allowed"
    case .internalServerError: return "Internal Server Error"
    case .custom(let code): return "Custom Status Code \(code)"
    }
  }
}

public struct Request {
  public let method: Method
  public let path: String
  public var param: [String: String]
  public init(method: Method, path: String, param: [String: String] = [:]) {
    self.method = method
    self.path = path
    self.param = param
  }
}

public struct Response {
  public let body: String
  public let status: Status
  public init(body: String, status: Status) {
    self.body = body
    self.status = status
  }
}

public struct Route {
  public let path: String
  public let method: Method
  public let handler: (_ req: Request) async -> Response
}

//Router Implementation
extension Server {
  public mutating func get(_ path: String, handler: @escaping (Request) async -> Response) {
    let route = Route(path: path, method: .GET, handler: handler)
    routes.append(route)
  }

  public mutating func post(_ path: String, handler: @escaping (Request) async -> Response) {
    let route = Route(path: path, method: .POST, handler: handler)
    routes.append(route)
  }

  public func handle(req: Request) async -> Response {
    print(req.path, routes.count)
    var route: Route? = nil
    var request = req
    for r in routes {
      if r.path == req.path {
        route = r
        break
      }

      // Dynamic Routes
      let regexPattern = "\\[[a-zA-Z]+\\]"
      do {
        let regex = try NSRegularExpression(pattern: regexPattern, options: [])
        let range = NSRange(location: 0, length: r.path.utf16.count)
        let matches = regex.matches(in: r.path, options: [], range: range)
        if matches.count >= 1 {
          let matchRange = Range(matches[0].range, in: r.path)!
          let matchedString = String(r.path[matchRange]).replacingOccurrences(of: "[", with: "")
            .replacingOccurrences(of: "]", with: "")
          let staticPath = r.path.components(separatedBy: "[")[0]
          let requestPath = req.path.components(separatedBy: "/")
          let staticReqPath = "/" + requestPath.dropLast().joined(separator: "/")
          let dynamicParam = requestPath.last!
          if staticPath == staticReqPath {
            route = r
            request.param[matchedString] = dynamicParam
            break
          }
        }
      } catch {
        print("Error creating regex: \(error)")
      }
    }

    if let route = route {
      return await route.handler(request)
    } else {
      let html =
        "<!DOCTYPE html><html><body style='text-align:center;'><h1>Not Found.</h1></body></html>"
      return Response(body: html, status: .notFound)
    }
  }
}
