Wake Up Scenario
================

The "Wake Up" scenario is the first scenario of our IoT demo. It is a simulation of some of the neat things we can do with Harman speakers as a user wakes up in the morning. 

The 3rd party things we used for this scenario are: 

*SmartThings*
	for turning on the lights automatically in the morning, making it easier to wake up. 
*Weather API*
	for weather forecast as you wake up, so you know how to dress yourself out the door. 
*Text-To-Speech API*
	for a custom greeting or reminder for youself, such as "You have a dentist appointment today!"

I will be leading you through the Wake Up Scenario in the best way I can. The numbers correspond to the numbering on the sequence diagram below.

Sequence Diagram
~~~~~~~~~~~~~~~~

.. figure::  images/wakeupsd.png

**Is the image above too hard for you to read?** `Click Here! <http://hkiotdemo.readthedocs.org/en/latest/_images/wakeupsd.png>`__ 

Initial Setup
~~~~~~~~~~~~~

Here, we have to set up the initial settings. We sign up once so have access to all the features, afterwards, you never have to login again, unless of course, you logged out for some reason. 

1. The user starts the HK Rules iOS app and enters their username, password, email, and name into the "Sign Up" page. The information is used to associate the user with Parse for configuration purposes. 

2. The "Sign Up" page signs the user up in the Parse Cloud to create their "HK Rules account", which creates a "User" object representing that user. If the sign-up fails, the user is redirected back to the "Sign Up" page.

3. If the sign-up is successful, the user is directed to the "Choose Scenario" page, which initializes the HKWControlHandler object, which controls audio playback of the speakers. 

Configuring For Wake Up
~~~~~~~~~~~~~~~~~~~~~~~

Here are the steps that lead to choosing all the different settings for the wake up scenario as mentioned before. 

4. On the "Choose Scenario" page, the user taps "Wake Up", which brings them to the "Wake Up" page.

5. The "Wake Up" page requests the currentUser from Parse.

6. The "Wake Up" page queries the currentUser for the WakeConfig object.

7. The user then configures the wakeConfig alarm data.

8. If the user chooses the "Turn on lights" option for their alarm, the "Wake Up" page checks to see if the current user has a SmartThings token. If it doesn't, then the user is redirected to SmartThings where they can authenticate their SmartThings account and gain a token for future control of their SmartThings devices. 

(At this point, you will have to go through multiple authentication pages, but rest assured, you will only have to do this once as well! We have been trying to find an easier user friendly way of handling these authentication process, but bear with us in the meantime.)

9. Once the user has configured all their alarm settings, he or she taps "Set", which will trigger the "setCloudAlarm()" function on the Parse Cloud.

Now We Wait...
~~~~~~~~~~~~~~

After you've "set" the alarm, the wait begins. Everything is done behind the scenes from the user perspective. 

10. During the "setCloudAlarm()" function, the Parse Cloud gets weather and TTS data from external APIs to send back to the user during the alarm.

11. At the designated alarm time, Parse sends a push notification to AppDelegate running in the HK Rules app on the user's iOS device, with all the configuration data concerning the alarm (alarm sound, weather/tts data, etc.).

12. When the AppDelegate receives the push notification, it tells the HKWControlHandler to play the alarm media through the Harman speakers.

13. When Parse sends the push notification, it also tells the SmartThings platform to turn on the user's lights (using the User's SmartThings authentication token from step 8).

And voila! The wake up scenario is done. Wasn't that cool?!