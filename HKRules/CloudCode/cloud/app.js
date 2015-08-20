
// These two lines are required to initialize Express in Cloud Code.
express = require('express');
app = express();

// Additional modules
var querystring = require('querystring');
var _ = require('underscore');
var Buffer = require('buffer').Buffer;

// SmartThings specific details, including application id and secret
var smartThingsClientId = '04e5f073-c826-482f-a6b5-e22e7d2d61fe';
var smartThingsClientSecret = '908091ac-6690-4349-8cf1-592b970a00ec';

var oauthCallback = 'http://hkrules.parseapp.com/oauthCallback';

// Global app configuration section
app.set('views', 'cloud/views');  // Specify the folder to find templates
app.set('view engine', 'ejs');    // Set the template engine
app.use(express.bodyParser());    // Middleware for reading request body

// Login with SmartThings.
// When called, generate a request token and redirect the browser to SmartThings.
app.get('/authorize', function(req, res) {
	res.redirect('https://graph.api.smartthings.com/oauth/authorize?response_type=code&client_id='+smartThingsClientId+'&scope=app&redirect_uri='+oauthCallback);
});

// OAuth Callback route.
// This is intended to be accessed via redirect from SmartThings.
app.get('/oauthCallback', function(req, res) {
	var u = new Buffer(smartThingsClientId+':'+smartThingsClientSecret).toString('base64');
	Parse.Cloud.httpRequest({
		url: 'https://graph.api.smartthings.com/oauth/token?code='+req.query.code+'&grant_type=authorization_code&redirect_uri='+oauthCallback+'&scope=app',
		headers: {
			'Authorization': 'Basic '+u
		}
	}).then(function(httpResponse) {
		res.render('login', {t: httpResponse.data.access_token});
		console.log(httpResponse.data);
	},function(httpResponse) {
		console.error(httpResponse.text);
		res.render('res', {message: 'http error: '+error.message});
	});
});

app.post('/login', function(req, res) {
	Parse.User.logIn(req.body.username, req.body.password, {
		success: function(user) {
			user.save({
				sttoken: req.body.t
			}, {
				success: function(user) {
					res.render('res', { message: 'Success! Please click back in the navigation bar.'});
				},
				error: function(user, error) {
					res.render('res', {message: 'user save error: '+error.message+error.code});
				}
			});
		},
		error: function(user, error) {
			res.render('res', {message: 'user login failed '+error.message+error.code});
		}
	});
});

// // Example reading from the request query string of an HTTP get request.
// app.get('/test', function(req, res) {
//   // GET http://example.parseapp.com/test?message=hello
//   res.send(req.query.message);
// });

// // Example reading from the request body of an HTTP post request.
// app.post('/test', function(req, res) {
//   // POST http://example.parseapp.com/test (with request body "message=hello")
//   res.send(req.body.message);
// });

// Attach the Express app to Cloud Code.
app.listen();
