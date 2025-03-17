//
//  ViewController.swift
//  ZoomiOSSDKDemo
//
//  Created by Zoom Video Communications on 8/14/20.
//  Copyright © 2020 Zoom Video Communications. All rights reserved.
//

import UIKit
import MobileRTC

class ViewController: UIViewController {

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // The Zoom SDK requires a UINavigationController to update the UI for us. Here we supplied the SDK with the ViewControllers navigationController.
        MobileRTC.shared().setMobileRTCRootController(self.navigationController)

    }

    // MARK: - IBOutlets

    @IBAction func joinAMeetingButtonPressed(_ sender: Any) {
        presentJoinMeetingAlert()
    }

    @IBAction func startAnInstantMeetingButtonPressed(_ sender: Any) {
            startMeeting()
    }

    // MARK: - Zoom SDK Examples

    /// Puts user into ongoing Zoom meeting using a known meeting number and meeting password.
    ///
    /// Assign a MobileRTCMeetingServiceDelegate to listen to meeting events and join meeting status.
    ///
    /// - Parameters:
    ///   - meetingNumber: The meeting number of the desired meeting.
    ///   - meetingPassword: The meeting password of the desired meeting.
    /// - Precondition:
    ///   - Zoom SDK must be initialized and authorized.
    ///   - MobileRTC.shared().setMobileRTCRootController() has been called.
    func joinMeeting(meetingNumber: String, meetingPassword: String) {
        // Obtain the MobileRTCMeetingService from the Zoom SDK, this service can start meetings, join meetings, leave meetings, etc.
        if let meetingService = MobileRTC.shared().getMeetingService() {

            // Set the ViewController to be the MobileRTCMeetingServiceDelegate
            meetingService.delegate = self

            // Create a MobileRTCMeetingJoinParam to provide the MobileRTCMeetingService with the necessary info to join a meeting.
            // In this case, we will only need to provide a meeting number and password.
            let joinMeetingParameters = MobileRTCMeetingJoinParam()
            joinMeetingParameters.meetingNumber = meetingNumber
            joinMeetingParameters.password = meetingPassword

            // Call the joinMeeting function in MobileRTCMeetingService. The Zoom SDK will handle the UI for you, unless told otherwise.
            // If the meeting number and meeting password are valid, the user will be put into the meeting. A waiting room UI will be presented or the meeting UI will be presented.
            meetingService.joinMeeting(with: joinMeetingParameters)
        }
    }

    /// Creates and starts a Zoom instant meeting. An instant meeting is an unscheduled meeting that begins instantly.
    ///
    /// Assign a MobileRTCMeetingServiceDelegate to listen to meeting events and start meeting status.
    ///
    /// - Precondition:
    ///   - Zoom SDK must be initialized and authorized.
    ///   - MobileRTC.shared().setMobileRTCRootController() has been called.
    ///   - User has logged into Zoom successfully.
    func startMeeting() {
        // Get MobileRTCMeetingService
        guard let meetingService = MobileRTC.shared().getMeetingService() else {
            print("[DEBUG] Failed to get meetingService")
            return
        }
        
        // delegate to receive meeting event
        meetingService.delegate = self

        // create MobileRTCMeetingStartParam4WithoutLoginUser to start meeting with ZAK token
        let startMeetingParameters = MobileRTCMeetingStartParam4WithoutLoginUser()
        
        // set pre-scheduled meeting number to start
        startMeetingParameters.meetingNumber = "YOUR_MEETING_NUMBER"
        
        // set your display name
        startMeetingParameters.userName = "USER_NAME"
        
        // put your ZAK token to start a meeting as a host
        startMeetingParameters.zak = "YOUR_ZAK_TOKEN"
        
        // start a meeting
        let response = meetingService.startMeeting(with: startMeetingParameters)
        print("startMeeting response: \(response)")
    }


    // MARK: - Convenience Alerts

    /// Creates alert for prompting the user to enter meeting number and password for joining a meeting.
    func presentJoinMeetingAlert() {
        let alertController = UIAlertController(title: "Join meeting", message: "", preferredStyle: .alert)

        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Meeting number"
            textField.keyboardType = .phonePad
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Meeting password"
            textField.keyboardType = .asciiCapable
            textField.isSecureTextEntry = true
        }

        let joinMeetingAction = UIAlertAction(title: "Join meeting", style: .default, handler: { alert -> Void in
            let numberTextField = alertController.textFields![0] as UITextField
            let passwordTextField = alertController.textFields![1] as UITextField

            if let meetingNumber = numberTextField.text, let password = passwordTextField.text {
                self.joinMeeting(meetingNumber: meetingNumber, meetingPassword: password)
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action : UIAlertAction!) -> Void in })

        alertController.addAction(joinMeetingAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - MobileRTCMeetingServiceDelegate

// Conform ViewController to MobileRTCMeetingServiceDelegate.
// MobileRTCMeetingServiceDelegate listens to updates about meetings, such as meeting state changes, join attempt status, meeting errors, etc.
extension ViewController: MobileRTCMeetingServiceDelegate {

    // Is called upon in-meeting errors, join meeting errors, start meeting errors, meeting connection errors, etc.
    func onMeetingError(_ error: MobileRTCMeetError, message: String?) {
        switch error {
        case .success:
            print("Successful meeting operation.")
        case .passwordError:
            print("Could not join or start meeting because the meeting password was incorrect.")
        default:
            print("MobileRTCMeetError: \(error) \(message ?? "")")
        }
    }

    // Is called when the user joins a meeting.
    func onJoinMeetingConfirmed() {
        print("Join meeting confirmed.")
    }

    // Is called upon meeting state changes.
    func onMeetingStateChange(_ state: MobileRTCMeetingState) {
        print("[DEBUG] Current meeting state: \(state)")
        
        switch state {
        case .waitingForHost:
            // Try stopping liveTranscription on waiting_for_host status
            if let meetingService = MobileRTC.shared().getMeetingService() {
                let liveTranscriptionStatus = meetingService.getLiveTranscriptionStatus()
                if liveTranscriptionStatus == .liveTranscription_Status_Start {
                    // stop liveTranscription
                    meetingService.stopLiveTranscription()
                    print("[DEBUG] Waiting for host - live transcription was active, calling stopLiveTranscription().")
                } else {
                    print("[DEBUG] Waiting for host - live transcription is not active, no action needed.")
                }
            }
        case .connecting:
            // ミーティングに接続中
            print("[DEBUG] Meeting state: Connecting...")
        case .reconnecting:
            // ミーティングに再接続中
            print("[DEBUG] Meeting state: Reconnecting...")
        default:
            // 他の状態変化は汎用的なログを出力
            print("[DEBUG] Meeting state changed: \(state)")
        }
    }
    
    //Is called upon recording state changes.
    func onRecordingStatus(_ status: MobileRTCRecordingStatus) {
        switch status {
        case .start:
            // クラウド録画が開始された
            if let meetingService = MobileRTC.shared().getMeetingService() {
                let liveTranscriptionStatus = meetingService.getLiveTranscriptionStatus()
                if liveTranscriptionStatus == .liveTranscription_Status_Start {
                    // ライブ字幕が実行中であれば停止する
                    meetingService.stopLiveTranscription()
                    print("[DEBUG] Recording started - live transcription was active, calling stopLiveTranscription().")
                } else {
                    // ライブ字幕が実行中でない場合
                    print("[DEBUG] Recording started - live transcription was not active.")
                }
            }
        case .stop: break
        case .pause: break
        case .fail: break
        case .connecting: break
        case .diskFull: break
        @unknown default:
            print("Recording status changed: \(status)")
        }
    }
}
