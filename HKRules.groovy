/**
 *  HKRules
 *
 *  Copyright 2015 Tyler Freckmann
 *
 *  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
 *  in compliance with the License. You may obtain a copy of the License at:
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed
 *  on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License
 *  for the specific language governing permissions and limitations under the License.
 *
 */
definition(
    name: "HKRules",
    namespace: "tylerfreckmann",
    author: "Tyler Freckmann",
    description: "Connect HKRules to SmartThings",
    category: "My Apps",
    iconUrl: "https://s3.amazonaws.com/smartapp-icons/Convenience/Cat-Convenience.png",
    iconX2Url: "https://s3.amazonaws.com/smartapp-icons/Convenience/Cat-Convenience@2x.png",
    iconX3Url: "https://s3.amazonaws.com/smartapp-icons/Convenience/Cat-Convenience@2x.png",
    oauth: true)


preferences {
	section("Allow HKRules to control these things...") {
		input "switches", "capability.switch", title: "Which Switches?", multiple: true
        input "motionSensors", "capability.motionSensor", title: "Which Motion Sensors?", multiple: true
        input "contactSensors", "capability.contactSensor", title: "Which Contact Sensors?", multiple: true
        input "presenceSensors", "capability.presenceSensor", title: "Which Presence Sensors?", multiple: true
        input "temperatureSensors", "capability.temperatureMeasurement", title: "Which Temperature Sensors?", multiple: true
        input "waterSensors", "capability.waterSensor", title: "Which Water Sensors?", multiple: true
        input "lightSensors", "capability.illuminanceMeasurement", title: "Which Light Sensors?", multiple: true
        input "relativeHumiditySensors", "capability.relativeHumidityMeasurement", title: "Which Relative Humidity Sensors?", multiple: true
        input "sirens", "capability.alarm", title: "Which Sirens?", multiple: true
        input "locks", "capability.lock", title: "Which Locks?", multiple: true
	}
}

def installed() {
	log.debug "Installed with settings: ${settings}"

	initialize()
}

def updated() {
	log.debug "Updated with settings: ${settings}"

	unsubscribe()
	initialize()
}

def initialize() {
	// TODO: subscribe to attributes, devices, locations, etc.
}

mappings {
	path("/devices") {
    	action: [
        	GET: "listDevices"
        ]
    }
    path("/switches") {
    	action: [
        	GET: "listSwitches"
        ]
    }
    path("/switches/:command/:which") {
    	action: [
        	GET: "updateSwitches"
        ]
    }
    path("/motionSensors") {
    	action: [
        	GET: "listMotionSensors"
        ]
    }
    path("/contactSensors") {
    	action: [
        	GET: "listContactSensors"
        ]
    }
    path("/presenceSensors") {
    	action: [
        	GET: "listPresenceSensors"
        ]
    }
    path("/temperatureSensors") {
    	action: [
        	GET: "listTemperatureSensors"
        ]
    }
    path("/waterSensors") {
    	action: [
        	GET: "listWaterSensors"
        ]
    }
    path("/lightSensors") {
    	action: [
        	GET: "listLightSensors"
        ]
    }
    path("/relativeHumiditySensors") {
    	action: [
        	GET: "listRelativeHumiditySensors"
        ]
    }
    path("/sirens") {
    	action: [
        	GET: "listSirens"
        ]
    }
    path("/sirens/:command/:which") {
    	action: [
        	PUT: "updateSirens"
        ]
    }
    path("/locks") {
    	action: [
        	GET: "listLocks"
        ]
    }
    path("/locks/:command/:which") {
    	action: [
        	PUT: "updateLocks"
        ]
    }
}

// TODO: implement event handlers

def listDevices() {
	def resp = []
    resp << [switches: listSwitches()]
    resp << [motionSensors: listMotionSensors()]
    resp << [contactSensors: listContactSensors()]
    resp << [presenceSensors: listPresenceSensors()]
    resp << [temperatureSensors: listTemperatureSensors()]
    resp << [waterSensors: listWaterSensors()]
    resp << [lightSensors: listLightSensors()]
    resp << [relativeHumiditySensors: listRelativeHumiditySensors()]
    resp << [sirens: listSirens()]
    resp << [locks: listLocks()]
    return resp
}

def listSwitches() {
	def switchesList = []
    switches.each {
    	log.debug "${it.switchState}"
        log.debug "${it.currentSwitch}"
        log.debug "${it.capabilities}"
        log.debug "${it.currentState("switch")}"
        log.debug "${it.currentValue("switch")}"
        log.debug "${it.hasAttribute("switch")}"
        log.debug "${it.hasCapability("Switch")}"
        log.debug "${it.latestState("switch")}"
        log.debug "${it.latestValue("switch")}"
        log.debug "${it.supportedAttributes}"
    	switchesList << [name: it.displayName, value: it.currentValue("switch")]
    }
    return switchesList
}

def updateSwitches() {
	def command = params.command
	def which = params.which
    
    if (command) {
    	if (which) {
        	if (switches[which.toInteger()].hasCommand(command)) {
            	switches[which.toInteger()]."$command"()
            	log.debug "${switches[which.toInteger()].currentValue("switch")}"
            }
        }
    }
    return "successfully turned on switches"
}

def listMotionSensors() {
	def motionSensorsList = []
    motionSensors.each {
    	motionSensorsList << [name: it.displayName, value: it.currentValue("motion")]
    }
    return motionSensorsList
}

def listContactSensors() {
	def contactSensorsList = []
    contactSensors.each {
    	contactSensorsList << [name: it.displayName, value: it.currentValue("contact")]
    }
    return contactSensorsList
}

def listPresenceSensors() {
	def presenceSensorsList = []
    presenceSensors.each {
    	presenceSensorsList << [name: it.displayName, value: it.currentValue("presence")]
    }
    return presenceSensorsList
}

def listTemperatureSensors() {
	def temperatureSensorsList = []
    temperatureSensors.each {
    	temperatureSensorsList << [name: it.displayName, value: it.currentValue("temperature")]
    }
    return temperatureSensorsList
}

def listWaterSensors() {
	def waterSensorsList = []
    waterSensors.each {
    	waterSensorsList << [name: it.displayName, value: it.currentValue("water")]
    }
    return waterSensorsList
}

def listLightSensors() {
	def lightSensorsList = []
    lightSensors.each {
    	lightSensorsList << [name: it.displayName, value: it.currentValue("illuminance")]
    }
    return lightSensorsList
}

def listRelativeHumiditySensors() {
	def relativeHumiditySensorsList = []
    relativeHumiditySensors.each {
    	relativeHumiditySensorsList << [name: it.displayName, value: it.currentValue("humidity")]
    }
    return relativeHumiditySensorsList
}

def listSirens() {
	def sirensList = []
    sirens.each {
    	sirensList << [name: it.displayName, value: it.currentValue("alarm")]
    }
    return sirensList
}

def updateSirens() {
	def command = params.command
	def which = params.which
    
    if (command) {
    	if (which) {
        	if (sirens[which.toInteger()].hasCommand(command)) {
            	sirens[which.toInteger()]."$command"()
            }
        }
    }
}

def listLocks() {
	def locksList = []
    locks.each {
    	locksList << [name: it.displayName, value: it.currentValue("lock")]
    }
    return locksList
}

def updateLocks() {
	def command = params.command
	def which = params.which
    
    if (command) {
    	if (which) {
        	if (locks[which.toInteger()].hasCommand(command)) {
            	locks[which.toInteger()]."$command"()
            }
        }
    }
}
