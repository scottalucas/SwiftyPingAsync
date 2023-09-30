# SwiftyPingAsync
### Additions to SwiftyPing to use Apple Concurrency

### Based on SwiftyPing (https://github.com/samiyr/SwiftyPing)

## Installation
Use the Swift package manager.
```swift
.Package(url: "https://github.com/scottalucas/SwiftyPingAsync.git", branch: "main")
```
## Overview
This package adds one new struct (AsyncPing) with the following methods.
Note that, unlike the SwiftyPing workflow, pinging begins once the
ping, pingOnce, or pingResult methods are called. AsyncPing does not
implement a "startPinging" method.

### ping()
Produces an AsyncStream<PingResponse>.

### pingOnce()
Produces an AsyncStream<PingResponse> with a target ping count of 1.

### pingResult()
Asynchronously produces a PingResult. If you don't specify a targetCount,
this method defaults to 10 pings. Once the specfied number of pings are
complete, the method produces a PingResult object.

### stopPinging()
Stops the pings that were started with ping() or pingOnce(). If you're
consuming ping() or pingOnce() output in a loop, you need to call 
this method if you break out of the loop early. Otherwise, the pings
will continue even after you exit the loop.

The **_targetCount_** property of the AsyncPing object sets how many pings 
will be sent. Once all pings are sent, the AsyncStream methods will finish. 
Again, note that if this property is not set, and you don't call stopPinging()
after you're done consuming the stream's output, pinging continues
indefinitely. See usage for an example.

The SwiftyPing package is exported from SwiftyPingAsync. Specifically,
SwiftyPingAsync uses PingResponse, PingResult, and PingConfiguration
objects from SwiftyPing. Refer to SwiftyPing for definitions and
usage guidance for those objects.

To use, first create a "pinger" object from AsyncPing. The following 
initializers are available:

   init(ipv4Address: String, config configuration: PingConfiguration, queue: DispatchQueue) throws 
   init(destination: SwiftyPing.Destination, configuration: PingConfiguration, queue: DispatchQueue) throws
   init(host: String, configuration: PingConfiguration, queue: DispatchQueue) throws

These initializers match the underlying SwiftyPing initializers.

### Usage
```swift

// Ping indefinitely
var pinger = try AsyncPing(ipv4Address: "8.8.8.8", config: .init(interval: 0.5, with: 1.0), queue: .global())
for try? await ping in pinger.ping() {
  //do work here
  if (ping.error == nil) { //exits on the first successful ping
    pinger.stopPinging()
    break
  }
}

// Ping 10 times
var pinger = try AsyncPing(ipv4Address: "8.8.8.8", config: .init(interval: 0.5, with: 1.0), queue: .global())
pinger.targetCount = 10
for try? await ping in pinger.ping() {
  //do work here
  if (ping.error != nil) { //exits on the first failed ping
    pinger.stopPinging()
    break
  }
}

// Ping once
 var pinger = try? AsyncPing(host: "google.com", configuration: .init(interval: 0.5, with: 1.0), queue: .global())
 for try await ping in pinger.pingOnce() {
    //do work here
 }

```

### License
Officially licensed under MIT. Use as you want.

