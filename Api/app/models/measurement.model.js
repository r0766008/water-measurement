const sql = require("./db.js");

const Measurement = function(measurement) {
  this.ID = measurement.ID
  this.PubNub_ID = measurement.PubNub_ID;
  this.Distance = measurement.Distance;
  this.Time = measurement.Time;
};

Measurement.getAll = (result) => {
  let query = "SELECT * FROM data ORDER BY timestamp DESC";

  sql.query(query, (err, res) => {
    if (err) {
      console.log("error: ", err);
      result(null, err);
      return;
    }

    console.log("measurements: ", res);
    result(null, res);
  });
};

module.exports = Measurement;