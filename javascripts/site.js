$(document).ready(function() {
  $.getJSON("http://query.yahooapis.com/v1/public/yql?q=select%20version%20from%20json%20where%20url%3D%22http%3A%2F%2Frubygems.org%2Fapi%2Fv1%2Fgems%2Friot.json%22&format=json&callback=?",
    function (data) {
      $("#release-version").text(data.query.results.json.version);
    }
  );
});
