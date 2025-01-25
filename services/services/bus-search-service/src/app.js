const express = require("express");
const dotenv = require("dotenv");
const searchRoutes = require("./routes/searchRoutes");

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// Routes
app.use("/api", searchRoutes);

// Start Server
app.listen(PORT, () => {
  console.log(`Bus Search Service is running on http://localhost:${PORT}`);
});
