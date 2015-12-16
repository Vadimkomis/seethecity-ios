# SeetheCity iOS App

SeetheCity is a demo iOS project that showcases the use of [Twitter's public APIs](https://dev.twitter.com/rest/public), [GNIP Audience API](https://gnip.com/insights/audience/), and [Fabric](https://get.fabric.io). It is a travel guide that highlights popular attractions in a number of major cities.

SeetheCity uses a custom API that's served from a Ruby on Rails app. The Ruby on Rails app can be downloaded and set up through https://github.com/twitterdev/seethecity-server.

## Getting Started

To get started and run the app, you need to follow these simple steps:

1. Clone the repository:

		git clone git@github.com:twitterdev/seethecity-ios.git

1. Open the SeetheCity Workspace with Xcode.

1. Sign up for [Fabric](https://fabric.io/sign_up).

1. Download and install the [Fabric Mac app](https://fabric.io/onboard).

1. Run the Fabric app and sign in with your Fabric account.

1. In the Fabric app, add a new project and select the SeetheCity Xcode Workspace.

1. Install the Twitter Kit SDK by following the instructions in the Fabric app or on https://fabric.io/kits/ios/twitterkit/install.

1. Ensure the [SeetheCity server](https://github.com/twitterdev/seethecity-server) is running.

1. Update the `host` Constant in `Constants.swift` with your SeetheCity server host.

1. You're all set! Run SeetheCity on your iPhone or the iOS Simulator.

## License

Copyright 2016 Twitter, Inc.

Licensed under the Apache License, Version 2.0
http://www.apache.org/licenses/LICENSE-2.0