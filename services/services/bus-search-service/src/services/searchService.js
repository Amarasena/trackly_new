const locationService = require("./locationService");
const busDataService = require("./busDataService");

class SearchService {
  async searchBuses(userLocation, destination) {
    try {
      const stops = await busDataService.getAllStops();
      const nearbyStops = locationService.findNearbyStops(userLocation, stops);

      if (!nearbyStops.length) {
        throw new Error("No nearby stops found.");
      }

      const buses = await busDataService.getBusesByRoute(destination);

      const matchedBuses = buses.filter((bus) =>
        nearbyStops.some((stop) => bus.routeStops.includes(stop.name))
      );

      return matchedBuses;
    } catch (error) {
      throw new Error(`Search failed: ${error.message}`);
    }
  }
}

module.exports = new SearchService();
