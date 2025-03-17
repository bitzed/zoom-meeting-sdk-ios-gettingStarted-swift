# ZoomiOSSDKDemo (Modified Version)

This repository contains a modified version of the demo app that uses the Zoom iOS SDK.  
**Important:** This project does not include the SDK package itself. You must download the latest SDK package from the [Zoom Marketplace](https://marketplace.zoom.us/) and manually import it into the project.

## Prerequisites

- Xcode 12 or later (latest version recommended)
- A device running iOS 13.0 or later
- Download of the Zoom iOS SDK (available from [Zoom Marketplace](https://marketplace.zoom.us/))

## Setup Instructions

1. **Download and Import the SDK Package**  
   - Visit the [Zoom Marketplace](https://marketplace.zoom.us/) and download the Zoom iOS SDK.  
   - Drag and drop the downloaded SDK framework (e.g., `MobileRTC.framework`) into your Xcode project.  
   - Make sure to check the "Copy items if needed" option to add the framework to your project.

2. **Configure Authentication Information**  
   - Open **AppDelegate.swift** and locate the line:
     ```swift
     authorizationService.jwtToken = "YOUR_JWT_TOKEN"
     ```
   - Replace `"YOUR_JWT_TOKEN"` with your issued JWT token.  
     Example:
     ```swift
     authorizationService.jwtToken = "YourJWTToken"
     ```

3. **Configure Meeting Start Parameters**  
   - Open **ViewController.swift** and replace the following placeholders with your information:
     - `YOUR_MEETING_NUMBER` → The meeting number to start
     - `USER_NAME` → The display name for the user
     - `YOUR_ZAK_TOKEN` → The ZAK token (required for starting a meeting as the host)
     
     Example:
     ```swift
     startMeetingParameters.meetingNumber = "123456789"
     startMeetingParameters.userName = "YourName"
     startMeetingParameters.zak = "YourZAKToken"
     ```

4. **Build and Run**  
   - After completing the setup, build the project in Xcode and run it on a simulator or an actual device.

## Notes

- **Managing Sensitive Information**  
  This project is set up so that the SDK package and authentication information (such as JWT and ZAK tokens) are not included, preventing sensitive information from being part of the repository.
  
- **SDK Updates**  
  The Zoom iOS SDK is periodically updated. Please download the latest SDK from the official site and apply it to your project accordingly.
