module.exports = app => {
  const measurements = require("../controllers/measurement.controller.js");

  var router = require("express").Router();

  // Retrieve all Tutorials
  router.get("/", measurements.findAll);

  app.use('/api/measurement', router);
};