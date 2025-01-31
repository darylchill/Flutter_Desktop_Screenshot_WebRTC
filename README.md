# Flutter Desktop Screenshot Capture

A Simple Flutter Desktop application powered by Flutter WebRTC to deliver real time communication between devices. Goal is to capture screenshot of the desktop app and stream to the devices(mobile) and display the images.

# Flutter WebRTC Implementation Guide (Desktop & Mobile)

This guide provides step-by-step instructions on setting up and running the Flutter WebRTC implementation using Flutter Desktop and Mobile.

# Purpose of the System

The purpose of this system is for the desktop application to capture screenshots and stream them to the mobile application, where they are displayed in real time.

# Prerequisites

Before starting, ensure the following:

  * Both the desktop and mobile devices are on the same network.
  * The ICMP (Internet Control Message Protocol) is enabled on the desktop to allow successful pinging between devices.
  * The Socket.IO signaling server is running to facilitate WebRTC communication.

# Setup & Execution

1. Enable ICMP Protocol

  Ensure that ICMP is enabled to allow network connectivity verification via ping. This step ensures the mobile device can communicate with the desktop application.
  * On Windows, open Command Prompt as Administrator and run:
  * netsh advfirewall firewall add rule name="Allow ICMPv4-In" protocol=icmpv4:any,any dir=in action=allow
  * On Linux/macOS, ICMP is usually enabled by default. If disabled, adjust firewall settings accordingly.

2. Start the Socket.IO Signaling Server

  * Open a terminal or command prompt.
  * Navigate to the directory containing the Socket.IO server script.
  * Start the server by running:
  * node index.js
  * Ensure the server is running before proceeding to the next steps.

3. Start the Desktop Application

  * Launch the Flutter Desktop application.
  * Click "Start/Restart Broadcasting" to initiate the WebRTC offer/answer mechanism.
  * The application will generate an offer, and upon receiving an answer from the mobile, it will exchange ICE candidates to establish a connection.

4. Begin Screen Capturing

  * Once the WebRTC connection is established (offer/answer and ICE candidates are exchanged), the desktop application will begin capturing and streaming images.

5. Connect the Mobile Application

  * Open the Flutter Mobile application.
  * Wait for the desktop application to successfully establish a WebRTC connection with the mobile device.
  * Once connected, the mobile application will start receiving and displaying the streamed images in real time.
  
# Troubleshooting
  
  * If the connection fails, verify that both devices are on the same network and that ICMP is enabled. 
  * Ensure that firewall rules are not blocking WebRTC traffic.
  * Verify that the Socket.IO signaling server is running.
  * Restart the desktop application and retry the process.


<p align="center"><a href="#" target="_blank"><img src="sample.png"  alt="sample image" class='logo' style='mix-blend-mode:multiply'></a></p>

