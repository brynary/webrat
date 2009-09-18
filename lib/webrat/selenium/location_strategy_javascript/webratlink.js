var links = inDocument.getElementsByTagName('a');

var candidateLinks = $A(links).select(function(candidateLink) {
  var textMatched = false;
  var titleMatched = false;
  var idMatched = false;

  if (getText(candidateLink).toLowerCase().indexOf(locator.toLowerCase()) != -1) {
    textMatched = true;
  }

  if (candidateLink.title.toLowerCase().indexOf(locator.toLowerCase()) != -1) {
    titleMatched = true;
  }

  if (candidateLink.id.toLowerCase().indexOf(locator.toLowerCase()) != -1) {
    idMatched = true;
  }

  return textMatched || idMatched || titleMatched;
});

if (candidateLinks.length == 0) {
  return null;
}

//reverse length sort
candidateLinks = candidateLinks.sortBy(function(s) {
  return s.length * -1;
});

return candidateLinks.first();
