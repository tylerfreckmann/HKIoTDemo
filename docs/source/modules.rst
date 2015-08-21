Overview of Classes
===================

The three main scenarios that demonstrate Harman's integration into the IoT space are:

* Wake Up
* Take a Shower
* Leave the Home

The HK Rules iOS application allows the user to configure their preferences regarding each scenario. These preferences are stored in the Parse Cloud associated with a "User" object that represents the actual person using the HK Rules app. The user configures their "Wake Up" preferences in a "WakeConfig" object and their "Take a Shower" preferences in a "ShowerConfig" object.

HK Rules controls the Harman speakers through the HKWControlHandler, from the HK Wireless SDK.

Parse notifies the user of events occuring in the home through push notifications. These notifications are sent to the HK Rules app, which handles them in the AppDelegate. The AppDelegate then activates the speakers accordingly.

Parse is notified of events occuring in the home through external sensors. The sensors in the demo are the "Shower Sensor" and the "Speech Sensor". The "Shower Sensor" detects when a shower is running. It uses the ACRCloud API to capture audio from the environment and check if it is representative of a shower. The "Speech Sensor" is a voice recognition sensor. It uses the Houndify API to recognize speech and convert it to usable data.

The Parse Cloud also allows the HK Rules system to integrate with other services, such as weather updates, text-to-speech, and other IoT platforms like `SmartThings <http://www.smartthings.com/developers/>`__. The way that Parse interacts with these third parties is through "Cloud Code".

Have trouble reading image? `Click Here! <http://hkiotdemo.readthedocs.org/en/latest/_images/hkrulesmoduleclassdiagram.png>`__ 

.. figure::  images/hkrulesmoduleclassdiagram.png