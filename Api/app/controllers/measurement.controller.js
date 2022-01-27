const Measurement = require("../models/measurement.model.js");

exports.findAll = (req, res) => {
  Measurement.getAll((err, data) => {
    if (err)
      res.status(500).send({
        message:
          err.message || "Some error occurred while retrieving measurements."
      });
    else res.send(data);
  });
};