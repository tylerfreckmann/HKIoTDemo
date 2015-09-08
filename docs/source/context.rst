Architecture Overview
=====================

The entities involved in this demo are:

*HK Rules Application*
	iOS application that functions as a central hub for interactingg with the Harman speakers. 
*Parse Cloud*
	Backend architecture for IoT functionality, and interfaces with third parties.
*Shower Sensor* 
	iOS application representing a sensor in the home (specifically detecting the lengths of showers).
*Speech Sensor*
	iOS application representing a voice recognition sensor. 
*SmartThings*
	Third party IoT devices such as contact sensors, temperature sensors, etc. (`SmartThings <http://www.smartthings.com/developers/>`__ )

Each of the things we used in this demo served a purpose. We tried to incorporate as many IoT platforms and devices as we can, but they're are just so much!

Context Diagram
~~~~~~~~~~~~~~~

Below is a diagram displaying how each of how entities are connected to each other. 

.. figure::  images/iotdemocontextdiagram.png 

**Is the image above too hard to read for you?** `Click Here! <http://hkiotdemo.readthedocs.org/en/latest/_images/iotdemocontextdiagram.png>`__ 