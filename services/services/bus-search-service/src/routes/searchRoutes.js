const express = require("express");
const searchService = require("../services/searchService");

const router = express.Router();

router.post("/search", async (req, res) => {
  const { latitude, longitude, destination } = req.body;

  if (!latitude || !longitude || !destination) {
    return res.status(400).json({ error: "Invalid input. Please provide latitude, longitude, and destination." });
  }

  try {
    const userLocation = { latitude, longitude };
    const matchedBuses = await searchService.searchBuses(userLocation, destination);

    res.status(200).json({ buses: matchedBuses });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
