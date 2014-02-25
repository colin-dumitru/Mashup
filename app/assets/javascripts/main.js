var is_streaming = true,
    template = null;

function run() {

    template = $("#tweet_template").text();

    $("#stream_button").click(getTweets);

    getTweets();
}

function getTweets() {
    $.getJSON( "tweets",
        function(data) {
            console.log(data);

            for (var i = 0; i < data.length; i++) {
                addTweet(data[i]);
            }
        }
    );
}

function addTweet(data) {
    var container = $("<div></div>")
        .addClass("tweet")
        .append(template);

    container.find("#tweet_text")
        .text(data.text);

    $("#tweets").prepend(container);

    $.post("translate", { text: data.text }, function(result) {
        container.find("#tweet_translated")
            .text(result.result);
    }, "json");

    $.post("time", { latitude: data.geo.coordinates[0], longitude: data.geo.coordinates[1] }, function(result) {
        container.find("#local_time")
            .text(
                new Date(parseInt(result.timestamp * 1000)).toGMTString() + " (" + data.place.country + ")"
            );
    }, "json");
}