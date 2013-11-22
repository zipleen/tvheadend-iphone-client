
function writeComment(comment) {
	html = "<div class=\"well\"><h3> " + comment['title'] + "</h3><small>by " + comment['author'] + " - <b>"+ comment['country'] + "</b> - " + comment['version'] + ' - ' ;
	
	for(i=0;i<comment['rate'];i++) {
		html += "<span class=\"glyphicon glyphicon-star\"></span>";
	}
	html += "</small><p class=\"review-text\">" + comment['comment'] + "</p></div>" ;
	$(".container").append(html);
}

function getReview(app, countries, page) {
	if (countries.length==0) {
		return;
	}
	
	country = countries.pop();
	
	var url = 'http://itunes.apple.com/rss/customerreviews/page=' + page + '/id=' + app + '/sortby=mostrecent/json?l=en&cc=' + country;
	console.log('going for ' + country);
    
	 $.getJSON( url + "&callback=?", function( data ) {
		   var entry = data['feed']['entry'];
		   var links = data['feed']['link'];
		   
		   if (entry && links) {
		           for (var i = 0; i < entry.length ;i++) {
		                   var rawReview = entry[i];
		                   if ('content' in rawReview) {        
		                       try
		                       {                
		                               var comment = [];
		                               comment['id'] = rawReview['id']['label'];
		                               comment['app'] = app;
		                               comment['author'] = rawReview['author']['name']['label'];
		                               comment['version'] = rawReview['im:version']['label'];
		                               comment['rate'] = rawReview['im:rating']['label'];
		                               comment['title'] = rawReview['title']['label'];
		                               comment['comment'] = rawReview['content']['label'];
		                               comment['vote'] = rawReview['im:voteCount']['label'];
		                               comment['country'] = country;
		                               
		                               writeComment(comment);
		                               console.log( comment);
						   }
						   catch (err) 
						   {
						           console.log(err);
						   }
		               }
		       }
		       
		       /*
		       Because there are only 50 reviews per page, we need to find out if there is a next page.
		       If so, we emit a 'nextPage' event.
		       */
		       for (var i = 0; i < links.length; i++) {
		               var link = links[i]['attributes'];
		               var rel = link['rel'];
		               var href = link['href'];
		               
		               // Find the last page number
		               if (rel == 'last') {
		                       var urlSplit = href.split('/');
		                       for (var index = 0; index < urlSplit.length; index++) {
		                               var currentUrlPart = urlSplit[index];
		                               if (currentUrlPart.substring(0, 5) == 'page=') {
		                                       var lastPage = currentUrlPart.replace('page=', '');
		                                       if (page < lastPage) {
		                                    	   	getReview(app, countries, page+1);
		                                       }
		                                   }
		                           }
		                   }
		           }
		       
		       getReview(app, countries, 1);
		   }
          
	 });
}

	

$( document ).ready(function() {
	countries = ['au', 'dk', 'fr', 'de','it', 'nl', 'no', 'ru', 'es', 'gb', 'pt'];
	getReview('638900112', countries , 1);
	
});