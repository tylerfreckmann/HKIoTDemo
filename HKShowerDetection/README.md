# HKShowerDetection
Background iOS application in Swift that picks up on shower noise. 

Use case scenario 2 of IoT demo
--------
1. Phone listens in the background for 'shower noise'.
2. Once it picks up noise, starts timer.
3. If timer exceeds shower configurated time, triggers event in cloud.
3. Cloud sends push notification to HKRules. 
4. HKRules handles the push notification, and sents TTS to Harman Omni speakers. 

Features implemented in application 
-------
1. Able to confirm if the shower is running by checking background noise in comparison to ACRCloud database of custom files.
2. Starts a timer on client side, if it exceeds shower configurated time, then trigger even in cloud.
3. Cloud event sends push notification to HKRules application. 
4. Implement functionality for handling push notification in HKRules application. 
5. Use TTS and play to Omni.

To do list
-------
