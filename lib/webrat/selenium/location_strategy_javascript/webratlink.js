var links = inDocument.getElementsByTagName('a');
var candidateLinks = $A(links).select(function(candidateLink) {
  var textMatched = PatternMatcher.matches(locator, getText(candidateLink));
  var idMatched = PatternMatcher.matches(locator, candidateLink.id);
  return textMatched || idMatched;
});
if (candidateLinks.length == 0) {
  return null;
}
candidateLinks = candidateLinks.sortBy(function(s) { return s.length * -1; }); //reverse length sort
return candidateLinks.first();
