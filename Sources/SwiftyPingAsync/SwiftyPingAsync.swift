   // The Swift Programming Language
   // https://docs.swift.org/swift-book

import SwiftyPing
import Foundation

typealias Configuration = PingConfiguration

struct AsyncPing {
   
   mutating func ping () -> AsyncThrowingStream<PingResponse, Error> {
      let stream = AsyncThrowingStream<PingResponse, Error> { cont in
         pinger.finished = { _ in
            cont.finish()
         }
         pinger.observer = { result in
            cont.yield(result)
         }
         do {
            try pinger.startPinging()
         } catch {
            cont.finish(throwing: error)
         }
      }
      return stream
   }
   
   mutating func pingOnce () -> AsyncThrowingStream<PingResponse, Error> {
      let stream = AsyncThrowingStream<PingResponse, Error> { cont in
         pinger.finished = { _ in
            cont.finish()
         }
         pinger.observer = { result in
            cont.yield(result)
         }
         do {
            pinger.targetCount = 1
            try pinger.startPinging()
         } catch {
            cont.finish(throwing: error)
         }
      }
      return stream
   }
   
   func pingResult () async throws -> PingResult {
      try await withCheckedThrowingContinuation { cont in
         pinger.finished = { result in
            cont.resume(returning: result)
         }
         do {
            try pinger.startPinging()
         } catch {
            cont.resume(throwing: error)
         }
      }
   }
   
   mutating func stopPinging() {
      pinger.stopPinging()
   }
   
   private var pinger: SwiftyPing
   
   init(ipv4Address: String, config configuration: PingConfiguration, count: Int? = nil, queue: DispatchQueue) throws {
      let pinger = try SwiftyPing(ipv4Address: ipv4Address, config: configuration, queue: queue)
      pinger.targetCount = count
      self.pinger = pinger
   }
   init(destination: SwiftyPing.Destination, configuration: PingConfiguration, count: Int? = nil, queue: DispatchQueue) throws {
      let pinger = try SwiftyPing(destination: destination, configuration: configuration, queue: queue)
      pinger.targetCount = count
      self.pinger = pinger
   }
   init(host: String, configuration: PingConfiguration, count: Int? = nil, queue: DispatchQueue) throws {
      let pinger = try SwiftyPing(host: host, configuration: configuration, queue: queue)
      pinger.targetCount = count
      self.pinger = pinger
   }
}


