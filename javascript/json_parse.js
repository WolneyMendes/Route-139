var fs = require( 'fs' )
var JSONStream = require('JSONStream')
var es = require('event-stream')

var calendar_dates = JSON.parse( fs.readFileSync('calendar_dates.json', 'utf8'));
var routes = JSON.parse( fs.readFileSync('routes.json','utf8'));
//var stop_times = require('./stop_times.json');
var stops = JSON.parse( fs.readFileSync('stops.json','utf8'));
var trips = JSON.parse( fs.readFileSync('trips.json','utf8'));

var myRoutes = []
var myRoutesDictionary = {}
function getMyRoutes() {
	for( var i=0; i< routes.length; i++ ) {
		var route = routes[i]
		if( route.route_short_name === "130" ||
			route.route_short_name === "132" ||
			route.route_short_name === "136" ||
			route.route_short_name === "139" ) {
			myRoutes.push(route)
			myRoutesDictionary[route.route_id]= route
		}
	}
}

var myTrips = []
var myTripsDictionary = {}
function getMyTrips() {
	for( var i=0; i<trips.length; i++ ) {
		var trip = trips[i]
		var route = myRoutesDictionary[trip.route_id]
		if( route ) {
			myTrips.push( trip )
			myTripsDictionary[trip.trip_id]= trip
		}
	}
}

var myStops = []
function getMyStops() {
	var myKnownStops = {}

	for( var i =0; i< myStopTimes.length; i++ ) {
		var stopTime= myStopTimes[i]
		if( !myKnownStops[stopTime.stop_id] ) {
			var stop= knownStopsDictionary[stopTime.stop_id]
			myKnownStops[stopTime.stop_id]= stop
			myStops.push(stop)
		}
	}
}

var knownStopsDictionary = {}
function buildKnowStopsDictionary() {
	for( var i=0; i<stops.length; i++ ) {
		var stop= stops[i]
		if( ! knownStopsDictionary[stop.stop_id] ) {
			knownStopsDictionary[stop.stop_id]= stop
		}
	}
}
buildKnowStopsDictionary()


var getStream = function() {
	var jsonData = 'stop_times.json'
	var stream = fs.createReadStream( jsonData, {encoding: 'utf8'})
	var parser = JSONStream.parse("*")
	return stream.pipe(parser);
}

var myStopTimes = []


function saveJSONtoFile( fileName, json ) {

	fs.writeFile( fileName, JSON.stringify(json, null, 4 ), function(err) {
		if( err ) {
			console.log( 'error while saving ' + fileName + ' ' + err )
		} else {
			console.log( 'Saved to ' + fileName )
		}
	} );
}

function saveAllTables() {
	// no change to calendar_dates 

	// save my stops
	saveJSONtoFile( '139Stops.json', myStops );

	// save my stop_times
	saveJSONtoFile( '139StopTimes.json', myStopTimes );

	// save my routes
	saveJSONtoFile( '139Routes.json', myRoutes );

	// save my trips
	saveJSONtoFile( '139Trips.json', myTrips );
}


getMyRoutes();
//console.log( myRoutes )
getMyTrips();
//console.log( myTrips )
getStream()
	.pipe( es.mapSync(function(stop_time) {
			var trip = myTripsDictionary[stop_time.trip_id]
			if( trip ) {
				myStopTimes.push(stop_time)
			}
		})
	)
	.on( "end", function() { 
			getMyStops()
			saveAllTables()
		} )
	;


