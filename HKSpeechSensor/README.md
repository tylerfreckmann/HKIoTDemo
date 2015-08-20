# HoundifyHK
Voice recognition iOS application that takes in voice commands in an IoT home

Uses Houndify API in order to recognize speech.
Takes voice commands and triggers event in Parse Cloud. 

Process:
-----------------------------
1. Listens for specific voice commands ("I'm leaving", "I'm leaving now", "I am leaving") 
2. Triggers event in Parse Cloud (Calls prepareToLeaveHouse() Cloud code)
3. Parse sends push notification containing TTS urls to HKRules application 
4. HKRule receives the notification and plays the media. 
