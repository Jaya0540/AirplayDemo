//
//  ViewController.swift
//  AirplayDemo
//
//  Created by Jai on 24/05/24.
//

import UIKit
import AVKit
import MediaPlayer
import AVFoundation

class ViewController: UIViewController {
    var airPlay = UIView()
    var player: AVPlayer?
    var routeDetector: AVRouteDetector?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpAirPlayButton()
        let airButton = UIBarButtonItem(customView: airPlay)
        self.navigationItem.rightBarButtonItems = [airButton]
        
        setUpAVPlayer()
        configureAudioSession()
        configureRouteDetector()
    }

    func setUpAirPlayButton() {
        airPlay.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let buttonView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let routerPickerView = AVRoutePickerView(frame: buttonView.bounds)
        routerPickerView.tintColor = UIColor.white
        routerPickerView.activeTintColor = .green
        buttonView.addSubview(routerPickerView)
        self.airPlay.addSubview(buttonView)
    }
    
    func setUpAVPlayer() {
        // Example URL for audio or video
        guard let url = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8") else { return }
        
        // Initialize the AVPlayer with the URL
        player = AVPlayer(url: url)
        
        // Create an AVPlayerViewController to present the video
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        // Add the AVPlayerViewController as a child view controller
        addChild(playerViewController)
        playerViewController.view.frame = view.bounds
        view.addSubview(playerViewController.view)
        playerViewController.didMove(toParent: self)
        
        // Start playback
        player?.play()
    }
    
    func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.allowAirPlay])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
        
        // Observe route change notifications to handle AirPlay route changes
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRouteChange(_:)),
                                               name: AVAudioSession.routeChangeNotification,
                                               object: audioSession)
    }
    
    func configureRouteDetector() {
        routeDetector = AVRouteDetector()
        routeDetector?.isRouteDetectionEnabled = true
        
        // Add observer for the isRouteDetected property using KVO
        routeDetector?.addObserver(self, forKeyPath: "isRouteDetected", options: [.new, .initial], context: nil)
    }
    
    // KVO observer method
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "isRouteDetected" {
            if let isRouteDetected = change?[.newKey] as? Bool {
                if isRouteDetected {
                    print("Route detected")
                    // Update UI or handle the detected route
                } else {
                    print("No route detected")
                    // Update UI or handle the absence of a detected route
                }
            }
        }
    }
    
    @objc func handleRouteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else { return }

        switch reason {
        case .newDeviceAvailable:
            print("New device available")
        case .oldDeviceUnavailable:
            print("Old device unavailable")
        default:
            break
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: nil)
        routeDetector?.removeObserver(self, forKeyPath: "isRouteDetected")
    }
}
