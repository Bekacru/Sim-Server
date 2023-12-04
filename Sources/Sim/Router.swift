import Foundation

enum Method {
  case GET, POST
}

enum Status: Equatable {
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

struct Request {
  let method: Method
  let path: String
  var param: [String: String] = [:]
}

struct Response {
  let body: String
  let status: Status
}

struct Route {
  let path: String
  let method: Method
  let handler: (_ req: Request) -> Response
}

struct Router {
  var routes: [Route] = []

  mutating func get(_ path: String, handler: @escaping (Request) -> Response) {
    let route = Route(path: path, method: .GET, handler: handler)
    routes.append(route)
  }

  mutating func post(_ path: String, handler: @escaping (Request) -> Response) {
    let route = Route(path: path, method: .POST, handler: handler)
    routes.append(route)
  }

  func handle(req: Request) -> Response {
    var route: Route? = nil
    var request = req
    for r in routes {
      if r.path == req.path {
        route = r
        break
      }
      //Dynamic Routes
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
          let requestPath =
            req.path.components(separatedBy: "/")
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
    if let route {
      return route.handler(request)
    } else {
      let html =
        "<!DOCTYPE html><html><body style='text-align:center;'><h1>Not Found.</h1></body></html>"
      return Response(body: html, status: .notFound)
    }
  }
}
