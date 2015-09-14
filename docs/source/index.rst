Welcome to HKIoTDemo's documentation!
=====================================

Welcome to our demo on how the Harman Wireless HD Audio System can be integrated into the Internet of Things. The `Wireless HD Audio SDK <http://developer.harman.com>`__ allows one to develop applications that connect HD Wireless speakers to other devices in the home.


.. note::

   If you would like to check out our source code for this project, click `here <https://github.com/tylerfreckmann/HKIoTDemo>`__!


Video of the Demo
~~~~~~~~~~~~~~~~~

Ever tired of reading plain old text? You probably would much rather see with your own eyes what we're doing, so click `here <https://www.youtube.com/watch?v=0GuJgEMhfbg>`__ for a video showcasing our project as a whole!  

About the project
~~~~~~~~~~~~~~~~~
Using Harman SDK, we were able to connect their speakers with other APIs and platforms. We were able to see how wifi enabled speakers can have an impact in a connected lifestyle environment. 

Challenges we ran into
~~~~~~~~~~~~~~~~~~~~~~
Brainstorming and figuring the different possible APIs we could use in this demo was a tough process. The amount of public APIs available to use is outstanding, and filtering out the choices for the purpose of our demos was difficult task. Other challenges we ran into include figuring out what the best platform as a service would be, and that eventually led us to using Facebook's Parse. 

Throughout the design phase of this demo, we had issues on how to structure the entire architecture. We wanted an easy to read setup for developers (in terms of code), as well as an easy to use setup for consumers (in terms of usability). 

A main challenge we have noted and hope to make more efficient is how authentication was handled in this demo. On the first run, the user had to authenticate with SmartThings and Parse multiple times in order to have the feature of "turning on the light" as he/she wakes up. Having multiple authentication screens lessens the user experience. And additionally, all the third party sensors required a Parse login to connect to the platform and our main "Hub". Our goal in the future is to minimalize the amount of authentication screens used. 

Architecture Overview
~~~~~~~~~~~~~~~~~~~~~

.. toctree::
   :maxdepth: 5

   context
 
Overview of Classes 
~~~~~~~~~~~~~~~~~~~

.. toctree::
   :maxdepth: 5

   modules

Wake Up Scenario
~~~~~~~~~~~~~~~~

.. toctree::
   :maxdepth: 5

   wakeup

Shower Scenario
~~~~~~~~~~~~~~~

.. toctree::
   :maxdepth: 5

   shower

Leave Home Scenario
~~~~~~~~~~~~~~~~~~~

.. toctree::
   :maxdepth: 5

   leave

AboutUs/References
~~~~~~~~~~~~~~~~~~

.. toctree::
   :maxdepth: 5

   references
