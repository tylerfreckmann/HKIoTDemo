require('cloud/app.js')

// Global variables used for speech URLS 
var weatherAPIKey = "2746bc27d6d47ddd627f76d17870dab3";
var baseSpeechURL = "http://api.voicerss.org/?key=8768e7a066a7443faa66380f7204ee96&hl=en-us&f=48khz_16bit_mono&src=";
var speechPadding = ",,,,,".split(",").join("%2C");
var longerPadding = ",,,,,,,".split(",").join("%2C");

// Used in "prepareToLeaveHouse"
var finalMsgForLeaveHouse = "";
var initialMessage = "";

/* Sets the alarm in the cloud, and notifies user of the result through push notifcation. */
Parse.Cloud.define("setCloudAlarm", function(request, response) {
    var alarmDate = new Date(request.params.alarmTime);
    var user = Parse.User.current();
    var wakeConfig = user.get("wakeConfig");
    wakeConfig.fetch().then(function(wakeConfig) {
        var pushQuery = new Parse.Query(Parse.Installation);
        pushQuery.equalTo("user", user);
        return Parse.Push.send({
            where: pushQuery,
            data: {
                "alert": "ALARM",
                "content-available": 1,
                "soundAlarm": 1,
                "soundFile": wakeConfig.get("sound"),
                "greeting": wakeConfig.get("greeting"),
                "weather": wakeConfig.get("weather"),
                "lights": wakeConfig.get("lights")
            },
            push_time: alarmDate
        });
    }).then(function() {
        response.success("push scheduled for "+user.get("username"));
    }, function(error) {
        response.error(error.message+' '+error.code);
    });
});

/* Called to push notification to HKRules application after shower timer triggered. */
Parse.Cloud.define("showerAlert", function(request, response) {

    var user = Parse.User.current();
               
    // Get the current time
    var alertTime = getCurrentTime();
                        
    var pushQuery = new Parse.Query(Parse.Installation);
    pushQuery.equalTo("user", user);
    pushQuery.equalTo("appName", "HKRules")                   
    
    // Convert alert message to TTS URL to get mp3 to stream from
    var showerAlertURL = baseSpeechURL 
        + longerPadding
        + "Alert%2C You have showered for ".split(" ").join("%20") 
        + request.params.showerTime.split(" ").join("%20");

    // Push to HKRules phone
    Parse.Push.send({
        where: pushQuery,
        data: {
            "alert": "You showered for " + request.params.showerTime,
            "content-available": 1,
            "showerAlertURL":  showerAlertURL
        },
            push_time: alertTime
    },{
        success: function() {
            response.success("push for " + request.params.username + " scheduled.");
        },
        error: function(error) {
            response.error("push errored");         
        }
    }); //end push     
});

/* Called when client is about to leave the house, checking home security and weather forecast */ 
Parse.Cloud.define("prepareToLeaveHouse", function (request, response) {
    var user = Parse.User.current();
    var alertTime = getCurrentTime();

    var pushQuery = new Parse.Query(Parse.Installation);
    pushQuery.equalTo("user", user);
    pushQuery.equalTo("appName", "HKRules");
     
    // Get TTS URL for  initial check message  
    initialMessage = "Hi%20" + request.params.username.split(" ").join("%20") + "%2C let me check if the house is safe right now. ".split(" ").join("%20");      
    console.log(finalMsgForLeaveHouse);
    // Request for the endpoint URL
    getSmartThingsEndpointURL(user).then(function(endPointResponse) {
        var json = JSON.parse(endPointResponse.text);
        var endPointURL = json[0]["url"];
        var apiCallURL = "https://graph.api.smartthings.com" + endPointURL;
        var checkSensorsURL = apiCallURL + "/contactSensors?access_token=" + user.get("sttoken");
        // Get list of contact sensors (doors, windows, etc...)
            console.log(finalMsgForLeaveHouse);

        return Parse.Cloud.httpRequest({url: checkSensorsURL});
    }).then(function(sensors) {
        parseListOfSensors(sensors, request);
            console.log(finalMsgForLeaveHouse);

        // Gets the current weather forecast
        return getWeatherMsg(request.params.locationLatitude, request.params.locationLongitude);
    }).then(function(weatherMessage) {
        var recapMessageURL = finalMsgForLeaveHouse + weatherMessage;
        // Push to HKRules 
        console.log(recapMessageURL);
        return Parse.Push.send({
                where: pushQuery,
                data: {
                    "alert": "Checking security of your home & getting your weather forecast!",
                    "content-available": 1,
                    "leaveFlag": 1, 
                    "recapMessageURL": recapMessageURL,
                    "timeStamp": getCurrentTime()
                },
                push_time: alertTime
            });
    }).then(function() {
        response.success("push for " + request.params.username + " scheduled.");
    }, function(error) {
        response.error(error);
    });
});

/* Helper function for getting SmartThings endpoint URL*/
var getSmartThingsEndpointURL = function(user) {
    var requestEndPointURL = "https://graph.api.smartthings.com/api/smartapps/endpoints?access_token="
        + user.get("sttoken");
    return Parse.Cloud.httpRequest({url: requestEndPointURL});
};

/* Helper function for getting the current time */
var getCurrentTime = function() {
    var alertTime = new Date();
    alertTime.getHours();
    alertTime.getMinutes();
    alertTime.getSeconds();
    return alertTime;
};

/* Helper function for going through the list of sensors, checking if any are open and creating TTS for them. */
var parseListOfSensors = function(sensors, request) {
    // Break up the list of sensors into JSON strings (based on [...])
    var matches = [];
    var pattern = /\[(.*?)\]/g;
    var match;
    while ((match = pattern.exec(sensors.text)) != null) {
        matches.push(match[1]);
    }

    var listOpenSensors = [];
    var anyOpenSensors = false; 
    // Loops through all sensors, and keeps track of them. 
    for (i = 0; i < matches.length; i++) {
        var currentSensor = JSON.parse(matches[i]);
        if (currentSensor["value"] != "closed") {
            anyOpenSensors = true;
            listOpenSensors.push(("%2C Your " + currentSensor["name"] + " is open!").split(" ").join("%20"));
        }
    }

    if (!anyOpenSensors) {
        finalMsgForLeaveHouse = 
            baseSpeechURL 
            + longerPadding
            + initialMessage 
            + speechPadding
            + request.params.username.split(" ").join("%20") 
            + "%2C All of your sensors are closed. Your home is safe and secured. ".split(" ").join("%20")
    } else {
        finalMsgForLeaveHouse =  
            baseSpeechURL 
            + longerPadding
            + initialMessage 
            + speechPadding
            + request.params.username.split(" ").join("%20") 
            + "%2C I am currently seeing some open sensors".split(" ").join("%20");

        for (i = 0; i < listOpenSensors.length; i++) {
            finalMsgForLeaveHouse += listOpenSensors[i];
        }
    }
};

/* Recieves the weather forecast given a coordinate. Returns a promise of a weather forecast. */
var getWeatherMsg = function(latitude, longitude) {
    var promise = new Parse.Promise()
    // Start fetching weather forecast
    var weatherURL = "https://api.forecast.io/forecast/" 
        + weatherAPIKey 
        + "/" + latitude 
        + "," + longitude;
    console.log(weatherURL);

    // Get the weather format in JSON 
    Parse.Cloud.httpRequest( {
        url: weatherURL, 
        success: function(weatherJSON) {
            console.log("called success");
            var weatherJson = JSON.parse(weatherJSON.text);
            var weatherMessage =  
                speechPadding + "Today, the weather is " + weatherJson["currently"]["summary"]
                + speechPadding + "The current temperature is " + Math.floor(weatherJson["currently"]["temperature"]) + "degrees. ";
            var chanceRain = weatherJson["currently"]["precipProbability"]*100;
            if (chanceRain > 0) {
                // There is a chance of it raining 
                weatherMessage = weatherMessage + speechPadding + "There is a " + chanceRain + " percent chance of it raining today. You should take an umbrella with you! "
            }
            else { 
                weatherMessage = weatherMessage +  "The chance of it raining today is 0 percent. "
            }
            weatherMessage = weatherMessage + speechPadding + "Have a good rest of the day!" ;
            weatherMessage = weatherMessage.split(" ").join("%20"); 
            promise.resolve(weatherMessage);
        }, 
        error: function () {
            console.log("weather failed");
            promise.reject("getWeatherMsg failed");
        }
    });
    return promise;
}

/* Parse Cloud method for turning on SmartThings lights */
Parse.Cloud.define("turnOnLights", function(request, response) {
    var user = Parse.User.current();
    getSmartThingsEndpointURL(user).then(function(httpResponse) {
        var json = JSON.parse(httpResponse.text);
        var epURL = json[0]["url"];
        var endpointURL = "https://graph.api.smartthings.com" + epURL + "/switches/on/0";
        return Parse.Cloud.httpRequest({
            url: endpointURL,
            headers: {
                "Authorization": "Bearer "+user.get("sttoken")
            }
        });
    }).then(function(httpResponse) {
        response.success("successfully turned on lights");
    }, function(error) {
        response.error(error);
    });
});

/* Parse Cloud method for getting the greeting and weather tts url for wake up rule */
Parse.Cloud.define("getGreetingAndWeatherTTSURL", function(request, response) {
    var user = Parse.User.current();
    var wakeConfig = user.get("wakeConfig");
    var greeting;
    wakeConfig.fetch().then(function(wakeConfig) {
        greeting = wakeConfig.get("greeting");
        greeting = greeting.split(" ").join("%20");
        if (request.params.weather) {
            return getWeatherMsg(request.params.latitude, request.params.longitude);
        } else {
            var promise = new Parse.Promise();
            promise.resolve("");
            return promise;
        }
    }).then(function(weatherMessage) {
        var ttsURL = baseSpeechURL+speechPadding+greeting+"%20"+weatherMessage;
        response.success(ttsURL);
    }, function(error) {
        response.error(error);
    });
});
