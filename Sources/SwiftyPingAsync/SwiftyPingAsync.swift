   // The Swift Programming Language
   // https://docs.swift.org/swift-book

@_exported import SwiftyPing
import Foundation

public struct AsyncPing {
   
   public mutating func ping () -> AsyncThrowingStream<PingResponse, Error> {
      pinger.targetCount = targetCount
      return AsyncThrowingStream<PingResponse, Error> { cont in
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
   }
   
   public mutating func pingOnce () -> AsyncThrowingStream<PingResponse, Error> {
      pinger.targetCount = 1
      return AsyncThrowingStream<PingResponse, Error> { cont in
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
   }
   
   public func pingResult () async throws -> PingResult {
      pinger.targetCount = targetCount ?? 10
      return try await withCheckedThrowingContinuation { cont in
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
   
   public mutating func stopPinging() {
      pinger.stopPinging()
   }
   
   public var targetCount: Int? = nil
   
   private var pinger: SwiftyPing
   
   public init(ipv4Address: String, config configuration: PingConfiguration, queue: DispatchQueue) throws {
      let pinger = try SwiftyPing(ipv4Address: ipv4Address, config: configuration, queue: queue)
      self.pinger = pinger
   }
   public init(destination: SwiftyPing.Destination, configuration: PingConfiguration, queue: DispatchQueue) throws {
      let pinger = try SwiftyPing(destination: destination, configuration: configuration, queue: queue)
      self.pinger = pinger
   }
   public init(host: String, configuration: PingConfiguration, queue: DispatchQueue) throws {
      let pinger = try SwiftyPing(host: host, configuration: configuration, queue: queue)
      self.pinger = pinger
   }
}
