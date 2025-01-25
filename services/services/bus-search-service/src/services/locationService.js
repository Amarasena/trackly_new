const geolib = require("geolib");

class LocationService {
  findNearbyStops(userLocation, stops, radius = 1000) {
    return stops.filter((stop) => {
      const distance = geolib.getDistance(
        { latitude: userLocation.latitude, longitude: userLocation.longitude },
        { latitude: stop.location.latitude, longitude: stop.location.longitude }
      );
      return distance <= radius;
    });
  }
}

module.exports = new LocationService();
