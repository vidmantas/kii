$(function(){
    var highlightRef = function (refWithHash) {
        var ref = $(refWithHash); // Happens to match the DOM id, how convenient.
        // Unhighlight all refs
        ref.parents("ol").find("li").removeClass("current");
        // Highlight current ref
        ref.addClass("current");
    }

    // Initial highlight
    if (document.location.hash) {
        highlightRef(document.location.hash);
    }
    
    $(".reference").click(function(){
        highlightRef($(this).attr("href"));
    });  
})