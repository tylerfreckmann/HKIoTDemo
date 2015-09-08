Shower Scenario
===============

The “Shower" scenario is the second scenario of our IoT demo. It is based around the idea of water conservation.

As mentioned earlier in this documentation, we didn't have an actual "Shower Sensor" device, so we wrote an iOS application that emulated one. We went through many different approaches, from checking FFT plots, to trying to detect ambient white noise in the background. But ultimately, we settled on using a sound fingerprinting platform as a basis for the application. 

The 3rd party things we used for this scenario are:

*ACRCloud API*
	for sound fingerprinting. Used to differentiate when a shower is running.  
*Text-To-Speech API*
	for converting an alert text to speech to play back through the speaker.

I will be leading you through the Shower Scenario in the best way that I can. The numbers correspond to the numbering on the sequence diagram below.

Sequence Diagram
~~~~~~~~~~~~~~~~

.. figure::  images/showersd.png

**Is the diagram too small for you to read?** `Click Here! <http://hkiotdemo.readthedocs.org/en/latest/_images/showersd.png>`__ 

Initial Setup
~~~~~~~~~~~~~

Here, we only have to login to the same user we created in the "Wake Up" scenario. This is the user in which the 
"Shower Sensor" application will pull the preferred shower time from. 

1. The user enters their username and password into the "Log In" page in the HK Rules iOS app, which logs the user in on the Parse side.

2. The user is then directed to the "Choose Scenarios" page which initializes the HKWControlHandler object.

3. The user then taps "Take a Shower" and is directed to the "Shower" page.

Configuring For Shower
~~~~~~~~~~~~~~~~~~~~~~

The following steps are used for configuring the shower preferences of an individual through the HK Rules application. 

4. The currentUser "User" object is retrieved, which returns a "ShowerConfig" object with it.

5. The user configures their preferences for the Shower scenario: how long they want to shower and whether they want periodic alerts.

Starting and Running the Shower Sensor
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

These are the steps neccesary to get the shower sensor up and running. 

6. The user then logs into the Shower Sensor so that the Shower Sensor can know what the user's shower preferences are (by retrieving them from Parse), and also which user to send the Shower alert to.

7. The shower sensor then retrieves the user's shower preferences in a ShowerConfig object from Parse.

8. The shower sensor begins listening to the environment, and sends a packet of sound data to the ACR Cloud for analysis. If the data resembles a shower sound, then the ACR Cloud sends back a positive response, which activates a timer on the shower sensor. The shower sensor keeps listening to the environment and sending data to ACR Cloud for analysis for the duration of the timer. If the shower sound is still playing before the timer runs out, the shower sensor sends an event to Parse which will trigger a shower alert.

9. If Parse receives a notification from the shower sensor that the shower is running longer than the user had configured, it will get TTS data from the TTS API and send a push notification to the HK Rules App on the user's iOS device.

10. When the HK Rules AppDelegate receives the push notification from Parse, it will play an alert about the shower through the Harman speakers.

And the wraps up the Shower Scenario! With this idea refined, we can start to be more cautious with our water spendings and produce noticable changes. 