import XCTest
@testable import SwiftyPingAsync

//Unit tests utilize an external source for pings, which can and will cause false test failures.
final class SwiftyPingAsyncTests: XCTestCase {
   func testPingIPv4() async throws {
      var byteCounts = [Int?]()
      var errors = [PingError?]()
      var addresses = [String?]()
      var headers = [IPHeader?]()
      var start = Date()
      do {
         var pinger = try AsyncPing(ipv4Address: "8.8.8.8", config: .init(interval: 0.5, with: 1.0), queue: .global())
         pinger.targetCount = 10
         for try await ping in pinger.ping() {
            byteCounts.append(ping.byteCount)
            errors.append(ping.error)
            addresses.append(ping.ipAddress)
            headers.append(ping.ipHeader)
         }
      } catch {
         assertionFailure()
      }
      XCTAssertLessThan(Date().timeIntervalSince(start), 5.0)
      XCTAssertEqual(byteCounts.compactMap({ $0 }).count, 10)
      XCTAssertEqual(errors.compactMap({ $0 }).count, 0)
      XCTAssertEqual(addresses.compactMap({ $0 }).count, 10)
      XCTAssertEqual(headers.compactMap({ $0 }).count, 10)
   }
   func testPingHostName() async throws {
      var count = 0
      var errorCount = 0
      do {
         var pinger = try AsyncPing(host: "google.com", configuration: .init(interval: 0.5, with: 1.0), queue: .global())
         pinger.targetCount = 10
         for try await ping in pinger.ping() {
            if ping.error != nil { errorCount += 1 }
            count += 1
         }
      } catch {
         assertionFailure()
      }
      XCTAssertEqual(count, 10)
      XCTAssertEqual(errorCount, 0)
   }
   func testPingOnce () async throws {
      var count = 0
      var errorCount = 0
      do {
         var pinger = try AsyncPing(host: "google.com", configuration: .init(interval: 0.5, with: 1.0), queue: .global())
         for try await ping in pinger.pingOnce() {
            if ping.error != nil { errorCount += 1 }
            count += 1
         }
      } catch {
         assertionFailure()
      }
      XCTAssertEqual(count, 1)
      XCTAssertEqual(errorCount, 0)
   }
   func testPingResult () async throws {
      var result: PingResult?
      do {
         var pinger = try AsyncPing(host: "google.com", configuration: .init(interval: 0.5, with: 1.0), queue: .global())
         result = try await pinger.pingResult()
      } catch {
         assertionFailure()
      }
      XCTAssertNotNil(result)
      XCTAssertNotNil(result?.packetLoss)
      XCTAssertNotNil(result?.packetsReceived)
      XCTAssertNotNil(result?.packetsTransmitted)
      XCTAssertNotNil(result?.roundtrip)
      XCTAssertNotNil(result?.roundtrip?.average)
      XCTAssertNotNil(result?.roundtrip?.maximum)
      XCTAssertNotNil(result?.roundtrip?.minimum)
      XCTAssertNotNil(result?.roundtrip?.standardDeviation)
      XCTAssertEqual(result?.packetLoss ?? 1, 0)
      XCTAssertEqual(result?.packetsReceived ?? .zero, 10)
      XCTAssertEqual(result?.packetsTransmitted ?? .zero, 10)
      XCTAssertEqual(result?.responses.count ?? .zero, 10)
   }
   func testPingResultWithPacketCount () async throws {
      var result: PingResult?
      do {
         var pinger = try AsyncPing(host: "google.com", configuration: .init(interval: 0.5, with: 1.0), queue: .global())
         pinger.targetCount = 5
         result = try await pinger.pingResult()
      } catch {
         assertionFailure()
      }
      XCTAssertNotNil(result)
      XCTAssertNotNil(result?.packetLoss)
      XCTAssertNotNil(result?.packetsReceived)
      XCTAssertNotNil(result?.packetsTransmitted)
      XCTAssertNotNil(result?.roundtrip)
      XCTAssertNotNil(result?.roundtrip?.average)
      XCTAssertNotNil(result?.roundtrip?.maximum)
      XCTAssertNotNil(result?.roundtrip?.minimum)
      XCTAssertNotNil(result?.roundtrip?.standardDeviation)
      XCTAssertEqual(result?.packetLoss ?? 1, 0)
      XCTAssertEqual(result?.packetsReceived ?? .zero, 5)
      XCTAssertEqual(result?.packetsTransmitted ?? .zero, 5)
      XCTAssertEqual(result?.responses.count ?? .zero, 5)
   }
}
