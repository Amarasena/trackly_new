const firestore = require("../firestore");

class BusDataService {
  async getAllStops() {
    const stopsSnapshot = await firestore.collection("busStops").get();
    return stopsSnapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
  }

  async getBusesByRoute(destination) {
    const busesSnapshot = await firestore
      .collection("buses")
      .where("routeStops", "array-contains", destination)
      .get();
    return busesSnapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
  }
}

module.exports = new BusDataService();
