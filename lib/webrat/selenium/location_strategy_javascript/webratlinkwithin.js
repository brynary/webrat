var locatorParts = locator.split('|');
var cssAncestor = locatorParts[0];
var linkText = locatorParts[1];
var matchingElements = eval_css(cssAncestor, inDocument);
var candidateLinks = matchingElements.collect(function(ancestor){
  var links = ancestor.getElementsByTagName('a');
  return $A(links).select(function(candidateLink) {
    return PatternMatcher.matches(linkText, getText(candidateLink));
  });
}).flatten().compact();
if (candidateLinks.length == 0) {
  return null;
}
candidateLinks = candidateLinks.sortBy(function(s) { return s.length * -1; }); //reverse length sort
return candidateLinks.first();
