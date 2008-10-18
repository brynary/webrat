var links = inDocument.getElementsByTagName('a');
var candidateLinks = $A(links).select(function(candidateLink) {
  return PatternMatcher.matches(locator, getText(candidateLink));
});
if (candidateLinks.length == 0) {
  return null;
}
candidateLinks = candidateLinks.sortBy(function(s) { return s.length * -1; }); //reverse length sort
return candidateLinks.first();
